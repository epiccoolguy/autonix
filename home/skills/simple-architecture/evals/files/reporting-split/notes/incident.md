# Incident: slow checkout on 2026-10-01

Checkout p95 went from 180 ms to 2.4 s between 09:00 and 10:30 while finance ran the monthly revenue
report about 15 times. Database CPU was at 95%; the report query does a sequential scan of
checkout.orders (40M rows) because of the to_char() filter. Outside month-end, load is low.
