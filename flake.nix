{
  description = "Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      home-manager,
      mac-app-util,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          users.users.miguel = {
            name = "miguel";
            home = "/Users/miguel";
          };

          nixpkgs.config.allowUnfree = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            awscli2
            azure-cli
            bat
            fzf
            google-cloud-sdk
            neovim
            nixfmt-rfc-style
            tmux
            zoxide
          ];

          homebrew = {
            enable = true;
            taps = builtins.attrNames config.nix-homebrew.taps;
            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;
            brews = [
              "mas"
            ];
            casks = [
              "1password"
              "firefox"
              "google-chrome"
              "iina"
              "visual-studio-code"
            ];
            masApps = {
              "WireGuard" = 1451685025;
            };
          };

          fonts.packages = with pkgs; [
            (nerdfonts.override { fonts = [ "Monaspace" ]; })
          ];

          system.defaults = {
            dock.autohide = true;
          };

          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          # nix.package = pkgs.nix;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true; # default shell on catalina
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          # Enable using Touch ID authentication for `sudo`
          security.pam.enableSudoTouchIdAuth = true;

          nix.extraOptions = ''
            ssl-cert-file = /Users/miguel/.config/ssl/ca-bundle.crt
          '';
        };
      homeconfig =
        { pkgs, ... }:
        {
          # this is internal compatibility configuration
          # for home-manager, don't change this!
          home.stateVersion = "23.05";
          # Let home-manager install and manage itself.
          programs.home-manager.enable = true;

          home.packages = with pkgs; [
            git
            git-credential-manager
          ];

          home.sessionVariables = {
            EDITOR = "nvim";
          };

          home.file.".alacritty.toml".source = ./.alacritty.toml;

          programs.zsh = {
            enable = true;
            shellAliases = {
              switch = "darwin-rebuild switch --flake \"$HOME/.config/nix#mac\"";
            };
          };

          programs.alacritty = {
            enable = true;
          };

          programs.git = {
            enable = true;
            userName = "Miguel Lo-A-Foe";
            userEmail = "miguel@loafoe.dev";
            ignores = [ ".DS_Store" ];
            extraConfig = {
              init.defaultBranch = "master";
              push.autoSetupRemote = true;
              credential.helper = "/run/current-system/sw/bin/git-credential-manager";
              credential.useHttpPath = true;
            };
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#mac
      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = false;

              # User owning the Homebrew prefix
              user = "miguel";

              # Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.miguel = homeconfig;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.mac.pkgs;

      # Enable nixfmt as formatter
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
