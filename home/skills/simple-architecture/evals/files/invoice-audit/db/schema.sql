CREATE SCHEMA billing;
CREATE TABLE billing.invoice (
    id           uuid PRIMARY KEY,
    customer_id  uuid NOT NULL,
    amount_cents bigint NOT NULL CHECK (amount_cents >= 0),
    status       text NOT NULL DEFAULT 'open',
    updated_at   timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON billing.invoice TO app;
