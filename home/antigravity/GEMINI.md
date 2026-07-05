
## Antigravity Customization

- **MCP Configuration:** Never mutate the active MCP settings at `~/.gemini/config/mcp_config.json` or through the UI directly. Instead, add or update the MCP server definition in the repository's base template at `home/antigravity/mcp_config.json`, then run a system switch to regenerate the config.
- **Settings & Permissions:** Runtime settings or permission allowlist changes are saved to `~/.gemini/antigravity-cli/settings.json` and are synced automatically back to the repository at `home/antigravity/settings.json` via a PreToolUse hook. Verify these changes are unstaged in Git and commit them as needed.
