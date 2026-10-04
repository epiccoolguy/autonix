# Linting

Read only when asked to set up or tighten linting.

- Inspect the existing formatter, linter, type checker, project configuration, and pinned versions. Extend that setup rather than adding a parallel toolchain.
- Consult official documentation for the installed versions before configuring rules. Use supported recommended checks as a starting point; do not copy a generic preset into every repository.
- Prefer checks for real defects: unchecked errors, unhandled promises, invalid casts, unused code, or omitted variants in a closed domain. Type checking does not replace runtime boundary validation.
- Do not enforce design preferences with class/name bans, implementation-count quotas, fixed file/nesting limits, or blanket restrictions on language-native features.
- Enable stricter rules only for a concrete correctness or maintenance benefit. Check existing code and legitimate exceptions before widening enforcement; do not force an unrelated cleanup or dependency upgrade.
- Run the affected checks, fix findings caused by the configuration change, and rerun them. Keep full system builds and unrelated test suites proportional to the change.
