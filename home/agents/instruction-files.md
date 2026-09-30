# Agent Instruction Files

- The global rules are nix-managed: edit `/etc/nix-darwin/home/AGENTS.md` (root) and `/etc/nix-darwin/home/agents/*.md` (these linked files), then `switch`. Deployed copies (`~/AGENTS.md`, `~/.config/agents/`, and the Claude, Codex, Copilot, and Gemini configs generated from them) are read-only - never edit them.
- Claude-only rules live in `/etc/nix-darwin/home/claude/CLAUDE.md`; Gemini-only rules in `/etc/nix-darwin/home/antigravity/GEMINI.md`.
- Keep memory and instruction files terse - they are paid as input tokens every turn. Keep the root to what every task needs; put the rest in a linked file with a "read before..." trigger, using absolute `~/` paths (the root is also concatenated into Gemini's config, so relative links break).
