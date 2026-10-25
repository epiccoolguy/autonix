# Data history and audit trail

Decide what question the history must answer before choosing a mechanism: "what was the value at time T", "who changed what", or "prove this record was never altered" need different shapes.

## Defaults

- **Append-only facts where the domain has history.** Model events the business cares about (payment received, rate effective from, return filed) as immutable rows. Current state is a table or view derived from them. These rows are the audit record; do not add a history table beside them.
- **Validity ranges for values that change over time** (prices, rates, assignments): `valid_from` / `valid_to` columns queried by date, not overwrites.
- **Enforce immutability in the database** (revoke UPDATE/DELETE from the application role, or a trigger that rejects them) when the record must be trustworthy. Application convention alone is not an audit guarantee.
- **No blanket history.** Do not add generic trigger-based history tables, `updated_by` on every table, or event sourcing by default. Add a history mechanism to a table when a stated requirement (regulatory, dispute resolution, debugging a real incident class) needs it.
- **Every fact or audit row records its actor:** the principal, the executing component, and the trace or request id (see actors). A history without who and why is only a diff.

## Deletes

- Hard delete is the default for data nobody must retain; it is also what privacy erasure requires.
- Soft delete (`deleted_at`) only when restore or retention is a requirement, and then every query path must filter it - prefer a view or row policy over remembering a `WHERE`.
- Where both retention and erasure apply, keep the fact and erase or pseudonymize the personal data in it.

## Alternatives

| Reaching for | Often sufficient | Keep more structure when |
| --- | --- | --- |
| Event sourcing | Current-state tables plus append-only facts | State must be rebuilt or reinterpreted from the full event log. |
| Generic history table per entity | Append-only domain facts | Arbitrary field-level change history of mutable rows is required. |
| Temporal-table extension | `valid_from`/`valid_to` columns | Many tables need system-time history and the extension is already supported. |
| Separate audit service | Actor columns on facts plus structured logs | Audit must be tamper-evident and independent of the writing component. |
