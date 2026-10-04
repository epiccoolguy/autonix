# Design Examples

These are alternatives to consider, not automatic rewrites. First identify the behavior a pattern is providing, then choose the smallest idiomatic construct preserving it.

| Pattern | Often sufficient | Keep more structure when |
| --- | --- | --- |
| Strategy | Function/callback/closure | Behavior has shared state, lifecycle, several related capabilities, or a required framework contract. |
| Command | Direct function for execution; tagged data for deferred work | Commands require persistence, serialization, undo, audit, retry, or scheduling. Closures are not serializable commands. |
| State | Enum/tagged union plus handling | Transitions need substantial behavior, an open set of implementations, or compile-time lifecycle constraints. A union alone does not enforce transitions. |
| Visitor | Pattern matching over closed variants | External types/operations must be extended independently, or an AST/library already supplies a visitor protocol. |
| Iterator | Native iteration, iterator adapters, or generators | Streaming, resource lifetime, backpressure, or a specialized traversal protocol needs an explicit object. Not every language has generators. |
| Decorator | Function composition or existing middleware | Resource ownership, identity, several methods, ordering, or framework metadata must be preserved. |
| Factory | Literal or ordinary constructor/factory function | Selection, validated construction, resource acquisition, or lifecycle actually requires coordination. |
| Builder | Literal/options for independent values | Required sequencing, cross-field validation, staged construction, or an existing public API makes a builder useful. |
| Dependency injection | Explicit arguments/constructors, wired at startup | An established framework's container manages real scope/lifecycle needs. Avoid adding a parallel wiring system. |
| Observer | Existing event/subscription/channel mechanism | Delivery, buffering, cleanup, ordering, or backpressure requires a stronger protocol. A direct call is enough for one synchronous reaction. |
| Adapter | Small boundary function/type | Multiple operations or protocol translation require cohesive state and invariants. A tiny adapter can still be essential. |
| Template Method | Explicit orchestration composed with functions/capabilities | A required framework or stable subclass contract supplies useful lifecycle behavior. |

## TypeScript: behavior variation

For one stateless choice, avoid scaffolding such as:

```typescript
interface DiscountStrategy {
  discount(subtotal: number): number;
}

class NoDiscount implements DiscountStrategy {
  discount(_subtotal: number): number {
    return 0;
  }
}

class PercentDiscount implements DiscountStrategy {
  constructor(private percent: number) {}

  discount(subtotal: number): number {
    return subtotal * this.percent / 100;
  }
}
```

Prefer a callback when it communicates the whole contract:

```typescript
function total(
  prices: readonly number[],
  discount: (subtotal: number) => number,
): number {
  const subtotal = prices.reduce((sum, price) => sum + price, 0);
  return subtotal - discount(subtotal);
}
```

If there is no actual behavioral variation, remove the callback too and call the required calculation directly. If pricing needs maintained state or several related operations, a cohesive object may communicate the contract better.

## TypeScript: valid states

Avoid a record with loading, failed, optional data, and optional error that allows contradictory combinations. Represent only supported combinations:

```typescript
type Load<T> =
  | { kind: "loading" }
  | { kind: "loaded"; value: T }
  | { kind: "failed"; error: Error };
```

Here the generic relates a meaningful payload to reusable state semantics; it need not wait for two instantiations. Use a concrete payload when this is specific to one feature. At external boundaries, parse and validate before assigning this type.

## Rust: closed alternatives

Avoid Box<dyn State> plus separate implementations merely to encode a fixed three-way decision:

```rust
enum Job {
    Queued,
    Running { worker: u32 },
    Failed { reason: String },
}

fn label(job: &Job) -> &str {
    match job {
        Job::Queued => "queued",
        Job::Running { .. } => "running",
        Job::Failed { .. } => "failed",
    }
}
```

For a public, externally extensible provider system, a narrow trait may be the correct boundary. Typestate may be worthwhile if a forbidden lifecycle transition must be rejected at compile time.

## Python: direct collection processing

Avoid a pipeline or strategy framework for filtering a finite collection when a comprehension expresses the operation:

```python
def active_user_emails(users: list[User]) -> list[str]:
    return [user.email for user in users if user.is_active and user.email]
```

User is the existing domain type in this fragment. For unbounded input, use a generator or streaming API with clear resource lifetime. Stateful stages, backpressure, or separate recovery policies can justify a dedicated pipeline; streaming alone does not require a new framework.

## Python: an invariant can justify a class

Avoid factories, validators, and interfaces around one interval when a dataclass can own its ordering invariant:

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Window:
    start: int
    end: int

    def __post_init__(self) -> None:
        if self.end < self.start:
            raise ValueError("end precedes start")

    def contains(self, value: int) -> bool:
        return self.start <= value < self.end
```

The methods enforce and express a concrete concept. Type hints still require runtime validation at untrusted input boundaries.

## Go: a real effect can justify a narrow interface

For a consumer that sends receipts over a network, ask only for the capability it needs:

```go
type receiptSender interface {
    Send(ctx context.Context, recipient string, body []byte) error
}
```

This can isolate network failure in deterministic tests even with one production sender. It does not justify mirroring the provider's full API. A function parameter may suffice for one independent operation.

## Preserve boundaries that earn their cost

- A one-line service that only calls another service adds little; a similarly short surface that checks authorization before storage access enforces a real boundary.
- A repository duplicating a database client's CRUD adds little; one that owns transactionality, tenant scoping, persistence mapping, or aggregate invariants can hide substantial complexity.
- A mapper copying identical trusted fields adds little; an explicit allowlist separating a public response from sensitive internal fields protects a security boundary.
- A tiny shared function combining context detachment with a bounded timeout can encode a correctness rule. Size and forwarding are clues, not proofs of uselessness.
- Keep a helper with its feature rather than starting utils.ts for one call site. Extract it when it expresses a shared concept or makes a genuine boundary clearer; a long file can also justify cohesive decomposition.
