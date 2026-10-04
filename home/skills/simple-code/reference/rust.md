# Rust Idioms

Write pragmatic Rust: concrete types over trait gymnastics, flat enums over OOP hierarchies, explicit error handling with `?`, and cheap cloning before complex lifetime puzzles.

## Core Defaults

- Prefer plain structs and enums with inherent `impl` blocks over generic traits.
- Use `enum` and exhaustive `match` for closed variants. Do not reach for `Box<dyn Trait>` when variants are known at compile time.
- Prefer explicit ownership or cheap clones (`Clone`, `Arc<str>`, `String`) over propagating complex lifetime parameters (`'a, 'b`) across domain models.

## Data Modeling & Invariants

- Use structs with public fields for passive data holding; protect strict invariants with private fields and validated constructors (`fn new(...) -> Result<Self, Error>`).
- Represent distinct domain states using tagged enums rather than boolean flags or polymorphic class structures.
- Rely on standard traits (`Clone`, `Debug`, `PartialEq`, `Serialize`) via `#[derive]`.

## Functions, Modules & Composition

- Organize code into cohesive file-level modules. A module boundary defines encapsulation; do not create one file per type.
- Replace textbook design patterns with Rust idioms:
  * Strategy -> Function pointer, closure `F: Fn(&Data) -> bool`, or concrete enum.
  * Command -> Enum representing actions processed by an executor function.
  * Builder -> Direct struct literals with `Default::default()`, reserving custom builders only for complex multi-stage runtime construction.
  * Factory -> Standard `new` constructor or conversion traits (`From`/`Into`).

## Error Handling & Control Flow

- Use `Result<T, E>` and `Option<T>` for fallible operations, propagated cleanly with the `?` operator.
- In libraries, use `thiserror` to define strongly typed domain error enums. In applications and binaries, use `anyhow::Result` for ergonomic error context.
- Never use `unwrap()` or `expect()` on input that can fail in production; handle failures explicitly or propagate them.
- Leverage RAII and `Drop` for automatic resource cleanup (locks, file descriptors, channels).

## Boundaries, Dependencies & Testing

- Define traits only when shared behavior spans multiple open-ended types or when defining an explicit seam for external I/O (network, database).
- Use generics (`T: Trait`) or `impl Trait` when static dispatch is desired; use `dyn Trait` only when heterogeneous storage or dynamic dispatch is genuinely necessary.
- Test against concrete in-memory implementations before creating mock-only traits.

## Side-by-Side Comparison

### Polymorphism & Domain State

AVOID (Trait Objects & Abstract Factory Emulation):
```rust
pub trait Notification {
    fn send(&self, recipient: &str) -> Result<(), Error>;
}

pub struct EmailNotification { pub body: String }
impl Notification for EmailNotification {
    fn send(&self, recipient: &str) -> Result<(), Error> { /* ... */ Ok(()) }
}

pub struct SmsNotification { pub message: String }
impl Notification for SmsNotification {
    fn send(&self, recipient: &str) -> Result<(), Error> { /* ... */ Ok(()) }
}

pub fn dispatch(notif: Box<dyn Notification>, to: &str) -> Result<(), Error> {
    notif.send(to)
}
```

DO (Flat Tagged Enum & Match):
```rust
pub enum Notification {
    Email { body: String },
    Sms { message: String },
}

pub fn dispatch(notif: &Notification, recipient: &str) -> Result<(), Error> {
    match notif {
        Notification::Email { body } => send_email(recipient, body),
        Notification::Sms { message } => send_sms(recipient, message),
    }
}
```

### Data Construction & Lifetimes

AVOID (Over-Engineered Builder & Lifetime Spaghetti):
```rust
pub struct RequestBuilder<'a, T> {
    endpoint: &'a str,
    payload: Option<&'a T>,
}

impl<'a, T> RequestBuilder<'a, T> {
    pub fn new(endpoint: &'a str) -> Self { Self { endpoint, payload: None } }
    pub fn with_payload(mut self, payload: &'a T) -> Self {
        self.payload = Some(payload);
        self
    }
}
```

DO (Direct Struct Literal & Owned Types):
```rust
pub struct Request<T> {
    pub endpoint: String,
    pub payload: Option<T>,
}

// Instantiate directly at caller:
let req = Request {
    endpoint: "/api/v1/orders".into(),
    payload: Some(order),
};
```
