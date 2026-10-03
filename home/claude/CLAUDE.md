# Global Instructions

@~/AGENTS.md

## Claude Code

- Plan inline by default - think it through and proceed without a mode switch. Enter plan mode only when the change genuinely warrants my sign-off: exiting plan mode always requires my interactive approval.
- Never use ultraplan (cloud plan refinement) - plan locally only.
- Review scaled to the diff: small -> review it yourself in-thread; large or risky -> dispatch the `code-reviewer` subagent. Suggest I run `/code-review` when a deeper pass is warranted; never suggest `/code-review ultra` unless I explicitly ask.
- Subagents: at most 8 per task, and no more than 4 running at once. Anything larger needs my go-ahead.
- Anything that needs a browser (interactive pages, logins, web app testing, visual checks) goes through Claude in Chrome (`mcp__claude-in-chrome__*`) by default - not Playwright/puppeteer scripts and not handing it back to me. Plain content fetches still use WebFetch.
