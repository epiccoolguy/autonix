# Go lint (opt-in)

Reference only - merge into a project's `.golangci.yml` when asked. Targets golangci-lint v2; check the project's installed version before copying.

| Rule | Enforced by |
|---|---|
| Never ignore errors; add context | `errcheck` (standard), `wrapcheck`, `errorlint`, `nilerr` |
| Exhaustive enum `switch` | `exhaustive` |
| No mutable globals, no `init()` | `gochecknoglobals`, `gochecknoinits` |
| Interfaces at the consumer, return structs | `iface`, `ireturn` |
| Guard clauses; nesting depth 3 | revive `early-return`, `indent-error-flow`, `superfluous-else`, `max-control-nesting`; `nestif` |
| No unused or flag params | `unparam`, revive `unused-parameter`, `flag-parameter` |
| No unchecked type assertions | `forcetypeassert` |

```yaml
version: "2"
linters:
  default: standard
  enable:
    - errorlint
    - exhaustive
    - forcetypeassert
    - gochecknoglobals
    - gochecknoinits
    - iface
    - ireturn
    - nestif
    - nilerr
    - revive
    - unparam
    - wrapcheck
  settings:
    exhaustive:
      default-signifies-exhaustive: false
    iface:
      enable: [identical, unused, opaque]
    nestif:
      min-complexity: 4
    revive:
      rules:
        - name: early-return
        - name: indent-error-flow
        - name: superfluous-else
        - name: unused-parameter
        - name: flag-parameter
        - name: max-control-nesting
          arguments: [3]
```
`gochecknoglobals` exempts sentinel errors (`var ErrX = errors.New(...)`), so they need no `//nolint`.
