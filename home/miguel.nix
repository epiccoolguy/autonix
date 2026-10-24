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
    openai.chatgpt
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

  # Codex plugin for Claude Code; miguel-only like the codex cask it drives. Enabled in
  # the shared claude/settings.json, where AS33AI ignores it since the marketplace is unknown there.
  # `marketplace add` always writes extraKnownMarketplaces into that repo file (which would
  # declare it to AS33AI too), so only add once; revert that one-time diff after a fresh setup.
  home.activation.claudeCodexPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    claude_bin="$(command -v claude || true)"
    if [ -n "$claude_bin" ]; then
      if ! "$claude_bin" plugin marketplace list 2>/dev/null | grep -q openai-codex; then
        $DRY_RUN_CMD "$claude_bin" plugin marketplace add openai/codex-plugin-cc || true
      fi
      $DRY_RUN_CMD "$claude_bin" plugin install codex@openai-codex 2>/dev/null || true
    fi
  '';
}
