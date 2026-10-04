# Planning

A plan is required before code when the change touches more than one file, adds a type, or adds or changes a public API. Otherwise just write the code.

## Pre-coding check

Answer in order; each "no" is a design to remove before writing.

1. Can this live in one file (the caller's file or one new module)?
2. Can each operation be a plain function taking plain data?
3. Is every interface, generic parameter, option, or wrapper used by two concrete paths in this change? If not, delete it and write the concrete code.

## Template

Keep it under ~30 lines. Use the existing format for plans: numbered concrete steps, then open questions.

```
Goal: <one line>

Types:
  <the data definitions, in the target language>

Signatures:
  <function signatures, in the target language>

Failure modes:
  - <failure> -> <how it is represented (error value, variant, exception)> -> <who handles it>

Steps:
  1. ...

Open questions:
  - ...
```

## Rules

- Write types and signatures in the target language, not pseudo-code.
- List every expected failure: invalid input, not found, conflict, timeout, permission. Bugs are not failure modes.
- Name the boundary where untrusted input becomes a precise type.
- State the reason for each new dependency.
- Design for current requirements only. "Might need later" is not a reason.
- Ask for confirmation only when the plan changes an externally consumed interface or makes a breaking change; otherwise proceed.
