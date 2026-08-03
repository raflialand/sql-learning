-- Solutions: Unit 09 — Timeliness
-- Run against dq_learning. Reference date: 2026-08-03

-- =====================================================================
-- Exercise 9.1 — Freshness of orders
-- =====================================================================
SELECT
    MAX(order_date) AS latest_order,
    DATEDIFF('2026-08-03', MAX(order_date)) AS days_since_latest
FROM orders;
-- Expected: 2026-08-15 / -12

-- =====================================================================
-- Exercise 9.2 — Freshness report (orders + daily_sales)
-- =====================================================================
SELECT 'orders' AS dataset, MAX(order_date) AS max_date,
       DATEDIFF('2026-08-03', MAX(order_date)) AS days_behind
FROM orders
UNION ALL
SELECT 'daily_sales', MAX(sale_date),
       DATEDIFF('2026-08-03', MAX(sale_date))
FROM daily_sales;
-- Expected: orders -12; daily_sales 2026-07-31 / 3

-- =====================================================================
-- Exercise 9.3 — Future-dated orders
-- =====================================================================
SELECT order_id, order_date, status, total_amount
FROM orders
WHERE order_date > '2026-08-03';
-- Expected: order 5

-- =====================================================================
-- Exercise 9.4 — Future-date percentage
-- =====================================================================
SELECT
    COUNT(*) AS total_orders,
    SUM(order_date > '2026-08-03') AS future_orders,
    ROUND(SUM(order_date > '2026-08-03') * 100.0 / COUNT(*), 1) AS future_pct
FROM orders;
-- Expected: 15 / 1 / 6.7

-- =====================================================================
-- Exercise 9.5 — Future-date PASS/FAIL
-- =====================================================================
SELECT
    CASE
        WHEN SUM(order_date > '2026-08-03') = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS future_date_check
FROM orders;
-- Expected: FAIL

-- =====================================================================
-- Exercise 9.6 — Expired-but-active products
-- =====================================================================
SELECT product_id, sku, product_name, discontinued_at, is_active
FROM products
WHERE discontinued_at IS NOT NULL
  AND discontinued_at < '2026-08-03'
  AND is_active = 1;
-- Expected: product 6 (Coffee Maker)

-- =====================================================================
-- Exercise 9.7 — Missing time buckets (date spine anti-join)
-- =====================================================================
WITH RECURSIVE date_spine AS (
    SELECT '2026-07-20' AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM date_spine WHERE d < '2026-07-31'
)
SELECT s.d AS missing_date
FROM date_spine s
LEFT JOIN daily_sales ds ON ds.sale_date = s.d
WHERE ds.sale_date IS NULL
ORDER BY s.d;
-- Expected: 0 rows (every day has data)

-- =====================================================================
-- Exercise 9.8 — Combined timeliness report
-- =====================================================================
SELECT 'future-dated orders' AS check_name, COUNT(*) AS violations
FROM orders
WHERE order_date > '2026-08-03'
UNION ALL
SELECT 'expired-but-active products', COUNT(*)
FROM products
WHERE discontinued_at IS NOT NULL
  AND discontinued_at < '2026-08-03'
  AND is_active = 1;
-- Expected: 1 / 1

-- =====================================================================
-- Exercise 9.9 (TRANSLATE — for reference)
-- Reports the most recent order date and how many days behind the
-- reference date it is. Negative = future-dated data present.

-- =====================================================================
-- Exercise 9.10 (TRANSLATE — for reference)
-- Builds a calendar of every day 2026-07-20..07-31, then finds days with
-- no daily_sales row. Conclusion: any returned day is a missing bucket —
-- a silently-dropped day in reports.

-- =====================================================================
-- Exercise 9.11 — Fixed: date as string / CURDATE()
-- =====================================================================
SELECT order_id, order_date
FROM orders
WHERE order_date > '2026-08-03';
-- or: WHERE order_date > CURDATE();

-- =====================================================================
-- Exercise 9.12 — Fixed: argument order in DATEDIFF
-- =====================================================================
SELECT DATEDIFF('2026-08-03', MAX(order_date)) AS days_since
FROM orders;
-- Expected: -12

-- =====================================================================
-- Exercise 9.13 — Fixed: add "in the past" condition
-- =====================================================================
SELECT product_id, sku, discontinued_at, is_active
FROM products
WHERE discontinued_at IS NOT NULL
  AND discontinued_at < CURDATE()
  AND is_active = 1;
-- Expected: product 6
