---
name: simple-code
description: Rules for simple, explicit code (Go/Rust/Zig style - plain data, functions, errors as values, minimal abstraction) with per-language guides for TypeScript, Python, Go, Rust, and Zig. Use when designing, planning, writing, refactoring, or reviewing code in any language.
---

# Simple Code

Write code the way idiomatic Go, Rust, and Zig read. Translate each rule into the language's own idiom; never transplant syntax (no fake `Result` in Go or Python). An existing repo's conventions win over these rules.

Before writing code, read the file for the language you are editing:
`reference/typescript.md`, `reference/python.md`, `reference/go.md`, `reference/rust.md`, `reference/zig.md`.
No reference file for the language: apply the rules below in that language's own idiom.
For non-trivial work, plan first with `reference/planning.md`.
Read `lint/<language>.md` only when asked to set up or tighten linting.

## Design

1. **Data first.** Model the data as plain structs, records, or types before writing behavior. No getters or setters on plain data; expose fields.
2. **Closed variants are sum types, matched exhaustively.** Tagged union, enum, or discriminated union. When matching your own enum, no catch-all arm that handles unknown variants at runtime, so adding a variant breaks the build. An arm whose only job is to prove exhaustiveness (`assert_never`, a `never` check) is fine.
3. **One state field, not several booleans.**
   Don't: `{ isLoading: boolean; error?: string; data?: User }`
   Do: `{ status: "loading" } | { status: "error"; error: string } | { status: "ok"; data: User }`
4. **Parse at the boundary.** Untrusted input (HTTP, files, env, CLI) is parsed once into a precise type; code past the boundary takes that type and does not re-validate.
   Don't: `function sendInvite(email: string)` re-checking `email.includes("@")`.
   Do: `parseEmail(raw): Email | ParseError` at the edge, `sendInvite(email: Email)` inside.
5. **Functions over classes; no inheritance.** Operations are functions taking data. Methods on data are fine where the language puts them (Go, Rust, Zig, Python dataclass methods). No base classes for code reuse.
6. **Replace patterns with plain constructs.**
   - Strategy -> function parameter.
   - Command -> tagged union handled by one function.
   - Decorator -> function that takes and returns a function.
   - Factory -> constructor function returning a struct.
   - Builder -> struct literal with defaults.
7. **No interface type until two implementations exist.** Applies to interfaces, traits used as objects, abstract bases, protocols. A test fake counts only for a process or I/O boundary (network, disk, clock, cloud API). Declare the interface in the consuming code, with only the methods it calls.
8. **Dependencies are parameters.** Pass the db handle, clock, allocator, or client into the function that needs it. No DI containers, service locators, singletons, or mutable globals.
9. **Immutable by default.** `const`, `readonly`, frozen dataclasses, `let` without `mut`. Mutating a local inside one function is fine when it reads more simply than a copy chain.

## Control flow

10. **Guard clauses and early returns.** Handle the failure or edge case first and return; the happy path stays unindented. No `else` after a `return`.
11. **Nesting depth at most 3** inside a function body. Extract a named function or invert a condition instead.
12. **Expected failures are in the signature.** Error return, `Result`, error union, or discriminated union - or, where exceptions are the idiom (Python), a narrow documented exception. Panics, asserts, and `unreachable` are for bugs only.
13. **Never swallow an error; add context when propagating.**
    Don't: `catch { return null }`, `except Exception: pass`, `_ = f()`.
    Do: `return fmt.Errorf("load config %s: %w", path, err)`.
14. **No handling for impossible cases.** If the types rule a case out, don't check for it. If an invariant could break, assert it rather than inventing a fallback.
15. **No boolean flag parameters that switch behavior.** Split the function.
    Don't: `render(doc, true)`. Do: `renderDraft(doc)` and `renderFinal(doc)`.
16. **No hidden control flow.** No custom decorators, metaclasses, reflection, monkey-patching, or macros that change what a call does. Allowed where the idiom requires them: `@dataclass`, `@property`, pytest fixtures, framework route decorators, Rust `derive`.
17. **Cleanup sits next to acquisition.** `defer`, `errdefer`, `using`, `with`, RAII. Never a cleanup call at the bottom of a long function.

## Structure

18. **Colocate.** Helpers and types live in the file that uses them until a second consumer exists. New features start in one file; split when a file passes ~400 lines or holds clearly separate runtime concerns (transport vs storage).
19. **Inline single-use helpers** unless the name captures a domain concept the caller benefits from reading.
20. **Flat layout.** No `models/`, `services/`, `repositories/`, `interfaces/`, `handlers/` layers for one feature, unless the repo already uses them.
21. **No `utils`, `helpers`, or `common` files or packages.** Put the function next to its caller or in a module named for its domain.
22. **Standard library first.** A new dependency needs a stated reason in the plan or PR (what it saves, why std isn't enough).
23. **No speculative generality.** No unused parameters, options, config keys, hooks, generic type parameters, or extension points. Every abstraction must be used by at least two concrete paths in the current change.
24. **Domain names.** Name things after what they are in the problem domain. Banned suffixes: `Manager`, `Helper`, `Util`, `Factory`, `Impl`, `Base`, `Processor`, `Handler` (unless it is an HTTP handler).

## Process

25. **Plan before non-trivial code**: data types, function signatures, failure modes. See `reference/planning.md`.
26. **Minimal diff.** Change only what the task needs. No drive-by renames, reformatting, or refactors; mention them as follow-ups instead.
27. **Comments explain why, never what.** Omit them when the why is obvious from the code.
28. **Test through the public API.** No mocking of your own internals; fakes only at process or I/O boundaries.
29. **Delete dead code your change creates**: unused functions, imports, parameters, and types.
30. **Deep modules.** Small public API, substantial implementation behind it. Export the minimum; keep everything else private to the file or package.
