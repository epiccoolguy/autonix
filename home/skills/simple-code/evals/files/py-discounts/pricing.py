from dataclasses import dataclass
from decimal import Decimal


@dataclass(frozen=True)
class LineItem:
    sku: str
    unit_price: Decimal
    quantity: int


def subtotal(items: list[LineItem]) -> Decimal:
    return sum((item.unit_price * item.quantity for item in items), Decimal("0"))


def total(items: list[LineItem]) -> Decimal:
    return subtotal(items)
