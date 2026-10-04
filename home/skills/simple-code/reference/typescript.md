# TypeScript and JavaScript Idioms

Write TypeScript with direct, data-first clarity: plain data shapes, exported functions, discriminated unions, and linear flow. Avoid enterprise-Java OOP patterns and speculative ceremony.

## Core Defaults

- Prefer plain functions, object literals, closures, and file-level modules over class hierarchies.
- Use `class` only when identity, encapsulated state, lifecycle hooks, or framework requirements (e.g. React components/boundaries, NestJS) genuinely benefit.
- Never introduce static utility classes, service/factory hierarchies, or container-based dependency injection for plain procedural logic.

## Data Modeling & Invariants

- Use `type` or `interface` solely to define passive data shapes. Follow repository convention rather than enforcing a rigid type vs interface preference.
- Model multi-state domains with discriminated unions (`{ status: 'idle' } | { status: 'active', data: ... }`), narrowed via standard control flow.
- Use exhaustive checks with a `never` assignment where missing a variant introduces defects.
- Validate untrusted external input (HTTP payloads, environment variables, disk reads) at system boundaries using runtime parsers/schemas (e.g. Zod, ArkType). Static type assertions (`as Type`) do not validate runtime data.

## Functions, Modules & Composition

- Organize code into cohesive file-level modules. A file with exported functions is already an encapsulated module.
- Replace textbook OOP patterns with native constructs:
  * Strategy -> Callback function or parameter.
  * Command -> Discriminated union parsed by a handler function.
  * Factory -> Plain constructor function returning an object literal.
  * Decorator -> Higher-order wrapper function.

## Error Handling & Control Flow

- Use `async`/`await` for sequential asynchronous effects.
- For anticipated domain failures (e.g. validation failure, resource not found), use explicit discriminated unions (`type Result<T, E> = { ok: true; value: T } | { ok: false; error: E }`) or nullable returns with early guard clauses.
- Use exceptions for truly unexpected runtime failures or when required by an established framework.
- Avoid catching and rethrowing generic errors across multiple intermediate layers without adding actionable context.

## Boundaries, Dependencies & Testing

- Pass dependencies explicitly as function arguments or capture them in a cleanly constructed closure during entry-point initialization.
- Define structural object interfaces or function signatures at the consumer call-site to isolate real I/O (network, database, clock) for tests.
- Do not mirror concrete implementations into mock-only interfaces when tests can run directly against in-memory implementations.

## Side-by-Side Comparison

### Data Modeling & Operations

AVOID (Enterprise OOP & Factory Bloat):
```ts
interface IUserRepository {
  findById(id: string): Promise<User>;
}

class UserService {
  constructor(private readonly userRepo: IUserRepository) {}

  async getUserDisplayName(id: string): Promise<string> {
    const user = await this.userRepo.findById(id);
    return `${user.firstName} ${user.lastName}`;
  }
}

class UserServiceFactory {
  static create(repo: IUserRepository): UserService {
    return new UserService(repo);
  }
}
```

DO (Plain Types & Exported Functions):
```ts
export type User = {
  id: string;
  firstName: string;
  lastName: string;
};

export function formatDisplayName(user: User): string {
  return `${user.firstName} ${user.lastName}`.trim();
}

export async function fetchUser(
  fetcher: (id: string) => Promise<User>,
  id: string,
): Promise<User> {
  return fetcher(id);
}
```

### Error Handling & Control Flow

AVOID (Deeply Nested Exceptions & Try/Catch Ladders):
```ts
class ValidationException extends Error {}
class DatabaseException extends Error {}

async function processOrder(orderId: string): Promise<void> {
  try {
    const order = await getOrder(orderId);
    if (!order) {
      throw new ValidationException("Order not found");
    }
    try {
      await chargeOrder(order);
    } catch (e) {
      throw new DatabaseException("Charge failed", { cause: e });
    }
  } catch (err) {
    logger.error(err);
    throw err;
  }
}
```

DO (Result Values & Linear Early Return Guards):
```ts
export type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

export async function processOrder(orderId: string): Promise<Result<void, string>> {
  const order = await getOrder(orderId);
  if (!order) {
    return { ok: false, error: "Order not found" };
  }

  const charge = await chargeOrder(order);
  if (!charge.ok) {
    return { ok: false, error: `Charge failed: ${charge.error}` };
  }

  return { ok: true, value: undefined };
}
```
