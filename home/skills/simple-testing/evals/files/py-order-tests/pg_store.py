from decimal import Decimal

import psycopg

from orders import Order


class PostgresOrderStore:
    def __init__(self, conn: psycopg.Connection):
        self.conn = conn

    def save(self, order: Order) -> None:
        self.conn.execute(
            "INSERT INTO orders (id, customer_email, total, status) VALUES (%s, %s, %s, %s)"
            " ON CONFLICT (id) DO UPDATE SET total = EXCLUDED.total, status = EXCLUDED.status",
            (order.id, order.customer_email, order.total, order.status),
        )

    def get(self, order_id: str) -> Order | None:
        row = self.conn.execute(
            "SELECT id, customer_email, total, status FROM orders WHERE id = %s", (order_id,)
        ).fetchone()
        if row is None:
            return None
        return Order(row[0], row[1], [], Decimal(row[2]), row[3])
