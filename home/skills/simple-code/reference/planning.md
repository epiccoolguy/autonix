# Simple Design & Planning

Express required behavior using the least powerful language-native construct that remains clear and maintainable. Judge total system complexity for callers, tests, and future maintainers, not raw line count or abstraction count. A small interface hiding substantial complexity is valuable; forwarding layers and speculative wrappers are not.

These principles are defaults against accidental complexity, not dogmatic bans on classes, interfaces, functional idioms, patterns, or frameworks. Existing contracts, safety, resource ownership, and verified architecture can justify structure. Stay within the scope of the task; do not rewrite unrelated architecture.

## Pre-Coding Sanity Protocol (The 3-Step Filter)

Before generating code or introducing abstractions, run these 3 checks:

1. "Can this be a single file or cohesive module?"
   Default to implementing logic directly in the caller's file or a single cohesive module. Reject directory sprawl (`models/`, `services/`, `handlers/`, `interfaces/`) for a single task. Split only when a file exceeds ~400 lines or addresses distinct runtime domains (e.g. transport vs storage engine).

2. "Can this be a plain function taking plain data?"
   Do not introduce a class or struct with mutable internal state if a stateless function accepting input data and returning output or a result type suffices.

3. "Does this abstraction earn its keep for current requirements?"
   Verify whether every interface, generic type parameter, or wrapper layer is actively consumed by at least two distinct concrete paths or establishes a necessary boundary (e.g. I/O seam, transaction scope, security check). If not, delete the abstraction and write concrete code.

## Planning & Implementation Workflow

### 1. Before Implementation

- Inspect existing behavior, callers, tests, and repo conventions. Identify required behavior, invariants, side effects, and compatibility constraints before selecting a structure.
- Start with the simplest concrete design. Identify actual domain boundaries: validation, authorization, resource ownership, transactions, protocols, lifetimes, or concurrency.
- In substantial plans, state the direct solution and the concrete justification for any significant new boundary or abstraction in a few numbered sentences. For routine changes, reason internally and proceed without ceremony.

### 2. During Implementation

- Implement the direct solution first. Add structure only as concrete complexity emerges; never generate speculative scaffolding, plugin hooks, configuration switches, or unused generic helpers.
- Default to plain data, functions, cohesive modules, native collections, and native error handling. Prefer standard library and existing project dependencies.
- Keep helpers, types, and schemas colocated with their caller at the narrowest useful visibility. Move them only when independent callers share the exact same domain concept.
- Shape interfaces around consumer capabilities, not implementation APIs. Define contracts near consumers. A small seam around external I/O (network, disk, subprocess) is justified for deterministic testing; mirroring internal classes solely for mocks is not.
- Make dependencies and side effects explicit. Pass dependencies via arguments or constructors wired at startup. Avoid hidden globals, service locators, and unnecessary DI containers.

### 3. Before Declaring Completion (Simplification Pass)

Inspect every newly added file, module, type, class, function, interface, and dependency in the diff:

- Can it be deleted, inlined, made concrete, made private, or colocated without losing clarity or safety?
- Does every abstraction hide, constrain, or coordinate meaningful complexity?
- Did any unrequested behavior, generic machinery, or speculative scaffolding enter the diff?
- Could direct code make the control flow easier to trace while preserving correctness, validation, concurrency safety, and error semantics?

Apply worthwhile simplifications, then run the required static checks and tests on the final diff.
