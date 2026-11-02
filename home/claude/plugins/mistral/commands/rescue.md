---
description: Delegate investigation, an explicit fix request, or follow-up rescue work to the Mistral rescue subagent
argument-hint: "[--background|--wait] [--resume|--fresh] [--read-only] [what Mistral should investigate, solve, or continue]"
allowed-tools: Bash(bash:*), AskUserQuestion, Agent
---

Invoke the `mistral:mistral-rescue` subagent via the `Agent` tool (`subagent_type: "mistral:mistral-rescue"`), forwarding the raw user request as the prompt.
`mistral:mistral-rescue` is a subagent, not a skill - do not call `Skill(mistral:mistral-rescue)` or `Skill(mistral:rescue)` (that re-enters this command).
The final user-visible response must be Mistral's output verbatim.

Raw user request:
$ARGUMENTS

Execution mode:
- `--background`: run the subagent in the background. `--wait` or neither: foreground. Do not forward these two flags.
- If the request includes `--resume` or `--fresh`, the user already chose; do not ask.
- Otherwise check for a resumable Mistral task in this repository:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/vibe-run.sh" last-session
```
- If it prints a session id, use `AskUserQuestion` exactly once: `Continue current Mistral session` or `Start a new Mistral session`. Put continue first with ` (Recommended)` when the request is a follow-up ("continue", "keep going", "apply the top fix", "dig deeper"); otherwise put new first. Add `--resume` or `--fresh` accordingly.
- If it prints nothing, route as a fresh task.

Operating rules:
- The subagent is a thin forwarder; do not ask it to inspect files or do follow-up work.
- Vibe has no per-call model or effort flag: drop `--model`/`--effort` and tell the user the model comes from `~/.vibe/config.toml`.
- If the request is empty, ask what Mistral should investigate or fix.
- If Vibe is missing or unauthenticated, tell the user to run `/mistral:setup`.
