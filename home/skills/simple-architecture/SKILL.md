---
name: simple-architecture
description: Designs and reviews system architecture with the fewest moving parts. Use for decisions that are expensive to reverse or cross a process, persisted-data, trust, or ownership boundary - splitting or adding services and cluster capabilities; sync vs async, events, queues, workflows; data ownership, history, audit trails, deletes; propagating and recording actors; operability and recovery; adopting a capability, framework, or language and dependency upgrade policy; frontend and BFF shape, including login, OIDC, sessions, and where tokens live; multi-site topology; writing decision records (ADRs) and architecture diagrams.
---

# Simple Architecture

Architecture is the set of decisions that are expensive to reverse, or that cross a process, persisted-data, trust, or ownership boundary [Booch; Fowler: Who Needs an Architect?]. What a refactor plus tests can change inside one deployable belongs to simple-code. Every component, hop, store, and copy is something to run, secure, back up, upgrade, and debug: prefer the fewest parts and the most direct data flow that meet current requirements [Ousterhout: The Nature of Complexity; Brooks: No Silver Bullet].

Tags in brackets name the source; [sources](reference/sources.md) gives the full reference.

## Making a decision

1. Read the repository's architecture docs and decision records. Precedence: repository decision records, then this skill's defaults. Deviating from a recorded decision means proposing to supersede it; following one needs no proposal. Applying one of this skill's defaults inside an existing component (for example keeping tokens server-side in the existing server) is not a new decision: implement it and say why. A record is for adding a component or departing from a default. Never carry another organization's or repository's stack choices into this one.
2. Name the force that requires the decision now and the simplest direct alternative. Consider at least two designs [Ousterhout: Design It Twice].
3. Propose in a PR: a decision record with status proposed (decision, alternatives, consequences), a Mermaid diagram when structure changes, and one or more working prototypes. Do not merge or push it directly, even where auto-merge or direct pushes are otherwise allowed. After the owner reviews, the record becomes accepted, the chosen prototype is completed, and the current-state doc is updated in the same PR.
4. Add a CI fitness function when a tool can check the decision cheaply [Ford: Fitness Functions].

## Everywhere

- **Conceptual integrity.** The system reads as one design; a new part follows existing patterns unless a decision record says otherwise [Brooks: Aristocracy, Democracy, and System Design].
- **One mechanism per job.** Reuse the running capability for a job before adding another; two mechanisms for one job is a defect [McKinley: Choose Boring Technology].
- **One owner per fact.** One writer and system of record per piece of state; copies are derived and rebuildable [DDIA: The Future of Data Systems; Pragmatic: DRY].
- **Every effect is attributable** to a principal, an executing component, and a trace.
- **Recoverable or not running.** State has a performed restore; a component has an owner, a symptom alert, and a runbook.

## References

Read only what applies, once per task:

| Deciding | Read |
| --- | --- |
| Splitting into modules or deployables | [decomposition](reference/decomposition.md) |
| Sync vs async, events, queues, workflows, retries | [communication](reference/communication.md) |
| Ownership, consistency, history, audit, deletes | [data](reference/data.md) |
| Identity, actor propagation, who-did-what records | [actors](reference/actors.md) |
| Failure handling, observability, availability, recovery | [operability](reference/operability.md) |
| A new capability, operator, framework, or language; upgrade policy | [capabilities](reference/capabilities.md) |
| Decision records, diagrams, fitness functions | [records](reference/records.md) |
| Web or native clients, BFF, where tokens live | [frontend](reference/frontend.md) |
| Several sites or regions, data placement, cross-site DR | [topology](reference/topology.md) |

Before declaring a design done, check each component, hop, queue, table, and copy it adds: remove it, merge it into an existing one, or keep it synchronous and local unless it serves a current consumer, enforces an invariant, or marks a needed boundary.
