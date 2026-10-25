# 0001. Modular monolith

Status: accepted

## Context
One team owns the whole product.

## Decision
One deployable; each module owns a Postgres schema. A module becomes a separate deployable only for a
trust boundary, a measured scaling or isolation need, or a separate owning team, recorded in a new
decision that supersedes this one for that module.

## Alternatives
Service per module: network hops and contracts without a present force.

## Consequences
Shared database resources; contention must be handled within the deployable first.
