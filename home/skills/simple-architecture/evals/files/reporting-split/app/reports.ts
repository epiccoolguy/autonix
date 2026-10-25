import type { Pool } from "pg";

// Run by finance on the first working day of the month, often several times.
export async function monthlyRevenue(db: Pool, month: string) {
  const res = await db.query(
    `SELECT p.category, date_trunc('day', o.placed_at) AS day, sum(l.qty * l.price_cents) AS revenue_cents
       FROM checkout.order_line l
       JOIN checkout.orders o ON o.id = l.order_id
       JOIN catalog.product p ON p.id = l.product_id
      WHERE to_char(o.placed_at, 'YYYY-MM') = $1
      GROUP BY 1, 2
      ORDER BY 1, 2`,
    [month],
  );
  return res.rows;
}
