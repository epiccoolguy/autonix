# Git & GitHub

- Use one isolated worktree per subject, then a PR. Reuse a harness-provided worktree for that subject; fetch `origin` before creating a worktree. Create a topic branch before committing if the harness starts in detached HEAD. No direct commits or pushes to the default branch.
- Preserve harness-managed worktree locations. For manually created Codex worktrees, use `${CODEX_HOME:-$HOME/.codex}/worktrees/<repo>/<subject>`, not the repository's protected `.codex/` directory; Gemini uses `.gemini/worktrees/` under the main checkout. Ignore repository-local worktree directories; never use another agent's directory.
- Conventional Commits (`type(scope): imperative, concise`); split unrelated changes into separate commits.
- Work autonomously end-to-end: once verified, commit, push, and open/update the PR; merge when green unless the harness forbids merging (e.g. background jobs).
- When pushing a rebased published topic branch, use `git push --force-with-lease=<branch>:<expected-commit>`, with the remote branch commit recorded before rebasing. Never use plain `--force` or force-push the default branch.
- Rebase-merge only (`gh pr merge --rebase` or the MCP equivalent); never merge commits or squash.
- Prefer the GitHub MCP server, else the `gh` CLI.
