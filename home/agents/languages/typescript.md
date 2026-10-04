# TypeScript Idioms

Write TypeScript like typed Go or Zig: imperative clarity, plain data shapes, pure functions, and early guard returns. Reject enterprise-Java OOP patterns.

## Rules

- Use `type` or `interface` solely to define passive data shapes.
- No `class` declarations unless required by third-party frameworks (e.g. React Error Boundaries, NestJS). Prefer modules of exported functions.
- Model multi-state domains with discriminated unions (`{ status: 'idle' } | { status: 'active', data: ... }`), never inheritance hierarchies.
- Use explicit result types or tuple returns `[Result, Error?]` for anticipated operational failures; do not throw exceptions across module boundaries.

## Side-by-Side Comparison

### Data Modeling & Logic

AVOID (Enterprise OOP & Factory Pattern):
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

DO (Plain Types & Functions):
```ts
export type User = {
  id: string;
  firstName: string;
  lastName: string;
};

export function formatDisplayName(user: User): string {
  return `${user.firstName} ${user.lastName}`.trim();
}

export async function fetchUser(fetcher: (id: string) => Promise<User>, id: string): Promise<User> {
  return fetcher(id);
}
```

### Error Handling & Control Flow

AVOID (Nested Try/Catch & Custom Exception Hierarchy):
```ts
class ValidationException extends Error {}
class DatabaseException extends Error {}

async function processOrder(orderId: string): Promise<void> {
  try {
    const order = await getOrder(orderId);
    if (!order) {
      throw new ValidationException("Not found");
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

DO (Result Values & Linear Guards):
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
