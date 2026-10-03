# Agent Instruction Files

- The global rules are nix-managed: edit `home/AGENTS.md` (root) and `home/agents/*.md` (these linked files) inside the active nix-darwin worktree. After merging and updating the main checkout at `/etc/nix-darwin`, hand the system switch to the user. Deployed copies (`~/AGENTS.md`, `~/.config/agents/`, and the Claude, Codex, Copilot, and Gemini configs generated from them) are read-only - never edit them.
- In that worktree, Claude-only rules live in `home/claude/CLAUDE.md`; Gemini-only rules in `home/antigravity/GEMINI.md`.
- Use `AGENTS.md` for shared repository instructions; keep agent-specific rules in that agent's instruction file.
- Keep memory and instruction files terse - they are paid as input tokens every turn. Keep the root to what every task needs; put the rest in a linked file with a "read before..." trigger, using absolute `~/` paths so cross-agent includes resolve consistently.
