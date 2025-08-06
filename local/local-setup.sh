#!/bin/bash

# Exit on error, on unset variable, and on pipeline failure.
set -euo pipefail

# Define vars
LOG_FILE="/var/log/phpjs-dev-environment-setup.log"
CURL_OPTS="--connect-timeout 15"
REQUIRED_DISK_GB=5

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Graceful exit function
exit_gracefully() {
    log "⚠️ Critical error occurred. Exiting setup."
    exit 1
}

# --- 1. Initial Sanity Checks ---
log "🚀 Starting system setup..."

# Check if running as root
if [[ "${EUID}" -ne 0 ]]; then
    log "❌ This script must be run as root. Please use 'sudo'."
    exit_gracefully
fi

# Check if SUDO_USER is set, needed for Git configuration
if [[ -z "$SUDO_USER" ]]; then
    log "⚠️  Cannot determine the original user. Git configuration will be skipped."
    GIT_CONFIG_SKIPPED=true
else
    GIT_CONFIG_SKIPPED=false
fi

# --- 2. Prerequisite Check ---
log "🔍 Checking for APT package manager..."
if ! command -v apt &> /dev/null; then
    log "❌ This script requires the 'apt' package manager and cannot continue."
    exit_gracefully
fi
log "👍 APT command found."

# --- 3. System Resource Check ---
log "🔍 Checking for sufficient disk space..."
# Get available disk space in Gigabytes on the root partition
AVAILABLE_GB=$(df --output=avail / | tail -n 1)
# Convert to an integer by dividing by 1024*1024
AVAILABLE_GB=$((AVAILABLE_GB / 1024 / 1024))

if (( AVAILABLE_GB < REQUIRED_DISK_GB )); then
    log "❌ Insufficient disk space. Requires ~${REQUIRED_DISK_GB}GB, but only ${AVAILABLE_GB}GB is available."
    exit_gracefully
fi
log "👍 Available disk space: ${AVAILABLE_GB}GB. Proceeding..."

# --- 4. Configure gai.conf for IPv4 precedence ---
if ! grep -qF "precedence ::ffff:0:0/96 100" /etc/gai.conf; then
    log "🔧 Setting IPv4-mapped IPv6 addresses to default precedence..."
    echo "precedence ::ffff:0:0/96 100" | tee -a /etc/gai.conf
else
    log "👍 IPv4 precedence already set in /etc/gai.conf."
fi

# --- 5. Handle System & Release Upgrade ---
if [[ -f /etc/os-release ]] && . /etc/os-release && [[ "$ID" == "debian" ]]; then
    read -p "This is a Debian system. Do you want to upgrade from Debian 12 (Bookworm) to Debian 13 (Trixie)? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log "🚀 Upgrading from Bookworm to Trixie..."
        sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
        apt update
        apt full-upgrade -y
    else
        log "Skipping Debian release upgrade. Continuing with a standard system update..."
        apt update
        apt upgrade -y
    fi
else
    log "ℹ️  OS is not Debian. Skipping the release upgrade prompt."
    log "Performing standard system update..."
    apt update
    apt upgrade -y
fi

# --- 6. Install Essential Packages ---
log "📦 Installing essential packages..."
apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    jq \
    zip

# --- 7. Install Visual Studio Code ---
if ! command -v code &> /dev/null; then
    read -p "Do you want to install Visual Studio Code? [y/N] " vscode_response
    if [[ "$vscode_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log "📦 Installing Visual Studio Code..."
        # Ensure the keyrings directory exists
        mkdir -p /etc/apt/keyrings
        # Add the Microsoft GPG key
        curl $CURL_OPTS -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg
        # Add the VS Code repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
        apt update
        apt install -y code
    else
        log "Skipping Visual Studio Code installation."
    fi
fi

# --- 8. Install Node.js, NPM, and PNPM ---
# This section dynamically finds the latest version and manually adds the repository.

log "🔧 Preparing to add Node.js repository..."

# Ask the user for their preferred Node.js channel
while true; do
    read -p "Install the latest Node.js 'LTS' or 'Current' release? [LTS/Current] " node_choice
    case "$node_choice" in
        [Ll][Tt][Ss] )
            # JQ filter to find the first release object that has an 'lts' name
            JQ_FILTER='[.[] | select(.lts)][0].version'
            log "👍 Selected latest 'LTS' release.";
            break;;
        [Cc]urrent )
            # JQ filter to find the first release object that does NOT have an 'lts' name
            JQ_FILTER='[.[] | select(.lts | not)][0].version'
            log "👍 Selected latest 'Current' release.";
            break;;
        * )
            log "❌ Invalid choice. Please enter 'LTS' or 'Current'.";;
    esac
done

# Dynamically determine the major version number from the official Node.js releases JSON
log "🔍 Finding latest version number from nodejs.org..."
NODE_VERSION_STRING=$(curl $CURL_OPTS -s https://nodejs.org/dist/index.json | jq -r "$JQ_FILTER")

if [ -z "$NODE_VERSION_STRING" ]; then
    log "❌ Could not determine Node.js version. Aborting Node.js setup."
    exit_gracefully
fi

# Extract just the major version number (e.g., "v22.5.0" -> "22")
NODE_MAJOR=$(echo "$NODE_VERSION_STRING" | sed 's/^v//' | cut -d. -f1)
log "✅ Found version: ${NODE_VERSION_STRING}. Using major version: ${NODE_MAJOR}"

# Add the NodeSource GPG key
log "Adding NodeSource GPG key..."
mkdir -p /etc/apt/keyrings
curl $CURL_OPTS -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

# Add the NodeSource repository for the determined major version
log "Adding Node.js v${NODE_MAJOR} repository..."
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list

# Update package lists and install Node.js
log "Updating package lists for Node.js..."
apt update

log "📦 Installing Node.js..."
apt install -y --no-install-recommends nodejs

# Upgrading npm and installing pnpm globally
log "Upgrading npm and installing pnpm globally..."
npm install -g npm@latest

log "📦 Installing pnpm using the official script (to avoid memory issues)..."
if [[ -n "$SUDO_USER" ]]; then
    sudo -u "$SUDO_USER" bash -c "curl -fsSL https://get.pnpm.io/install.sh | sh -"
    log "👍 pnpm installed for user '$SUDO_USER'."

    # Install Playwright globally using the newly installed pnpm for the same user
    log "📦 Installing Playwright globally for user '$SUDO_USER'..."
    sudo -u "$SUDO_USER" bash -c 'export PNPM_HOME="$HOME/.local/share/pnpm" && export PATH="$PNPM_HOME:$PATH" && pnpm install -g playwright && playwright install --with-deps'
    log "👍 Playwright and its browsers installed globally."
    log "ℹ️ A new terminal session may be needed for 'pnpm' and 'playwright' commands to be available in your path."

else
    log "⚠️ Could not determine original user. Skipping pnpm and Playwright installation."
    log "To install manually, run as a regular user in this order:"
    log "1. curl -fsSL https://get.pnpm.io/install.sh | sh -"
    log "2. pnpm install -g playwright"
    log "3. playwright install --with-deps"
fi

# --- 9. Install PHP and Extensions ---
log "📦 Installing PHP and required extensions..."
apt install -y --no-install-recommends \
    php php-bcmath php-calendar php-cli php-common php-ctype php-curl php-dom \
    php-exif php-fileinfo php-ftp php-gd php-gmp php-iconv php-intl php-ldap \
    php-mbstring php-mysqli php-mysqlnd php-opcache php-pdo php-pgsql php-posix \
    php-readline php-simplexml php-soap php-sockets php-sqlite3 php-sysvsem \
    php-tokenizer php-xml php-xmlreader php-xmlwriter php-zip

# --- 10. Install Composer ---
log "📦 Installing Composer..."
EXPECTED_CHECKSUM="$(curl $CURL_OPTS -sS https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    log '❌ ERROR: Invalid Composer installer checksum'
    rm -f composer-setup.php
    exit_gracefully
else
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm -f composer-setup.php
    log "👍 Composer installed successfully."
fi

# --- 11. Configure Git for the User ---
if [[ -n "$SUDO_USER" && "$GIT_CONFIG_SKIPPED" = false ]]; then
    if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
        log "Git is already configured for '$SUDO_USER'."
    else
        read -p "Do you want to configure Git with your name, email, and credential helper? [y/N] " git_response
        if [[ "$git_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            read -p "Enter your full name for Git: " git_name
            read -p "Enter your email for Git: " git_email

            log "🔧 Configuring Git for user '$SUDO_USER'..."
            sudo -u $SUDO_USER git config --global user.name "$git_name"
            sudo -u $SUDO_USER git config --global user.email "$git_email"
            sudo -u $SUDO_USER git config --global credential.helper 'cache --timeout=2592000'
            log "👍 Git has been configured."
        else
            log "Skipping Git configuration."
        fi
    fi
else
    log "Skipping Git configuration because the original user could not be determined."
fi

# --- 12. Enable Wayland support for Electron apps ---
log "Adding ELECTRON_OZONE_PLATFORM_HINT=auto to /etc/environment..."

if ! grep -q '^ELECTRON_OZONE_PLATFORM_HINT=auto' /etc/environment; then
    echo 'ELECTRON_OZONE_PLATFORM_HINT=auto' | tee -a /etc/environment > /dev/null
    log "✅ Added ELECTRON_OZONE_PLATFORM_HINT to /etc/environment."
else
    log "ℹ️ ELECTRON_OZONE_PLATFORM_HINT already present in /etc/environment."
fi

# --- 13. Clean Up ---
log "🧹 Cleaning up..."
apt autoremove -y
apt clean -y
rm -rf /tmp/* /var/tmp/*

# --- 14. Final Message ---
log "✅ System setup is complete!"
log "A reboot is recommended to ensure all changes take effect."
log "You can reboot now by running: sudo reboot"