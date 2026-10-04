# Rust lint (opt-in)

Optional correctness checks, not mechanical enforcement of design preferences. Select rules that fit existing code and required contracts; do not use implementation counts, class/name bans, or fixed complexity limits as proxies for simplicity.

Reference only - merge into a project's `Cargo.toml` / `clippy.toml` when asked. Check the project's toolchain version before copying. The compiler already rejects non-exhaustive `match`.

| Rule | Enforced by |
|---|---|
| No `_` arm on your own enums | `wildcard_enum_match_arm` (restriction), `match_wildcard_for_single_variants` (pedantic) |
| Panics only for bugs | `unwrap_used`, `expect_used`, `panic`, `todo`, `unimplemented` (restriction) |
| Take ownership only when needed | `needless_pass_by_value` (pedantic) |
| Few parameters | `too_many_arguments` (complexity, warns by default) |

`Cargo.toml`:
```toml
[lints.clippy]
wildcard_enum_match_arm = "warn"
match_wildcard_for_single_variants = "warn"
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
todo = "warn"
unimplemented = "warn"
needless_pass_by_value = "warn"
```

`clippy.toml`:
```toml
allow-unwrap-in-tests = true
allow-expect-in-tests = true
allow-panic-in-tests = true
```
