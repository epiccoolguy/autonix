---
name: simple-testing
description: Chooses, writes, and reviews automated tests and the checks that gate a change. Use when adding, changing, or reviewing tests; deciding between unit, integration, and end-to-end tests; choosing mocks, fakes, or real dependencies; fixing flaky or slow tests; laying out tests in CI; adding a deploy check; and before declaring a code change done.
---

# Simple Testing

Tests exist to give confidence to change: behavior can be changed and refactored safely [SWE at Google: Testing Overview; Fowler: Building Tests]. Judge a test by regression protection, resistance to refactoring, speed, and maintenance cost; a test that fails on a correct refactor is a false alarm [Khorikov: Four Pillars]. This skill covers which tests to write, in which tier, and what must pass before work is done. Shaping code so it can be tested (seams, interfaces at the consumer, explicit effects) and language test idioms belong to simple-code; restore drills, probes, and alerts belong to simple-architecture.

Tags in brackets name the source; [sources](reference/sources.md) gives the full reference.

Read the repository's test docs, CI config, and decision records first. Precedence: repository decision records, then this skill's defaults. Keep the repository's tier names, commands, and frameworks.

## Three tiers

| Tier | What it touches | Runs | Read |
| --- | --- | --- | --- |
| Unit | one process, no I/O, no sleep | the default local test command, and in CI | [unit](reference/unit.md) |
| Integration | real dependencies in containers | the CI PR gate; one documented command locally | [integration](reference/integration.md) |
| End-to-end | a deployed system, through the API or a browser | on demand and on a schedule | [e2e](reference/e2e.md) |

Static checks (format, lint, types, schema breaking-change checks) run with unit tests. Most tests are unit tests; there is no fixed ratio [Fowler: Shapes of Testing].

Every deployable also gets a **deploy check** that fails the rollout (see e2e).

## Everywhere

- **Behavior through the public interface.** Assert observable outcomes; never test private code or verify calls between in-process collaborators [Khorikov: Observable Behavior; Beck: Test Desiderata].
- **Real in-process, doubles at the edge** (see unit).
- **Deterministic.** Inject clock and randomness, never sleep, no order dependence, no real external network outside end-to-end tests.
- **Readable alone.** Each test builds its own data with the relevant values visible, contains no logic, and checks one behavior named in its title [SWE at Google: Unit Testing].
- **A flaky test is a defect.** Fix it, or quarantine it with an issue and an owner and delete it if not fixed by a stated deadline. Never fix it with sleeps or retries [Fowler: Eradicating Non-Determinism].
- **Coverage is a signal, not a gate.** Read coverage of the changed lines; never write a test only to raise the number [Fowler: TestCoverage].

## Done gate

Before declaring a change done:

1. Run static checks and unit tests.
2. Run integration tests locally when the change touches an adapter, query, migration, wiring or config, or a dependency version.
3. Bug fix: first write a test that fails without the fix, in the lowest tier that catches it [Ousterhout: Software Trends]. New behavior: add a test through the public interface.
4. Never skip, weaken, or delete a test, or update goldens or snapshots, without saying so and why.
5. With a PR, the work is done only when CI, including any deploy check, is green. Report skipped tiers plainly.
