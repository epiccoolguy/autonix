# Go

- Prefer concrete structs and functions; use methods for behavior belonging to a type. Constructors may validate invariants or initialize resources; do not require them when a useful zero value or struct literal suffices.
- Define small interfaces at actual consumers, usually in the consuming package. Return concrete types unless the API deliberately provides a polymorphic contract. Reuse standard contracts such as io.Reader. Do not mirror a concrete type's API to enable mocks; a narrow effect seam can be justified by deterministic tests.
- Use explicit error returns, add useful context, and preserve error identity when callers need it. Use defer for scoped cleanup. Handle real I/O failures; do not panic or ignore errors to shorten code.
- Keep packages cohesive and names specific. Keep unexported helpers and types nearby; a file is not a package boundary. Compose structs rather than importing inheritance-style base/service/factory hierarchies.
- Use ordinary loops and control flow when clear. Use function values for simple behavioral variation. Add goroutines/channels for actual concurrency, with clear ownership, cancellation, and shutdown; events alone do not require a channel.
- Go constants and switches do not provide Rust-style closed enums or exhaustiveness; use existing exhaustive-switch checks when useful. Protect meaningful invariants with narrow APIs and boundary validation. Use generics when a genuinely type-independent algorithm or container benefits; one current instantiation is not itself a reason to reject one.
