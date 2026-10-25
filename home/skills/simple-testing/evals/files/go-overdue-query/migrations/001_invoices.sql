CREATE TABLE invoices (
    id text PRIMARY KEY,
    customer text NOT NULL,
    cents bigint NOT NULL,
    due_on date NOT NULL,
    paid_at timestamptz
);
