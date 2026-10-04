# Go

Most rules are already Go idiom; this file covers where agents drift.

## Data

- Exported concrete structs with exported fields. Make zero values useful. No `GetX()` getters; name accessors `X()` when one is needed at all.
- Enums are a named type plus `iota` constants. `switch` over them covers every constant (enforced by the `exhaustive` linter).
- Closed variants that carry data: a sealed interface (unexported marker method) plus a type switch, only when an enum with fields doesn't fit.

## Interfaces

- Accept interfaces, return structs. Define the interface in the consumer package with only the methods it calls; never in the package that implements it.
- No interface only for mocking, except at process or I/O boundaries. Otherwise test against real in-memory implementations or `httptest`.
  ```go
  // package profile (the consumer), not package storage
  type userGetter interface {
      Get(ctx context.Context, id string) (storage.User, error)
  }
  ```

## Errors

- Return `error` as the last value; check it immediately with a guard; no `else` after `if err != nil { return ... }`.
- Wrap with context: `fmt.Errorf("get user %s: %w", id, err)`. Start the message with the operation, not "failed to".
- Sentinel errors (`var ErrNotFound = errors.New(...)`) or typed errors only when callers branch on them with `errors.Is` / `errors.As`.
- `panic` only for programmer errors. Never let a panic cross a package API.
- Never `_ =` an error without a comment saying why it is safe.

## Structure

- Flat packages named for what they provide. No `util`, `common`, `models`, `interfaces`, or `services` packages.
- No `init()`. No package-level mutable variables; pass dependencies (db, logger, clock) as parameters or struct fields set by the caller.
- `ctx context.Context` is the first parameter of anything that does I/O.
- `defer` the cleanup on the line after a successful acquire.
- Table-driven tests through the exported API.

## Don't / do

Don't:
```go
type DiscountStrategy interface{ Apply(float64) float64 }
type vipDiscount struct{}
func (vipDiscount) Apply(a float64) float64 { return a * 0.8 }
```
Do:
```go
func applyDiscount(amount float64, tier Tier) float64 {
    if tier == TierVIP {
        return amount * 0.8
    }
    return amount
}
```
