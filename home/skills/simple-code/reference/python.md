# Python

- Prefer module functions and plain values; use dataclasses, NamedTuple, TypedDict, or ordinary classes according to the data, identity, and invariants involved. Frozen data can prevent accidental mutation; do not impose frozen/slots on every record.
- Use Enum or unions of distinct records for meaningful alternatives, and explicit optionality. Where the project's type checker supports it, exhaustive handling with assert_never can catch omitted variants. Type hints do not validate runtime input.
- Parse untrusted input at real boundaries using existing schemas or small parsers. Keep invariant checks where construction or mutation can violate them; do not assume annotations make arbitrary dicts safe.
- Use functions or closures for simple behavioral variation. Use a narrow Protocol when a consumer needs a real capability; there is no implementation-count quota. Stateful classes, context managers, and required framework inheritance can be the simplest design.
- Pass important dependencies explicitly and keep helpers near their consumers. Prefer specific cohesive modules to generic utility buckets. Do not replace useful library decorators or dynamic protocols with bespoke machinery merely to avoid runtime features.
- Use comprehensions, generators, or ordinary loops according to clarity. Preserve generator/resource lifetime and deliberate async ordering; avoid dense nested comprehensions for effectful work.
- Use idiomatic exceptions and narrow catches, preserving useful context. Do not impose result wrappers or catch-and-ignore failures that callers need. Use with, context managers, or ExitStack when they clarify resource ownership.
- Follow existing typing, formatting, and testing conventions. Do not add a strict checker, validation library, or new dependencies solely to enforce this style.
