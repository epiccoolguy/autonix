# Python

## Data

- Records are `@dataclass(frozen=True, slots=True)`. Use `NamedTuple` for small tuples, `TypedDict` only for dict-shaped JSON at the boundary.
- Variants are a union of dataclasses, or an `Enum`, matched with `match` and closed with `assert_never`:
  ```python
  def area(s: Circle | Rect) -> float:
      match s:
          case Circle(r=r):
              return math.pi * r**2
          case Rect(w=w, h=h):
              return w * h
          case _:
              assert_never(s)
  ```
- Type hints on every function signature; the code passes pyright/mypy strict. Avoid `Any`.
- Absence is `X | None`, checked with a guard clause.

## Boundary parsing

- Parse raw dicts, env, and argv into dataclasses in one function at the edge. Use pydantic or msgspec only if the repo already has them.

## Functions and modules

- Module-level functions. Methods on a dataclass are fine when they only read its fields.
- No inheritance for code reuse. Where an interface is justified, use a `typing.Protocol` declared in the consuming module, not an ABC.
- No metaclasses, `__getattr__` tricks, or monkey-patching. Decorators only where the idiom requires them: `@dataclass`, `@property`, `functools.cache`, framework routes, pytest fixtures.
- Pass dependencies as parameters. No module-level mutable state; `global` is banned.
- No `utils.py` or `helpers.py`.

## Errors

- Exceptions are the idiom; don't fake a `Result` type.
- Expected failures raise a narrow custom exception (`class OrderNotFound(Exception)`) defined in the module that raises it. Name it in the docstring.
- Catch the narrowest type, as close to the cause as is useful. Re-raise with context: `raise ConfigError(f"load {path}") from err`.
- Never use bare `except:`, `except Exception: pass`, or log-and-continue on errors the caller should see.
- Keep `try` blocks to the lines that can raise.

## Cleanup

- `with` for every resource (files, locks, connections, temp dirs). Use `contextlib.contextmanager` or `ExitStack` instead of manual `close()`.

## Don't / do

Don't: `def export(rows, as_csv=False, gzip=False): ...`
Do: `def export_csv(rows: list[Row]) -> bytes: ...` and `def export_json(rows: list[Row]) -> bytes: ...`
