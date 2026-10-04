# TypeScript

## Data

- Data shapes are `type` aliases (or `interface` for object shapes the repo already writes that way). Mark fields `readonly` and use `as const` for literal tables.
- Variants are discriminated unions with a literal tag (`kind` or `status`). Use string literal unions instead of `enum`.
- Exhaustive `switch` on the tag: no `default` arm, and end with a `never` check so a new variant fails to compile.
  ```ts
  function area(s: Shape): number {
    switch (s.kind) {
      case "circle": return Math.PI * s.r ** 2;
      case "rect": return s.w * s.h;
    }
    const unreachable: never = s;
    throw new Error(`unhandled shape ${JSON.stringify(unreachable)}`);
  }
  ```
- No `any`. Use `unknown` at the boundary and narrow it. Use `as` only after narrowing, never to silence the compiler. No `!` non-null assertions.

## Boundary parsing

- Parse `unknown` input into a precise type in one function at the edge. Use the schema library the repo already has (zod, valibot); otherwise hand-write the parse function.
- Branded types for parsed primitives: `type Email = string & { readonly __brand: "Email" }`.

## Functions and modules

- A module of exported functions, not a class. Classes only for `Error` subclasses or when a framework requires them (React error boundaries, NestJS, Angular).
- No static-only classes and no singleton instances. No barrel `index.ts` files that only re-export.
- Pass dependencies as parameters (`fetchUser(db, id)`), not constructor injection.

## Errors

- Expected domain failures inside your own code return a discriminated union:
  ```ts
  type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };
  ```
  Define it once per project, next to its first use, unless the repo already has one. No tuple returns `[value, err]`.
- Throw only for bugs, and at framework edges where the framework expects throws (HTTP handlers, React Query). Throw `Error` subclasses only, never strings.
- `catch (e)`: `e` is `unknown`; narrow it, add context with `new Error("charge order", { cause: e })`, rethrow or convert to a value. Never an empty `catch`.
- Every promise is awaited, returned, or explicitly `void`-ed with a comment explaining why.

## Cleanup

- `using` / `await using` with `Symbol.dispose` where the runtime supports it; otherwise `try { ... } finally { release() }` right after acquiring.

## Don't / do

Don't:
```ts
class UserService {
  constructor(private readonly repo: IUserRepository) {}
  async displayName(id: string) { const u = await this.repo.findById(id); return `${u.first} ${u.last}`; }
}
```
Do:
```ts
export function displayName(user: User): string {
  return `${user.first} ${user.last}`.trim();
}
```
