# Rust

## Data

- Plain structs with `pub` fields when there is no invariant to protect. Use a newtype with `TryFrom` when there is: `struct Email(String)` built only by parsing.
- Closed variants are `enum`s. `match` on your own enums lists every variant; no `_` arm.
- `impl` blocks on your data are idiomatic; keep them to operations on that type.
- Prefer owned types (`String`, `Vec<T>`, `Arc<str>`) and cheap clones over lifetime parameters threaded through domain structs.
- No `Rc<RefCell<_>>` object graphs; restructure ownership (indices, arenas, passing `&mut`) instead.

## Traits

- Generics with trait bounds over `Box<dyn Trait>`. Use `dyn` only for genuinely open sets of types (plugins, heterogeneous collections).
- No single-implementation traits. When the variants are known, use an `enum`.
- `derive` is fine. Don't write your own proc-macro or `macro_rules!` DSL to save typing.

## Errors

- Return `Result<T, E>` and propagate with `?`.
- Libraries: a `thiserror` enum of the failures callers branch on. Binaries: `anyhow::Result` with `.context("load config")` at each propagation step. Use the crate the project already has.
- No `unwrap()` / `expect()` outside tests, except for an invariant the code proves, with an `expect("why this holds")` message.
- `panic!`, `unreachable!`, `todo!` mark bugs or unfinished code; none in finished library code paths.

## Structure

- Default visibility is private; then `pub(crate)`; `pub` only for the crate's real API.
- Cleanup through `Drop` (RAII guards); no manual `close()` calls at the end of a function.
- Modules are files; no `mod.rs` re-export layers for one feature.

## Don't / do

Don't:
```rust
pub trait Notification { fn send(&self, to: &str) -> Result<()>; }
pub fn dispatch(n: Box<dyn Notification>, to: &str) -> Result<()> { n.send(to) }
```
Do:
```rust
pub enum Notification { Email { body: String }, Sms { text: String } }

pub fn dispatch(n: &Notification, to: &str) -> Result<()> {
    match n {
        Notification::Email { body } => send_email(to, body),
        Notification::Sms { text } => send_sms(to, text),
    }
}
```
