{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./common.nix ];

  home.username = "miguel";
  home.homeDirectory = "/Users/miguel";

  home.packages = with pkgs; [
    claude-code
  ];

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
    google.gemini-cli-vscode-ide-companion
  ];

  programs.antigravity = {
    enable = true;
    profiles.default = {
      userSettings = config.programs.vscode.profiles.default.userSettings;
      keybindings = config.programs.vscode.profiles.default.keybindings;
      extensions = config.programs.vscode.profiles.default.extensions;
      globalSnippets = config.programs.vscode.profiles.default.globalSnippets;
    };
  };

  home.activation.linkAntigravityIdeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Create the target directories if they don't exist
    mkdir -p "$HOME/Library/Application Support/Antigravity IDE/User"
    mkdir -p "$HOME/.antigravity-ide"

    # Link settings.json
    if [ -e "$HOME/Library/Application Support/Antigravity/User/settings.json" ]; then
      if [ -f "$HOME/Library/Application Support/Antigravity IDE/User/settings.json" ] && [ ! -L "$HOME/Library/Application Support/Antigravity IDE/User/settings.json" ]; then
        rm -f "$HOME/Library/Application Support/Antigravity IDE/User/settings.json"
      fi
      ln -sf "$HOME/Library/Application Support/Antigravity/User/settings.json" "$HOME/Library/Application Support/Antigravity IDE/User/settings.json"
    fi

    # Link keybindings.json
    if [ -e "$HOME/Library/Application Support/Antigravity/User/keybindings.json" ]; then
      if [ -f "$HOME/Library/Application Support/Antigravity IDE/User/keybindings.json" ] && [ ! -L "$HOME/Library/Application Support/Antigravity IDE/User/keybindings.json" ]; then
        rm -f "$HOME/Library/Application Support/Antigravity IDE/User/keybindings.json"
      fi
      ln -sf "$HOME/Library/Application Support/Antigravity/User/keybindings.json" "$HOME/Library/Application Support/Antigravity IDE/User/keybindings.json"
    fi

    # Link global.code-snippets
    if [ -e "$HOME/Library/Application Support/Antigravity/User/snippets/global.code-snippets" ]; then
      mkdir -p "$HOME/Library/Application Support/Antigravity IDE/User/snippets"
      if [ -f "$HOME/Library/Application Support/Antigravity IDE/User/snippets/global.code-snippets" ] && [ ! -L "$HOME/Library/Application Support/Antigravity IDE/User/snippets/global.code-snippets" ]; then
        rm -f "$HOME/Library/Application Support/Antigravity IDE/User/snippets/global.code-snippets"
      fi
      ln -sf "$HOME/Library/Application Support/Antigravity/User/snippets/global.code-snippets" "$HOME/Library/Application Support/Antigravity IDE/User/snippets/global.code-snippets"
    fi

    # Link extensions directory
    if [ -d "$HOME/.antigravity/extensions" ]; then
      if [ -d "$HOME/.antigravity-ide/extensions" ] && [ ! -L "$HOME/.antigravity-ide/extensions" ]; then
        rm -rf "$HOME/.antigravity-ide/extensions"
      fi
      ln -sf "$HOME/.antigravity/extensions" "$HOME/.antigravity-ide/extensions"
    fi
  '';

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
