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
    argocd
    awscli2
    (azure-cli.withExtensions [
      azure-cli.extensions.azure-devops
    ])
    bruno
    coreutils
    curl
    delve
    deno
    findutils
    gawk
    gh
    github-copilot-cli
    gnumake
    gnused
    golangci-lint
    google-cloud-sdk
    gopls
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
    nixfmt-tree
    nodejs_24
    pnpm
    podman
    pyright
    python3
    ripgrep
    rtk
    shellcheck
    skaffold
    texliveFull
    tmux
    tree
    typescript-language-server
    unzip
    yq
    zip
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
            [[ -f "$HOME/.env" ]] && set -a && source "$HOME/.env" && set +a
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
            export KUBECONFIG="''${HOME}/.kube/config:''${HOME}/.kube/config-mlzw"
          '';
          zshFunctions = lib.mkOrder 1000 ''
            # git-clone wrapper: derive local path from URL
            #   https://user@host/org/_git/repo  →  ~/host/org/repo
            #   https://host/org/repo.git        →  ~/host/org/repo
            function git() {
              [[ "$1" == "clone" ]] || { command git "$@"; return; }

              local url="" found=0
              for arg in "''${@:2}"; do
                case "$arg" in
                  -*) ;;
                  *://*)
                    url="$arg"
                    found=1
                    ;;
                  *)
                    # non-flag arg after URL = explicit target dir; pass through
                    (( found )) && { command git "$@"; return; }
                    ;;
                esac
              done

              [[ -z "$url" ]] && { command git "$@"; return; }

              local target="''${url#*://}"
              target="''${target#*@}"
              [[ "$target" == *"/_git/"* ]] && target="''${target%%/_git/*}/''${target#*/_git/}"
              target="''${target%.git}"
              target="$HOME/$target"

              mkdir -p "''${target:h}"
              command git clone "''${@:2}" "$target"
            }
          '';
        in
        lib.mkMerge [
          zshEarlyInit
          zshGeneralConfig
          zshFunctions
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
    go.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "yes";
        SecurityKeyProvider = "/usr/lib/ssh-keychain.dylib";
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
      package = null;

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
            "search.exclude" = {
              "/result" = true;
            };
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
            "[go]" = {
              "editor.defaultFormatter" = "golang.go";
              "editor.codeActionsOnSave" = {
                "source.organizeImports" = "explicit";
              };
            };
            "[xml]"."editor.defaultFormatter" = "redhat.vscode-xml";
            "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
          };

          extensions = with pkgs.vscode-marketplace; [
            davidanson.vscode-markdownlint
            dbaeumer.vscode-eslint
            eamodio.gitlens
            editorconfig.editorconfig
            esbenp.prettier-vscode
            github.github-vscode-theme
            golang.go
            humao.rest-client
            jnoortheen.nix-ide
            mechatroner.rainbow-csv
            mikestead.dotenv
            ms-azuretools.vscode-containers
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

    antigravity = {
      package = null;
      profiles.default = {
        userSettings = config.programs.vscode.profiles.default.userSettings;
        keybindings = config.programs.vscode.profiles.default.keybindings;
        extensions = config.programs.vscode.profiles.default.extensions;
        globalSnippets = config.programs.vscode.profiles.default.globalSnippets;
      };
    };
  };

  home.file = {
    # Canonical global rules for agents
    "AGENTS.md".source = ./AGENTS.md;

    ".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
    ".claude/RTK.md".source = ./claude/RTK.md;
    ".codex/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/AGENTS.md";
    ".gemini/GEMINI.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/AGENTS.md";
    ".copilot/copilot-instructions.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/AGENTS.md";

    ".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nix-darwin/home/claude/settings.json";
    ".claude/statusline.sh".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nix-darwin/home/claude/statusline.sh";
  };

  # programs.claude-code.mcpServers cannot be used here because claude is installed via brew
  # (programs.claude-code.package = null). That option works by wrapping the nix-managed binary
  # with --plugin-dir; without a package, no wrapper is created and mcpServers is ignored.
  # Instead, we call `claude mcp add-json` directly to write into ~/.claude.json, which is
  # where the CLI reads MCP server registrations from regardless of how it was installed.
  home.activation.githubMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    env_file="$HOME/.env"
    claude_bin="$(command -v claude || true)"
    if [ -f "$env_file" ] && [ -n "$claude_bin" ]; then
      pat="$(grep '^GITHUB_PAT=' "$env_file" | cut -d= -f2-)"
      if [ -n "$pat" ]; then
        json="{\"type\":\"http\",\"url\":\"https://api.githubcopilot.com/mcp\",\"headers\":{\"Authorization\":\"Bearer $pat\"}}"
        $DRY_RUN_CMD "$claude_bin" mcp remove github --scope user 2>/dev/null || true
        $DRY_RUN_CMD "$claude_bin" mcp add-json github "$json" --scope user
      fi
    fi
  '';

  # LSP plugins must be *installed* (downloaded into ~/.claude/plugins) in addition to
  # being enabled via settings.json's enabledPlugins. Installation state lives in mutable
  # ~/.claude/plugins/installed_plugins.json, which is not nix-managed, so install them
  # here for reproducibility. `claude plugin install` is idempotent. The LSP servers
  # themselves (gopls, typescript-language-server, pyright) come from home.packages above.
  home.activation.claudeLspPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    claude_bin="$(command -v claude || true)"
    if [ -n "$claude_bin" ]; then
      for plugin in gopls-lsp typescript-lsp pyright-lsp; do
        $DRY_RUN_CMD "$claude_bin" plugin install "$plugin@claude-plugins-official" 2>/dev/null || true
      done
    fi
  '';
}
