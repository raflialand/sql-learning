-- Solutions: Unit 08 — Consistency
-- Run against dq_learning (load dq_dataset_clean.sql for dq_clean_* tables)

-- =====================================================================
-- Exercise 8.1 — Orphan orders (no matching customer)
-- =====================================================================
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- Expected: order 3 (customer_id 99)

-- =====================================================================
-- Exercise 8.2 — Orphan order items (no matching product)
-- =====================================================================
SELECT oi.item_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
-- Expected: item 4 (product_id 99)

-- =====================================================================
-- Exercise 8.3 — Orphan order items (no matching order)
-- =====================================================================
SELECT oi.item_id, oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
-- Expected: item 20 (order_id 999)

-- =====================================================================
-- Exercise 8.4 — Combined referential integrity report
-- =====================================================================
SELECT 'orders.customer_id' AS relation, o.order_id AS child_id, o.customer_id AS fk_value
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'order_items.product_id', oi.item_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'order_items.order_id', oi.item_id, oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
-- Expected: 3 rows

-- =====================================================================
-- Exercise 8.5 — Currency inconsistency (items vs orders)
-- =====================================================================
SELECT oi.item_id, oi.order_id, oi.currency AS item_currency, o.currency AS order_currency
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.currency <> o.currency;
-- Expected: item 14 (USD) under order 12 (EUR)

-- =====================================================================
-- Exercise 8.6 — State inconsistency (operational vs master)
-- =====================================================================
SELECT c.customer_id, c.state AS operational_state, m.state AS master_state
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.state, '') <> COALESCE(m.state, '');
-- Expected: customers 4 (California/CA), 6 (tx/TX), 12 (Oregon/OR)

-- =====================================================================
-- Exercise 8.7 — Phone format consistency
-- =====================================================================
SELECT
    CASE
        WHEN phone REGEXP '^\\(' THEN 'parens format'
        WHEN phone LIKE '%.%'   THEN 'dot format'
        WHEN phone LIKE '%-%'   THEN 'dash format'
        ELSE 'other'
    END AS phone_format,
    COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY phone_format
ORDER BY cnt DESC;
-- Expected: dash 9, parens 2, dot 1

-- =====================================================================
-- Exercise 8.8 — Canonicalized phones
-- =====================================================================
SELECT customer_id, phone,
       REGEXP_REPLACE(phone, '[^0-9]', '') AS canonical_phone
FROM customers
WHERE phone IS NOT NULL
ORDER BY customer_id;
-- e.g., customer 1 -> 5551234567, customer 9 -> 5557778888

-- =====================================================================
-- Exercise 8.9 — Non-USD orders
-- =====================================================================
SELECT order_id, total_amount, currency
FROM orders
WHERE currency <> 'USD';
-- Expected: orders 12, 13 (EUR)

-- =====================================================================
-- Exercise 8.10 (TRANSLATE — for reference)
-- Returns orders whose customer_id does not exist in customers. These are
-- orphans: they vanish from any INNER JOIN, silently understating reports.

-- =====================================================================
-- Exercise 8.11 (TRANSLATE — for reference)
-- Compares each customer's state to the clean master. COALESCE converts
-- NULLs to '' so missing states count as a difference (NULL <> 'x' is
-- UNKNOWN and would otherwise be skipped).

-- =====================================================================
-- Exercise 8.12 (TRANSLATE — for reference)
-- Strips every non-digit from phone with a regex, yielding a canonical
-- 10-digit form. This lets you compare/dedup phones ignoring formatting.

-- =====================================================================
-- Exercise 8.13 — Fixed orphan check (LEFT JOIN + IS NULL)
-- =====================================================================
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- =====================================================================
-- Exercise 8.14 — Fixed NULL-safe comparison
-- =====================================================================
SELECT c.customer_id, c.state AS operational_state, m.state AS master_state
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.state, '') <> COALESCE(m.state, '');

-- =====================================================================
-- Exercise 8.15 — Fixed canonicalization (regex strips all non-digits)
-- =====================================================================
SELECT customer_id, phone,
       REGEXP_REPLACE(phone, '[^0-9]', '') AS cleaned
FROM customers;
