# 0002. Availability

Status: accepted

## Context
Customers have a contractual 99.9% monthly availability for the import API.

## Decision
Every workload serving or processing customer requests runs at least 3 replicas spread across zones
(topologySpreadConstraints on `topology.kubernetes.io/zone`) with a PodDisruptionBudget of
`minAvailable: 2`. Stateful dependencies are platform-managed (MySQL, RabbitMQ) and not deployed by
product teams.

## Alternatives
Single replica plus restore: restore time breaks the contract.

## Consequences
Workers must be safe to run concurrently.
