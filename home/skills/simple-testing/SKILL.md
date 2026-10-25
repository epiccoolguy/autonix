---
name: simple-testing
description: Chooses, writes, and reviews automated tests and the checks that gate a change. Use when adding, changing, or reviewing tests; deciding between unit, integration, contract, and end-to-end tests; choosing mocks, fakes, or real dependencies; fixing flaky or slow tests; property-based tests, fuzzing, or mutation testing; coverage and CI test layout; deploy-time smoke and synthetic checks; migration and restore tests; and before declaring a code change done.
---

# Simple Testing

Tests exist to give confidence to change: behavior can be changed and refactored safely [SWE at Google: Testing Overview; Fowler: Building Tests]. Judge a test by regression protection, resistance to refactoring, speed, and maintenance cost; a test that fails on a correct refactor is a false alarm and erodes trust in the suite [Khorikov: Four Pillars]. This skill covers which tests to write, at which tier, against which dependencies, and what must pass before work is done. Shaping code so it can be tested (seams, interfaces at the consumer, explicit effects) and language test idioms belong to simple-code. That a decision gets a fitness function and that state gets a drilled restore belong to simple-architecture; how to build those as tests is here.

Tags in brackets name the source; [sources](reference/sources.md) gives the full reference.

## Before writing tests

Read the repository's test docs, CI config, and decision records. Precedence: repository decision records, then this skill's defaults. Keep the repository's tier names, commands, and frameworks. Never carry another repository's stack choices into this one.

## Everywhere

- **Behavior through the public interface.** Assert observable outcomes of a module's public API. Never test private code directly or verify calls between in-process collaborators [Khorikov: Observable Behavior; Beck: Test Desiderata; Ousterhout: Modules Should Be Deep].
- **Real in-process, doubles at the edge.** A test double stands in for a real dependency (see unit). Use real code inside the process; for what leaves it prefer real, then fake, then stub, then mock [SWE at Google: Test Doubles].
- **Lowest tier that catches the failure.** Classify tests by size: small (one process, no I/O, no sleep), medium (one machine, real dependencies in containers), large (deployed system, browser, several services) [SWE at Google: Testing Overview]. Most tests are small.
- **Deterministic.** Inject clock and randomness, never sleep, no order dependence, no real external network below large (see determinism).
- **Readable alone.** Each test builds its own data, shows the values that matter, contains no logic, and checks one behavior named in its title [SWE at Google: Unit Testing].
- **A flaky test is a defect.** Fix it or quarantine it with an issue and an owner [Fowler: Eradicating Non-Determinism].
- **Find bugs once.** A bug found by a human gets an automated test [Pragmatic: Pragmatic Starter Kit].

## References

Read only what applies, once per task:

| Deciding | Read |
| --- | --- |
| Test sizes, tiers, commands, suite shape | [shape](reference/shape.md) |
| Unit tests, test doubles, fakes | [unit](reference/unit.md) |
| Databases, brokers, third-party services in tests | [integration](reference/integration.md) |
| APIs or messages between deployables | [contracts](reference/contracts.md) |
| End-to-end tests, deploy checks, synthetic probes | [deploy](reference/deploy.md) |
| Property-based tests, fuzzing, mutation testing | [generative](reference/generative.md) |
| Test data, time, randomness, concurrency, flaky tests | [determinism](reference/determinism.md) |
| Coverage, CI layout and speed | [ci](reference/ci.md) |
| Migrations, restore tests, production data checks | [data](reference/data.md) |

## Done gate

Before declaring a change done:

1. Run static checks and the small tests of affected packages, then the full small suite.
2. Run the medium tier for each dependency the change touches: an adapter, query, migration, wiring or config, or a dependency version.
3. Schema or contract change: run the breaking-change check and the golden examples (see contracts). Migration: see data.
4. Bug fix: first write a test that fails without the fix, at the lowest tier that catches it [Ousterhout: Software Trends]. New behavior: add a test through the public interface.
5. Read coverage of the changed lines; test what is uncovered or say why not.
6. Never skip, weaken, or delete a test, or update goldens or snapshots, without saying so and why. Never fix a flaky test with sleeps or retries.
7. With a PR, the work is done only when CI, including any deploy check, is green. Report skipped tiers plainly.
