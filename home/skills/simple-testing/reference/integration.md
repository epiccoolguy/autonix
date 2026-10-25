# Integration tests

An integration test checks one adapter against one real out-of-process dependency, not the whole system with everything live [Fowler: IntegrationTest]. They form the CI PR gate.

## Dependencies

- Run databases, caches, and brokers your application owns for real, in containers, with the same engine and major version as production. No in-memory or substitute engines: isolation and locking differ between engines [Khorikov: Database Testing].
- Build the schema by applying all migrations to an empty database. Check that the committed schema dump or generated code matches what the migrations produce.
- Run the same tests against the real adapter and its unit-test fake.
- Test third-party services against a fake server at the HTTP edge or the vendor's emulator, never the live service.

## Running

- One documented command starts the dependencies and runs the tier, locally and in CI. The mechanism is the repository's choice: a compose file or test-managed containers (for example testcontainers). Both work with podman.
- Keep the PR gate to about ten minutes [Fowler: Continuous Integration].

## Isolation

- Each test creates its own uniquely keyed data and never relies on rows another test created.
- When a test needs an empty or exclusive database, give it a fresh one cloned from a migrated template database.
- Roll back a transaction per test only where the framework and the application share one connection.
