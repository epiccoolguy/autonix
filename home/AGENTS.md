# Global Agent Instructions

macOS, but GNU core tools precede Apple's BSD ones in `PATH` - assume GNU flags. `docker` is podman.

## Always

- Concise, direct responses; follow intentional repo conventions. Do not copy accidental complexity or expand the task into an architecture rewrite.
- No code comments unless the WHY is non-obvious; no error handling for impossible scenarios.
- Before coding, inspect the existing behavior and conventions. Choose the simplest direct, local, language-native solution to the actual requirements. Prefer plain data and functions; add structure only when it removes greater complexity, enforces meaningful invariants, or establishes a real boundary. Keep dependencies and effects visible. Do not build for hypothetical requirements.
- Prefer deep modules that hide meaningful complexity behind a small public interface; test behavior through that interface. Confirm externally consumed interface changes or breaking changes unless explicitly requested or already approved.
- Plain printable ASCII in responses, code, commits, and docs: `-`, `"`, `'`, `...` instead of em dashes, smart quotes, ellipses, arrows, or decorative symbols.
- For code/config changes, review and simplify the diff: question each added construct and remove unneeded structure and speculative behavior while preserving correctness and real boundaries. Run applicable static checks then tests, fix findings caused by the change, and rerun affected checks. Report failures and skipped checks plainly.
- Secrets: read tokens from the environment or `~/.env`; never print them or write them anywhere else.
- Never change cluster state directly - GitOps only.
- Plans for my review: concise but unambiguous. Use numbered concrete steps, followed by unresolved questions, if any.

## Read before the matching work

- Architecture, new modules, layers, polymorphic contracts, generic APIs, extension points, or dependencies: `~/.agents/skills/simple-code/SKILL.md`
- Implementing Go, Rust, Zig, TypeScript/JavaScript, or Python: read the matching `~/.agents/skills/simple-code/reference/go.md`, `~/.agents/skills/simple-code/reference/rust.md`, `~/.agents/skills/simple-code/reference/zig.md`, `~/.agents/skills/simple-code/reference/typescript.md`, or `~/.agents/skills/simple-code/reference/python.md` once per task, before choosing the design. Read only languages being changed.
- Commits, branches, worktrees, PRs, merges: `~/.config/agents/git.md`
- Running alongside other sessions, or depending on another session's work: `~/.config/agents/parallel-sessions.md`
- Toolchains, devShells, flakes, running project tools, configuring a versioned tool, formatting Nix: `~/.config/agents/dev-environments.md`
- Kubernetes, ArgoCD, deploys, promotions, release tags: `~/.config/agents/deploys.md`
- Editing agent instruction files (this one included) or agent memory: `~/.config/agents/instruction-files.md`
