# Architecture

One TypeScript API (`src/`) on Postgres 16. Merging to `main` builds an image, deploys it to staging,
and, after the staging smoke check passes, to production. Production runs 3 replicas with rolling
updates (`deploy/api.yaml`). Pending SQL migrations in `migrations/` are applied by `src/main.ts`
when the process starts.
