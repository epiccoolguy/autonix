import unittest
from datetime import datetime, timezone

from billing import billing_period


class BillingPeriodTest(unittest.TestCase):
    def test_mid_month_order(self):
        placed = datetime(2026, 3, 15, 12, 0, tzinfo=timezone.utc)
        self.assertEqual(billing_period(placed), "2026-03")

    def test_naive_datetime_rejected(self):
        with self.assertRaises(ValueError):
            billing_period(datetime(2026, 3, 15, 12, 0))


if __name__ == "__main__":
    unittest.main()
