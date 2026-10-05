# Rust

## Data and behavior

- Prefer structs, enums, functions, and inherent `impl` methods. Model closed alternatives as enums handled with `match`, listing every variant of your own enums instead of a `_` arm.
- Protect invariants with private fields and a validated constructor or newtype (`TryFrom`). Typestate is worth its extra types only for an important lifecycle constraint.
- Use traits for needed capabilities, ecosystem integration, or real polymorphism, and reuse standard traits. Use an enum instead of `dyn Trait` when the set is closed.

## Control flow and effects

- Return `Result` for recoverable failures and propagate with `?`, adding context. Follow the project's error crates (e.g. `thiserror` enums in libraries, `anyhow` with `.context(...)` in binaries) rather than adding new ones. Without an error crate, define a small error enum or struct; don't return `&str`/`String` errors. No `unwrap` on input-dependent paths outside tests. Use `expect("why this holds")` only for a proven invariant.
- Prefer a simple `clone` to threading lifetimes through domain structs. `Rc`, `Arc`, and interior mutability need a concrete ownership reason, not silencing the borrow checker.

## Modules and boundaries

- Private by default, then `pub(crate)`, and `pub` only for the real API. Modules follow cohesive boundaries, not one file per type.
- Pass dependencies as arguments or fields set by the caller. No global mutable state.
- Custom macros, sprawling trait bounds, and type-level machinery need benefits exceeding their diagnostic and maintenance cost.
