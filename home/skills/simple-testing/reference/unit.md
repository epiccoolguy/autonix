# Unit tests

A unit test checks one unit of behavior, quickly, isolated from other tests, not from its collaborators [Khorikov: Observable Behavior]. This is the classical school: real objects, assertions on outputs and state. Mocking every collaborator and verifying calls breaks tests on refactors that keep behavior [Fowler: Mocks Aren't Stubs].

## Test doubles

A test double stands in for a real dependency in a test [Meszaros: Test Double]. Example: a `SignupService` that saves a user and sends a welcome email.

| Kind | What it is | Example |
| --- | --- | --- |
| stub | returns canned answers; never asserted on | a user store whose `Exists` always returns false |
| spy | records calls for later assertions | a mailer that appends sent messages to a list |
| mock | preset with expected calls, fails itself if they don't happen | `mailer.EXPECT().Send(...)` from a mocking library |
| fake | a working, simpler implementation | an in-memory user store backed by a map |

- Use real code for everything inside the process.
- Use a double only where code leaves the process. Prefer a fake, then a stub, then a mock [SWE at Google: Test Doubles].
- Use a spy or mock only when the call itself is the requirement and other systems observe it: an email sent, an event published, a third-party API called [Khorikov: Unmanaged Dependencies].
- Mock only types you own: wrap a third-party API in an adapter and double the adapter [GOOS: Only Mock Types You Own].
- A hand-written fake lives next to the real implementation; the integration suite runs the same tests against both, so the fake cannot drift [Fowler: ContractTest].
- Never patch module or import paths; inject the dependency. Never widen visibility for a test.

## Test data and determinism

- Build data with small builder or factory functions that have valid defaults; the test overrides only what it is about [GOOS: Test Data Builders].
- Inject the clock and randomness; print the seed on failure. Use fake time instead of sleeps.
- Tests pass in any order, in parallel, and in any time zone. Run the race detector where the language has one.

## Generated inputs

Add a property-based test when a property is easy to state, such as `decode(encode(x)) == x` or an invariant [Pragmatic: Property-Based Testing]. Add a fuzz target for code that parses untrusted input. Keep every failing input as an example test.

## Contracts between deployables

The schema's breaking-change check runs with the static checks. Golden examples versioned with the schema are parsed by the producer's and each consumer's unit tests; consumers ignore unknown fields [Fowler: TolerantReader].
