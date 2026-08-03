-- Solutions: Unit 04 — Completeness
-- Run against dq_learning. Reference date: 2026-08-03

-- =====================================================================
-- Exercise 4.1 — Missing emails (NULL or empty/whitespace)
-- =====================================================================
SELECT customer_id, email
FROM customers
WHERE email IS NULL OR TRIM(email) = '';
-- Expected: customer 5 and 14

-- =====================================================================
-- Exercise 4.2 — Orders missing required fields
-- =====================================================================
SELECT
    order_id,
    (total_amount IS NULL)  AS missing_amount,
    (customer_id IS NULL)   AS missing_customer,
    (order_date IS NULL)    AS missing_date
FROM orders
WHERE total_amount IS NULL
   OR customer_id IS NULL
   OR order_date IS NULL;
-- Expected: order 4 (missing_amount = 1)

-- =====================================================================
-- Exercise 4.3 — Email completeness ratio
-- =====================================================================
SELECT
    COUNT(email)                              AS emails_present,
    COUNT(*)                                  AS total_rows,
    ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS completeness_pct
FROM customers;
-- Expected: 86.7

-- =====================================================================
-- Exercise 4.4 — PASS/FAIL threshold rule (email >= 99%)
-- =====================================================================
SELECT
    CASE
        WHEN ROUND(COUNT(email) * 100.0 / COUNT(*), 1) >= 99 THEN 'PASS'
        ELSE 'FAIL'
    END AS email_completeness_check
FROM customers;
-- Expected: FAIL

-- =====================================================================
-- Exercise 4.5 — PASS/FAIL threshold rule (phone >= 90%)
-- =====================================================================
SELECT
    CASE
        WHEN ROUND(COUNT(phone) * 100.0 / COUNT(*), 1) >= 90 THEN 'PASS'
        ELSE 'FAIL'
    END AS phone_completeness_check
FROM customers;
-- Expected: FAIL (80%)

-- =====================================================================
-- Exercise 4.6 — Multi-column completeness report (UNION ALL)
-- =====================================================================
SELECT 'orders.total_amount' AS field, COUNT(*) AS total,
       ROUND(COUNT(total_amount) * 100.0 / COUNT(*), 1) AS completeness_pct
FROM orders
UNION ALL
SELECT 'orders.status', COUNT(*),
       ROUND(COUNT(status) * 100.0 / COUNT(*), 1)
FROM orders
UNION ALL
SELECT 'orders.ship_city', COUNT(*),
       ROUND(COUNT(ship_city) * 100.0 / COUNT(*), 1)
FROM orders;
-- Expected: 93.3 / 93.3 / 86.7

-- =====================================================================
-- Exercise 4.7 — Classify customers by completeness level
-- =====================================================================
SELECT
    CASE
        WHEN email IS NULL AND phone IS NULL AND state IS NULL
             AND first_name IS NULL THEN 'fully empty'
        WHEN email IS NULL OR phone IS NULL OR state IS NULL
             OR first_name IS NULL THEN 'partially complete'
        ELSE 'fully complete'
    END AS completeness_level,
    COUNT(*) AS cnt
FROM customers
GROUP BY completeness_level;
-- Expected: fully complete 8, partially complete 6, fully empty 1

-- =====================================================================
-- Exercise 4.8 — Orders with no line items (cross-table completeness)
-- =====================================================================
SELECT o.order_id
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.item_id IS NULL;
-- Expected: zero rows

-- =====================================================================
-- Exercise 4.9 (TRANSLATE — for reference)
-- Counts orders with NULL total_amount. Business implication: finance
-- cannot book revenue for these orders; revenue reporting is incomplete.

-- =====================================================================
-- Exercise 4.10 (TRANSLATE — for reference)
-- Completeness report for order_items. All three are 100% (no NULLs in
-- qty, unit_price, or total_price in this dataset). The check still
-- matters: NULLs are the "silent skip" that reporting tools mishandle.

-- =====================================================================
-- Exercise 4.11 — Fixed: IS NULL not = NULL
-- =====================================================================
SELECT customer_id, email
FROM customers
WHERE email IS NULL OR TRIM(email) = '';
-- `= NULL` always evaluates to UNKNOWN (false); use IS NULL.

-- =====================================================================
-- Exercise 4.12 — Fixed: float division
-- =====================================================================
SELECT ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS pct FROM customers;
-- Expected: 86.7 (multiply by 100.0 to force floating-point division)

-- =====================================================================
-- Exercise 4.13 — Fixed: OR not AND for "any missing"
-- =====================================================================
SELECT order_id
FROM orders
WHERE total_amount IS NULL
   OR customer_id IS NULL
   OR order_date IS NULL;
-- Expected: order 4
