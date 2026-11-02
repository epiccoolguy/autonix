#!/usr/bin/env bash
# The Codex plugin's SessionEnd hook only stops the broker for the session's own cwd, so
# brokers started from worktrees outlive them (openai/codex-plugin-cc#380). Stop those
# whose worktree is gone.
pgrep -f 'app-server-broker\.mjs serve' | while read -r pid; do
  cwd=$(ps -o command= -p "$pid" | sed -n 's/.* --cwd \(.*\) --pid-file .*/\1/p')
  if [ -n "$cwd" ] && [ ! -d "$cwd" ]; then
    kill "$pid"
  fi
done
exit 0
