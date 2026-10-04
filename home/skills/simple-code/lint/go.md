# Go lint (opt-in)

Optional correctness checks, not mechanical enforcement of design preferences. Select rules that fit existing code and required contracts; do not use implementation counts, class/name bans, or fixed complexity limits as proxies for simplicity.

Reference only - merge into a project's `.golangci.yml` when asked. Targets golangci-lint v2; check the project's installed version before copying.

| Rule | Enforced by |
|---|---|
| Check errors and preserve error identity | `errcheck` (standard), `errorlint`, `nilerr` |
| Exhaustive enum `switch` | `exhaustive` |
| No unchecked type assertions | `forcetypeassert` |

```yaml
version: "2"
linters:
  default: standard
  enable:
    - errorlint
    - exhaustive
    - forcetypeassert
    - iface
    - nilerr
    - revive
    - unparam
  settings:
    exhaustive:
      default-signifies-exhaustive: false
    iface:
      enable: [identical, unused, opaque]
    revive:
      rules:
        - name: early-return
        - name: indent-error-flow
        - name: superfluous-else
        - name: unused-parameter
```
