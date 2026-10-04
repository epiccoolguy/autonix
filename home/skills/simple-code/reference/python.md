# Python Idioms

Write Python with idiomatic, modern simplicity: module-level functions, clean dataclasses, explicit control flow, and context managers. Avoid heavy abstract class hierarchies and Java-like patterns.

## Core Defaults

- Prefer module-level functions, plain values, and standard collections over elaborate class hierarchies.
- Use classes when encapsulating stateful resources, identity, or implementing context managers (`__enter__`/`__exit__`).
- Do not create abstract base classes (ABCs) or factory classes when functions or closures satisfy the requirement.

## Data Modeling & Invariants

- Use `dataclass(frozen=True)` or `NamedTuple` for passive, immutable data records. Use `TypedDict` for structured dictionary shapes (e.g. JSON payloads).
- Model domain variants with `Enum` or unions of distinct dataclasses. Narrow them with `match` or `isinstance` statements.
- Use `typing.assert_never` in match arms to enforce compile-time exhaustiveness where omitted variants would cause bugs.
- Parse untrusted external data (JSON, configs) at boundaries using schema validators (e.g. Pydantic, msgspec). Type annotations alone do not enforce runtime validation.

## Functions, Modules & Composition

- Keep functions small, focused, and pure where practical.
- Use modules as natural namespaces. Group related functions in a file; avoid single-method classes or `utils.py` dumping grounds.
- Replace OOP patterns with language features:
  * Strategy -> Callable parameter or closure.
  * Command -> Dataclass representing the command passed to an executor.
  * Decorator -> Native Python function decorator (`@wraps`).
  * Factory -> Standard constructor or factory function returning a dataclass.

## Error Handling & Control Flow

- Use idiomatic Python exceptions for errors. Catch specific, narrow exception types; never use bare `except:` or `except Exception:` unless logging at a top-level process boundary.
- Do not force foreign `Result` object hierarchies onto Python code; Python's idiomatic path is linear flow with early guards and clean exception raising.
- Use `try/except` with guard returns to keep main logic unindented.
- Use context managers (`with` blocks or `@contextmanager`) for deterministic resource cleanup (file handles, database connections, locks).

## Boundaries, Dependencies & Testing

- Pass dependencies explicitly as function arguments or class initialization parameters.
- Use `typing.Protocol` to define narrow structural capabilities needed by callers, avoiding rigid inheritance coupling.
- Test against real in-memory implementations or standard library fakes (e.g. `sqlite3`, `io.BytesIO`) before reaching for complex mock frameworks.

## Side-by-Side Comparison

### Data Modeling & Operations

AVOID (Java-style Abstract Base Classes & Factories):
```python
from abc import ABC, abstractmethod

class NotificationSender(ABC):
    @abstractmethod
    def send(self, recipient: str, message: str) -> None:
        pass

class EmailNotificationSender(NotificationSender):
    def send(self, recipient: str, message: str) -> None:
        send_email(recipient, message)

class NotificationSenderFactory:
    @staticmethod
    def get_sender(kind: str) -> NotificationSender:
        if kind == "email":
            return EmailNotificationSender()
        raise ValueError(f"Unknown kind: {kind}")
```

DO (Protocols, Plain Dataclasses & Functions):
```python
from typing import Protocol, Callable
from dataclasses import dataclass

class Notifier(Protocol):
    def __call__(self, recipient: str, message: str) -> None: ...

@dataclass(frozen=True)
class Notification:
    recipient: str
    message: str

def send_notification(notify: Notifier, notif: Notification) -> None:
    notify(notif.recipient, notif.message)
```

### Control Flow & Resource Management

AVOID (Manual Resource Tracking & Generic Catch):
```python
def process_data(filepath: str) -> list[str]:
    handle = open(filepath, "r")
    try:
        data = handle.read()
        lines = [line.strip() for line in data.splitlines()]
        return lines
    except Exception as e:
        print("Failed to read file", e)
        return []
    finally:
        handle.close()
```

DO (Context Managers & Narrow Handling):
```python
from pathlib import Path

def process_data(filepath: Path) -> list[str]:
    if not filepath.exists():
        return []

    with filepath.open(encoding="utf-8") as f:
        return [line.strip() for line in f if line.strip()]
```
