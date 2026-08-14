-- Case 01 — Brew & Co. Model Queries (SQLite)
-- One query per sub-question (metric × dimension). Run statement-by-statement
-- with the same helper used for expected results:
--   python ../sql-skill-push/_tools/run_query.py ../sql-skill-push/datasets/01-beginner/retail.db <this-file>
-- (the helper executes a single statement; split and run each block above a blank line for full output)

-- Q1 (Overall Trends): monthly revenue + order count + AOV
SELECT strftime('%Y-%m', order_date) AS month,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS revenue,
       ROUND(SUM(total_amount) / COUNT(*), 2) AS aov
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;

-- Q2 (Overall Trends): revenue + order count by store
SELECT store_id,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS revenue
FROM orders
GROUP BY store_id
ORDER BY revenue DESC;

-- Q3 (Overall Trends): revenue + order count by menu category
SELECT p.category,
       COUNT(DISTINCT oi.order_id) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Q4 (Growth Rates): month-over-month revenue growth %
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- Q5 (Performance Measurement): category mix per store (segment comparison)
SELECT o.store_id,
       p.category,
       COUNT(*) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.prod_id
GROUP BY o.store_id, p.category
ORDER BY o.store_id, revenue DESC;

-- Q6 (KPI Reporting): bottom products by revenue — WHY they underperform (units, price, active flag)
SELECT p.prod_id,
       p.prod_name,
       p.category,
       p.unit_price,
       p.is_active,
       COALESCE(SUM(oi.quantity), 0) AS units_sold,
       ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS revenue
FROM products p
LEFT JOIN order_items oi ON p.prod_id = oi.product_id
GROUP BY p.prod_id
ORDER BY revenue ASC
LIMIT 10;
