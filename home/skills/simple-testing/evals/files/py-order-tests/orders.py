from dataclasses import dataclass
from decimal import Decimal
from typing import Protocol

import pricing


@dataclass
class Order:
    id: str
    customer_email: str
    lines: list[tuple[str, int, Decimal]]
    total: Decimal
    status: str = "placed"


class OrderStore(Protocol):
    def save(self, order: Order) -> None: ...
    def get(self, order_id: str) -> Order | None: ...


class Mailer(Protocol):
    def send(self, to: str, subject: str, body: str) -> None: ...


def place_order(
    store: OrderStore,
    mailer: Mailer,
    order_id: str,
    customer_email: str,
    lines: list[tuple[str, int, Decimal]],
    coupon: str | None = None,
) -> Order:
    order = Order(order_id, customer_email, lines, pricing.total(lines, coupon))
    store.save(order)
    try:
        mailer.send(customer_email, f"Order {order_id} confirmed", f"Total: {order.total}")
    except Exception:
        order.status = "confirmation_pending"
        store.save(order)
    return order
