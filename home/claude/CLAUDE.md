# Global Instructions

@~/AGENTS.md

## Claude Code

- Plan inline by default — think it through and proceed without a mode switch. Enter plan mode only when the change genuinely warrants my sign-off: exiting plan mode always requires my interactive approval.
- Never use ultraplan (cloud plan refinement) — plan locally only.
- Review scaled to the diff: small → review it yourself in-thread; large or risky → dispatch the `code-reviewer` subagent. The bundled `/code-review` skill is user-invocable only — never attempt to invoke it; suggest I run it (or `/code-review ultra`) when a deeper pass is warranted. Never escalate to ultracode or workflow reviews unless I explicitly ask.
