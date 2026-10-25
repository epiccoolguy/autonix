# Architecture

One deployable (TypeScript on Node), one Postgres database with a schema per module. The app connects
as role `app`. Requests are authenticated with an OIDC JWT; handlers get `req.user.sub` and
`req.traceId` (W3C traceparent). Migrations are plain SQL files in `db/migrations`.
