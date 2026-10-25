import type { Pool } from "pg";

export interface RequestContext {
  user: { sub: string };
  traceId: string;
}

export async function updateAmount(db: Pool, ctx: RequestContext, invoiceId: string, amountCents: number): Promise<void> {
  void ctx;
  const res = await db.query(
    "UPDATE billing.invoice SET amount_cents = $2, updated_at = now() WHERE id = $1 AND status = 'open'",
    [invoiceId, amountCents],
  );
  if (res.rowCount === 0) throw new Error("invoice not found or not open");
}
