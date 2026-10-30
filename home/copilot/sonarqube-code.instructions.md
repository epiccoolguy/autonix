---
name: "SonarQube Instructions"
description: "Checks code changes and commits with SonarQube for IDE, the sonar CLI secrets scan, and the sonarqube MCP server. Use when changing or committing code, reviewing SonarQube findings, or checking issues and quality gates."
---

# SonarQube instructions

Run these checks before committing code changes, whether or not a pull request is planned. CI's SonarQube analysis and Quality Gate remain authoritative.

1. For each changed source file, call `sonarqube_analyzeFile` (SonarQube for IDE), then read its findings with `problems` for that file. Findings arrive asynchronously; if only compiler errors are listed, check again. If the tool is unavailable outside VS Code, skip this step and say so.
2. Run `sonar analyze secrets <changed-files>` to scan the files before committing. Do not assume the global pre-push hook covers repositories with a local `core.hooksPath` (such as Husky).
3. If checks find issues, fix them and repeat until clean, or summarize the remaining findings for the user before committing.
4. If the sonarqube MCP server is available, use `search_sonar_issues_in_projects` to check existing issues in touched files. When reviewing an existing pull request, use `get_project_quality_gate_status` with its PR key from `list_pull_requests`. Find the project key with `sonar list projects -q <repo-name>`; never guess it.
5. Never push with `--no-verify`. Do not exclude files, add allowlist entries, change issue status, or run `sonar remediate` without user approval.
