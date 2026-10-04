# Rust

## Data and behavior

- Prefer structs, enums, functions, and inherent `impl` methods. Use `Option` for absence. Model closed alternatives as enums handled with `match`, listing every variant of your own enums instead of a `_` arm so a new variant fails to compile.
- Protect invariants with private fields and a validated constructor or newtype (`TryFrom`). Typestate is worth its extra types only for an important lifecycle constraint.
- Use traits for needed capabilities, ecosystem integration, or real polymorphism, and reuse standard traits. Choose generics/`impl Trait` or `dyn Trait` by actual dispatch and storage needs; use an enum instead of `dyn` when the set is closed.

## Control flow and effects

- Choose iterator chains or loops by clarity: chains for transformations, loops for stateful or sequential work.
- Return `Result` for recoverable failures and propagate with `?`, adding context. Follow the project's error crates (e.g. `thiserror` enums in libraries, `anyhow` with `.context(...)` in binaries) rather than adding new ones. No `unwrap` on input-dependent paths outside tests. Use `expect("why this holds")` only for a proven invariant, and `panic!` only for bugs.
- Borrow or move deliberately. A simple `clone` can be clearer than threading lifetimes through domain structs. `Box`, `Rc`, `Arc`, and interior mutability need a concrete ownership reason, not silencing the borrow checker. Use `Drop`/RAII for cleanup.

## Modules and boundaries

- Private by default, then `pub(crate)`, and `pub` only for the real API. Modules follow cohesive boundaries, not one file per type.
- Pass dependencies as arguments or fields set by the caller. No global mutable state.
- `derive` and established library macros reduce ceremony. Custom macros, sprawling trait bounds, and type-level machinery need benefits exceeding their diagnostic and maintenance cost.
