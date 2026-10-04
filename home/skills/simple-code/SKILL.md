---
name: simple-code
description: Designs, implements, and reviews simple, idiomatic code. Use when writing or refactoring TypeScript, Python, Go, or Rust; when adding abstractions, interfaces, classes, generics, layers, or dependencies; when choosing a design pattern; or when reviewing a diff for unnecessary complexity.
---

# Simple Code

Prefer direct, local, idiomatic code. Add structure when it removes greater complexity, enforces an invariant, or establishes a needed boundary. Respect intentional repository conventions and the current requirements.

Before choosing the design, read only what applies, once per task:

- Implementation or review: the matching language guide below.
- Architectural decisions, new abstractions or dependencies, or changes crossing behavioral boundaries: also [design](reference/design.md).
- Unclear pattern choice or abstraction payoff: [examples](reference/examples.md).
- Requested lint setup or tightening: [linting](reference/linting.md).

| Language | Guide |
| --- | --- |
| TypeScript | [typescript](reference/typescript.md) |
| Python | [python](reference/python.md) |
| Go | [go](reference/go.md) |
| Rust | [rust](reference/rust.md) |

For mixed-language changes, read each affected guide. For other languages, apply the same principles in that language's idioms and the repository's conventions.

Before declaring completion, check each construct the diff adds or expands: delete, inline, make concrete, make private, or move it next to its only consumer unless it enforces an invariant, hides real complexity, or marks a needed boundary. Remove unrequested behavior. Routine work needs no design document, checklist report, or extra approval.
