# Global Agent Instructions

Software engineer (Go, TypeScript, Nix) on macOS machines managed by nix-darwin + home-manager (repo `/etc/nix-darwin`). Packages via nix; brew only for GUI apps or tools missing from nixpkgs. Core Unix tools are GNU (nixpkgs) ahead of Apple's BSD tools in `PATH` - assume GNU flag semantics. `docker` is podman.

Repository instructions loaded by the agent override these defaults on conflict.

## Always

- Concise, direct responses; match the repo's existing conventions over generic best practices.
- No code comments unless the WHY is non-obvious; no error handling for impossible scenarios; no abstractions beyond the task.
- Prefer deep modules: small public interface, tests against the interface. Confirm externally consumed interface changes or breaking changes unless explicitly requested or already approved.
- Plain printable ASCII in responses, code, commits, and docs: `-`, `"`, `'`, `...` instead of em dashes, smart quotes, ellipses, arrows, or decorative symbols.
- For code/config changes, review the diff, run applicable static checks then tests, fix findings caused by the change, and rerun affected checks. Report failures and skipped checks plainly.
- Secrets: read tokens from the environment or `~/.env`; never print them or write them anywhere else.
- Never change cluster state directly - GitOps only.
- Plans for my review: concise but unambiguous. Use numbered concrete steps, followed by unresolved questions, if any.

## Read before the matching work

- Commits, branches, worktrees, PRs, merges: `~/.config/agents/git.md`
- Running alongside other sessions, or depending on another session's work: `~/.config/agents/parallel-sessions.md`
- Toolchains, devShells, flakes, running project tools, configuring a versioned tool, formatting Nix: `~/.config/agents/dev-environments.md`
- Kubernetes, ArgoCD, deploys, promotions, release tags: `~/.config/agents/deploys.md`
- Editing agent instruction files (this one included) or agent memory: `~/.config/agents/instruction-files.md`
