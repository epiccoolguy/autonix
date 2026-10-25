# Capabilities and dependencies

A capability is anything the platform runs on behalf of applications: a database, broker, identity provider, operator, gateway, cache, scheduler, or observability backend. The scarcest resource is operator attention [Brooks: The Design of Design].

## Build or adopt

Classify the need [Evans: Distillation]:
- **core** (the differentiator): build it, and spend innovation there;
- **generic** (identity, messaging, storage, email): adopt;
- **supporting:** the simpler of a small build or an adoption.

The cheapest code is code not written [Brooks: No Silver Bullet].

## A new capability

- Show that a running capability cannot cover the need, even less elegantly: the existing database as a queue, a cache, search, or cron; the existing broker; the existing identity provider.
- At most one new-to-us technology in flight at a time [McKinley: Choose Boring Technology].
- Adoption criteria:
  - mature and maintained: years in production, active releases, more than one maintainer, CVE response (OpenSSF Scorecard as a signal);
  - operability fit: declarative install through the deployment pipeline, a metrics endpoint, a backup and restore story, an availability setup that matches the target;
  - an open protocol and exit path (SQL, OIDC, S3, OTel, CloudEvents) [Pragmatic: Reversibility].
- Prefer an operator already in use; use plain manifests when there is one instance and no lifecycle to automate.

## Definition of done

- an owner and one declarative definition in the deployment pipeline;
- credentials scoped per consumer and environment;
- a symptom alert with a runbook;
- for state: backups and a performed restore;
- an upgrade path and an exit path;
- a decision record (see records).

## Languages and runtimes

- A language or runtime is a capability: one per role (for example one backend language and one rendering runtime), each recorded in a decision record with its steward and exit path [McKinley: Choose Boring Technology].
- A new language needs a force: a runtime need, a separate owning team, or an ecosystem the role depends on.
- Working code stays in its language; rewrite only for a concrete force.
- Contracts cross languages through a language-neutral schema (JSON Schema) with generated types, not hand-written copies.
- Data access is SQL-first: plain SQL migrations plus generated or typed queries, no ORM that hides transactions or per-transaction settings.

## Upgrades

Upgrades are as automated as possible behind guard rails:
- automated upgrade PRs (an update bot such as Renovate) promoted through environments like any change;
- a minimum release age before an update is proposed, also set in the package manager where it supports one (for example pnpm `minimumReleaseAge`), with install scripts disabled;
- non-major updates automerge after green required checks; majors wait for the owner;
- where one deployment serves every environment (shared infrastructure), automerge less (for example patch only) and record how upgrades are staged.

Small, frequent steps; nothing pinned without a recorded reason.

```mermaid
flowchart TD
    N[Need] --> D{Subdomain}
    D -- core --> B[Build]
    D -- generic or supporting --> X{Existing capability covers it?}
    X -- yes --> R[Reuse]
    X -- no --> A[Adopt mature OSS with an open protocol]
    A --> DOD[Definition of done]
```

## Alternatives

| Reaching for | Often sufficient | Add it when |
| --- | --- | --- |
| Cache server | Index, HTTP caching, in-process memo | Measured load or latency the database cannot meet |
| Search engine | Postgres full-text search, pg_trgm | Relevance or scale the database lacks |
| Workflow engine | Idempotent consumer chain, state in the owner's tables | Multi-step compensation must be tracked |
| Service mesh | NetworkPolicy plus workload tokens | mTLS identity or traffic policy is required |
| HA replicas | Single instance plus drilled restore | Restore cannot meet a stated target |
