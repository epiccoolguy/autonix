---
description: Run a Mistral Vibe review that challenges the implementation approach and design choices
argument-hint: '[--wait|--background] [--base <ref>] [--scope auto|working-tree|branch] [focus ...]'
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(bash:*), Bash(git:*), AskUserQuestion
---

Run an adversarial, read-only Mistral review. It questions the chosen approach, design choices, tradeoffs, and assumptions - not just implementation defects.

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
- Preserve the user's arguments and focus text exactly; do not weaken the adversarial framing. Quote the focus text as one argument.

Foreground flow:
```typescript
Bash({
  command: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/vibe-run.sh" adversarial-review <flags> "<focus text>"`,
  description: "Mistral adversarial review",
  timeout: 600000
})
```
The `[mistral] ...` lines are progress on stderr; leave them out. Return the review that follows them verbatim, without commentary, and do not fix anything it mentions. If it fails, show the error output (the `mistral:` lines and any Vibe error text) verbatim.

Background flow:
```typescript
Bash({
  command: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/vibe-run.sh" adversarial-review <flags> "<focus text>"`,
  description: "Mistral adversarial review",
  run_in_background: true
})
```
Then tell the user: "Mistral adversarial review started in the background; its shell shows live `[mistral]` progress. You'll be notified when it finishes." When it completes, return the review verbatim, without the progress lines.
