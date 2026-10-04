# Go

## Data and behavior

- Prefer concrete structs and functions, with methods for behavior that belongs to a type. Use a useful zero value or struct literal when possible. Write a constructor only to validate invariants or acquire resources. Compose structs; no base, service, or factory hierarchies.
- Define small interfaces in the consuming package, holding only the methods it calls. Return concrete types unless the package deliberately offers a polymorphic contract. Reuse standard contracts such as `io.Reader`.
- Model closed alternatives as a named type with constants. The compiler doesn't check switch exhaustiveness, so use the `exhaustive` linter where the repo has it. Use a sealed interface with a type switch only when variants carry different data. Protect invariants with unexported fields and validation at the boundary.

## Control flow and effects

- Prefer ordinary loops and direct calls. Use function values for simple variation, and generics for genuinely type-independent algorithms or containers.
- Return `error` last and check it immediately with a guard. Wrap with context, `fmt.Errorf("load config %s: %w", path, err)`; use sentinel or typed errors only when callers branch with `errors.Is` or `errors.As`. `panic` only for programmer errors, and never discard an error without a comment saying why.
- `defer` the cleanup on the line after a successful acquire. `ctx context.Context` is the first parameter of anything that does I/O. Start goroutines only for actual concurrency, with clear ownership, cancellation, and shutdown.

## Modules and boundaries

- Keep packages cohesive and named for what they provide; no `util`, `common`, or `models` packages. Keep unexported helpers nearby; a file is not a package boundary.
- Pass dependencies as parameters or struct fields set by the caller. No `init()` side effects or package-level mutable state.
- Don't mirror a concrete API in an interface only for mocks. A narrow seam around real effects (network, disk, clock) can justify an interface with one production implementation.
