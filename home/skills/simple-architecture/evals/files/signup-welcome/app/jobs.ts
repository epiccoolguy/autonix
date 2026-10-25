import type { PoolClient } from "pg";

export type Handler = (payload: unknown) => Promise<void>;
export const handlers = new Map<string, Handler>();

export async function enqueue(tx: PoolClient, kind: string, payload: unknown, dedupeKey?: string): Promise<void> {
  await tx.query(
    "INSERT INTO public.jobs (kind, payload, dedupe_key) VALUES ($1, $2, $3) ON CONFLICT (dedupe_key) DO NOTHING",
    [kind, JSON.stringify(payload), dedupeKey ?? null],
  );
}
