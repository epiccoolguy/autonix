# Records, diagrams, and fitness functions

Conceptual integrity needs a written record that everyone follows, and the rationale is the part that gets lost [Brooks: The Design of Design].

## Two kinds of record

Mirror the data model: current state plus append-only history.

- **Current truth:** a topic doc or `ARCHITECTURE.md` describing the system as it is now, always rewritten, never amended with banners [matklad: ARCHITECTURE.md].
- **Decision log:** short, numbered, immutable decision records (ADRs) [Nygard: Documenting Architecture Decisions]. Status is proposed, accepted, or superseded by N. A superseding record updates the current-truth doc in the same PR.

Use the repository's existing location and template. Otherwise use `docs/adr/NNNN-title.md` with:

```markdown
# NNNN. Title

Status: proposed | accepted | superseded by NNNN

## Context
The force that requires a decision now.

## Decision
What we do, with a Mermaid diagram when structure changes.

## Alternatives
At least one other design and why not.

## Consequences
What gets easier, what gets harder, the exit path, the fitness function if any.
```

## Proposal flow

The agent opens a PR with a proposed record and one or more prototypes. The owner reviews the PR. The decision is finalized in that PR: the record is accepted, the chosen prototype is completed, the others are removed, and the current-truth doc is updated [Ousterhout: Design It Twice].

## Diagrams

A Mermaid diagram is mandatory when a record or doc adds or changes:

| Concern | Diagram |
| --- | --- |
| Components and boundaries | `flowchart` with subgraphs (C4 context or container level) [Brown: C4 Model] |
| A flow across components, including actors | `sequenceDiagram` |
| Data ownership and schema | `erDiagram` |
| Lifecycle of an entity or workflow | `stateDiagram-v2` |

Keep diagrams as code next to the text. A diagram shows the real mechanism, not decoration.

## Fitness functions

Give a decision a CI check when a tool can verify it cheaply [Ford: Fitness Functions]:
- import or dependency rules (depguard, import-linter, dependency-cruiser);
- a schema-ownership check;
- policy as code for manifests (Kyverno, conftest, kubeconform);
- contract and schema compatibility checks.

Everything else is checked in review against the record.
