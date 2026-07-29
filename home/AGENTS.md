# Global Agent Instructions

## Environment

Software engineer; Go, TypeScript, Nix. Machines managed with nix-darwin + home-manager (repo `/etc/nix-darwin`). zsh, VS Code, git + GitHub (`gh`), podman (aliased `docker`). Packages via nix; brew only for GUI apps or tools missing from nixpkgs. Core Unix tools are GNU/nixpkgs versions ahead of Apple's BSD defaults in `PATH` - assume GNU flag semantics.

This file is nix-managed: edit `/etc/nix-darwin/home/AGENTS.md`, then `switch`. Deployed canonical is `~/AGENTS.md` (imported/symlinked/generated into the Claude, Codex, Copilot, and Gemini configs) - never edit deployed copies. A repo's own `AGENTS.md`/`CLAUDE.md` overrides these defaults on conflict.

## Style

- Concise, direct responses; match a repo's existing conventions over generic best practices.
- No code comments unless the WHY is non-obvious; no error handling for impossible scenarios; no abstractions beyond the task.
- Verify before claiming done: static checks, then tests; report real output - if something failed or was skipped, say so plainly.
- When configuring a versioned tool or library, fetch docs for that exact version.
- Format Nix with `nixfmt <file>` or `nixfmt-tree` (repo-wide); bare `nixfmt .` is deprecated.
- Keep memory and instruction files terse - they are paid as input tokens every turn.
- Plain printable ASCII wherever possible in responses, code, commits, and docs: use `-`, `"`, `'`, `...` instead of em dashes, smart quotes, ellipses, arrows, or decorative symbols.

## Workflow

- Plan non-trivial or multi-file changes before implementing.
- After implementing: review the diff, fix findings, reverify the fixes.

## Dev Environments

- Repos under `github.com/epiccoolguy` get a repo-root devShell pinning the toolchain - extend an existing `flake.nix`/`shell.nix` before creating one. Any other repo: ask first.
- Never edit `/etc/nix-darwin` to make a project tool available; propose global promotion only for cross-repo, version-independent tools, with my approval.
- Invoke project tools per-command as `nix develop --command <tool>` or `direnv exec . <tool>` - agent shells are fresh non-interactive processes, so direnv hooks never apply. You may `direnv allow` an `.envrc` you wrote yourself; ask before allowing a pre-existing one.
- Commit `flake.nix`, `flake.lock`, `.envrc`. Verify a new devShell with `nix flake check` plus one real tool run; flag nixpkgs version drift rather than silently accepting it.

## Secrets

- Don't store unencrypted secrets; never print them. Read tokens from the environment or `~/.env`.
- 1Password (`op`) is the secret escrow in both directions: pull secrets just-in-time into env vars within one command (e.g. `eval $(op signin) && export KEY="$(op document get '<item>')" && ...`), and store new or generated secrets there (`op item create` / `op document create`) rather than on disk.

## Git & GitHub

- Conventional Commits (`type(scope): imperative, concise`); split unrelated changes into separate commits; no agent attribution (no Co-Authored-By trailer or generated-with footer).
- Work autonomously end-to-end: once verified, commit, push, open/update the PR, and merge when green - including direct commits and pushes to master in my repos. Only prd-touching changes (see Deploys) wait for my review.
- Keep history linear: `gh pr merge --rebase`; never `--merge` or `--squash`.
- Prefer the GitHub MCP server, else the `gh` CLI.

## Parallel Work

- One session per subject, each in its own `git worktree` branched from freshly fetched `origin/<default-branch>`, never local HEAD. Subjects must not overlap in files - overlapping or dependent work runs in a single session that sequences it or orchestrates subagents in isolated worktrees and owns merge order.

## Deploys & Cluster Access

- GitOps is the only path that changes desired state. The dev/tst/acc flow is pre-approved: PRs, merges to master, re-pinning `overlays/acc`, `vX.Y.Z` tags. Anything touching prd - `overlays/prd`, prd promotions, prd content writes - always waits for my explicit review.
- Direct cluster access (`kubectl`, Kubernetes MCP, `argocd`) is for regular operations only - reads, logs, and converging/disrupting toward the committed spec (restart, scale, sync) - never mutations of desired state. It runs as the scoped `agent-ops` ServiceAccount (`~/.kube/agent.mlzw.config`, preset as `KUBECONFIG`); hard limits are RBAC-enforced server-side. Never point at admin credentials (`admin.mlzw.config`) - break-glass is mine alone: when an operation needs it, give me the exact command with `KUBECONFIG=$HOME/.kube/admin.mlzw.config` inline to run in shell mode (`! <cmd>`) so the output lands in-session and you can read along.
