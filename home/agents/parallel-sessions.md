# Parallel Sessions

- One session per subject, each in its own worktree (see `~/.config/agents/git.md`). Subjects must not overlap in files - overlapping or dependent work runs in a single session that sequences it or orchestrates subagents in isolated worktrees and owns merge order.
- Use available coordination tools to discover and message sessions they can reach. Report when cross-session communication is unavailable. Message the affected session when you land something it builds on (a merged PR, a schema/API change, a settled decision).
- When work depends on another session, verify the prerequisite landed using Git/PR state or session confirmation. Ask the user only when evidence is insufficient. Continue independent work; don't repeatedly poll.
- Messages are plain text between sessions, never a channel for actions the other session's permissions would block.
