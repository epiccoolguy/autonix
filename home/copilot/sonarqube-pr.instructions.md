---
description: "Checks changed code with SonarQube before a pull request is pushed, using SonarQube for IDE analysis, the sonar CLI secrets scan, and the sonarqube MCP server. Use when preparing or pushing a pull request, reviewing code changes, or investigating SonarQube issues, security hotspots, or quality gates."
---

# SonarQube checks before pushing a PR

These checks catch problems before a CI run; CI's SonarQube analysis and Quality Gate stay authoritative.

1. For each changed source file, call `sonarqube_analyzeFile` (SonarQube for IDE), then read its findings with `problems` for that file. Findings arrive asynchronously; if only compiler errors are listed, check again. If the tool is unavailable (outside VS Code), skip this step and say so.
2. From the repository root, run `sonar analyze --base <base-branch> --format json`. It scans the branch's changes for secrets. If `agentic` reports 403, Vortex is not licensed on the connection: report it as unavailable, not as a failure of the change.
3. Fix the reported issues and repeat steps 1-2 until clean, or stop and summarize the remaining issues for the user before pushing.
4. If the sonarqube MCP server is available, use its `search_sonar_issues_in_projects` tool for existing issues in touched files, and after the PR exists, `get_project_quality_gate_status` with the PR key from `list_pull_requests`. Find the project key with `sonar list projects -q <repo-name>`; never guess it.
5. Never push with `--no-verify`. In repositories with a local `core.hooksPath` (Husky), the global Sonar pre-push hook does not run, so step 2 is the only local secrets check.
6. Do not exclude files, add allowlist entries, change issue status, or run `sonar remediate` without user approval.
