from datetime import datetime, timezone

SHOP_TZ = "Europe/Amsterdam"


def billing_period(placed_at: datetime) -> str:
    """Billing period "YYYY-MM" of an order, by the calendar month in the shop's time zone."""
    if placed_at.tzinfo is None:
        raise ValueError("placed_at must be timezone-aware")
    return placed_at.astimezone(timezone.utc).strftime("%Y-%m")
