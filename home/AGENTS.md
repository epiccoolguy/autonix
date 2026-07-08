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

## Feature Workflow

- **Plan**: start feature work in plan mode; author the plan with Fable or Opus at high effort.
- **Implement**: execute the approved plan in auto-accept mode with Sonnet at high effort.
- **Review**: after implementation, follow the sequence in Code Review.

## Agent Efficiency

Keep context lean and tool calls cheap — these levers are built in, use them by default:

- Delegate broad searches, log-trawling, and multi-file audits to a subagent; surface only the conclusion, not the raw dumps, into the main thread.
- Use plan mode for non-trivial or multi-file changes (feature work always plans — see Feature Workflow); act directly only when the path is obvious.
- Prefer LSP navigation (go-to-definition, find-references) over blind grep to locate symbols — gopls, typescript-language-server, and pyright are installed and wired as LSP plugins.
- Lean on the built-in review/cleanup skills on diffs (`/code-review`, `/simplify`, `/verify`) instead of re-deriving them by hand.
- Keep memory and instruction files terse: they are paid as input tokens on every turn.
- Prefer concise, telegraphic output; skip restating the task and sign-offs (see General Preferences).

## Code Review

- For ad-hoc diffs outside the implementation flow, a plain `/code-review` (plus `/simplify`, `/verify`) suffices; apply the fixes.
- After implementation, always run this sequence:
  1. Suggest an ultracode review (the `ultracode` keyword — local multi-agent dynamic workflow, not the cloud `/code-review ultra`); it needs my explicit approval. When approved, run **one** pass with Sonnet at high effort.
  2. If I decline, instead run a regular `/code-review` with Opus at max effort.
  3. Either way, fix the findings with Sonnet at high effort.
  4. Reverify with a regular `/code-review` with Opus at high effort.
- Steps that name a model the session isn't on: run them via a subagent pinned to that model, or ask me to `/model` first.
- A plan/task-pinned `/code-review` effort overrides the efforts above; confirm with me before deviating from it.

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

- Worktrees: for a new feature or any change that may run alongside other agents, work in a dedicated `git worktree` rather than the shared checkout, so parallel agents don't collide
- Feature delivery: on a feature branch, when work is complete and verified (Code Review sequence passed), autonomously commit, push, and open or update its pull request — don't leave finished work uncommitted. You may merge a green, verified PR autonomously as long as production (prd) is not impacted. This does not apply to changes on `master`/the default branch (commit/push those only when I ask)
- Deploys: the GitOps flow through dev/tst/acc (PRs to master, merges, re-pinning `overlays/acc`, `vX.Y.Z` tags) is pre-approved. Anything touching prd — `overlays/prd`, prd-suffixed apps/namespaces, prd promotions — always waits for my explicit review
- Commit messages: follow Conventional Commits (`type(scope): imperative mood, concise subject line`)
- Don't add agent attributions: no `Co-Authored-By: Claude` trailer in commit messages and no "Generated with Claude Code" footer in PR bodies
- Split unrelated changes into separate logical commits; don't bundle them
- PRs: keep history linear — when merging, use `gh pr merge --ff` if the branch is a direct child of the base, else `gh pr merge --rebase`. Never `--merge` (the `gh` default; creates a 2-parent merge commit) and never `--squash`
- For remote operations (PRs, issues, reviews, code search), prefer the GitHub MCP server when available; otherwise use the `gh` CLI. If a stale `GITHUB_TOKEN` env var breaks `gh` auth, fall back with `env -u GITHUB_TOKEN gh ...`
