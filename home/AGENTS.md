# Global Agent Instructions

## About Me

I'm a software engineer working primarily with Go, TypeScript, and Nix. My machines are managed with nix-darwin and home-manager (repo at `/etc/nix-darwin`).

These global agent instructions are nix-managed — edit the source at `/etc/nix-darwin/home/AGENTS.md` and run `switch` to apply. The deployed canonical is `~/AGENTS.md`; tool configs reference it: `~/.claude/CLAUDE.md` imports it, and `~/.gemini/GEMINI.md` (Gemini CLI + Antigravity), `~/.codex/AGENTS.md` (Codex), and `~/.copilot/copilot-instructions.md` (Copilot CLI) symlink to it. Don't edit the deployed files directly.

## General Preferences

- Prefer concise, direct responses — skip preamble and summaries
- Default to no code comments unless the WHY is non-obvious
- Don't add error handling for scenarios that can't happen
- Don't introduce abstractions beyond what the task requires

## Working Style

- Verify before claiming done: run static checks (`bash -n`, `go vet`, `go mod tidy`), then tests, and report real output
- If tests fail or a step was skipped, say so plainly — don't paper over it
- Match existing conventions in a file/repo over generic best practices
- When configuring a versioned tool or library, fetch docs for that exact version rather than relying on memory

## Language Conventions

- Go: `gofmt`/`goimports`; table-driven tests; wrap errors with `%w`
- TypeScript: prefer `type` over `interface` unless extending; avoid `any`
- Nix: format with `nixfmt <file>` (per-file) or `nixfmt-tree` (whole repo); bare `nixfmt .` is deprecated

## Secrets

- Never commit secrets or print them in logs/output
- Read tokens from the environment or `~/.env`, never hardcode

## Tools & Environment

- Shell: zsh
- Editor: VS Code
- VCS: git with GitHub (`gh` CLI available)
- Container runtime: podman (aliased as `docker`)
- Package manager: nix (prefer nix packages; brew inside nix flake for tools not in nixpkgs or with a graphical interface)

## Git & GitHub

- Commit messages: follow Conventional Commits (`type(scope): imperative mood, concise subject line`)
- Split unrelated changes into separate logical commits; don't bundle them
- PRs: linear merge with fast-forward (no squash, no merge commits)
- For remote operations (PRs, issues, reviews, code search), prefer the GitHub MCP server when available; otherwise use the `gh` CLI. If a stale `GITHUB_TOKEN` env var breaks `gh` auth, fall back with `env -u GITHUB_TOKEN gh ...`
