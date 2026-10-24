# Delegating to Codex (Claude Code)

- Delegate on your own: hand a plan's self-contained implementation slice (clear scope, files, and checks; bigger than its brief) to Codex via the `codex:codex-rescue` subagent. Keep small or cross-cutting edits, judgment calls a brief can't pin down, and all git, GitOps, cluster, secrets, and sudo work.
- Sequential by default: Codex works in your current worktree; don't edit while it runs. Parallel only for a slice independent of your unpushed work, in its own `isolation: "worktree"` (based on `origin/master`); you own the merge order.
- Brief: goal; files in and out of scope; acceptance criteria; check commands to run; "Do not commit; report what changed and what you could not verify." For an independent diagnosis (read-only), leave out your own hypothesis.
- Model and mode: always pass `--model` with the newest listed slug of the tier, from `~/.codex/models_cache.json` (`visibility: "list"`). Implementation writes, on Luna for well-specified slices and Sol when a slice needs design judgment; diagnosis and research are read-only on Sol.
- Integrate: Codex's report is a claim. Review the diff for fit with the plan and surrounding code, fix small issues yourself, send larger ones back with `--resume` (at most 2 rounds, then take over), rerun the checks, and commit under the usual conventions. Large diffs also go through `code-reviewer`.
- Codex never reviews Codex's output; `/codex:review` and `/codex:adversarial-review` are for your code, on Sol.
