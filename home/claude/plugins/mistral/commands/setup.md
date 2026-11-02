---
description: Check whether the local Mistral Vibe CLI is installed and signed in
allowed-tools: Bash(vibe:*), Bash(command:*)
---

Check that Mistral Vibe is ready for `/mistral:review` and `/mistral:rescue`:

1. Run `command -v vibe && vibe --version`. If it is missing, tell the user to install the `mistral-vibe` Homebrew formula and stop.
2. Run a smoke test: `vibe --trust --max-turns 1 --enabled-tools read_file -p "Reply with the single word: ready"`.
3. If it prints `ready`, report that Vibe is ready and which model is active (`active_model` in `~/.vibe/config.toml`).
4. If it fails with an auth error, tell the user to run `! vibe --setup` to sign in with their Mistral account or API key.
