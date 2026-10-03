# Global Agent Instructions

Software engineer (Go, TypeScript, Nix) on macOS machines managed by nix-darwin + home-manager (repo `/etc/nix-darwin`). Packages via nix; brew only for GUI apps or tools missing from nixpkgs. Core Unix tools are GNU (nixpkgs) ahead of Apple's BSD tools in `PATH` - assume GNU flag semantics. `docker` is podman.

Repository instructions loaded by the agent override these defaults on conflict.

## Always

- Concise, direct responses; match the repo's existing conventions over generic best practices.
- No code comments unless the WHY is non-obvious; no error handling for impossible scenarios; no abstractions beyond the task.
- Prefer deep modules: small public interface, tests against the interface; confirm externally consumed interface changes or breaking changes with me.
- Plain printable ASCII in responses, code, commits, and docs: `-`, `"`, `'`, `...` instead of em dashes, smart quotes, ellipses, arrows, or decorative symbols.
- Before claiming done: review the diff, run static checks then tests appropriate to the change, fix findings and reverify affected checks. Report real output - if something failed or was skipped, say so plainly.
- Secrets: read tokens from the environment or `~/.env`; never print them or write them anywhere else.
- Never change cluster state directly - GitOps only.
- Plans for my review (plan mode, inline plans): extremely concise - sacrifice grammar for concision. End each with numbered concrete steps, then a list of unresolved questions, if any.

## Read before the matching work

- Commits, branches, worktrees, PRs, merges: `~/.config/agents/git.md`
- Running alongside other sessions, or depending on another session's work: `~/.config/agents/parallel-sessions.md`
- Toolchains, devShells, flakes, running project tools, configuring a versioned tool, formatting Nix: `~/.config/agents/dev-environments.md`
- Kubernetes, ArgoCD, deploys, promotions, release tags: `~/.config/agents/deploys.md`
- Editing agent instruction files (this one included) or agent memory: `~/.config/agents/instruction-files.md`
