# Global Agent Instructions

## About Me & Environment

I'm a software engineer working primarily in Go, TypeScript, and Nix. My machines are managed with nix-darwin and home-manager (repo at `/etc/nix-darwin`). Shell: zsh. Editor: VS Code. VCS: git with GitHub (`gh` CLI). Container runtime: podman (aliased as `docker`). Packages via nix; brew inside the flake only for GUI apps or tools missing from nixpkgs. Core Unix tools (coreutils, findutils, sed, awk, grep, diffutils, less, rsync, bash) are GNU/nixpkgs versions ahead of Apple's BSD/ancient defaults in `PATH` — assume GNU flag semantics (e.g. `sed -i` needs no empty-string arg), not BSD. A PreToolUse hook transparently proxies common dev commands through `rtk` for token savings — no action needed.

This file is nix-managed: edit the source at `/etc/nix-darwin/home/AGENTS.md` and run `switch`. The deployed canonical is `~/AGENTS.md`: `~/.claude/CLAUDE.md` imports it, `~/.codex/AGENTS.md` (Codex) and `~/.copilot/copilot-instructions.md` (Copilot CLI) symlink to it, and `~/.gemini/GEMINI.md` (Gemini CLI + Antigravity) is generated from it. Never edit the deployed copies.

These are global defaults. A repository's own `AGENTS.md`/`CLAUDE.md` takes precedence on any conflict and may specialize or override any rule here — where a repo defines its own version of a workflow (code-review sequence, end-of-plan handoff, promotion/merge policy), follow the repo's and treat these as the fallback for anything it leaves unspecified.

## Style

- Concise, direct responses — no preamble, no restating the task, no summaries or sign-offs.
- No code comments unless the WHY is non-obvious.
- No error handling for scenarios that can't happen; no abstractions beyond what the task requires.
- Match a file/repo's existing conventions over generic best practices.

## Working

- Verify before claiming done: static checks (`bash -n`, `go vet`, `go mod tidy`), then tests; report real output. If a test fails or a step was skipped, say so plainly — don't paper over it.
- Lean on the built-in skills on diffs (`/code-review`, `/simplify`, `/verify`) instead of re-deriving them by hand.
- When configuring a versioned tool or library, fetch docs for that exact version rather than relying on memory.
- Delegate broad searches, log-trawling, and multi-file audits to subagents; surface conclusions into the main thread, not raw dumps. Pin read-only search/audit subagents to a cheaper model (Haiku, or Sonnet if the search needs light judgment) — reserve Opus/high-effort subagents for genuine reasoning (planning, verification, adversarial review).
- Locate symbols with LSP navigation (plugins are wired for the main languages) rather than blind grep.
- Keep memory and instruction files terse — they are paid as input tokens on every turn.

## Feature Workflow

1. **Plan**: feature work always starts in plan mode, as does any other non-trivial or multi-file change (non-feature work may skip planning only when the path is obvious); author the plan with Fable or Opus at high effort (the default model `opusplan[1m]` gives Opus in plan mode). Never use ultraplan (cloud plan-refinement on Claude Code on the web): don't run `/ultraplan`, don't trigger the `ultraplan` keyword, and don't suggest "refine with Ultraplan on Claude Code on the web" at plan approval — plan locally only.
2. **Implement**: execute the approved plan in auto mode with Sonnet at high effort (`opusplan` switches to Sonnet automatically outside plan mode).
3. **Review**: run the post-implementation sequence in Code Review.
4. **Hand off & close out**: do this unprompted at the end of every session — never ask whether to clean up, never wait to be asked for a handoff.
   - **Hand off at stage boundaries, never mid-stage.** Handoff cost tracks how much load-bearing state lives in the transcript rather than in git, so once work is committed, pushed, and documented it is nearly free. Trigger one when the follow-up has a different working set, needs its own branch/worktree, is an out-of-scope review finding, is blocked on slow external input, or when you catch yourself re-deriving established facts.
   - **Otherwise keep working**: the remainder is small and in files already open; the value is accumulated debugging context (finish it, or write the findings into a commit message or issue first); the next step is an obvious direct dependency. Never emit a handoff for work you could finish in a couple of edits — that's procrastination, not delegation.
   - A handoff prompt must stand alone: task, exact files/symbols, branch and its state, acceptance check. If it needs the old transcript to make sense, do the work instead. A repo's own handoff convention wins over this.
   - **Clean up**: if the session ran in a `git worktree`, remove it (`ExitWorktree` remove, or `git worktree remove` once the branch is pushed) and mark its shared-ledger entry done. Same for any other worktree or branch whose work is merged and pushed — remove it rather than reporting it as a cleanup candidate. Pause for my confirmation only when it holds unpushed commits, unmerged commits, or uncommitted changes, since removing that loses work. Say what you cleaned up; don't ask permission for the rest.

When a step names a model the session isn't on, run it via a subagent pinned to that model, or ask me to `/model` first.

## Code Review

- Ad-hoc diffs outside the implementation flow: a plain `/code-review` (plus `/simplify`, `/verify`) suffices; apply the fixes.
- Post-implementation sequence (the `code-reviewer` subagent is pinned to Opus at max effort — dispatch it for every regular review/reverify pass instead of running `/code-review` inline, so review never silently inherits the builder's Sonnet session; the one exception is the ultracode-approved pass in step 1, which must run in this thread since only I can approve it):
  1. Assess the diff. Large or high-risk → propose `ultracode`; needs my explicit approval. Ultracode is the **local** workflow orchestration (`xhigh` effort, fans out reviewer subagents that adversarially cross-check each other) — never the separately-billed cloud `/code-review ultra`. Approved → run it in this thread, then go to step 3. Declined, or diff is normal → step 2.
  2. Dispatch the `code-reviewer` subagent for a regular `/code-review` at max effort.
  3. Fix the findings with Sonnet at high effort.
  4. Reverify: dispatch the `code-reviewer` subagent again (also max effort, same as step 2 — there's no separate "high effort" reverify tier now that both passes go through the same pinned subagent).
- A plan/task-pinned `/code-review` effort overrides these; confirm with me before deviating.

## Languages

- Go: `gofmt`/`goimports`; table-driven tests; wrap errors with `%w`.
- TypeScript: prefer `type` over `interface` unless extending; avoid `any`.
- Nix: format with `nixfmt <file>` (per-file) or `nixfmt-tree` (whole repo); bare `nixfmt .` is deprecated.

## Secrets

- Never commit secrets or print them in logs/output; read tokens from the environment or `~/.env`, never hardcode.

## Git & GitHub

- Conventional Commits (`type(scope): imperative mood, concise subject`); split unrelated changes into separate logical commits; no agent attribution (no `Co-Authored-By: Claude` trailer, no "Generated with Claude Code" footer).
- Commit and push each logical change as you finish it, on any branch including `master`/the default branch — never accumulate work into one massive commit or PR. Larger features: open a feature branch and merge each stage into it individually; for sub-items, branch off the feature branch and merge each back individually. Keep the stages clearly separated and documented in commit messages and PR descriptions, so each is reviewable on its own.
- New features or anything that may run alongside other agents: work in a dedicated `git worktree` so parallel agents don't collide (see Parallel Work).
- Feature branches: once work is complete and verified (Code Review sequence passed), autonomously commit, push, and open or update the PR — don't leave finished work uncommitted. You may merge a green, verified PR if prd is untouched.
- Keep history linear: `gh pr merge --rebase` (there is no `--ff` flag); never `--merge` (the `gh` default; creates a 2-parent merge commit) and never `--squash`.
- Remote operations (PRs, issues, reviews, code search): prefer the GitHub MCP server when available, else the `gh` CLI. If a stale `GITHUB_TOKEN` breaks `gh` auth, fall back with `env -u GITHUB_TOKEN gh ...`.

## Parallel Work

- Before fanning out parallel sessions, decompose and partition by non-overlapping file/module ownership; classify each task as independent or dependent on another's output. All sessions share one rate limit — fan out only when tasks are genuinely independent *and* time-critical, otherwise sequence.
- Always base a new worktree/branch on freshly-fetched `origin/<default-branch>`, never local HEAD — `git fetch origin && git worktree add -b feat/x <path> origin/master`. Local `master` goes stale the moment another agent pushes, so branching off it silently forks from an old base and forces avoidable rebases/conflicts at merge.
- Independent, non-overlapping tasks → one `git worktree` per session (see Git & GitHub).
- Dependent or file-overlapping tasks → never run as uncoordinated parallel sessions: sequence them, or run them under a single Opus orchestrator that dispatches Sonnet subagents (Workflow fan-out) and owns merge ordering.
- Shell-mode (`! cmd`) commands run in the session's cwd, so from a worktree every relative path and bare `git` resolves inside that worktree — while tools that resolve a fixed root ignore the worktree entirely (`switch`/`darwin-rebuild` without `--flake` always builds `/etc/nix-darwin`, the main checkout). Before handing me a shell-mode command from a worktree session, pull the main checkout (`git -C <main-checkout> pull`) so it carries the merged commits, and write commands with absolute paths or `git -C <path>` rather than relying on cwd. Otherwise a deploy silently uses stale config and the change just merged looks like a no-op.
- Register every in-flight parallel task in the shared ledger at `$(git rev-parse --git-common-dir)/agent-ledger.md` (shared across all worktrees of the repo, never committed): branch, files/areas touched, status. Read it before starting; if a task would touch files another session owns, don't parallelize — sequence or merge the work.

## Deploys & Cluster Access

- The GitOps flow through dev/tst is pre-approved: PRs to master, merges, `vX.Y.Z` tags. **acc is human-gated** alongside prd — re-pinning `overlays/acc` waits for my review, same as prd. Anything touching prd — `overlays/prd`, prd-suffixed apps/namespaces, prd promotions — always waits for my explicit review.
- `kubectl` and the (read-only) Kubernetes MCP run as the least-privilege `agent-ops` ServiceAccount via the scoped kubeconfig `~/.kube/agent.mlzw.config` (preset as `KUBECONFIG`): cluster-wide read minus Secrets, logs in all workload-hosting namespaces including prd, full write in `sandcastle-dev`/`sandcastle-tst`, bounded pod-delete/scale (`agent-ops-workload-ops` — no content writes) everywhere else including `sandcastle-prd` (#754 — every prd op is apiserver-audited; ask-rules pause prd-touching mutations for my confirmation). prd Secrets, `exec`, and content writes outside dev/tst stay Forbidden — enforced server-side by RBAC + Pod Security Admission. GitOps is the only path that changes desired state; the ops verbs just converge/disrupt toward the committed spec. Never override `KUBECONFIG`/`--kubeconfig` toward the admin config (`admin.mlzw.config`) — break-glass admin access is mine alone.
- `argocd` (CLI and MCP server): `get` everywhere, `sync` + resource actions on all apps including prd (#754 — plain sync converges to committed master only; `update`/`override` are withheld by design as the master-only enforcement). prd-touching argocd commands pause for my confirmation (settings ask-rule); prd *content* changes and promotions (line above) always wait for my explicit review.
