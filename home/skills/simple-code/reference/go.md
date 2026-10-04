# Go

## Data and behavior

- Prefer concrete structs and functions; use methods for behavior belonging to a type. Use a useful zero value or struct literal when possible, and constructors for invariants or resources.
- Define small interfaces at actual consumers, usually in the consuming package. Return concrete types unless the API deliberately supplies a polymorphic contract. Reuse standard contracts such as io.Reader.
- Constants and switches do not provide native tagged unions or compiler-enforced exhaustiveness. Protect invariants with narrow APIs and boundary validation; use existing exhaustive-switch checks where useful.

## Control flow and effects

- Prefer ordinary loops and direct calls. Use function values for simple variation and generics for genuinely type-independent algorithms or containers.
- Return and check errors explicitly, adding useful context and preserving identity when callers need it. Use defer for scoped cleanup; do not panic or ignore errors to shorten code.
- Add goroutines/channels for actual concurrency, with clear ownership, cancellation, and shutdown.

## Modules and boundaries

- Keep packages cohesive, names specific, and unexported helpers nearby; a file is not a package boundary.
- Avoid interfaces mirroring concrete APIs solely for mocks. A narrow seam around real effects can justify an interface with one production implementation.
