# Capabilities

A capability is anything the platform runs on behalf of applications: a database, broker, identity provider, operator, gateway, cache, scheduler, or observability backend.

## Before adding one

- Name the requirement it serves today and the consumer that needs it. "We will need it later" is not a consumer.
- Check whether a running capability already covers it, even if less elegantly: Postgres as a queue, cache, job table, or search index; the existing broker for scheduling; the existing identity provider for service credentials. A second mechanism needs a reason the first cannot meet.
- Prefer a managed operator or upstream chart already in use over a new install method; prefer plain manifests over an operator when there is one instance and no lifecycle to automate.
- Count what it adds: upgrades, CVEs, backups, restore drills, credentials, network policy, dashboards, alerts, on-call knowledge.

## Definition of done

A capability is not installed until it has:

- An owner and one place it is declared (GitOps; no hand-applied state).
- Credentials scoped per consumer and environment, never shared between consumers.
- Monitoring and an alert on the failure that matters.
- For state: backups and a restore that has actually been performed. A backup never restored is a hypothesis.
- A documented way to remove it.

## Alternatives

| Reaching for | Often sufficient | Add it when |
| --- | --- | --- |
| New service | Module in an existing service | Independent deploy cadence, scaling, ownership, or security boundary is needed now. |
| Message broker | Direct call or a job table in the existing database | Several consumers, fan-out, or delivery guarantees across components (see communication). |
| Cache (Redis etc.) | Database index, HTTP caching, in-process memo | Measured latency or load the database cannot meet. |
| Search engine | Database full-text search | Relevance, scale, or language features the database lacks. |
| Workflow engine | State column plus idempotent consumers or a scheduled job | Long-running multi-step processes with compensation that hand-rolled state cannot keep correct. |
| Service mesh | NetworkPolicy plus TLS at the edge | mTLS identity or traffic policy is a current requirement. |
| HA / replicas | Single instance plus tested restore | The availability target is stated and restore time cannot meet it. |
