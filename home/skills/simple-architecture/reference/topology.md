# Multi-site topology

## Defaults

- **Each site is an independent cell.** No runtime dependency crosses a site boundary: no cross-site reads, calls, consumers, or quorums [Helland: Life beyond Distributed Transactions; AWS: Cell-Based Architecture]. A WAN partition then degrades nothing except the cross-site paths below.
- Only three things cross sites:
  - desired state flows in through the deployment pipeline (for example GitOps);
  - backups flow out to object storage outside the site;
  - observability is read across sites, read-only.
- **No stretched clusters** (etcd, database, or broker quorums across a WAN). No synchronous replication across sites. Across distance, every consistency guarantee costs latency on every request [DDIA: Replication; Abadi: PACELC].
- **Disaster recovery across sites:** off-site async backups, restored into another site. The restore is drilled with a stated RTO and RPO (see [operability](operability.md)). A warm replica at another site is added only when restore cannot meet a stated target.
- **Data placement is explicit.** Each dataset has one home site. Personal data stays where residency rules require, and that includes backup locations.

```mermaid
flowchart TB
    G[(Git: desired state)] --> S1 & S2
    subgraph S1["Site A (cell)"]
        A1[GitOps agent] --> C1[Capabilities + apps]
    end
    subgraph S2["Site B (cell)"]
        A2[GitOps agent] --> C2[Capabilities + apps]
    end
    C1 & C2 -. "async backups" .-> OS[(Off-site object storage)]
    OBS[Observability] -. "read-only" .-> C1 & C2
    OS -. "DR: restore into another site" .-> C2
```

## Avoid

Stretched clusters; active-active by default; cross-site service calls; a broker spanning sites so consumers depend on remote state; KubeFed-style federation control planes.
