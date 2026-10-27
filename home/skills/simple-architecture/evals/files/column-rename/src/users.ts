import type { Db } from "./db";

export type User = { id: string; email: string; fullName: string };

export async function getUser(db: Db, id: string): Promise<User | undefined> {
  const row = await db.one("select id, email, full_name from users where id = $1", [id]);
  return row && { id: row.id, email: row.email, fullName: row.full_name };
}

export async function updateName(db: Db, id: string, fullName: string): Promise<void> {
  await db.exec("update users set full_name = $2 where id = $1", [id, fullName]);
}
