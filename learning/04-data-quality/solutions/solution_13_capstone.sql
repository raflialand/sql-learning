-- Solutions: Unit 13 — Capstone (reference audit SQL)
-- Run against dq_learning (load dq_dataset_clean.sql for dq_clean_* tables)
-- Reference date: 2026-08-03

-- =====================================================================
-- STEP 2: PROFILE
-- =====================================================================

-- 13.3 Row count survey
SELECT 'daily_sales' AS tbl, COUNT(*) AS row_count FROM daily_sales
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'customers',   COUNT(*) FROM customers
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'addresses',   COUNT(*) FROM addresses;

-- 13.4 Frequency of order status
SELECT status, COUNT(*) AS cnt FROM orders GROUP BY status ORDER BY cnt DESC;
-- shipped(9), pending(2), Shipped(1), SHIPPED(1), shippd(1), cancelled(1)
-- -> validity (typo) + consistency (casing)

-- 13.5 Frequency of customer state
SELECT state, COUNT(*) AS cnt FROM customers WHERE state IS NOT NULL
GROUP BY state ORDER BY cnt DESC;
-- CA vs California, OR vs Oregon, lowercase tx -> consistency

-- =====================================================================
-- STEP 3: FINDINGS
-- =====================================================================

-- 13.6a Completeness: customers missing email
SELECT customer_id, first_name, last_name, 'missing email' AS finding
FROM customers WHERE email IS NULL OR TRIM(email) = '';
-- 2 rows (customers 5, 14)

-- 13.6b Completeness: orders missing total_amount
SELECT order_id, 'missing total_amount' AS finding
FROM orders WHERE total_amount IS NULL;
-- 1 row (order 4)

-- 13.6c Completeness: daily_sales NULL revenue
SELECT sale_date, region_id, 'NULL total_revenue' AS finding
FROM daily_sales WHERE total_revenue IS NULL;
-- 1 row (2026-06-05 RGN002)

-- 13.7a Uniqueness: duplicate customer emails
SELECT email, COUNT(*) AS cnt, 'duplicate email' AS finding
FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1;
-- 2 groups (alice, ivy)

-- 13.7b Uniqueness: duplicate SKUs
SELECT sku, COUNT(*) AS cnt, 'duplicate sku' AS finding
FROM products GROUP BY sku HAVING COUNT(*) > 1;
-- 2 groups (SKU-1001, SKU-1006)

-- 13.7c Uniqueness: duplicate addresses
SELECT customer_id, address_line, city, country, COUNT(*) AS cnt
FROM addresses
GROUP BY customer_id, address_line, city, country
HAVING COUNT(*) > 1;
-- customer 1 duplicate address

-- 13.8a Validity: invalid emails
SELECT customer_id, email, 'invalid email' AS finding
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
-- customers 6, 7

-- 13.8b Validity: invalid prices
SELECT product_id, sku, unit_price, 'invalid price' AS finding
FROM products WHERE unit_price <= 0;
-- products 3, 4

-- 13.8c Validity: invalid order statuses
SELECT order_id, status, 'invalid status' AS finding
FROM orders WHERE status IS NULL OR status NOT IN ('shipped','pending','cancelled');
-- orders 4, 8, 9, 10

-- 13.9a Accuracy: item total mismatch
SELECT item_id, qty, unit_price, total_price, 'total mismatch' AS finding
FROM order_items WHERE qty * unit_price <> total_price;
-- item 5

-- 13.9b Accuracy: order total vs items
SELECT o.order_id, o.total_amount,
       COALESCE(SUM(oi.qty * oi.unit_price), 0) AS items_total
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount IS NULL
    OR COALESCE(SUM(oi.qty * oi.unit_price), 0) <> o.total_amount;
-- orders 4, 15

-- 13.9c Accuracy: price vs master
SELECT p.product_id, p.unit_price AS op, m.unit_price AS master
FROM products p JOIN dq_clean_products m ON p.product_id = m.product_id
WHERE COALESCE(p.unit_price, -1) <> COALESCE(m.unit_price, -1);
-- products 3, 4

-- 13.10a Consistency: orphan orders
SELECT o.order_id, o.customer_id, 'orphan customer' AS finding
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- order 3

-- 13.10b Consistency: orphan items
SELECT oi.item_id, oi.product_id, 'orphan product' AS finding
FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
-- item 4

-- 13.10c Consistency: currency mismatch
SELECT oi.item_id, oi.currency AS item_cur, o.currency AS order_cur
FROM order_items oi JOIN orders o ON oi.order_id = o.order_id
WHERE oi.currency <> o.currency;
-- item 14

-- 13.10d Consistency: state vs master
SELECT c.customer_id, c.state AS op, m.state AS master
FROM customers c JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.state,'') <> COALESCE(m.state,'');
-- customers 4, 6, 12

-- 13.11a Timeliness: future orders
SELECT order_id, order_date, 'future date' AS finding
FROM orders WHERE order_date > '2026-08-03';
-- order 5

-- 13.11b Timeliness: expired-but-active products
SELECT product_id, sku, discontinued_at, is_active, 'expired-but-active' AS finding
FROM products
WHERE discontinued_at IS NOT NULL AND discontinued_at < CURDATE() AND is_active = 1;
-- product 6

-- 13.12a Anomaly: z-score > 2 in daily_sales
WITH stats AS (
    SELECT region_id, AVG(total_orders) AS mu, STDDEV_POP(total_orders) AS sigma
    FROM daily_sales WHERE total_orders IS NOT NULL GROUP BY region_id
)
SELECT ds.sale_date, ds.region_id, ds.total_orders,
       ROUND((ds.total_orders - s.mu)/NULLIF(s.sigma,0),2) AS z
FROM daily_sales ds JOIN stats s ON ds.region_id = s.region_id
WHERE ds.total_orders IS NOT NULL
  AND ABS((ds.total_orders - s.mu)/NULLIF(s.sigma,0)) > 2;
-- spike 2026-06-15, dip 2026-06-25

-- 13.12b Anomaly: week-over-week spike > 50%
WITH lagged AS (
    SELECT sale_date, region_id, total_orders,
        LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date) AS prev_week
    FROM daily_sales WHERE total_orders IS NOT NULL
)
SELECT sale_date, region_id, total_orders, prev_week
FROM lagged
WHERE prev_week IS NOT NULL
  AND ABS(total_orders - prev_week)/NULLIF(prev_week,0) > 0.5;
-- spike and dip

-- =====================================================================
-- STEP 4: SCORECARDS
-- =====================================================================

-- 13.13 Customers scorecard
SELECT 'Completeness' AS dimension, 'email present' AS rule,
       ROUND(COUNT(email)*100.0/COUNT(*),1) AS metric, 99.0 AS threshold,
       CASE WHEN COUNT(email)*100.0/COUNT(*) >= 99 THEN 'PASS' ELSE 'FAIL' END AS status
FROM customers
UNION ALL SELECT 'Uniqueness', 'no dup emails', COUNT(*), 0,
       CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT email FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*)>1) d
UNION ALL SELECT 'Validity', 'email format', COUNT(*), 0,
       CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM customers
WHERE email IS NOT NULL AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
UNION ALL SELECT 'Validity', 'state standard', COUNT(*), 0,
       CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM customers
WHERE state IS NOT NULL AND UPPER(state) NOT IN
('AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME',
 'MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA',
 'RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY');
-- 4 rows, all FAIL -> overall 0%

-- 13.14 Orders scorecard
SELECT 'Completeness' AS dimension, 'total_amount present' AS rule,
       ROUND(COUNT(total_amount)*100.0/COUNT(*),1) AS metric, 100.0 AS threshold,
       CASE WHEN COUNT(total_amount)*100.0/COUNT(*) >= 100 THEN 'PASS' ELSE 'FAIL' END AS status
FROM orders
UNION ALL SELECT 'Timeliness', 'no future dates', COUNT(*), 0,
       CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM orders WHERE order_date > '2026-08-03'
UNION ALL SELECT 'Validity', 'status domain', COUNT(*), 0,
       CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM orders WHERE status IS NULL OR status NOT IN ('shipped','pending','cancelled')
UNION ALL SELECT 'Consistency', 'no orphan customers', COUNT(*), 0,
       CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END
FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
-- 4 rows, all FAIL -> overall 0%
