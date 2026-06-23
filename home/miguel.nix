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
  ];

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
    google.gemini-cli-vscode-ide-companion
  ];

  # Cmd+Shift+I opens the Claude Code sidebar instead of the built-in chat.
  programs.vscode.profiles.default.keybindings = [
    {
      key = "shift+cmd+i";
      command = "-workbench.action.chat.open";
    }
    {
      key = "shift+cmd+i";
      command = "claude-vscode.sidebar.open";
    }
  ];

  programs.antigravity.enable = true;

  # Reuse VS Code settings for Antigravity IDE (installed via homebrew cask)
  home.file = {
    "Library/Application Support/Antigravity IDE/User/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Antigravity/User/settings.json";

    "Library/Application Support/Antigravity IDE/User/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Antigravity/User/keybindings.json";

    "Library/Application Support/Antigravity IDE/User/snippets/global.code-snippets".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Application Support/Antigravity/User/snippets/global.code-snippets";

    ".antigravity-ide/extensions".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.antigravity/extensions";
  };

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
