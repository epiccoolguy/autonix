# Communication

## Sync or async

Decide per operation, in this order:

1. **No consumer beyond the caller:** a plain synchronous write. Do not publish an event nobody consumes; events exist only where a consumer does.
2. **Completion gates something you do not mediate** (authentication, authorization, a third party acting on the result) **or rejection must be immediate:** synchronous.
3. **Otherwise, when another component must react, or the work is slow, external, or failure-prone:** validate synchronously, execute asynchronously. The handler checks authorization, schema, and invariants (reads only), publishes, and returns 202 with the idempotency key. A 202 then means "this will happen", not "this may be rejected later". When acceptance depends on contended state (uniqueness, stock, quota), reads cannot promise that: reserve atomically before the 202, or accept that the consumer may reject and expose that status.

Async is not free: every read path gains a pending state, and a dead-lettered request needs a visible status. Do not go async to make a handler feel faster.

## Delivery

- Assume at-least-once delivery. Every consumer is idempotent, keyed on a stable message or request id; redelivery is the retry mechanism.
- An HTTP handler that both commits a row and publishes is a dual write with no redelivery behind it. Removing the dual write - validate, publish only, and let the consumer write - is simpler than adding an outbox.
- A consumer that writes then publishes, acking last, is safe only if a redelivered message re-runs the publish after its idempotent write turns into a no-op. A handler that short-circuits on "already processed" loses the event; there, use an outbox.
- Bound retries with backoff and route exhausted messages to a dead-letter path that someone is alerted on and can replay.
- Large payloads go by reference (claim check), not through the broker.

## Messages

- **Event:** a fact that happened, past tense, owned by the emitter, any number of consumers. **Command:** a request for one owner to do something. Do not disguise a command as an event to avoid naming the dependency.
- One envelope standard and one schema format for the whole system. Version the contract, not each field; consumers are tolerant readers (ignore unknown fields, treat enums as open).
- Every message carries: id, type and version, source component, actor (see actors), trace context, and time.

## Reads across components

- Default to a synchronous read from the owner.
- Materialize a local projection only when the call is too slow, too frequent, crosses an availability boundary, or many components need the same data. A projection is derived and must be rebuildable from its source.
- Never write to another component's store.

## Alternatives

| Reaching for | Often sufficient | Keep more structure when |
| --- | --- | --- |
| Event per write | Plain sync write | A consumer exists now. |
| Saga / workflow engine | Chain of idempotent consumers, each publishing the next fact | Compensation across many steps must be tracked and visible. |
| Outbox | Publish-only edge; consumer writes | A handler must both commit and publish atomically. |
| Event sourcing | Current-state tables plus append-only facts where history matters | Rebuilding state from events is itself a requirement. |
| Polling for status | 202 with key, then read the entity | Clients cannot read the entity, or work can dead-letter (then a status resource is required). |
