---
name: simple-code
description: Design and review simple, local, idiomatic software. Use for architectural decisions, new abstractions, and implementation or simplification in Go, Rust, Zig, TypeScript, JavaScript, Python, and other languages.
---

# Simple Code

Prefer direct, local, language-native solutions to current requirements. Added structure should remove greater complexity, enforce meaningful invariants, or establish a real boundary. These are defaults, not bans on classes, interfaces, functional code, duplication, patterns, or frameworks. Follow intentional repository conventions and stay within the task.

Read only relevant guidance, once per task and before choosing the design:

- Architecture, new modules, layers, polymorphic contracts, generic APIs, extension points, or dependencies: [design and implementation](reference/planning.md).
- Implementing or reviewing Go: [Go](reference/go.md).
- Implementing or reviewing Rust: [Rust](reference/rust.md).
- Implementing or reviewing Zig: [Zig](reference/zig.md).
- Implementing or reviewing TypeScript or JavaScript: [TypeScript and JavaScript](reference/typescript.md).
- Implementing or reviewing Python: [Python](reference/python.md).
- Other languages: apply the shared philosophy using that language's native idioms and the repository's conventions.
- Unclear pattern choice or abstraction payoff: [examples and exceptions](reference/examples.md).
- Only when asked to set up or tighten linting: the matching lint/go.md, lint/rust.md, lint/typescript.md, or lint/python.md. Check the project's installed versions; do not add lint configuration automatically.

Before completion, simplify the diff while preserving correctness and meaningful boundaries. Routine changes need no architecture document, checklist report, or extra approval gate.
