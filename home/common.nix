{
  config,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    (azure-cli.withExtensions [
      azure-cli.extensions.azure-devops
    ])
    curl
    deno
    git
    git-credential-manager
    k9s
    kind
    kubectl
    kubernetes-helm
    nixd
    nodejs_22
    nodejs_22.pkgs.pnpm
    podman
    skaffold
    vscode
  ];

  home.sessionVariables = {
    LC_CTYPE = "C";
    EDITOR = "nvim";
    HOMEBREW_ACCEPT_EULA = "Y";
  };

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
        switch = "sudo darwin-rebuild switch --flake \"$HOME/.config/nix\"";
        docker = "podman";
      };

      initContent = ''
        export PROMPT='%n %~/ ? %? %% '

        HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
        HISTSIZE=1000000
        SAVEHIST=1000000
        setopt APPEND_HISTORY
        setopt INC_APPEND_HISTORY
        setopt HIST_IGNORE_DUPS

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

        export DOCKER_HOST="unix://$(podman machine inspect --format '{{ .ConnectionInfo.PodmanSocket.Path }}')"
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
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
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
            "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
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
            jnoortheen.nix-ide
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
}
