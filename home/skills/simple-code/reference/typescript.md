# TypeScript

## Data and behavior

- Prefer functions, object literals, closures, and modules. Use a class when identity, encapsulated state, lifecycle, or the framework requires it, including `Error` subclasses. No static-only utility classes.
- Model closed alternatives as discriminated unions with a literal tag. Where omissions matter, end the `switch` with a `never` check instead of a fallback `default`.
- Type the capability a consumer calls as a function type or small structural type, following the repo's `type`/`interface` convention. Use a brand only behind a validating constructor; no conditional or mapped types for simple models.

## Control flow and effects

- Every promise is awaited, returned, or deliberately detached with a comment. Use `Promise.all` only for deliberate concurrency. Release resources in `try/finally` next to acquisition, or with `using` where supported.
- Follow the repo's convention for expected failures, thrown `Error`s or a result union; don't add a second, project-wide wrapper. No empty `catch`: narrow `unknown`, add context with `new Error("charge order", { cause })`, then rethrow or convert.

## Modules and boundaries

- Validate `unknown` external input with the existing schema library or a small parser, never with `as`.
- Pass dependencies as parameters or capture them in a clearly constructed closure. Add a DI container only where the framework provides one.
- Keep helpers and types in the module that uses them; no barrel files that only re-export. For JavaScript in the same project, follow its JSDoc/checking conventions without starting a migration.
