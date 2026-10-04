# Simple Design

Use the least powerful language-native construct that clearly and correctly expresses the design. Judge total complexity for readers, callers, tests, and operations, not line count or abstraction count. A small interface hiding substantial complexity is valuable; several forwarding layers are not.

These are defaults, not bans on classes, interfaces, functional code, duplication, patterns, or frameworks. Existing contracts, safety, ownership, performance requirements, and intentional architecture can justify more structure. Stay within the task; do not rewrite unrelated architecture.

## Before implementation

- Read the affected behavior, callers, tests, and applicable repo instructions. Identify the required behavior, invariants, effects, and compatibility constraints before selecting a structure.
- Start with the simplest concrete solution. Identify actual complexity and boundaries: validation, authorization, ownership, transactions, protocols, lifetimes, concurrency, or independent consumers. Reuse an existing abstraction when its meaning fits, not merely its shape.
- Compare added machinery with what it removes. Consider the concepts, files, dependency directions, execution paths, and runtime mechanisms needed to understand or change one behavior. If these grow out of proportion to the requirement, reconsider the design before coding.
- In a substantial plan, briefly state the direct solution and the concrete reason for each significant new boundary or abstraction. A few sentences within the existing numbered plan suffice. For routine changes, reason internally and proceed; do not add design documents, approval gates, or architecture checklists.

## During implementation

- Implement the direct solution within required boundaries first. Add structure as concrete complexity emerges; do not generate unused scaffolding, plugin hooks, configuration, alternate implementations, or generalized frameworks.
- Default to plain data, functions, cohesive modules, native collections and iteration, and native error handling. Prefer the standard library and existing dependencies when they fit; new dependencies need a concrete benefit that accounts for maintenance cost. Use methods, classes, interfaces, traits, and wrappers when they make ownership, invariants, behavior, lifecycle, or required polymorphism clearer.
- Prefer readable statements and direct calls. Use loops, expressions, iterators, closures, or composition according to clarity and language idiom. Do not hide sequential effects inside clever pipelines or split one readable operation into tiny forwarding functions.
- Keep helpers, constants, schemas, and types with their consumer, with the narrowest useful visibility. Move them when independent consumers share the same concept, a real boundary warrants it, or the module becomes harder to navigate. Prefer cohesive feature organization to global technical buckets when the repo permits; do not introduce generic utils/common/shared/types dumping grounds or reorganize a repo for symmetry.
- Start concrete. Extract the smallest common concept after evidence from use, repeated change, or established domain semantics. Similar-looking code with different reasons to change need not share an abstraction. Repetition is evidence, not a required quota.
- Every abstraction should hide, constrain, coordinate, or compress meaningful complexity. Forwarding services, one-method wrappers, one-implementation interfaces, single-type factories/generics, base classes with one subclass, CRUD repositories, identity mappers, and one-plugin systems warrant scrutiny, not automatic deletion. A named pattern is not a justification.
- Shape contracts around the capabilities consumers need, not an implementation's whole API. Place them near consumers when the language and dependency rules support it. Prefer existing standard contracts. A small seam around real I/O can support deterministic tests even with one production implementation; mirroring every class solely for mocks does not justify an interface layer.
- Make important dependencies explicit through parameters, constructors, or a small cohesive dependency value wired at an entry point. Avoid hidden mutable globals, service locators, and unnecessary DI containers. Keep network, database, filesystem, and process effects recognizable. Separate pure computation from I/O when this clarifies behavior; do not create ceremonial domain/application/infrastructure layers.
- Use enums/unions, explicit optionality, narrow types, and useful immutability to remove invalid combinations. Use newtypes/brands and controlled construction when they enforce a meaningful invariant. Validate untrusted data at real boundaries. Do not replace runtime validation with casts, or relocate simple logic into difficult type machinery.
- Use language features to implement the needed behavior before assembling textbook pattern machinery. Preserve required serialization, undo, extensibility, lifecycle, ordering, cancellation, and ownership semantics. Consult [examples and exceptions](examples.md) when the idiomatic form or an abstraction's payoff is unclear.

## Before declaring completion

Inspect every new or expanded file, module, type, interface/trait, class, function, generic, layer, configuration option, and dependency in the diff.

- Can it be deleted, inlined, made concrete, made private, or colocated with its only consumer without losing useful meaning or increasing reader effort?
- What complexity does this abstraction hide, constrain, coordinate, or compress? Does this wrapper enforce an invariant, this contract represent a real capability or boundary, and this layer do useful work?
- Are genericity, visibility, extension points, configuration, and dependencies needed for current requirements? Did any unrequested behavior or scaffolding enter the change?
- Could direct code make the behavior easier to follow? Preserve security, validation, resource ownership, error semantics, transactions, concurrency, compatibility, and meaningful boundaries.

Apply worthwhile simplifications, then run the required checks on the final diff. Re-run affected checks after subsequent edits. Keep the pass internal for routine changes; report material retained tradeoffs when they help review. Do not turn simplification into unrelated cleanup or demand a report for every construct.
