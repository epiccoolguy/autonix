# Go Idioms

Write Go in the spirit of the standard library: small interfaces defined at consumer sites, flat packages, exported concrete structs, and linear error returns.

## Rules

- Accept interfaces, return structs. Never define an interface in the same package that provides the implementation.
- Zero mock-only interfaces: do not create `type Service interface` solely to generate mocks for unit tests. Test against real in-memory implementations or test servers.
- Keep packages flat. Avoid Java-esque `pkg/models`, `pkg/interfaces`, or `pkg/services` circular dependency structures.
- Return explicit `error` values. Wrap with context via `fmt.Errorf("action %s: %w", id, err)`. Guard clauses with immediate returns; no `else` branches after `if err != nil`.

## Side-by-Side Comparison

### Interface Definition & Consumers

AVOID (Producer-Side Single-Implementation Interfaces):
```go
package storage

// AVOID: Package defines its own 1-to-1 interface
type UserStore interface {
    Get(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, u *User) error
}

type SQLUserStore struct { /* ... */ }
func (s *SQLUserStore) Get(ctx context.Context, id string) (*User, error) { /* ... */ }
func (s *SQLUserStore) Save(ctx context.Context, u *User) error { /* ... */ }
```

DO (Consumer-Side Minimal Interface):
```go
package storage

// Return concrete type directly
type SQLUserStore struct { /* ... */ }
func (s *SQLUserStore) Get(ctx context.Context, id string) (*User, error) { /* ... */ }
func (s *SQLUserStore) Save(ctx context.Context, u *User) error { /* ... */ }

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

AVOID (Premature Strategy / Provider Pattern):
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
