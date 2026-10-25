{
  config,
  pkgs,
  lib,
  inputs,
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

  # miguel-only like the codex cask it drives.
  programs.claude-code.plugins.codex = "${inputs.codex-plugin-cc}/plugins/codex";

  # Official OVHcloud MCP hub, scoped to the domain section (zones, records, DNSSEC) for
  # external DNS. OAuth via /mcp, so no secret here. Left out of the permission allowlist:
  # the section also edits and orders domains, so every call prompts.
  programs.claude-code.mcpServers.ovh = {
    type = "http";
    url = "https://mcp.eu.ovhcloud.com/mcp/v1_domain";
  };

  # Weekly renewal of the 30-day mlzw agent credentials the MCP servers use (kubeconfig,
  # Argo CD and Grafana tokens), via mlzw-infra's script. Needs the LAN or VPN; a missed
  # run (asleep) runs on wake. Failures raise a notification so nothing expires unnoticed.
  launchd.agents.renew-agent-tokens = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.writeShellScript "renew-agent-tokens" ''
          echo "== $(date)"
          if ! ${config.home.homeDirectory}/github.com/epiccoolguy/mlzw-infra/scripts/renew-agent-tokens.sh; then
            /usr/bin/osascript -e 'display notification "See ~/Library/Logs/renew-agent-tokens.log" with title "mlzw agent token renewal failed"'
            exit 1
          fi
        ''}"
      ];
      StartCalendarInterval = [
        {
          Weekday = 1;
          Hour = 9;
          Minute = 0;
        }
      ];
      RunAtLoad = false;
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
        PATH = "/etc/profiles/per-user/miguel/bin:/usr/bin:/bin";
      };
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/renew-agent-tokens.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/renew-agent-tokens.log";
    };
  };
}
