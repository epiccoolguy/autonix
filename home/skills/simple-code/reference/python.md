# Python

## Data and behavior

- Prefer module functions and plain values. Choose dataclasses, NamedTuple, TypedDict, or ordinary classes according to data, identity, and invariants; frozen and slots are options, not universal requirements.
- Use Enum or unions of distinct records for meaningful alternatives, with explicit optionality. Use assert_never where the existing checker supports exhaustive handling.
- Use functions or closures for simple variation, and narrow Protocols for real capabilities. Stateful classes and required framework inheritance can simplify a design.

## Control flow and effects

- Choose comprehensions, generators, or loops by clarity. Preserve generator/resource lifetime and deliberate async ordering; avoid dense effectful comprehensions.
- Use idiomatic exceptions, narrow catches, and useful error context. Do not add result wrappers or swallow failures callers need.
- Use with, context managers, or ExitStack when they clarify resource ownership.

## Modules and boundaries

- Parse untrusted input with existing schemas or small parsers. Type hints do not validate runtime data; retain checks where construction or mutation can violate invariants.
- Pass important dependencies explicitly and keep modules cohesive. Follow existing typing and testing conventions; do not add a strict checker or validation library solely to impose this style.
