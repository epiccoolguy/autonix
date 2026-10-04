# Design

Use the least powerful construct that clearly and correctly expresses the current behavior. Judge the concepts and context a reader must load, not line counts or numbers of implementations. Each default below names when more structure is right.

## Before implementation

- Read the affected implementation, callers, tests, and repository instructions. Identify the required behavior, invariants, effects, compatibility constraints, and language idioms.
- Start from the simplest concrete solution within the real boundaries: validation, authorization, ownership, transactions, protocols, concurrency, independent consumers. Reuse an existing abstraction when its meaning fits, not merely its shape.
- Compare what added machinery introduces (concepts, files, dependencies, execution paths, runtime mechanisms) with what it removes. In a substantial plan, state the direct solution and one concrete reason per significant new abstraction. Reason internally for routine edits.

## Defaults

- **Plain data and functions.** Use methods, classes, traits, generics, or patterns when they make ownership, invariants, lifecycle, or required polymorphism clearer.
- **Abstractions earn their cost.** Each one should hide, constrain, coordinate, or compress real complexity. A wrapper enforcing authorization, ownership, or validation can be worth it with one consumer; a forwarding service or identity mapper usually isn't. Domain semantics and required contracts can justify an abstraction before any duplication.
- **Concrete and local first.** Keep helpers, constants, schemas, and types near their consumer with narrow visibility. Extract when independent consumers share a concept, a real boundary needs it, or decomposition improves navigation. No technical dumping grounds or files created for symmetry. No unused scaffolding, alternate implementations, hooks, configuration, or plugin systems.
- **Contracts at the consumer.** Shape them around the capabilities the consumer calls, near it where the language allows, reusing standard contracts. A narrow seam around real effects can support deterministic tests with one production implementation; mirroring every type for mocks cannot.
- **Explicit dependencies and effects.** Pass dependencies as parameters, constructors, or one cohesive value wired at the entry point. Keep network, database, filesystem, and process effects recognizable. Separate pure computation from I/O when useful, without imposing domain/application/infrastructure layers.
- **Native mechanisms.** Use the language's collections, iteration, error handling, and resource management, choosing loops, expressions, closures, or composition by clarity. Preserve ordering, cancellation, ownership, and error meaning. Use the standard library and existing dependencies first; a new dependency needs a concrete benefit that outweighs its maintenance cost.
- **Valid states.** Use explicit optionality, discriminated variants, narrow types, and useful immutability to rule out invalid combinations. Newtypes or brands need a real invariant and controlled construction. Validate untrusted input at real boundaries; never replace validation with casts, and don't move simple logic into difficult type machinery.
- **Patterns by behavior.** Implement what a pattern provides with native features when they suffice, keeping required serialization, undo, extensibility, lifecycle, and delivery semantics. See [examples](examples.md) when the payoff is unclear.

## Before completion

- Check every added or expanded file, module, type, interface/trait, class, function, generic, layer, option, and dependency:
  - Can it be deleted, inlined, made concrete, made private, or moved next to its only consumer without losing meaning?
  - Does it enforce an invariant, hide complexity, or establish a needed boundary?
  - Did unrequested behavior enter the diff?
- Apply worthwhile simplifications while preserving security, validation, ownership, error semantics, transactions, concurrency, and compatibility. Then run applicable checks and tests on the final diff, and rerun affected ones after edits. Keep routine self-review internal; report material tradeoffs when useful. Don't expand into unrelated cleanup or another approval process.
