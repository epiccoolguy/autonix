# Sources

Each bracketed tag in this skill maps to one entry below. Read this file when asked why a rule exists or to justify one in a decision record. DDIA tags use 1st-edition chapter titles; the 2nd edition (Kleppmann and Riccomini) reorganizes chapters, so check titles there.

## Core library

| Tag | Source | Used for |
| --- | --- | --- |
| Ousterhout: The Nature of Complexity | Ousterhout, *A Philosophy of Software Design*, 2nd ed., ch. "The Nature of Complexity" | Complexity as change amplification, cognitive load, unknown unknowns; every part costs |
| Ousterhout: Modules Should Be Deep | same, ch. "Modules Should Be Deep" | Deep parts, shallow services |
| Ousterhout: Pull Complexity Downwards | same, ch. "Pull Complexity Downwards" | Complexity on the server, not every client |
| Ousterhout: Design It Twice | same, ch. "Design It Twice" | Alternatives and prototypes before deciding |
| Evans: Bounded Context | Evans, *Domain-Driven Design*, ch. "Maintaining Model Integrity" | Modules along model boundaries |
| Evans: Aggregates | same, ch. "The Life Cycle of a Domain Object" | One aggregate per transaction |
| Evans: Distillation | same, ch. "Distillation" | Core vs supporting vs generic subdomains; build vs adopt |
| Evans: Domain Events | Evans, *Domain-Driven Design Reference* (2015) | Events as facts in the domain language |
| Fowler: Who Needs an Architect? | Fowler, IEEE Software 2003, citing Ralph Johnson | Architecture as the shared, hard-to-change decisions |
| DDIA: Reliable, Scalable, and Maintainable Applications | Kleppmann, *Designing Data-Intensive Applications* | Fault vs failure; operability, simplicity, evolvability |
| DDIA: Encoding and Evolution | same | Compatible schema evolution, tolerant readers |
| DDIA: Transactions | same | Isolation levels, write skew |
| DDIA: The Trouble with Distributed Systems | same | Unreliable clocks; ordering |
| DDIA: Stream Processing | same | Logs, at-least-once plus idempotence |
| DDIA: Replication | same | Replication models, lag, cost of consistency across distance |
| DDIA: The Future of Data Systems | same | System of record vs derived data; end-to-end argument; data ethics and erasure |
| Pragmatic: DRY | Thomas and Hunt, *The Pragmatic Programmer*, 20th anniv. ed., "DRY - The Evils of Duplication" | One authoritative representation of knowledge |
| Pragmatic: Reversibility | same, "Reversibility" | No final decisions; exit paths |
| Pragmatic: Dead Programs Tell No Lies | same | Crash on impossible state |
| Pragmatic: Stay Safe Out There | same | Least privilege, secure defaults |
| Bentley: Data Structures Programs | Bentley, *Programming Pearls*, 2nd ed., column 3 | Representation shapes the program |
| Bentley: The Back of the Envelope | same, column 7 | Estimating before sizing |
| Brooks: Aristocracy, Democracy, and System Design | Brooks, *The Mythical Man-Month*, anniv. ed., ch. 4 | Conceptual integrity |
| Brooks: The Second-System Effect | same, ch. 5 | Over-building |
| Brooks: Ten Pounds in a Five-Pound Sack | same, ch. 9 | "Show me your tables" |
| Brooks: No Silver Bullet | same, ch. 16 | Essential vs accidental complexity; buy before build |
| Brooks: The Design of Design | Brooks, *The Design of Design* | Recorded rationale; budgeting the scarcest resource |
| Ousterhout: Designing for Performance | Ousterhout, *A Philosophy of Software Design*, 2nd ed., ch. "Designing for Performance" | Measure before modifying; fix the critical path |
| Pragmatic: Pragmatic Starter Kit | Thomas and Hunt, *The Pragmatic Programmer*, 20th anniv. ed., Topic 51 | Version control, regression tests, full automation |
| CD: The Problem of Delivering Software | Humble and Farley, *Continuous Delivery*, 2010, ch. 1 | Small, frequent, automated releases |
| CD: Configuration Management | same, ch. 2 | Everything needed to recreate an environment in version control |
| CD: Only Build Your Binaries Once | same, ch. 5 (deployment pipeline practices) | Build once, promote the same artifact |
| CD: Deploying and Releasing Applications | same, ch. 10 | One automated path; rollback by redeploying a known-good version |
| CD: Managing Data | same, ch. 12 | Migrations decoupled from application deploys |
| Accelerate | Forsgren, Humble, Kim, *Accelerate*, 2018; DORA reports | Trunk-based development, deployment automation; heavyweight change approval hurts delivery |

## Further

| Tag | Source |
| --- | --- |
| Booch | Grady Booch: "significant decisions, where significant is measured by cost of change" |
| Parnas: On the Criteria | Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules", CACM 1972 |
| Conway | Conway, "How Do Committees Invent?", 1968 |
| Deutsch: Fallacies of Distributed Computing | Peter Deutsch et al., Sun Microsystems, 1994 |
| Fowler: MonolithFirst | martinfowler.com/bliki/MonolithFirst.html (2015) |
| Fowler: Strangler Fig | martinfowler.com/bliki/StranglerFigApplication.html |
| Newman: Monolith to Microservices | Newman, *Monolith to Microservices*, 2019 |
| Skelton: Team Topologies | Skelton and Pais, *Team Topologies*, 2019 |
| Hohpe: (pattern) | Hohpe and Woolf, *Enterprise Integration Patterns*, 2003 - Command Message, Event Message, Idempotent Receiver, Dead Letter Channel, Claim Check, Correlation Identifier |
| Nygard: (pattern) | Nygard, *Release It!*, 2nd ed., 2018 - Timeouts, Circuit Breaker, Bulkheads |
| Nygard: Documenting Architecture Decisions | Nygard, cognitect.com blog, 2011 (origin of ADRs) |
| Helland: Immutability Changes Everything | Pat Helland, CIDR 2015 |
| brandur: Soft Deletion Probably Isn't Worth It | brandur.org, 2022 |
| Stripe: Idempotency Keys | Stripe API idempotent requests; IETF draft "The Idempotency-Key HTTP Header Field" |
| Brooker: Exponential Backoff and Jitter | Marc Brooker, AWS Architecture Blog, 2015 |
| Candea: Crash-Only Software | Candea and Fox, HotOS 2003 |
| Google SRE: Data Integrity | Beyer et al., *Site Reliability Engineering*, 2016, ch. 26 (restores, not backups) |
| Google SRE: Monitoring Distributed Systems | Beyer et al., *Site Reliability Engineering*, 2016; burn-rate alerts in *The Site Reliability Workbook* |
| McKinley: Choose Boring Technology | Dan McKinley, mcfunley.com, 2015 (innovation tokens) |
| Ford: Fitness Functions | Ford, Parsons, Kua, *Building Evolutionary Architectures* |
| Brown: C4 Model | Simon Brown, c4model.com |
| matklad: ARCHITECTURE.md | Aleksey Kladov, matklad.github.io, 2021 |
| GDPR: Storage Limitation | GDPR Art. 5(1)(e); Recital 26 (pseudonymized data remains personal data) |
| NIST SP 800-207 | Zero Trust Architecture |
| NIST SP 800-53 AU-3 | Content of audit records |
| OWASP Logging Cheat Sheet | cheatsheetseries.owasp.org |
| RFC 8693 | OAuth 2.0 Token Exchange (`act` claim) |
| W3C Trace Context | w3.org/TR/trace-context |
| Kubernetes | Controller/reconcile pattern; API server audit log fields |
| Newman: Backends For Frontends | Sam Newman, samnewman.io, 2015 |
| Miller: Islands Architecture | Jason Miller, jasonformat.com, 2020 |
| IETF: OAuth 2.0 for Browser-Based Applications | IETF OAuth WG draft (BFF pattern, no tokens in the browser) |
| RFC 8252 | OAuth 2.0 for Native Apps |
| Helland: Life beyond Distributed Transactions | Pat Helland, CIDR 2007 / ACM Queue 2016 |
| AWS: Cell-Based Architecture | AWS Well-Architected, "Reducing the Scope of Impact with Cell-Based Architecture" |
| Abadi: PACELC | Daniel Abadi, "Consistency Tradeoffs in Modern Distributed Database System Design", IEEE Computer 2012 |
| Fowler: Continuous Integration | martinfowler.com/articles/continuousIntegration.html (2024 rev.) |
| Hammant: Trunk-Based Development | Paul Hammant, trunkbaseddevelopment.com |
| Hodgson: Feature Toggles | Pete Hodgson, martinfowler.com/articles/feature-toggles.html, 2017 |
| Twelve-Factor: (factor) | 12factor.net - Build, Release, Run; Dev/Prod Parity; Logs |
| OpenGitOps | opengitops.dev principles v1.0 (declarative, versioned, pulled, continuously reconciled) |
| SLSA | slsa.dev, v1.2 Build track (provenance, hardened isolated builds) |
| Sigstore | sigstore.dev (keyless signing, transparency log) |
| OpenSSF Scorecard | scorecard.dev - Pinned-Dependencies, Dangerous-Workflow |
| Prometheus: Naming | prometheus.io/docs/practices/naming and instrumentation (units, suffixes, label cardinality) |
| OpenTelemetry: Semantic Conventions | opentelemetry.io/docs/specs/semconv (metric names, resource attributes, messaging span links) |
