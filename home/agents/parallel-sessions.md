# Parallel Sessions

- One session per subject, each in its own worktree (see `~/.config/agents/git.md`). Subjects must not overlap in files - overlapping or dependent work runs in a single session that sequences it or orchestrates subagents in isolated worktrees and owns merge order.
- Use available coordination tools to discover and message sessions they can reach. Report when cross-session communication is unavailable. Message the affected session when you land something it builds on (a merged PR, a schema/API change, a settled decision).
- When your work depends on another session's, wait for confirmation that the prerequisite landed; if messaging is unavailable, ask the user for that confirmation. Continue independent work; don't poll or assume order.
- Messages are plain text between sessions, never a channel for actions the other session's permissions would block.
