# Python lint (opt-in)

Reference only - merge into a project's `pyproject.toml` when asked. Check the project's installed ruff and pyright versions before copying.

| Rule | Enforced by |
|---|---|
| Never swallow errors; add context | `BLE001`, `E722`, `S110`, `B904` |
| No mutable globals | `PLW0603` |
| No unused params | `ARG` |
| No boolean flag params | `FBT` |
| Guard clauses, no `else` after `return` | `RET505`-`RET508`, `SIM` |
| Nesting depth 3 | `PLR1702` (preview-only, default 5), `C901` as a backstop |
| No `Any` | `ANN401`, pyright strict |
| Exhaustive `match` | pyright `reportMatchNotExhaustive` (off even in strict) |

```toml
[tool.ruff.lint]
preview = true
explicit-preview-rules = true
select = [
  "E", "F", "B", "UP", "SIM", "RET", "ARG", "FBT",
  "BLE001", "S110", "PLW0603", "ANN", "C90", "TRY", "PLR1702",
]
ignore = ["TRY003"]

[tool.ruff.lint.pylint]
max-nested-blocks = 3

[tool.ruff.lint.mccabe]
max-complexity = 10

[tool.pyright]
typeCheckingMode = "strict"
reportMatchNotExhaustive = "error"
```
`explicit-preview-rules` limits preview to the rules named in `select` (here only `PLR1702`).
