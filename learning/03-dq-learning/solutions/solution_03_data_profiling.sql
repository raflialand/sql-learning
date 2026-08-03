-- Solutions: Unit 03 — Data Profiling
-- Run against dq_learning. Reference date: 2026-08-03

-- =====================================================================
-- Exercise 3.1 — Row counts across tables
-- =====================================================================
SELECT 'daily_sales' AS tbl, COUNT(*) AS row_count FROM daily_sales
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'customers',   COUNT(*) FROM customers
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'products',    COUNT(*) FROM products
ORDER BY row_count DESC;

-- =====================================================================
-- Exercise 3.2 — NULL-rate report for orders
-- =====================================================================
SELECT
    COUNT(*)                                            AS total_rows,
    SUM(ship_city IS NULL)                              AS null_ship_city,
    ROUND(SUM(ship_city IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_ship_city,
    SUM(total_amount IS NULL)                           AS null_total_amount,
    ROUND(SUM(total_amount IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_total,
    SUM(status IS NULL)                                 AS null_status,
    ROUND(SUM(status IS NULL) * 100.0 / COUNT(*), 1)    AS pct_null_status
FROM orders;

-- =====================================================================
-- Exercise 3.3 — Price statistics
-- =====================================================================
SELECT
    ROUND(MIN(unit_price), 2)         AS min_price,
    ROUND(MAX(unit_price), 2)         AS max_price,
    ROUND(AVG(unit_price), 2)         AS avg_price,
    ROUND(STDDEV_POP(unit_price), 2)  AS stddev_price
FROM products;
-- min = -5.00 (negative price!) and a zero-price product exist.
-- Both are validity defects; statistics surfaced them for free.
-- avg = 40.08, stddev = 63.05

-- =====================================================================
-- Exercise 3.4 — Frequency of order statuses
-- =====================================================================
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status
ORDER BY cnt DESC;
-- shipped(9), pending(2), Shipped(1), SHIPPED(1), shippd(1), cancelled(1)
-- Conclusion: casing variants (Shipped/SHIPPED) + typo (shippd) inflate
-- the value set -> validity + consistency issues.

-- =====================================================================
-- Exercise 3.5 — Bucketed price frequency
-- =====================================================================
SELECT
    CASE
        WHEN unit_price < 0   THEN 'negative'
        WHEN unit_price = 0   THEN 'zero'
        WHEN unit_price < 50  THEN '0-50'
        WHEN unit_price < 100 THEN '50-100'
        WHEN unit_price < 200 THEN '100-200'
        ELSE '200+'
    END AS price_band,
    COUNT(*) AS cnt
FROM products
GROUP BY price_band
ORDER BY price_band;

-- =====================================================================
-- Exercise 3.6 — Cardinality of customers
-- =====================================================================
SELECT
    COUNT(*)              AS total_rows,
    COUNT(email)          AS non_null_emails,
    COUNT(DISTINCT email) AS distinct_emails,
    COUNT(phone)          AS non_null_phones,
    COUNT(DISTINCT phone) AS distinct_phones
FROM customers;
-- phones: 12 non-null, 9 distinct -> three pairs share a phone:
-- customers 1&2, 3&4, and 11&12

-- =====================================================================
-- Exercise 3.7 (TRANSLATE — for reference)
-- Reports nullability of order_id/customer_id, EUR order count, distinct
-- status count, and latest order date. Reader should notice: latest date
-- is in the future (timeliness), statuses are messy (validity), EUR orders
-- exist (consistency).

-- =====================================================================
-- Exercise 3.8 (TRANSLATE — for reference)
-- Profiles products: min/max/avg weight, distinct categories, NULL categories.
-- max_weight 150.00 for a chair is implausible -> accuracy/validity lead.
-- distinct categories counts 'Office' and 'Home & Office' as separate.

-- =====================================================================
-- Exercise 3.9 — Fixed NULL percentage (float division)
-- =====================================================================
SELECT
    COUNT(*) AS total,
    SUM(email IS NULL) AS nulls,
    ROUND(SUM(email IS NULL) * 100.0 / COUNT(*), 2) AS pct
FROM customers;
-- Multiplying by 100.0 forces floating-point division.

-- =====================================================================
-- Exercise 3.10 — Fixed distinct state count
-- =====================================================================
SELECT COUNT(DISTINCT state) AS distinct_states
FROM customers;
-- 11. Higher than ~50 states *because* of consistency defects:
-- 'CA'/'California', 'OR'/'Oregon', lowercase 'tx'.

-- =====================================================================
-- Exercise 3.11 — Fixed frequency query
-- =====================================================================
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status
ORDER BY cnt DESC;
-- Group by the categorical column (status), not the alias (cnt);
-- order by the count descending for "most frequent first".
