# Architecture

One deployable (TypeScript on Node) with modules `users`, `billing`, `catalog`. One Postgres database,
one schema per module. Background work goes through the `jobs` table: a worker in the same deployable
claims due rows with `FOR UPDATE SKIP LOCKED`, runs the handler registered for `kind`, and retries with
backoff up to `max_attempts`. Email goes through `sendEmail` in `app/email.ts` (SMTP relay).
