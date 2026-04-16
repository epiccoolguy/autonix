{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    awscli2
    (azure-cli.withExtensions [
      azure-cli.extensions.azure-devops
    ])
    github-copilot-cli
    bat
    bruno
    curl
    deno
    git
    google-cloud-sdk
    gradle
    inetutils
    jdk
    k9s
    kind
    kubectl
    kubelogin
    kubernetes-helm
    maven
    neovim
    nixd
    nixfmt
    nodejs_24
    pnpm
    podman
    python3
    shellcheck
    skaffold
    texliveFull
    tmux
    vscode
  ];

  home.sessionVariables = {
    LC_CTYPE = "C";
    EDITOR = "nvim";
    HOMEBREW_ACCEPT_EULA = "Y";
    SSH_SK_PROVIDER = "/usr/lib/ssh-keychain.dylib";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.shell.enableShellIntegration = true;

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
        switch = "sudo darwin-rebuild switch";
        docker = "podman";
        createcacerts = "security export -t certs -k /System/Library/Keychains/SystemCertificates.keychain -p > \"/usr/local/share/ca-certificates/cacerts.crt\" && security export -t certs -k /Library/Keychains/System.keychain -p >> \"/usr/local/share/ca-certificates/cacerts.crt\"";
        python = "python3";
        pip = "pip3";
      };

      # Removed initExtra, replaced with ordered initContent below

      initContent =
        let
          zshEarlyInit = lib.mkOrder 500 ''
            [[ ! $(command -v nix) && -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]] && source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          '';
          zshGeneralConfig = lib.mkOrder 1000 ''
            export PROMPT='%n %1~ ? %? %% '

            HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
            HISTSIZE=1000000
            SAVEHIST=1000000
            setopt APPEND_HISTORY
            setopt INC_APPEND_HISTORY
            setopt HIST_IGNORE_DUPS

            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

            export DOCKER_HOST="unix://$(podman machine inspect --format '{{ .ConnectionInfo.PodmanSocket.Path }}')"
          '';
        in
        lib.mkMerge [
          zshEarlyInit
          zshGeneralConfig
        ];
    };

    fzf = {
      enable = true;
      defaultCommand = "fd --hidden --exclude .git";
      fileWidgetCommand = "fd --hidden --exclude .git --type file";
      fileWidgetOptions = [
        "--preview='bat --color=always {}'"
      ];
    };

    uv = {
      enable = true;
      settings = {
        python-downloads = "never";
        python-preference = "only-system";
        index = [
          {
            name = "nn-pypi";
            publish-url = "https://artifactory.insim.biz/artifactory/api/pypi/nn-pypi";
            url = "https://artifactory.insim.biz/artifactory/api/pypi/nn-pypi/simple";
            default = true;
          }
        ];
      };
    };

    zoxide.enable = true;
    fd.enable = true;
    bat.enable = true;
    jq.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        addKeysToAgent = "yes";
        extraOptions = {
          SecurityKeyProvider = "/usr/lib/ssh-keychain.dylib";
        };
      };
    };

    git = {
      enable = true;
      ignores = [ ".DS_Store" ];
      settings = {
        credential.helper = "manager";
        credential.useHttpPath = true;
        init.defaultBranch = "master";
        push.autoSetupRemote = true;
        user = {
          name = "Miguel Lo-A-Foe";
        };
      };
    };

    vscode = {
      enable = true;

      profiles = {
        default = {
          userSettings = {
            "cSpell.dictionaries" = [
              "aws"
              "google"
            ];
            "cSpell.language" = "en-GB,nl";
            "diffEditor.maxComputationTime" = 0;
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
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
            "npm.packageManager" = "pnpm";
            "redhat.telemetry.enabled" = false;
            "security.workspace.trust.untrustedFiles" = "open";
            "terminal.integrated.suggest.enabled" = false;
            "typescript.enablePromptUseWorkspaceTsdk" = true;
            "typescript.tsserver.log" = "off";
            "window.autoDetectColorScheme" = true;
            "window.confirmBeforeClose" = "keyboardOnly";
            "window.restoreWindows" = "none";
            "workbench.colorTheme" = "GitHub Light Default";
            "workbench.preferredDarkColorTheme" = "GitHub Dark Default";
            "workbench.preferredLightColorTheme" = "GitHub Light Default";
            "workbench.sideBar.location" = "right";
            "[xml]"."editor.defaultFormatter" = "redhat.vscode-xml";
            "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
          };

          extensions = with pkgs.vscode-marketplace; [
            davidanson.vscode-markdownlint
            dbaeumer.vscode-eslint
            eamodio.gitlens
            editorconfig.editorconfig
            esbenp.prettier-vscode
            github.copilot
            github.copilot-chat
            github.github-vscode-theme
            humao.rest-client
            jnoortheen.nix-ide
            mechatroner.rainbow-csv
            mikestead.dotenv
            ms-playwright.playwright
            redhat.vscode-xml
            streetsidesoftware.code-spell-checker
            streetsidesoftware.code-spell-checker-british-english
            streetsidesoftware.code-spell-checker-british-english-ise
            streetsidesoftware.code-spell-checker-dutch
            timonwong.shellcheck
            typespec.typespec-vscode
            vscjava.vscode-gradle
            vscjava.vscode-java-pack
            vstirbu.vscode-mermaid-preview
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
}
