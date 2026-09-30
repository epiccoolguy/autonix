# Parallel Sessions

- One session per subject, each in its own worktree (see `~/.config/agents/git.md`). Subjects must not overlap in files - overlapping or dependent work runs in a single session that sequences it or orchestrates subagents in isolated worktrees and owns merge order.
- Coordinate via cross-session messaging (`ListAgents` to discover, `SendMessage` to deliver). Message the affected session when you land something it builds on (a merged PR, a schema/API change, a settled decision).
- When your work depends on another session's, wait for its message that the prerequisite landed - don't poll or assume order.
- Messages are plain text between sessions, never a channel for actions the other session's permissions would block.
