---
description: Run a Mistral Vibe code review against local git state
argument-hint: '[--wait|--background] [--base <ref>] [--scope auto|working-tree|branch]'
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(bash:*), Bash(git:*), AskUserQuestion
---

Run a read-only Mistral review of the current changes.

Raw slash-command arguments:
`$ARGUMENTS`

Core constraint:
- This command is review-only. Do not fix issues, apply patches, or suggest that you are about to make changes.
- Your only job is to run the review and return Mistral's output verbatim.

Execution mode rules:
- If the raw arguments include `--wait`, run in the foreground without asking.
- If the raw arguments include `--background`, run in a Claude background task without asking.
- Otherwise, estimate the review size:
  - Working tree: `git status --short --untracked-files=all`, `git diff --shortstat --cached`, `git diff --shortstat`. Untracked files count as reviewable work.
  - Branch review (`--base` given or a clean tree): `git diff --shortstat <base>...HEAD`.
  - Recommend waiting only when the review is clearly tiny (roughly 1-2 files); otherwise recommend background.
- Then use `AskUserQuestion` exactly once with two options, the recommended one first with ` (Recommended)` appended: `Wait for results`, `Run in background`.

Argument handling:
- Preserve the user's arguments exactly; the script ignores `--wait` and `--background`.
- `/mistral:review` takes no focus text. For custom framing, point the user to `/mistral:adversarial-review`.

Foreground flow:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/vibe-run.sh" review $ARGUMENTS
```
Return stdout verbatim, without commentary, and do not fix anything it mentions. If it fails, show stderr.

Background flow:
```typescript
Bash({
  command: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/vibe-run.sh" review $ARGUMENTS`,
  description: "Mistral review",
  run_in_background: true
})
```
Then tell the user: "Mistral review started in the background. You'll be notified when it finishes." When it completes, return its output verbatim.
