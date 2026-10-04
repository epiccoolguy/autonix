---
name: simple-code
description: Design, implement, refactor, and review simple, idiomatic software. Use for coding tasks, with focused guidance for TypeScript, Python, Go, and Rust.
---

# Simple Code

Prefer direct, local, idiomatic code. Add structure when it removes greater complexity, enforces an invariant, or establishes a needed boundary. Respect intentional repository conventions and the current requirements.

Before choosing the design, read only the relevant references, once per task:

- Routine implementation or review: the matching language guide below.
- Architectural decisions, new abstractions or dependencies, or changes crossing behavioral boundaries: also read [design](reference/design.md).
- Unclear pattern choice or abstraction payoff: read [examples](reference/examples.md).
- Requested lint setup or tightening: read [linting](reference/linting.md).

| Language | Reference |
| --- | --- |
| TypeScript | [TypeScript](reference/typescript.md) |
| Python | [Python](reference/python.md) |
| Go | [Go](reference/go.md) |
| Rust | [Rust](reference/rust.md) |

For mixed-language changes, read each affected guide. For other languages, use the shared principles and repository conventions; do not invent a matching reference. Routine work needs no architecture document, checklist report, or additional approval gate.
