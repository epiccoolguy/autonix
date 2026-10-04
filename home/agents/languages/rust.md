# Rust Idioms

Write pragmatic Rust: concrete types over trait gymnastics, flat enums over OOP hierarchies, explicit error handling with `?`, and cheap cloning before complex lifetime puzzles.

## Rules

- Use `enum` for polymorphism over closed sets of types. Do not reach for `Box<dyn Trait>` when variants are known at compile time.
- Prefer explicit ownership or cheap clones (`Clone`, `Arc<str>`, `String`) over propagating generic lifetime parameters (`'a, 'b`) across domain structs.
- Only define traits when shared behavior spans multiple open-ended types. No single-implementation traits.
- Use `Result<T, E>` with the `?` operator. In libraries use `thiserror` for concrete domain error variants; in binaries/tools use `anyhow::Result`.

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
