# Code Design & Architecture

Apply the low-ceremony, pragmatic ethos of Go, Rust, and Zig across all languages. Prevent architectural slop: no speculative interfaces, redundant wrappers, or premature OOP hierarchies.

## Core Axioms

1. Data-Oriented Modeling:
   - Separate data from behavior. Model entities as plain data types (structs, records, type aliases) without internal state machines, getters, setters, or lifecycle hooks.
   - Operations are standalone functions taking data in and returning new data out: `(Data) -> Result<Data, Error>`.
   - Avoid mutable class state encapsulating business logic. State machines belong in explicit tagged unions/enums passed between pure functions.

2. Errors as Plain Values:
   - Handle errors inline as values. Avoid throwing exceptions for normal control flow, business validations, or expected domain conditions.
   - Use early guard clauses (`if (err) return ...;`) to keep happy paths unindented. Avoid nested `try/catch` or `else` pyramids.
   - Preserve error context cleanly with explicit error types or wrappers; do not swallow errors or catch generic root exceptions.

3. Colocation & Simplicity Thresholds:
   - Single-file baseline: Write new features in a single file first. Only split when the file exceeds ~400 lines or spans clearly distinct runtime domains (e.g. HTTP transport vs storage engine).
   - Rule of Three: Keep helper functions private and colocated directly adjacent to their call site. Never extract a shared "common" or "util" package until identical logic is needed in 3 independent locations.
   - Interface Budget: Never create an interface with only one concrete implementation. Do not create interfaces for mock-only testing unless crossing a remote process/hardware boundary (e.g. cloud API, disk). Define interfaces at consumer call sites, not producer packages.

4. Functions & Modules Over OOP Hierarchy:
   - A file or package is a module. Use plain module exports rather than singleton classes, service classes, or static utility classes.
   - Replace OOP design patterns:
     * Strategy pattern -> Plain function or callback passed as an argument.
     * Command pattern -> Tagged union/enum parsed by an executor function.
     * Decorator pattern -> Plain function wrapper `fn wrap(inner: Fn) -> Fn`.
     * Factory pattern -> Plain constructor function returning a struct `fn new(...) -> Item`.
     * Builder pattern -> Struct literal with default fields, unless constructing complex runtime-checked inputs across many stages.

## Agent Planning Protocol (Pre-Coding Sanity Check)

Before writing or proposing code changes, run these 3 sequential checks:

1. "Can this be a single file?"
   Default to keeping the implementation in the caller's file or a single dedicated module. Reject directory sprawl (`models/`, `services/`, `handlers/`, `interfaces/`) for a single task.

2. "Can this be a plain function taking plain data?"
   Do not introduce a `class` or struct with mutable internal fields if a function taking input arguments and returning an output or `Result` suffices.

3. "Does this introduce an abstraction for an imagined future requirement?"
   Verify whether every interface, generic type parameter, config hook, or wrapper layer is consumed by at least two distinct concrete paths in the current pull request. If not, delete the abstraction and write concrete code.
