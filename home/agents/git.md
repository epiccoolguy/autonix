# Git & GitHub

- Use one isolated worktree per subject, then a PR. Reuse a harness-provided worktree for that subject; create new worktrees from freshly fetched `origin/<default-branch>` (never local HEAD). Create a topic branch before committing if the harness starts in detached HEAD. No direct commits or pushes to the default branch.
- Preserve harness-managed worktree locations. For manually created Codex worktrees, use `${CODEX_HOME:-$HOME/.codex}/worktrees/<repo>/<subject>`, not the repository's protected `.codex/` directory. Claude and Gemini use `.claude/worktrees/` and `.gemini/worktrees/` under the main checkout. Ignore repository-local worktree directories; never use another agent's directory.
- Conventional Commits (`type(scope): imperative, concise`); split unrelated changes into separate commits; no Co-Authored-By trailer or generated-with footer.
- Work autonomously end-to-end: once verified, commit, push, open/update the PR, and merge when green.
- Rebase-merge only (`gh pr merge --rebase` or the MCP equivalent); never merge commits or squash.
- Prefer the GitHub MCP server, else the `gh` CLI.
