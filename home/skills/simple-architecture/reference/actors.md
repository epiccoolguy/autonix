# Actors

The goal: for any irregular effect, answer who asked for it, which component did it, on whose authority, and in which request - from durable records, not by reconstructing from memory.

## Identity

- One identity provider for humans; one credential per component per environment for infrastructure (database role, broker user, storage key). Never share a credential between components; it erases attribution.
- Validate tokens at every component that acts on them. A component trusts identity it verified, not a field a caller asserted.

## Propagation

Every request and message carries:

- **Principal:** the human or external client the work is ultimately for, namespaced by kind (for example `user:<sub>`, `service:<name>`, `job:<name>`).
- **Executor:** the component doing the work. On a hop, the receiver records the caller's authenticated identity (token subject, broker user, mTLS name), not only the principal the caller claims.
- **Trace context:** W3C `traceparent` across HTTP and messages, so one trace id links the whole chain.
- **Idempotency or request key**, where one exists.

A principal field on a message is an assertion by the publisher. Make it trustworthy by restricting who may publish (broker permissions) and by recording the authenticated publisher beside it, so a wrong principal is still attributable to the component that sent it.

Scheduled jobs, migrations, and operators are actors too: give each its own identity and record it the same way. No effect is attributed to "system".

## Recording

- **Durable records** (fact rows, audit rows): principal, executor, trace id, and time. These answer disputes; logs alone do not, because logs rotate and can be dropped.
- **Logs:** structured, one line per significant effect, with principal, executor, trace id, and key. Never log secrets or tokens; log the token subject, not the token.
- **Platform audit:** changes to infrastructure go through GitOps, so the commit and its author are the record. Direct changes bypass that trail; treat them as incidents.

## Alternatives

| Reaching for | Often sufficient | Keep more structure when |
| --- | --- | --- |
| Separate service identities with token exchange | Propagate the user token, validate per hop, network policy limits callers | Services act without a user, or delegation (`act` chain) must be provable. |
| Service mesh for identity | Per-component credentials to each infrastructure capability | mTLS between services is a current requirement. |
| Central audit log service | Actor columns on facts plus structured logs with trace id | Audit must survive compromise of the writing component. |
