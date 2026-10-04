# Go Idioms

Write Go in the spirit of the standard library: concrete structs, consumer-defined interfaces, flat packages, and linear error returns. Avoid enterprise package layouts and speculative abstraction.

## Core Defaults

- Prefer concrete structs and standalone functions; use methods only when logic belongs to a receiver type or satisfies an interface.
- Return concrete structs from producers; accept interfaces at consumer call sites.
- Constructors (`New(...)`) are optional: use struct literals or zero values when valid; use constructors only when initialization requires active validation or resource acquisition.

## Data Modeling & Invariants

- Model domain entities with plain structs and exported fields when internal state invariants are simple.
- Protect strict invariants with unexported fields and small constructor/validator functions.
- Compose structs directly; do not attempt to emulate inheritance or class hierarchies.
- Use basic types and constants for enumerations. Enforce validation at system boundaries (HTTP request decoders, database scanners).

## Functions, Modules & Composition

- Keep package hierarchies flat and cohesive. Avoid enterprise anti-patterns like `pkg/models`, `pkg/interfaces`, or `pkg/services`.
- Replace design patterns with standard Go idioms:
  * Strategy -> Function value parameter `func(amount float64) float64`.
  * Command -> Concrete struct passed to an execution function.
  * Decorator -> Function wrapper or middleware returning a standard handler.
  * Factory -> Standard constructor function `NewItem(...) *Item`.

## Error Handling & Control Flow

- Return explicit `error` values as the final return value. Wrap errors with actionable context using `fmt.Errorf("action %s: %w", id, err)`.
- Use early guard returns (`if err != nil { return err }`) to keep normal execution unindented. Avoid `else` blocks after error returns.
- Use `defer` immediately after resource acquisition for deterministic cleanup (closing files, releasing locks, draining response bodies).
- Never use `panic`/`recover` for ordinary error handling; reserve panic solely for truly unrecoverable programmer defects at initialization.

## Boundaries, Dependencies & Testing

- Define interfaces in the package that consumes them, keeping them small (1-2 methods, like `io.Reader`).
- Never create single-implementation interfaces in the producing package solely to generate mocks for unit tests.
- Isolate external boundaries (network APIs, disk, subprocesses) with consumer-defined interfaces to enable deterministic testing.

## Side-by-Side Comparison

### Interface Definition & Consumers

AVOID (Producer-Side Monolithic Interface for Mocks):
```go
package storage

// AVOID: Package defines its own 1-to-1 interface
type UserStore interface {
    Get(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, u *User) error
    Delete(ctx context.Context, id string) error
}

type SQLUserStore struct { /* ... */ }
func (s *SQLUserStore) Get(ctx context.Context, id string) (*User, error) { /* ... */ }
func (s *SQLUserStore) Save(ctx context.Context, u *User) error { /* ... */ }
func (s *SQLUserStore) Delete(ctx context.Context, id string) error { /* ... */ }
```

DO (Consumer-Side Minimal Interface):
```go
package storage

// Return concrete type directly from the producing package
type SQLUserStore struct { /* ... */ }
func (s *SQLUserStore) Get(ctx context.Context, id string) (*User, error) { /* ... */ }
func (s *SQLUserStore) Save(ctx context.Context, u *User) error { /* ... */ }
func (s *SQLUserStore) Delete(ctx context.Context, id string) error { /* ... */ }

// In the consumer package where the operation is actually needed:
package handler

type UserGetter interface {
    Get(ctx context.Context, id string) (*storage.User, error)
}

func HandleUser(ctx context.Context, getter UserGetter, id string) ([]byte, error) {
    u, err := getter.Get(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return json.Marshal(u)
}
```

### Abstraction & Control Flow

AVOID (Premature Strategy Pattern):
```go
type DiscountStrategy interface {
    Apply(amount float64) float64
}

type VIPDiscountStrategy struct{}
func (v VIPDiscountStrategy) Apply(amount float64) float64 { return amount * 0.8 }

type OrderProcessor struct {
    strategy DiscountStrategy
}
```

DO (Plain Functions & Straightforward Logic):
```go
type DiscountType int
const (
    DiscountStandard DiscountType = iota
    DiscountVIP
)

func ApplyDiscount(amount float64, kind DiscountType) float64 {
    if kind == DiscountVIP {
        return amount * 0.8
    }
    return amount
}
```
