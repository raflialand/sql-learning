-- Case 02 — MarketHub Model Queries (SQLite)
-- One query per sub-question (metric × dimension). Run statement-by-statement
-- with the same helper used for expected results:
--   python ../sql-skill-push/_tools/run_query.py ../sql-skill-push/datasets/02-intermediate/ecommerce.db <this-file>
-- Fixed scope used consistently: order status IN ('Completed','Shipped').

-- Q1 (Overall Trends): monthly GMV + order count (Completed/Shipped scope)
SELECT strftime('%Y-%m', order_date) AS month,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS gmv
FROM orders
WHERE status IN ('Completed', 'Shipped')
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;

-- Q2 (Overall Trends): GMV by top-level category
SELECT parent.cat_name AS category,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gmv
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.prod_id
JOIN categories sub ON p.cat_id = sub.cat_id
JOIN categories parent ON sub.parent_cat_id = parent.cat_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY parent.cat_name
ORDER BY gmv DESC;

-- Q3 (Growth Rates): month-over-month GMV growth %
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           SUM(total_amount) AS gmv
    FROM orders
    WHERE status IN ('Completed', 'Shipped')
    GROUP BY month
)
SELECT month,
       ROUND(gmv, 2) AS gmv,
       ROUND((gmv - LAG(gmv) OVER (ORDER BY month)) / LAG(gmv) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- Q4 (Growth Rates): year-over-year — Jan-2025 vs Jan-2026
SELECT strftime('%Y', order_date) AS year,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS gmv,
       ROUND(SUM(total_amount) / COUNT(*), 2) AS aov
FROM orders
WHERE status IN ('Completed', 'Shipped')
  AND strftime('%Y-%m', order_date) IN ('2025-01', '2026-01')
GROUP BY strftime('%Y', order_date)
ORDER BY year;

-- Q5 (Performance Measurement): GMV + AOV by buyer country
SELECT c.country,
       COUNT(*) AS order_count,
       ROUND(SUM(o.total_amount), 2) AS gmv,
       ROUND(SUM(o.total_amount) / COUNT(*), 2) AS aov
FROM orders o
JOIN customers c ON o.customer_id = c.cust_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY c.country
ORDER BY gmv DESC;

-- Q6 (Performance Measurement): repeat purchase rate by country
-- Fixed definition: buyers with >=2 Completed/Shipped orders / buyers with >=1.
WITH buyer_orders AS (
    SELECT c.country,
           o.customer_id,
           COUNT(*) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.cust_id
    WHERE o.status IN ('Completed', 'Shipped')
    GROUP BY c.country, o.customer_id
)
SELECT country,
       SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
       COUNT(*) AS total_buyers,
       ROUND(100.0 * SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM buyer_orders
GROUP BY country
ORDER BY repeat_rate_pct DESC;

-- Q7 (KPI Reporting): payment failure rate by method (the "why")
SELECT method,
       COUNT(*) AS attempts,
       SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed,
       ROUND(100.0 * SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_rate_pct
FROM payments
GROUP BY method
ORDER BY failure_rate_pct DESC;

-- Q8 (KPI Reporting): investment drill-down — vendor country × top category GMV
SELECT v.country AS vendor_country,
       parent.cat_name AS category,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gmv
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.prod_id
JOIN vendors v ON p.vendor_id = v.vendor_id
JOIN categories sub ON p.cat_id = sub.cat_id
JOIN categories parent ON sub.parent_cat_id = parent.cat_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY v.country, parent.cat_name
ORDER BY gmv DESC
LIMIT 10;
