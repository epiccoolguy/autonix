# Architecture

One deployable (TypeScript on Node), one Postgres database. Order events (`orders.order.placed.v1`) are
published to the broker and consumed by the shipping service, which is owned by another team. Nothing
else consumes events today.
