# Global Agent Instructions

macOS, but GNU core tools precede Apple's BSD ones in `PATH` - assume GNU flags. `docker` is podman.

## Always

- Concise, direct responses; match the repo's existing conventions over generic best practices.
- Confirm externally consumed interface changes or breaking changes unless explicitly requested or already approved.
- Plain printable ASCII in responses, code, commits, and docs: `-`, `"`, `'`, `...` instead of em dashes, smart quotes, ellipses, arrows, or decorative symbols.
- For code/config changes, review the diff, run applicable static checks then tests, fix findings caused by the change, and rerun affected checks. Report failures and skipped checks plainly.
- Secrets: read tokens from the environment or `~/.env`; never print them or write them anywhere else.
- Never change cluster state directly - GitOps only.
- Plans for my review: concise but unambiguous. Use numbered concrete steps, followed by unresolved questions, if any.

## Code

Write code the way idiomatic Go, Rust, and Zig read: plain data and functions, explicit control flow, errors as values - translated into each language's idioms, never transplanted. An existing repo's conventions win over these rules.

- Data first: plain structs/records; closed variant sets as sum types matched exhaustively, so illegal states can't be built.
- Parse untrusted input once at the boundary into precise types; code inside trusts them and doesn't re-validate.
- Functions over classes; no inheritance. Methods on data are fine where the language puts them (Go, Rust, Zig).
- No interface type, trait object, abstract base, or factory until two implementations exist (a test fake counts only at a process or I/O boundary); declare it at the consumer.
- Dependencies are explicit parameters: no DI containers, service locators, or mutable globals.
- Expected failures are in the signature (error return, `Result`, union, or a narrow documented exception where that is the idiom); panics/asserts only for bugs. Never swallow an error; add context when propagating. No handling for impossible cases.
- Guard clauses and early returns; nesting depth at most 3.
- Cleanup sits next to acquisition: `defer`, `using`, `with`, RAII.
- No speculative generality: no unused params, options, hooks, config, or layers "for later".
- Helpers and types stay in the file that uses them until a second consumer exists; inline single-use helpers unless the name captures a domain concept.
- Prefer deep modules: small public API, tests against that API.
- Standard library first; state the reason for each new dependency.
- Domain names; no `Manager`, `Helper`, `Util`, `Factory`, `Impl`, `Base`.
- Comments explain why, never what; omit them when the why is obvious.
- Minimal diff: only what the task needs, no drive-by refactors.
- Non-trivial work: plan data types, signatures, and failure modes before code.
- Before designing, writing, or reviewing non-trivial code, read `~/.agents/skills/simple-code/SKILL.md` and the language file it names.

## Read before the matching work

- Commits, branches, worktrees, PRs, merges: `~/.config/agents/git.md`
- Running alongside other sessions, or depending on another session's work: `~/.config/agents/parallel-sessions.md`
- Toolchains, devShells, flakes, running project tools, configuring a versioned tool, formatting Nix: `~/.config/agents/dev-environments.md`
- Kubernetes, ArgoCD, deploys, promotions, release tags: `~/.config/agents/deploys.md`
- Editing agent instruction files (this one included) or agent memory: `~/.config/agents/instruction-files.md`
