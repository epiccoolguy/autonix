# Python lint (opt-in)

Optional correctness checks, not mechanical enforcement of design preferences. Select rules that fit existing code and required contracts; do not use implementation counts, class/name bans, or fixed complexity limits as proxies for simplicity.

Reference only - merge into a project's `pyproject.toml` when asked. Check the project's installed ruff and pyright versions before copying.

| Rule | Enforced by |
|---|---|
| Never swallow errors; add context | `BLE001`, `E722`, `S110`, `B904` |
| No unused params | `ARG` |
| Guard clauses, no `else` after `return` | `RET505`-`RET508`, `SIM` |
| No `Any` | `ANN401`, pyright strict |
| Exhaustive `match` | pyright `reportMatchNotExhaustive` (off even in strict) |

```toml
[tool.ruff.lint]
select = [
  "E", "F", "B", "UP", "SIM", "RET", "ARG",
  "BLE001", "S110", "ANN", "TRY",
]
ignore = ["TRY003"]

[tool.pyright]
typeCheckingMode = "strict"
reportMatchNotExhaustive = "error"
```
