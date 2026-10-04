# Linting

Read only when asked to set up or tighten linting.

- Inspect the existing formatter, linter, type checker, project configuration, and pinned versions. Extend that setup rather than adding a parallel toolchain.
- Consult official documentation for the installed versions before configuring rules. Use supported recommended checks as a starting point; do not copy a generic preset into every repository.
- Prefer checks for real defects: unchecked errors, unhandled promises, invalid casts, unused code, or omitted variants in a closed domain. Type checking does not replace runtime boundary validation.
- Defect checks that default or recommended setups leave off, worth considering where the repo uses the tool (verify names and options against the installed version):
  - typescript-eslint: `switch-exhaustiveness-check` (in no preset); `no-floating-promises` and `no-misused-promises` (type-checked presets only).
  - ruff: `B904`, `BLE001`, `S110` (ruff's default selection varies by release - check which are already on). pyright: `strict`, which enables `reportMatchNotExhaustive`.
  - golangci-lint: `errorlint`, `exhaustive`, `nilerr`, `forcetypeassert` (outside the `standard` set).
  - clippy: `unwrap_used`, `expect_used`, `wildcard_enum_match_arm` (restriction group, allow by default), with `allow-unwrap-in-tests` / `allow-expect-in-tests` in `clippy.toml`.
- Do not enforce design preferences with class/name bans, implementation-count quotas, fixed file/nesting limits, or blanket restrictions on language-native features.
- Enable stricter rules only for a concrete correctness or maintenance benefit. Check existing code and legitimate exceptions before widening enforcement; do not force an unrelated cleanup or dependency upgrade.
- Run the affected checks, fix findings caused by the configuration change, and rerun them. Keep full system builds and unrelated test suites proportional to the change.
