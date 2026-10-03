# Global Instructions

@~/AGENTS.md

## Antigravity Customization

- **MCP Configuration:** Never mutate the active MCP settings at `~/.gemini/config/mcp_config.json` or through the UI directly. Instead, add or update the MCP server definition in the repository's base template at `/etc/nix-darwin/home/antigravity/mcp_config.json`, then run a system switch to regenerate the config.
- **Settings & Permissions:** Runtime settings or permission allowlist changes are saved to `~/.gemini/antigravity-cli/settings.json` and are synced automatically back to the repository at `/etc/nix-darwin/home/antigravity/settings.json` via a PreToolUse hook. Verify these changes are unstaged in Git and commit them as needed.
- **Worktrees:** Create agent Git worktrees under `.gemini/worktrees/` in the main checkout; never use another agent's worktree directory.
- **Subagents:** At most 8 per task, and no more than 4 running at once. Use the `research` subagent for broad multi-file survey or external searches that would clutter context; perform targeted single-file lookups directly.
- **Artifacts:** Keep plans and summaries inline by default. Create artifacts only for extensive reports or persistent multi-step plans requested for review; keep them terse and focused.
- **Browsing:** Use `read_url_content` for static documentation and public web pages. For interactive sessions, logins, or browser UI testing, recommend the `/browser` workflow.

