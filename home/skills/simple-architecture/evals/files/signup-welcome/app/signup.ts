import { randomUUID } from "node:crypto";
import type { Pool } from "pg";

export async function signUp(db: Pool, email: string): Promise<string> {
  const id = randomUUID();
  await db.query("INSERT INTO users.account (id, email) VALUES ($1, $2)", [id, email]);
  return id;
}
