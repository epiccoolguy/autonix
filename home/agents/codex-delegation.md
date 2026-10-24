# Working with Codex (Claude Code)

Codex is a different model family: it catches what you miss in review, and it can implement well-specified slices while you keep the plan. You stay accountable for everything that merges - Codex never commits, pushes, or touches git, GitOps, the cluster, secrets, or sudo.

## Picking the model

Always pass `--model` with the newest model of the tier (the cache lists newest first):

```bash
jq -r '[.models[] | select(.visibility=="list") | .slug | select(endswith("-sol"))][0]' ~/.codex/models_cache.json
```

Swap `-sol` for `-luna` for the Luna tier. Sol: reviews, diagnosis, research, and slices needing design judgment. Luna: well-specified slices.

## Delegating implementation

Delegate on your own when a slice of the plan is self-contained, expected to change about 50 lines or more, and you can name its files and a check command up front. Do smaller or cross-cutting edits and judgment calls a brief can't pin down yourself.

- Run it through the `codex:codex-rescue` subagent, sequentially in your current worktree, and don't edit while it runs. Commit your own changes first (a WIP commit is fine) so `git status` afterwards shows only Codex's. Run a slice in parallel (its own `isolation: "worktree"`, based on `origin/<default branch>`) only when it doesn't depend on your unpushed work; you own the merge order.
- Start each new slice with `--fresh`; follow-ups on the same slice use `--resume`. Without either, the subagent may continue the previous thread.
- Write the brief like this:

<example>
--fresh --model gpt-6-luna
Goal: add a `--json` flag to `cmd/report` that prints the report as JSON.
In scope: cmd/report/main.go, cmd/report/main_test.go. Out of scope: everything else.
Done when: `go test ./cmd/report/...` passes and `report --json` emits valid JSON.
Do not commit. Report what changed and what you could not verify.
</example>

For diagnosis (after two failed fix attempts, or when the root cause stays unclear after investigating) and research, run read-only on Sol and leave your own hypothesis out of the brief, so the second opinion stays independent.

## Integrating a slice

1. Treat Codex's report as a claim. Run `git status` and revert Codex's new or changed files outside the brief's scope.
2. Review the diff against the plan and the surrounding code. Fix small issues yourself; send larger ones back with `--resume` - after 2 rounds, take over.
3. Rerun the checks and commit under the usual conventions. Large diffs also go through `code-reviewer`.

## Reviewing every PR

Before opening or updating any PR, after your own review:

1. From the worktree, run as a background Bash command (reviews can outlast the foreground timeout; the `/codex:*` review commands are user-only):
   ```bash
   node ~/.claude/skills/codex/scripts/codex-companion.mjs review --base origin/<default branch> --model <Sol> --wait
   ```
2. For risky changes (GitOps, auth, secrets, data migrations), also run `adversarial-review` with the same flags plus a sentence on what to challenge.
3. Fix valid findings and rerun the checks. For each dismissed finding, say why in the PR description; a dismissed P0 or P1 also goes in your final report to the user.
4. Re-review after substantial fixes, at most 2 rounds. Skip the re-review when an update is a pure rebase with no content change.

## When Codex is unavailable

On a usage limit, auth failure, or outage, don't wait or retry: implement slices yourself, review the PR with `code-reviewer` instead, and note "Codex review skipped: <reason>" in the PR description.
