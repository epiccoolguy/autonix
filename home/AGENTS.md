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

## Agent Efficiency

Keep context lean and tool calls cheap — these levers are built in, use them by default:

- Delegate broad searches, log-trawling, and multi-file audits to a subagent; surface only the conclusion, not the raw dumps, into the main thread.
- Use plan mode for non-trivial or multi-file changes; act directly only when the path is obvious.
- Prefer LSP navigation (go-to-definition, find-references) over blind grep to locate symbols — gopls, typescript-language-server, and pyright are installed and wired as LSP plugins.
- Lean on the built-in review/cleanup skills on diffs (`/code-review`, `/simplify`, `/verify`) instead of re-deriving them by hand.
- Keep memory and instruction files terse: they are paid as input tokens on every turn.
- Prefer concise, telegraphic output; skip restating the task and sign-offs (see General Preferences).

## Code Review

- Default to `/code-review` on diffs (plus `/simplify`, `/verify`); apply the fixes.
- High-risk changes (security, auth, concurrency/locking, data migrations, money, infra/deploy) additionally get **one** local ultracode pass — prefix the review request with the `ultracode` keyword (local multi-agent workflow; not the cloud `/code-review ultra`): regular `/code-review` → fix → ultracode pass → fix → reverify with a regular `/code-review`. Never loop the ultracode pass.
- Don't escalate to ultracode silently — it spawns a workflow that needs an approval prompt, so tell me first; if a plan/task pinned a specific `/code-review` effort, confirm before overriding it.

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
- Feature delivery: on a feature branch, when work is complete and verified, autonomously commit, push, and open or update its pull request — don't leave finished work uncommitted. You may merge a green, verified PR autonomously as long as production (prd) is not impacted. This does not apply to changes on `master`/the default branch (commit/push those only when I ask)
- Deploys: the GitOps flow through dev/tst/acc (PRs to master, merges, re-pinning `overlays/acc`, `vX.Y.Z` tags) is pre-approved. Anything touching prd — `overlays/prd`, prd-suffixed apps/namespaces, prd promotions — always waits for my explicit review
- Commit messages: follow Conventional Commits (`type(scope): imperative mood, concise subject line`)
- Don't add agent attributions: no `Co-Authored-By: Claude` trailer in commit messages and no "Generated with Claude Code" footer in PR bodies
- Split unrelated changes into separate logical commits; don't bundle them
- PRs: keep history linear — when merging, use `gh pr merge --ff` if the branch is a direct child of the base, else `gh pr merge --rebase`. Never `--merge` (the `gh` default; creates a 2-parent merge commit) and never `--squash`
- For remote operations (PRs, issues, reviews, code search), prefer the GitHub MCP server when available; otherwise use the `gh` CLI. If a stale `GITHUB_TOKEN` env var breaks `gh` auth, fall back with `env -u GITHUB_TOKEN gh ...`

## Antigravity Customization

- **MCP Configuration:** Never mutate the active MCP settings at `~/.gemini/config/mcp_config.json` or through the UI directly. Instead, add or update the MCP server definition in the repository's base template at `home/antigravity/mcp_config.json`, then run a system switch to regenerate the config.
- **Settings & Permissions:** Runtime settings or permission allowlist changes are saved to `~/.gemini/antigravity-cli/settings.json` and are synced automatically back to the repository at `home/antigravity/settings.json` via a PreToolUse hook. Verify these changes are unstaged in Git and commit them as needed.

