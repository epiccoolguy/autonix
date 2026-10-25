# Global Agent Instructions

macOS, but the GNU/Linux userland precedes Apple's BSD tools in `PATH` - assume GNU flags. Commands run in bash 5 (Claude), zsh with bash-like globbing (Codex, Antigravity), or `/bin/bash` 3.2 (Copilot) - write bash that also runs on 3.2. Scripts use `#!/usr/bin/env bash`, never `/bin/bash` (3.2). `docker` is podman.

## Always

- Concise, direct responses; follow intentional repo conventions. Do not copy accidental complexity or expand the task into an architecture rewrite.
- No code comments unless the WHY is non-obvious; no error handling for impossible scenarios.
- Before coding, inspect the existing implementation and choose the simplest direct, local, idiomatic solution to the actual requirements. Keep dependencies and effects visible; introduce structure only for a concrete benefit.
- Prefer deep modules that hide meaningful complexity behind a small public interface; test behavior through that interface. Confirm externally consumed interface changes or breaking changes unless explicitly requested or already approved.
- Plain printable ASCII in responses, code, commits, and docs: `-`, `"`, `'`, `...` instead of em dashes, smart quotes, ellipses, arrows, or decorative symbols.
- For code/config changes, review and simplify the diff: question each added construct and remove unneeded structure and speculative behavior while preserving correctness and real boundaries. Run applicable static checks then tests, fix findings caused by the change, and rerun affected checks. Report failures and skipped checks plainly.
- Secrets: read tokens from the environment or `~/.env`; never print them or write them anywhere else.
- Never change cluster state directly - GitOps only.
- Plans for my review: concise but unambiguous. Use numbered concrete steps, followed by unresolved questions, if any.

## Read before the matching work

- Designing, implementing, refactoring, or reviewing code: `~/.agents/skills/simple-code/SKILL.md`
- Commits, branches, worktrees, PRs, merges: `~/.config/agents/git.md`
- Running alongside other sessions, or depending on another session's work: `~/.config/agents/parallel-sessions.md`
- Toolchains, devShells, flakes, running project tools, configuring a versioned tool, formatting Nix: `~/.config/agents/dev-environments.md`
- Kubernetes, ArgoCD, deploys, promotions, release tags: `~/.config/agents/deploys.md`
- Editing agent instruction files (this one included), skills, or agent memory: `~/.config/agents/instruction-files.md`
