# PHP & JavaScript Development Environment

A modern PHP & JavaScript Development Environment with multiple deployment options and automated setup scripts. This project includes support for Google Firebase Studio (formerly Project IDX), GitHub Codespaces, and Local System Installation.

## 📁 Project Structure

```
php-javascript-development-environment/
├── .devcontainer/                      # GitHub Codespaces configuration
│   ├── Containerfile                   # Docker container definition
│   └── devcontainer.json               # VS Code dev container settings
├── .idx/                               # Google Firebase Studio configuration
│   └── dev.nix                         # Nix environment definition
├── local/                              # Local system installation
│   └── local-setup.sh                  # Automated setup script
├── LICENSE                             # GNU GPL v3 license
└── README.md                           # Project documentation
```

## 🚀 Quick Start

Choose your preferred setup method:

- **[1. Cloud IDE: Google Firebase Studio (formerly Project IDX)](#1-cloud-ide-google-firebase-studio-formerly-project-idx)**
- **[2. Dev Containers: GitHub Codespaces](#2-dev-containers-github-codespaces)**
- **[3. Direct Install: Local Setup Script](#3-direct-install-local-setup-script)**

## 📋 Prerequisites

### System Requirements

- **Minimum Disk Space**: 5GB available space
- **Minimum RAM**: 4GB (8GB recommended for optimal performance)
- **Operating System**: 
  - Debian 12 (Bookworm) or Debian 13 (Trixie)
  - Nix (for Firebase Studio)
- **Network**: Stable internet connection for cloud-based options

## 🏗️ Setup Methods

### 1. Cloud IDE: Google Firebase Studio (formerly Project IDX)

The fastest way to get started with a cloud-based development environment.

#### Features

- **Cloud-based**: No local installation required
- **Pre-configured**: PHP, Node.js, Composer, and pnpm ready
- **AI Integration**: Gemini AI assistant built-in
- **Auto-updates**: Dependencies updated automatically on workspace start
- **Zero maintenance**: No system updates or dependency management needed

#### Prerequisites

- A Google account
- Stable internet connection
- Modern web browser

#### Environment Details

Configured via `.idx/dev.nix`:

- **Nix Channel**: Latest unstable for cutting-edge packages
- **PHP**: Latest version with Composer
- **Node.js**: Latest Current version with pnpm
- **Additional Tools**: cacert, curl, git, zip

#### Setup Instructions

1. Open [Firebase Studio](https://studio.firebase.google.com)
2. Click "Import Repo" → Paste `https://github.com/UnifyKitHQ/php-javascript-development-environment`
3. Name your workspace → Click "Import"

**What happens next:** Workspace auto-detects `.idx/dev.nix` and sets up the environment automatically. You're ready to code!

### 2. Dev Containers: GitHub Codespaces

Use a containerized environment for development with full isolation.

#### Features

- **Containerized**: Isolated development environment
- **Pre-configured**: PHP, Node.js, Composer, and pnpm ready
- **Auto-updates**: Dependencies updated automatically on workspace start
- **VS Code integration**: Built-in extensions and customizations

#### Prerequisites

- A GitHub account
- Stable internet connection
- Modern web browser

#### Environment Details

Configured via `.devcontainer/Containerfile`:

- **Base Image**: Debian 13 (Trixie) with non-root dev user
- **PHP**: Latest version with comprehensive extensions
- **Node.js**: Latest Current version with pnpm
- **Additional Tools**: Playwright with browser dependencies, Composer

#### Setup Instructions

1. Fork the repo to your GitHub account
2. Go to your repo → Click **Code** → **Codespaces** → **Create codespace on your desired branch**

**What happens next:** Codespaces auto-detects `.devcontainer` and sets up the environment automatically. You're ready to code!

### 3. Direct Install: Local Setup Script

For native system installation without virtualization. This comprehensive setup script installs and configures all necessary development tools on your local system.

#### Features

- **Native performance**: Direct system access without virtualization overhead
- **Full customization**: Complete control over your development environment
- **Offline capable**: Works without internet after initial setup
- **System integration**: Seamless integration with local tools and services
- **Comprehensive tooling**: Includes VS Code, Playwright, and all PHP extensions

#### Prerequisites

- **Operating System**: Debian 12 (Bookworm) or Debian 13 (Trixie)
- **Disk Space**: Minimum 5GB available space
- **RAM**: 4GB minimum (8GB recommended)
- **Network**: Stable internet connection for initial setup
- **Permissions**: Root access (sudo) required

#### Environment Details

Configured via `local/local-setup.sh`:

- **System**: Debian with optional upgrade to Trixie
- **PHP**: Latest version with comprehensive extensions (bcmath, curl, gd, intl, mbstring, mysql, pgsql, sqlite3, xml, zip, etc.)
- **Node.js**: Latest LTS or Current version (user choice) with npm
- **Additional Tools**: pnpm, Playwright, Composer, VS Code (optional)

#### Setup Instructions

```bash
git clone https://github.com/UnifyKitHQ/php-javascript-development-environment.git
cd php-javascript-development-environment
sudo bash local/local-setup.sh
```

**Interactive Prompts:**
- Debian upgrade option (12 → 13)
- VS Code installation preference
- Node.js version choice (LTS or Current)
- Git configuration setup
- All prompts can be skipped with default options

**Post-Installation:**
- Reboot recommended for all changes to take effect
- New terminal session may be needed for pnpm/playwright commands
- Setup logs available at `/var/log/phpjs-dev-environment-setup.log`

**⚠️ Warning**: This method modifies your host system directly. Use with caution and ensure you have proper backups.

## 📊 Quick Comparison

| Feature | Firebase Studio | GitHub Codespaces | Local Setup |
|---------|----------------|-------------------|-------------|
| **Setup Speed** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Resource Usage** | Cloud-based | Container | Native |
| **Internet Required** | Yes | Yes | No (after setup) |
| **Customization** | Limited | High | Full |
| **Cost** | Free tier | Free tier | Free |

## 🔧 Configuration

### Environment Variables

```bash
# Sets the path for pnpm-installed binaries
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
```

### Git Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
```

## 🛠️ What's Inside?

| Tool                 | Description                                    |
| -------------------- | ---------------------------------------------- |
| **PHP**              | Latest stable version for server-side logic    |
| **Composer**         | PHP dependency manager                         |
| **Node.js**          | Latest Current/LTS version for frontend tooling       |
| **pnpm**             | Fast, disk space-efficient package manager     |
| **Git**              | Version control system                         |
| **Common Utilities** | `ca-certificates`, `curl`, `gnupg2`, `jq`, `unzip`, `zip`|
| **VS Code**          | (Optional) Can be installed by setup scripts   |

## 🚀 Getting Started

After setup, create a simple test to verify everything works:

```bash
# Test PHP
php -r "echo 'PHP is working!';"

# Test Node.js
node -e "console.log('Node.js is working!');"

# Test Composer
composer --version

# Test pnpm
pnpm --version
```

## 🐛 Troubleshooting

### Common Issues

#### **Insufficient Disk Space**
- **Solution**: Free up space or use cloud/container options
- **Check**: `df -h` to verify available space

#### **Permission Denied**
- **Solution**: Use `sudo` if needed for local setup
- **Alternative**: Use cloud-based options

#### **Docker Errors**
- **Solution**: Ensure Docker is running and user is in `docker` group
- **Check**: `docker --version` and `groups $USER`

#### **Network Connectivity Issues**
- **Firebase Studio**: Check browser compatibility and firewall settings
- **Codespaces**: Verify GitHub access and internet connection
- **Local Setup**: Ensure stable internet for initial downloads

#### **PHP/Node.js Version Issues**
- **Check versions**: `php --version` and `node --version`
- **Update if needed**: Follow setup instructions for your chosen method

### Need Help?

1. **Review setup logs** for specific error messages
2. **Try alternate setup method** if one fails
3. **Check existing GitHub issues** or [create a new one](https://github.com/UnifyKitHQ/php-javascript-development-environment/issues)
4. **Include system details** when reporting issues:
   - Error messages
   - OS version
   - Setup method used

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Test all setup methods thoroughly
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Submit a pull request

### Development Guidelines

- Test changes across all three setup methods
- Update documentation for any new features
- Follow existing code style and formatting
- Add appropriate error handling

## 📄 License

Licensed under GNU GPL v3. See [LICENSE](LICENSE).

## 🙏 Acknowledgments

- Google Firebase Studio for cloud development environment
- Docker for containerization technology
- VS Code for excellent development experience
- Open source community for tools and libraries

## 📞 Support

- **GitHub Issues**: Check existing issues or create a new one
- **Documentation**: Review this README and project wiki
- **Community**: Join discussions in GitHub Discussions
- **Email**: For private support, contact maintainers directly

---

**Happy Coding! 🎉**

*Built with ❤️ for the PHP and JavaScript development community*