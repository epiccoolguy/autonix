# Global Agent Instructions

macOS, but GNU core tools precede Apple's BSD ones in `PATH` - assume GNU flags. `docker` is podman.

## Always

- Concise, direct responses; match the repo's existing conventions over generic best practices.
- No code comments unless the WHY is non-obvious; no error handling for impossible scenarios; no abstractions beyond the task.
- Code design: Data first, minimal ceremony. Plain data structures, pure functions, modules over OOP classes. Linear control flow; errors as values with early return guards. Colocate helpers until 3+ callers exist.
- Interface budget: Strict ban on single-implementation interfaces, speculative wrappers, and factory abstractions. Define interfaces at the consumer call-site only when 2+ concrete implementations exist right now.
- 3-step pre-coding check: (1) Can this be a single file? (2) Can this be a plain function taking plain data? (3) Does this introduce an abstraction for an imagined future requirement? If 3 is yes, eliminate it.
- Prefer deep modules: small public interface, tests against the interface. Confirm externally consumed interface changes or breaking changes unless explicitly requested or already approved.
- Plain printable ASCII in responses, code, commits, and docs: `-`, `"`, `'`, `...` instead of em dashes, smart quotes, ellipses, arrows, or decorative symbols.
- For code/config changes, review the diff, run applicable static checks then tests, fix findings caused by the change, and rerun affected checks. Report failures and skipped checks plainly.
- Secrets: read tokens from the environment or `~/.env`; never print them or write them anywhere else.
- Never change cluster state directly - GitOps only.
- Plans for my review: concise but unambiguous. Use numbered concrete steps, followed by unresolved questions, if any.

## Read before the matching work

- Designing, writing, or refactoring code architecture: `~/.config/agents/code-design.md`
- Writing or refactoring Go: `~/.config/agents/languages/go.md`
- Writing or refactoring Rust: `~/.config/agents/languages/rust.md`
- Writing or refactoring TypeScript: `~/.config/agents/languages/typescript.md`
- Writing or refactoring Zig: `~/.config/agents/languages/zig.md`
- Commits, branches, worktrees, PRs, merges: `~/.config/agents/git.md`
- Running alongside other sessions, or depending on another session's work: `~/.config/agents/parallel-sessions.md`
- Toolchains, devShells, flakes, running project tools, configuring a versioned tool, formatting Nix: `~/.config/agents/dev-environments.md`
- Kubernetes, ArgoCD, deploys, promotions, release tags: `~/.config/agents/deploys.md`
- Editing agent instruction files (this one included) or agent memory: `~/.config/agents/instruction-files.md`
