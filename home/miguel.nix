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
    # The mlzw repos' toolchain, on PATH everywhere instead of per-repo devShells (mlzw-infra#454).
    actionlint
    age
    cilium-cli
    cosign
    crane
    kubeconform
    kustomize
    sops
    # Owner admin access to mlzw-hp (mlzw-infra decisions/0020): runs one command with the
    # admin kubeconfig, read from 1Password behind its approval and kept only in a temp file
    # for that command. The ambient KUBECONFIG stays the read-only agent one.
    (writeShellScriptBin "mlzw-admin" ''
      set -euo pipefail
      [ $# -gt 0 ] || { echo "usage: mlzw-admin <command> [args...], e.g. mlzw-admin kubectl get nodes" >&2; exit 2; }
      f="$(mktemp)"
      trap 'rm -f "$f"' EXIT
      op read "''${MLZW_ADMIN_KUBECONFIG_REF:-op://Private/mlzw-hp-admin-kubeconfig/notesPlain}" >"$f"
      KUBECONFIG="$f" "$@"
    '')
  ];

  # mlzw nodes: the cluster key is served by the 1Password SSH agent with approval per use, so
  # an agent session cannot reach a node's admin credential on its own (mlzw-infra decisions/0020).
  programs.ssh.settings."172.22.20.* 172.17.20.* 10.10.20.*" = {
    IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  };

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

  # Daily Renovate triage (mlzw-infra decisions/0021): headless Claude runs the repo's
  # /renovate-triage skill as the mlzw-agent App with read-only cluster access. Local, not a
  # cloud routine, because verifying a deploy needs the LAN-only cluster and Argo. A missed
  # run (asleep) runs on wake; failures raise a notification.
  launchd.agents.renovate-triage = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.writeShellScript "renovate-triage" ''
          echo "== $(date)"
          cd ${config.home.homeDirectory}/github.com/epiccoolguy/mlzw-infra || exit 1
          if ! git pull -q --ff-only || ! /opt/homebrew/bin/claude -p "/renovate-triage" \
            --allowedTools "Bash Read Grep Glob Skill"; then
            /usr/bin/osascript -e 'display notification "See ~/Library/Logs/renovate-triage.log" with title "mlzw Renovate triage failed"'
            exit 1
          fi
        ''}"
      ];
      StartCalendarInterval = [
        {
          Hour = 10;
          Minute = 0;
        }
      ];
      RunAtLoad = false;
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
        PATH = "/etc/profiles/per-user/miguel/bin:/opt/homebrew/bin:/usr/bin:/bin";
      };
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/renovate-triage.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/renovate-triage.log";
    };
  };
}
