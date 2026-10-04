# Design

Use the least powerful construct that clearly and correctly expresses the current behavior. Judge the concepts and context a reader must load, not line counts or numbers of implementations. Plain data and functions are a starting point; methods, classes, traits, generics, patterns, and frameworks are useful when their benefits exceed their costs.

## Before implementation

- Read the affected implementation, callers, tests, and repository instructions. Identify the required behavior, invariants, effects, compatibility constraints, and language idioms.
- Choose the simplest concrete solution within the real boundaries: validation, authorization, ownership, transactions, protocols, concurrency, or independent consumers. Reuse existing abstractions when their meaning fits. Do not plan hypothetical extension points.
- Compare the added concepts, files, dependencies, execution paths, and runtime mechanisms with what they remove. Reconsider machinery out of proportion to the requirement. In substantial plans, briefly explain the direct solution and significant new abstractions; reason internally for routine edits.

## During implementation

- Implement the direct solution within required boundaries. Introduce structure as actual complexity emerges. Do not generate unused scaffolding, alternate implementations, plugin hooks, configuration, or generic frameworks.
- Every abstraction should hide, constrain, coordinate, or compress meaningful complexity. A wrapper enforcing authorization, ownership, or validation may be valuable with one consumer. A forwarding service or identity mapper usually is not. Domain semantics and required contracts can justify abstraction before duplication.
- Keep helpers, constants, schemas, and types near their consumer with narrow visibility. Extract a shared concept for independent consumers or a real boundary, and decompose modules when it improves navigation. Prefer cohesive feature organization when the repo permits; avoid technical dumping grounds and files created for symmetry.
- Shape contracts around consumer capabilities, not an implementation's whole API. Place them near consumers when language and dependency rules permit. Reuse standard contracts. A narrow seam around real effects can support deterministic tests with one production implementation; mirroring every type solely for mocks adds ceremony.
- Make important dependencies explicit through parameters, constructors, or a cohesive dependency value wired at an entry point. Keep network, database, filesystem, and process effects recognizable. Separate pure computation from I/O when useful, without imposing domain/application/infrastructure layers.
- Use native collections, iteration, error handling, and resource management. Choose loops, expressions, closures, or composition by clarity. Preserve ordering, cancellation, ownership, and error meaning. Prefer the standard library and existing dependencies when they fit; justify new dependencies by implementation and maintenance benefits.
- Use explicit optionality, discriminated variants, narrow types, and useful immutability to remove invalid combinations. Newtypes or brands need meaningful invariants and controlled construction. Validate untrusted input at real boundaries; do not replace validation with casts or assertions, or move simple logic into difficult type machinery.
- Implement the behavior a pattern provides with native features where they suffice. Preserve required serialization, undo, extensibility, lifecycle, and delivery semantics. Consult [examples](examples.md) when the payoff is unclear.

## Before completion

- Inspect every added or expanded file, module, type, interface/trait, class, function, generic, layer, configuration option, and dependency. Can it be deleted, inlined, made concrete, made private, or colocated without losing useful meaning? Does it enforce an invariant, hide complexity, or establish a needed boundary? Did unrequested behavior enter the diff?
- Apply worthwhile simplifications while preserving security, validation, ownership, error semantics, transactions, concurrency, and compatibility. Run applicable static checks and tests on the final diff; rerun affected checks after edits. Keep routine self-review internal and report material tradeoffs when useful. Do not expand the task into unrelated cleanup or create another approval process.
