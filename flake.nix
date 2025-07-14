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
    homebrew-powershell = {
      url = "github:PowerShell/Homebrew-Tap";
      flake = false;
    };
    homebrew-mssql = {
      url = "github:microsoft/homebrew-mssql-release";
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
      homebrew-powershell,
      homebrew-mssql,
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

          system.primaryUser = "miguel";

          nixpkgs.config.allowUnfree = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            awscli2
            bat
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
              "openssl"
              "powershell/tap/powershell"
              "microsoft/mssql-release/mssql-tools18"
              "wimlib"
            ];
            casks = [
              "1password"
              "firefox"
              "google-chrome"
              "iina"
              "transmission"
            ];
            masApps = {
              "WireGuard" = 1451685025;
            };
          };

          fonts.packages = with pkgs; [
            nerd-fonts.monaspace
          ];

          system.defaults = {
            NSGlobalDomain = {
              "com.apple.trackpad.scaling" = 3.0; # Set "Tracking speed" to "Fast"
              "com.apple.trackpad.forceClick" = true; # Enable "Force Click and haptic feedback"
              KeyRepeat = 2; # Set "Key repeat rate" to "Fast"
              InitialKeyRepeat = 15; # Set "Delay until repeat" to "Short"
              "com.apple.keyboard.fnState" = true; # "Use F1, F2, etc as standard function keys"
              NSDocumentSaveNewDocumentsToCloud = false; # Disable saving to iCloud by default
            };

            trackpad = {
              FirstClickThreshold = 2; # Set "Click" to "Firm"
            };

            dock = {
              tilesize = 16;
              magnification = true;
              largesize = 128;
              autohide = true;
              autohide-delay = 0.0;
              autohide-time-modifier = 1.0;
              show-recents = false;
              mru-spaces = false;
              expose-group-apps = true;
            };

            finder = {
              AppleShowAllExtensions = true;
              AppleShowAllFiles = true;
              ShowPathbar = true;
              ShowStatusBar = true;
              FXPreferredViewStyle = "Nlsv";
              _FXSortFoldersFirst = true;
              _FXSortFoldersFirstOnDesktop = true;
              FXDefaultSearchScope = "SCcf";
              FXEnableExtensionChangeWarning = false;
              NewWindowTarget = "Home";
            };

            spaces = {
              spans-displays = false;
            };
          };

          # Auto upgrade nix package and the daemon service.
          nix.enable = true;
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
          security.pam.services.sudo_local.touchIdAuth = true;

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
            (azure-cli.withExtensions [
              azure-cli.extensions.azure-devops
            ])
            curl
            deno
            git
            git-credential-manager
            nodejs_22
            nodejs_22.pkgs.pnpm
            vscode
          ];

          home.sessionVariables = {
            EDITOR = "nvim";
          };

          home.shell.enableShellIntegration = true;

          home.file.".alacritty.toml".source = ./.alacritty.toml;

          programs = {
            zsh = {
              enable = true;
              enableCompletion = true;

              syntaxHighlighting = {
                enable = true;
              };

              autosuggestion = {
                enable = true;
              };

              shellAliases = {
                switch = "darwin-rebuild switch --flake \"$HOME/.config/nix#mac\"";
              };

              initContent = ''
                export PROMPT='%n %~/ ? %? %% '

                export LC_CTYPE=C

                HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
                HISTSIZE=1000000
                SAVEHIST=1000000
                setopt APPEND_HISTORY
                setopt INC_APPEND_HISTORY
                setopt HIST_IGNORE_DUPS

                zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

                export HOMEBREW_ACCEPT_EULA=Y;
              '';
            };

            fzf = {
              enable = true;
              defaultCommand = "fd --hidden --exclude .git";
              fileWidgetCommand = "fd --hidden --exclude .git --type file";
              fileWidgetOptions = [
                "--preview='bat --color=always {}'"
              ];
            };

            zoxide.enable = true;
            fd.enable = true;
            bat.enable = true;
            jq.enable = true;

            git = {
              enable = true;
              userName = "Miguel Lo-A-Foe";
              userEmail = "miguel@loafoe.dev";
              ignores = [ ".DS_Store" ];
              extraConfig = {
                init.defaultBranch = "master";
                push.autoSetupRemote = true;
                credential.helper = "manager";
              };
            };

            vscode = {
              enable = true;

              profiles = {
                default = {
                  userSettings = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
                    "editor.formatOnSave" = true;
                    "editor.insertSpaces" = true;
                    "editor.minimap.enabled" = false;
                    "editor.multiCursorLimit" = 100000;
                    "editor.stickyScroll.defaultModel" = "foldingProviderModel";
                    "editor.stickyScroll.enabled" = true;
                    "editor.tabSize" = 2;
                    "eslint.useFlatConfig" = true;
                    "files.encoding" = "utf8";
                    "files.eol" = "\n";
                    "files.insertFinalNewLine" = true;
                    "files.trimFinalNewLines" = true;
                    "files.trimTrailingWhitespace" = true;
                    "git.autofetch" = "all";
                    "git.confirmSync" = false;
                    "git.replaceTagsWhenPull" = true;
                    "gitlens.plusFeatures.enabled" = false;
                    "npm.packageManager" = "pnpm";
                    "redhat.telemetry.enabled" = false;
                    "security.workspace.trust.untrustedFiles" = "open";
                    "typescript.enablePromptUseWorkspaceTsdk" = true;
                    "typescript.tsserver.log" = "off";
                    "window.autoDetectColorScheme" = true;
                    "workbench.colorTheme" = "GitHub Light Default";
                    "workbench.preferredDarkColorTheme" = "GitHub Dark Default";
                    "workbench.preferredLightColorTheme" = "GitHub Light Default";
                    "workbench.sideBar.location" = "right";
                    "[xml]"."editor.defaultFormatter" = "redhat.vscode-xml";
                  };

                  extensions = with pkgs.vscode-extensions; [
                    bierner.markdown-mermaid
                    davidanson.vscode-markdownlint
                    dbaeumer.vscode-eslint
                    eamodio.gitlens
                    editorconfig.editorconfig
                    esbenp.prettier-vscode
                    github.copilot
                    github.copilot-chat
                    github.github-vscode-theme
                    humao.rest-client
                    mikestead.dotenv
                    # ms-playwright.playwright
                    mechatroner.rainbow-csv
                    redhat.vscode-xml
                    streetsidesoftware.code-spell-checker
                    timonwong.shellcheck
                    # typespec.typespec-vscode
                  ];

                  keybindings = [
                    {
                      key = "shift+cmd+c";
                      command = "-workbench.action.terminal.openNativeConsole";
                      when = "!terminalFocus";
                    }
                    {
                      key = "shift+cmd+c";
                      command = "git.checkout";
                    }
                    {
                      key = "ctrl+tab";
                      command = "-workbench.action.quickOpenNavigateNextInEditorPicker";
                    }
                    {
                      key = "ctrl+tab";
                      command = "workbench.action.focusNextGroup";
                    }
                    {
                      key = "ctrl+shift+tab";
                      command = "-workbench.action.quickOpenNavigatePreviousInEditorPicker";
                    }
                    {
                      key = "ctrl+shift+tab";
                      command = "workbench.action.focusPreviousGroup";
                    }
                  ];

                  globalSnippets = {
                    generate-uuid = {
                      prefix = [
                        "uuid"
                      ];
                      body = [
                        "\${UUID}"
                      ];
                      description = "Generate a version 4 UUID";
                    };

                    unix-timestamp = {
                      prefix = [
                        "unix"
                      ];
                      body = [
                        "\${CURRENT_SECONDS_UNIX}"
                      ];
                      description = "The number of seconds since the Unix epoch";
                    };

                    iso8601-timestamp = {
                      prefix = [
                        "iso8601"
                      ];
                      body = [
                        "\${CURRENT_YEAR}-\${CURRENT_MONTH}-\${CURRENT_DATE}T\${CURRENT_HOUR}:\${CURRENT_MINUTE}:\${CURRENT_SECOND}\${CURRENT_TIMEZONE_OFFSET}"
                      ];
                      description = "Current time expressed as ISO 8601 timestamp";
                    };
                  };
                };
              };
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
                "powershell/homebrew-tap" = homebrew-powershell;
                "microsoft/homebrew-mssql-release" = homebrew-mssql;
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
