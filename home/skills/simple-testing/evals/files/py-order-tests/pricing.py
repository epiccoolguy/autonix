from decimal import Decimal

COUPONS = {"WELCOME10": Decimal("0.10")}


def total(lines: list[tuple[str, int, Decimal]], coupon: str | None = None) -> Decimal:
    subtotal = sum((price * qty for _, qty, price in lines), Decimal("0"))
    if coupon is not None:
        if coupon not in COUPONS:
            raise ValueError(f"unknown coupon {coupon}")
        subtotal -= (subtotal * COUPONS[coupon]).quantize(Decimal("0.01"))
    return max(subtotal, Decimal("0"))
