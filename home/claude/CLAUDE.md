# Global Claude Instructions

## About Me

I'm a software engineer working primarily with Go, TypeScript, and Nix. My machines are managed with nix-darwin and home-manager (repo at `/etc/nix-darwin`).

## General Preferences

- Prefer concise, direct responses — skip preamble and summaries
- Default to no code comments unless the WHY is non-obvious
- Don't add error handling for scenarios that can't happen
- Don't introduce abstractions beyond what the task requires

## Tools & Environment

`~/.claude/` is nix-managed — to change `CLAUDE.md` or `settings.json`, edit the source files at `/etc/nix-darwin/home/claude/` and run `switch` to apply. Do not edit `~/.claude/` files directly.

- Shell: zsh
- Editor: VS Code
- VCS: git with GitHub (`gh` CLI available)
- Container runtime: podman (aliased as `docker`)
- Package manager: nix (prefer nix packages; brew inside nix flake for tools not in nixpkgs or with a graphical interface)

## Git & GitHub

- Commit messages: follow Conventional Commits (`type(scope): imperative mood, concise subject line`)
- PRs: linear merge with fast-forward (no squash, no merge commits)
- Use `gh` CLI for GitHub operations
