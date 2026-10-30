---
description: "Use when preparing a pull request, reviewing code changes, or checking SonarQube findings and quality gates."
---

# SonarQube pre-push checks

Before pushing code changes for a pull request:

- Use the SonarQube MCP server to identify the repository's linked project and review findings relevant to the changed code. Do not guess project keys.
- Run `sonar analyze agentic --base <base-ref>` when the project and server support local change analysis. Report unsupported or unavailable checks as not run.
- If analysis finds blocking issues, summarize them and pause before pushing unless the user asks to proceed.
- Let the Sonar CLI pre-push hook scan unpushed commits for secrets. Do not bypass it with `--no-verify`.
- Treat CI's SonarQube Quality Gate as authoritative; local analysis does not replace it.
- Do not change quality gates, suppress findings, or invoke remediation without user approval.
