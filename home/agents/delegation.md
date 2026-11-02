# Working with Codex and Mistral Vibe (Claude Code)

Codex and Mistral Vibe are different model families: they catch what you miss in review, and they can implement well-specified slices while you keep the plan. You stay accountable for everything that merges - neither may commit, push, or touch git, GitOps, the cluster, secrets, or sudo.

## Picking the agent and model

For Codex, always pass `--model` with the newest model of the tier (the cache lists newest first):

```bash
jq -r '[.models[] | select(.visibility=="list") | .slug | select(endswith("-sol"))][0]' ~/.codex/models_cache.json
```

Swap `-sol` for `-luna` for the Luna tier. Vibe has no per-call model: it runs `active_model` from `~/.vibe/config.toml` (managed in `home/vibe/config.toml`; unset means Vibe's default), so leave `--model` out of its briefs.

- Codex Sol: reviews, diagnosis, research, and slices needing design judgment.
- Codex Luna or Mistral: well-specified slices. Use Mistral for slices that fit one Vibe run (about 9 minutes, then `--resume`) and whose check only builds and tests locally.

## Delegating implementation

Delegate on your own when a slice of the plan is self-contained, expected to change about 50 lines or more, and you can name its files and a check command up front. Do smaller or cross-cutting edits and judgment calls a brief can't pin down yourself.

- Run it through the `codex:codex-rescue` or `mistral:mistral-rescue` subagent, sequentially in your current worktree, and don't edit while it runs. Commit your own changes first (a WIP commit is fine) so `git status` afterwards shows only the delegate's. Run a slice in parallel (its own `isolation: "worktree"`, based on `origin/<default branch>`) only when it doesn't depend on your unpushed work; you own the merge order.
- Start each new slice with `--fresh`; follow-ups on the same slice use `--resume`. Without either, the subagent may continue the previous thread. A Vibe run that stops at its time limit says so; continue it with `--resume`.
- Mistral write runs have no sandbox and auto-approve every tool call, so "do not commit" is only a request. Keep its slices off anything that deploys, reaches the network, or reads secrets.
- Write the brief like this; for Mistral, drop `--model gpt-6-luna` from the first line:

<example>
--fresh --model gpt-6-luna
Goal: add a `--json` flag to `cmd/report` that prints the report as JSON.
In scope: cmd/report/main.go, cmd/report/main_test.go. Out of scope: everything else.
Done when: `go test ./cmd/report/...` passes and `report --json` emits valid JSON.
Do not commit. Report what changed and what you could not verify.
</example>

For diagnosis (after two failed fix attempts, or when the root cause stays unclear after investigating) and research, run read-only (Codex on Sol, Mistral with `--read-only`) and leave your own hypothesis out of the brief, so the second opinion stays independent.

## Integrating a slice

1. Treat the delegate's report as a claim. Run `git status` and revert its new or changed files outside the brief's scope. After a Mistral slice, also check `git log` and `git reflog` show no new commits, and nothing was pushed.
2. Review the diff against the plan and the surrounding code. Fix small issues yourself; send larger ones back with `--resume` - after 2 rounds, take over.
3. Rerun the checks and commit under the usual conventions. Large diffs also go through `code-reviewer`.

## Reviewing every PR

Before opening or updating any PR, after your own review:

1. From the worktree, run both reviews in parallel as background Bash commands (reviews can outlast the foreground timeout; the `/codex:*` and `/mistral:*` review commands are user-only):
   ```bash
   node ~/.claude/skills/codex/scripts/codex-companion.mjs review --base origin/<default branch> --model <Sol> --wait
   bash ~/.claude/plugins/marketplaces/mistral-plugin-cc/plugins/mistral/scripts/vibe-run.sh review --base origin/<default branch>
   ```
   The Mistral script comes from the plugin marketplace, not nix; if the path is gone, find `vibe-run.sh` under `~/.claude/plugins`.
2. For risky changes (GitOps, auth, secrets, data migrations), also run `adversarial-review` on both: Codex with the same flags plus a sentence on what to challenge, Mistral with `--base` and that sentence as one quoted argument.
3. Fix valid findings and rerun the checks. For each dismissed finding, say why in the PR description; a dismissed P0 or P1 also goes in your final report to the user.
4. Re-review after substantial fixes, at most 2 rounds. Skip the re-review when an update is a pure rebase with no content change.

## When one is unavailable

On a usage limit, auth failure, or outage, don't wait or retry: give its slices to the other or implement them yourself, and note "<Codex|Mistral> review skipped: <reason>" in the PR description. If both are unavailable, review the PR with `code-reviewer` instead.
