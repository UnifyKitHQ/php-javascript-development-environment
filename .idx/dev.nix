# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {

  channel = "unstable";

  # Use https://search.nixos.org/packages to find packages
  packages = with pkgs; [
    cacert
    curl
    git
    nodejs_latest
    pnpm
    php
    php.packages.composer
    zip
  ];

  # Sets environment variables in the workspace
  env = { };
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [];

    # Enable previews
    previews = {
      enable = true;
      previews = {
        # web = {
        #   # Example: run "npm run dev" with PORT set to IDX's defined port for previews,
        #   # and show it in IDX's web preview panel
        #   command = ["npm" "run" "dev"];
        #   manager = "web";
        #   env = {
        #     # Environment variables to set for your server
        #     PORT = "$PORT";
        #   };
        # };
      };
    };

    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = { };
      # Runs when a workspace is (re)started
      onStart = {
        update = "echo 'Updating dependencies...' && if [ -f composer.json ]; then composer update; else echo '⏩ Skipping composer: composer.json not found.'; fi && if [ -f package.json ]; then pnpm update --latest; else echo '⏩ Skipping pnpm: package.json not found.'; fi";
      };
    };
  };
}