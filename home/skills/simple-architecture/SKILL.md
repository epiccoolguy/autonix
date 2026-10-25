---
name: simple-architecture
description: Designs and reviews system architecture with the fewest moving parts. Use when adding a service, cluster capability, operator, broker, database, or other runtime component; when choosing sync vs async communication, events vs commands, or retries and idempotency; when designing persistence for history, audit trails, or deletes; or when deciding how actors (users, services, jobs) are authenticated, propagated, recorded, and logged.
---

# Simple Architecture

Every component, hop, and copy of data is something to run, secure, back up, upgrade, and debug. Prefer the fewest runtime parts and the most direct data flow that meets the current requirements. Add a part when it removes greater operational or correctness risk, enforces an invariant, or establishes a needed boundary. Code-level design inside a component belongs to simple-code.

First read the repository's own architecture docs, ADRs, and conventions; recorded decisions win over these defaults. If a design contradicts one, say so and ask rather than diverging silently.

Read only what applies, once per task:

| Deciding | Reference |
| --- | --- |
| A new service, capability, operator, or infrastructure dependency | [capabilities](reference/capabilities.md) |
| Sync vs async, events, commands, retries, idempotency | [communication](reference/communication.md) |
| History, audit trail, temporal data, deletes | [data-history](reference/data-history.md) |
| Identity, actor propagation, who-did-what records and logs | [actors](reference/actors.md) |

These hold everywhere:

- **One mechanism per job.** Reuse the capability already running for that job (broker, database, identity provider, log store) before adding another. Two ways to do the same thing is a defect to remove, not an option to keep.
- **One owner per fact.** Each piece of state has one writer and one source of truth. Copies (caches, projections, read models) are derived, rebuildable, and named as such.
- **Every effect is attributable.** Any state change can be traced to the actor that caused it, the component that executed it, and the request or trace it belonged to.
- **Recoverable or not worth running.** State that matters has a tested restore path; a component without an owner, monitoring, and recovery story is not done.

Before declaring a design done, check each component, hop, queue, table, and copy it adds: remove it, merge it into an existing one, or make it synchronous and local unless it serves a current consumer, enforces an invariant, or marks a needed boundary. In a design for review, name the direct alternative and one concrete reason per added part.
