# Python

## Data and behavior

- Prefer module functions and plain values. Choose `dataclass`, `NamedTuple`, `TypedDict`, or an ordinary class by data, identity, and invariants. `frozen=True` and `slots=True` are options, not requirements.
- Model meaningful alternatives as an `Enum` or a union of distinct dataclasses, handled with `match`. Where the checker supports it, end with `case _: assert_never(x)` to prove exhaustiveness. Make absence explicit with `X | None`.
- Use functions or closures for simple variation, and a narrow `Protocol` near its consumer for a real capability. Stateful classes, context managers, and required framework inheritance can be the simplest design. Library decorators (`@dataclass`, `@property`, `functools.cache`, framework routes, pytest fixtures) are idiomatic; avoid bespoke metaclass or `__getattr__` machinery.

## Control flow and effects

- Choose comprehensions, generators, or loops by clarity. Avoid dense effectful comprehensions, and preserve generator lifetime and deliberate async ordering.
- Raise narrow exception types for expected failures; don't add result wrappers. Catch the narrowest type and keep the `try` block to the lines that raise. Chain context with `raise LoadError(f"load {path}") from err`. Never use bare `except:` or swallow failures callers need.
- Manage resources with `with`, `contextlib.contextmanager`, or `ExitStack`.

## Modules and boundaries

- Parse untrusted input with the existing schema library or a small parser. Type hints do not validate runtime data; keep checks where construction or mutation can violate invariants.
- Pass important dependencies explicitly. No mutable module-level state or `global`. Keep modules cohesive; no `utils.py` buckets.
- Follow existing typing, formatting, and testing conventions. Don't add a strict checker or validation library solely to impose this style.
