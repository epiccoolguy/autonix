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
    wireguard-tools
  ];

  programs.vscode.profiles.default.extensions = with pkgs.vscode-marketplace; [
    anthropic.claude-code
    google.gemini-cli-vscode-ide-companion
  ];

  # No personal Copilot subscription: disable VS Code's built-in AI/Copilot UI.
  programs.vscode.profiles.default.userSettings = {
    "chat.disableAIFeatures" = true;
    # Run Claude Code in an integrated terminal instead of the webview, which
    # avoids the sidebar/panel relocation issues with the view UI.
    "claudeCode.useTerminal" = true;
  };

  # Cmd+Shift+I opens Claude Code in a terminal (mirrors the Copilot CLI on corporate).
  programs.vscode.profiles.default.keybindings = [
    {
      key = "shift+cmd+i";
      command = "-workbench.action.chat.open";
    }
    {
      key = "shift+cmd+i";
      command = "claude-vscode.terminal.open";
    }
  ];

  programs.git.settings.user.email = "miguel@loafoe.dev";
}
