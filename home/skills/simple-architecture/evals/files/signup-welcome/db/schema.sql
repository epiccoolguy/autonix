CREATE SCHEMA users;
CREATE TABLE users.account (
    id         uuid PRIMARY KEY,
    email      text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.jobs (
    id           bigserial PRIMARY KEY,
    kind         text NOT NULL,
    dedupe_key   text UNIQUE,
    payload      jsonb NOT NULL,
    run_at       timestamptz NOT NULL DEFAULT now(),
    attempts     int NOT NULL DEFAULT 0,
    max_attempts int NOT NULL DEFAULT 6,
    done_at      timestamptz
);
