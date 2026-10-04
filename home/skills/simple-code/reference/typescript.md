# TypeScript

## Data and behavior

- Prefer functions, object literals, closures, and modules. Use a class when identity, encapsulated state, lifecycle, or a framework requires it, including `Error` subclasses. No static-only utility classes.
- Model closed alternatives as discriminated unions with a literal tag, narrowed by ordinary control flow. Where omissions matter, end the `switch` with a `never` check instead of a fallback `default`. Make absence explicit (`T | undefined` or a variant).
- Use structural object or function types for the capabilities a consumer calls, following the repo's `type`/`interface` convention. `readonly` constrains assignment, not deep runtime mutation. Use a brand only when a validating constructor controls it; avoid elaborate conditional or mapped types for simple models.

## Control flow and effects

- Choose array methods, `for...of`, or generators by clarity. Use `async`/`await` for sequential effects and `Promise.all` only for deliberate concurrency; an `async` callback in `forEach` is not awaited.
- Every promise is awaited, returned, or deliberately detached with a comment. Preserve cancellation (`AbortSignal`), ordering, and cleanup (`try/finally` next to acquisition, or `using` where supported).
- Follow the repo's convention for expected failures, thrown `Error`s or a result union; don't add a second, project-wide wrapper. No empty `catch`: narrow `unknown`, add context with `new Error("charge order", { cause })`, then rethrow or convert.

## Modules and boundaries

- Validate `unknown` external input with the existing schema library or a small parser. Annotations, `as`, and brands do not validate runtime data.
- Pass dependencies as parameters or capture them in a clearly constructed closure. No service locators. Add a DI container only where the framework provides one.
- Keep helpers and types in the module that uses them; no barrel files that only re-export. For JavaScript in the same project, follow its JSDoc/checking conventions without starting a migration.
