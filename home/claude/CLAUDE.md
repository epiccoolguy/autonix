# Global Instructions

@~/AGENTS.md

## Claude Code

- Plan inline by default - think it through and proceed without a mode switch. Enter plan mode only when the change genuinely warrants my sign-off: exiting plan mode always requires my interactive approval.
- Never use ultraplan (cloud plan refinement) - plan locally only.
- Review scaled to the diff: small -> review it yourself in-thread; large or risky -> dispatch the `code-reviewer` subagent. The bundled `/code-review` skill is user-invocable only - never attempt to invoke it; suggest I run it when a deeper pass is warranted. Never escalate to ultracode or workflow reviews unless I explicitly ask.
- Keep dynamic workflows small: at most 8 subagents total, and no more than 4 running at once. Anything larger needs my go-ahead.
- Anything that needs a browser (interactive pages, logins, web app testing, visual checks) goes through Claude in Chrome (`mcp__claude-in-chrome__*`) by default - not Playwright/puppeteer scripts and not handing it back to me. Plain content fetches still use WebFetch.

## Superpowers

The rules in these files win over the `superpowers` skills on conflict.

- Use `superpowers:systematic-debugging` for any bug or unexpected behavior, `superpowers:test-driven-development` for features and fixes in repos that have tests, `superpowers:verification-before-completion` before claiming done, `superpowers:receiving-code-review` when acting on review feedback, and `superpowers:writing-plans` / `superpowers:executing-plans` for multi-step work I asked to be planned - save plans in `docs/plans/`, not `docs/superpowers/plans/`.
- Skip the ones that re-litigate settled defaults: `superpowers:brainstorming` (I plan inline), `superpowers:requesting-code-review` (review is scaled to the diff), `superpowers:finishing-a-development-branch` (I merge autonomously), and `superpowers:using-git-worktrees` / `superpowers:subagent-driven-development` / `superpowers:dispatching-parallel-agents` (use plain `git worktree` per `~/.config/agents/git.md` and the subagent caps above).
