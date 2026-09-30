# Git & GitHub

- Every change goes through its own `git worktree` on a branch from freshly fetched `origin/<default-branch>` (never local HEAD), then a PR. No direct commits or pushes to the default branch.
- Conventional Commits (`type(scope): imperative, concise`); split unrelated changes into separate commits; no Co-Authored-By trailer or generated-with footer.
- Work autonomously end-to-end: once verified, commit, push, open/update the PR, and merge when green.
- Rebase-merge only (`gh pr merge --rebase` or the MCP equivalent); never merge commits or squash.
- Prefer the GitHub MCP server, else the `gh` CLI.
