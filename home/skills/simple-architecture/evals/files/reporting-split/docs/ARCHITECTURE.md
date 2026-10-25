# Architecture

One deployable (TypeScript on Node) with modules `checkout`, `catalog`, `reporting`. One Postgres
database, a schema per module; modules call each other's code APIs, never each other's tables.
Decisions are in `decisions/`.
