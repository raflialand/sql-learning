-- Solutions: Unit 07 — Accuracy
-- Run against dq_learning (load dq_dataset_clean.sql for dq_clean_* tables)

-- =====================================================================
-- Exercise 7.1 — Line-item total mismatch
-- =====================================================================
SELECT item_id, order_id, qty, unit_price, total_price,
       qty * unit_price AS expected_total
FROM order_items
WHERE qty * unit_price <> total_price;
-- Expected: item 5 (5.00 vs 4.00)

-- =====================================================================
-- Exercise 7.2 — Order total vs items (NULL-safe)
-- =====================================================================
SELECT
    o.order_id,
    o.total_amount,
    COALESCE(SUM(oi.qty * oi.unit_price), 0) AS items_total,
    ROUND(o.total_amount - COALESCE(SUM(oi.qty * oi.unit_price), 0), 2) AS diff
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount IS NULL
    OR ROUND(o.total_amount - COALESCE(SUM(oi.qty * oi.unit_price), 0), 2) <> 0;
-- Expected: order 4 (NULL vs 4.00), order 15 (0.00 vs 19.95)

-- =====================================================================
-- Exercise 7.3 — Price vs master data
-- =====================================================================
SELECT p.product_id, p.sku,
       p.unit_price AS operational_price,
       m.unit_price AS master_price
FROM products p
JOIN dq_clean_products m ON p.product_id = m.product_id
WHERE p.unit_price <> m.unit_price;
-- Expected: products 3 (-5.00 vs 9.99), 4 (0.00 vs 24.99)

-- =====================================================================
-- Exercise 7.4 — Weight vs master data
-- =====================================================================
SELECT p.product_id, p.sku,
       p.weight_kg AS operational_weight,
       m.weight_kg AS master_weight
FROM products p
JOIN dq_clean_products m ON p.product_id = m.product_id
WHERE p.weight_kg <> m.weight_kg;
-- Expected: product 5 (150.00 vs 12.00)

-- =====================================================================
-- Exercise 7.5 — Customer email vs master data (with NULL handling)
-- =====================================================================
SELECT c.customer_id,
       c.email AS operational_email,
       m.email AS master_email
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.email, '') <> COALESCE(m.email, '');
-- Expected: customers 5, 6, 7

-- =====================================================================
-- Exercise 7.6 — Product lifecycle rule
-- =====================================================================
SELECT product_id, sku, product_name, is_active, discontinued_at
FROM products
WHERE (is_active = 0 AND discontinued_at IS NULL)
   OR (is_active = 1 AND discontinued_at IS NOT NULL AND discontinued_at <= CURRENT_DATE);
-- Expected: product 6 (active but discontinued 2025-01-01)

-- =====================================================================
-- Exercise 7.7 — Currency mismatch between items and orders
-- =====================================================================
SELECT oi.item_id, oi.order_id,
       oi.currency AS item_currency,
       o.currency  AS order_currency
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.currency <> o.currency;
-- Expected: item 14 (USD) under order 12 (EUR)

-- =====================================================================
-- Exercise 7.8 — Business-rule scorecard
-- =====================================================================
SELECT
    COUNT(*) AS total_products,
    SUM(unit_price <= 0 OR weight_kg < 0.1 OR weight_kg > 50) AS rule_violations,
    ROUND(SUM(unit_price <= 0 OR weight_kg < 0.1 OR weight_kg > 50) * 100.0 / COUNT(*), 1) AS violation_pct
FROM products;
-- Expected: 12 / 3 / 25.0

-- =====================================================================
-- Exercise 7.9 (TRANSLATE — for reference)
-- Lists orders where the summed line-item value differs from the order's
-- stored total. HAVING filters the grouped result (post-aggregation),
-- catching order/items discrepancies.

-- =====================================================================
-- Exercise 7.10 (TRANSLATE — for reference)
-- Compares each customer's email to master data. COALESCE converts NULL
-- to '' so that missing emails are treated as a difference rather than
-- silently skipped (NULL <> 'x' is UNKNOWN, which WHERE drops).

-- =====================================================================
-- Exercise 7.11 — Float-safe comparison
-- =====================================================================
SELECT item_id, order_id, qty, unit_price, total_price
FROM order_items
WHERE ABS(qty * unit_price - total_price) > 0.01;
-- Expected: item 5

-- =====================================================================
-- Exercise 7.12 — NULL-safe master comparison
-- =====================================================================
SELECT p.product_id, p.unit_price AS operational_price, m.unit_price AS master_price
FROM products p
JOIN dq_clean_products m ON p.product_id = m.product_id
WHERE COALESCE(p.unit_price, -1) <> COALESCE(m.unit_price, -1);
-- Expected: products 3, 4 (and any NULL prices in a fuller dataset)

-- =====================================================================
-- Exercise 7.13 — Fixed lifecycle rule (past discontinuation)
-- =====================================================================
SELECT product_id, sku, is_active, discontinued_at
FROM products
WHERE is_active = 1 AND discontinued_at IS NOT NULL AND discontinued_at <= CURRENT_DATE;
-- Expected: product 6
