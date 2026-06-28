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
- High-risk changes (security, auth, concurrency/locking, data migrations, money, infra/deploy, wide blast radius) are not merge-ready until an **ultracode** review has run. Flow: regular `/code-review` first → fix → **one** ultracode pass → fix → reverify with a regular `/code-review` only. Ultracode runs at most once per change — never loop it.
- Ultracode is a local dynamic workflow that fans out reviewer subagents to adversarially cross-check each other (`xhigh` effort + workflow orchestration), so it catches more than a single pass. It runs locally and counts toward plan usage (needs Claude Code v2.1.154+, a paid plan, and workflows enabled in `/config`).
- Don't escalate to ultracode silently — it spawns a workflow that needs an approval prompt, so tell me you're running it. If a plan/task pinned a specific `/code-review` effort, confirm before overriding it with ultracode.
- Opt in one of two ways: per review, prefix the request with the `ultracode` keyword (e.g. `ultracode: review the current branch diff for correctness, concurrency/locking, and security boundaries`); or for the whole session set `/effort ultracode`, run the review, then revert with `/effort high` for routine work.

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
- Feature delivery: on a feature branch, when work is complete and verified, autonomously commit, push, and open or update its pull request — don't leave finished work uncommitted. Never merge a PR unless I explicitly request it. This does not apply to changes on `master`/the default branch (commit/push those only when I ask)
- Commit messages: follow Conventional Commits (`type(scope): imperative mood, concise subject line`)
- Don't add agent attributions: no `Co-Authored-By: Claude` trailer in commit messages and no "Generated with Claude Code" footer in PR bodies
- Split unrelated changes into separate logical commits; don't bundle them
- PRs: keep history linear — when merging, use `gh pr merge --ff` if the branch is a direct child of the base, else `gh pr merge --rebase`. Never `--merge` (the `gh` default; creates a 2-parent merge commit) and never `--squash`
- For remote operations (PRs, issues, reviews, code search), prefer the GitHub MCP server when available; otherwise use the `gh` CLI. If a stale `GITHUB_TOKEN` env var breaks `gh` auth, fall back with `env -u GITHUB_TOKEN gh ...`
