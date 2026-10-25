import type { Pool } from "pg";

export interface Profile {
  id: string;
  displayName: string;
}

export async function getProfile(db: Pool, userId: string): Promise<Profile | undefined> {
  const res = await db.query("SELECT id, display_name FROM users.profile WHERE id = $1", [userId]);
  const row = res.rows[0];
  return row && { id: row.id, displayName: row.display_name };
}
