# Global Agent Instructions

## About Me & Environment

I'm a software engineer working primarily in Go, TypeScript, and Nix. My machines are managed with nix-darwin and home-manager (repo at `/etc/nix-darwin`). Shell: zsh. Editor: VS Code. VCS: git with GitHub (`gh` CLI). Container runtime: podman (aliased as `docker`). Packages via nix; brew inside the flake only for GUI apps or tools missing from nixpkgs. A PreToolUse hook transparently proxies common dev commands through `rtk` for token savings — no action needed.

This file is nix-managed: edit the source at `/etc/nix-darwin/home/AGENTS.md` and run `switch`. The deployed canonical is `~/AGENTS.md`: `~/.claude/CLAUDE.md` imports it, `~/.codex/AGENTS.md` (Codex) and `~/.copilot/copilot-instructions.md` (Copilot CLI) symlink to it, and `~/.gemini/GEMINI.md` (Gemini CLI + Antigravity) is generated from it. Never edit the deployed copies.

## Style

- Concise, direct responses — no preamble, no restating the task, no summaries or sign-offs.
- No code comments unless the WHY is non-obvious.
- No error handling for scenarios that can't happen; no abstractions beyond what the task requires.
- Match a file/repo's existing conventions over generic best practices.

## Working

- Verify before claiming done: static checks (`bash -n`, `go vet`, `go mod tidy`), then tests; report real output. If a test fails or a step was skipped, say so plainly — don't paper over it.
- Lean on the built-in skills on diffs (`/code-review`, `/simplify`, `/verify`) instead of re-deriving them by hand.
- When configuring a versioned tool or library, fetch docs for that exact version rather than relying on memory.
- Delegate broad searches, log-trawling, and multi-file audits to subagents; surface conclusions into the main thread, not raw dumps.
- Locate symbols with LSP navigation (plugins are wired for the main languages) rather than blind grep.
- Keep memory and instruction files terse — they are paid as input tokens on every turn.

## Feature Workflow

1. **Plan**: feature work always starts in plan mode, as does any other non-trivial or multi-file change (non-feature work may skip planning only when the path is obvious); author the plan with Fable or Opus at high effort (the default model `opusplan[1m]` gives Opus in plan mode).
2. **Implement**: execute the approved plan in auto mode with Sonnet at high effort (`opusplan` switches to Sonnet automatically outside plan mode).
3. **Review**: run the post-implementation sequence in Code Review.

When a step names a model the session isn't on, run it via a subagent pinned to that model, or ask me to `/model` first.

## Code Review

- Ad-hoc diffs outside the implementation flow: a plain `/code-review` (plus `/simplify`, `/verify`) suffices; apply the fixes.
- Post-implementation sequence:
  1. Propose an ultracode review (the `ultracode` keyword — local multi-agent dynamic workflow, not the cloud `/code-review ultra`); it needs my explicit approval. Approved → **one** pass with Sonnet at high effort.
  2. Declined → regular `/code-review` with Opus at max effort.
  3. Either way, fix the findings with Sonnet at high effort.
  4. Reverify with a regular `/code-review` with Opus at high effort.
- A plan/task-pinned `/code-review` effort overrides these; confirm with me before deviating.

## Languages

- Go: `gofmt`/`goimports`; table-driven tests; wrap errors with `%w`.
- TypeScript: prefer `type` over `interface` unless extending; avoid `any`.
- Nix: format with `nixfmt <file>` (per-file) or `nixfmt-tree` (whole repo); bare `nixfmt .` is deprecated.

## Secrets

- Never commit secrets or print them in logs/output; read tokens from the environment or `~/.env`, never hardcode.

## Git & GitHub

- Conventional Commits (`type(scope): imperative mood, concise subject`); split unrelated changes into separate logical commits; no agent attribution (no `Co-Authored-By: Claude` trailer, no "Generated with Claude Code" footer).
- New features or anything that may run alongside other agents: work in a dedicated `git worktree` so parallel agents don't collide.
- Feature branches: once work is complete and verified (Code Review sequence passed), autonomously commit, push, and open or update the PR — don't leave finished work uncommitted. You may merge a green, verified PR if prd is untouched. On `master`/the default branch, commit/push only when I ask.
- Keep history linear: `gh pr merge --ff` if the branch is a direct child of the base, else `--rebase`; never `--merge` (the `gh` default; creates a 2-parent merge commit) and never `--squash`.
- Remote operations (PRs, issues, reviews, code search): prefer the GitHub MCP server when available, else the `gh` CLI. If a stale `GITHUB_TOKEN` breaks `gh` auth, fall back with `env -u GITHUB_TOKEN gh ...`.

## Deploys & Cluster Access

- The GitOps flow through dev/tst/acc is pre-approved: PRs to master, merges, re-pinning `overlays/acc`, `vX.Y.Z` tags. Anything touching prd — `overlays/prd`, prd-suffixed apps/namespaces, prd promotions — always waits for my explicit review.
- `kubectl` and the (read-only) Kubernetes MCP run as the least-privilege `agent-ops` ServiceAccount via the scoped kubeconfig `~/.kube/agent.config` (preset as `KUBECONFIG`): cluster-wide read minus Secrets and most pod logs (logs only in non-prod namespaces), write only in `zandbak-dev`/`zandbak-tst` — enforced server-side by RBAC + Pod Security Admission. Never override `KUBECONFIG`/`--kubeconfig` toward an admin config (`admin.config`, `config-mlzw`) — break-glass admin access is mine alone.
- `argocd` CLI: read-only `app` subcommands only (get/list/diff/history/resources/manifests); cluster mutations go through the GitOps flow, never `argocd app sync`/`rollback`/`delete`.
