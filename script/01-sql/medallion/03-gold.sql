-- medallion-lab · Layer 3: Gold (curated star schema + analytics marts)
-- Runs against attached schemas: `silver` (data/medallion/silver.db) -> `gold` (data/medallion/gold.db)
-- DE-roadmap Week 3 star schema: dim_customer / dim_product / dim_date + fact_order_items (line grain)
-- + fact_orders (order grain), plus two reporting marts. Each table is dropped + rebuilt on run (idempotent).

-- dim_customer: unique customer_key over deduplicated customers
DROP TABLE IF EXISTS gold.dim_customer;
CREATE TABLE gold.dim_customer AS
SELECT ROW_NUMBER() OVER (ORDER BY cust_id) AS customer_key,
       cust_id, first_name, last_name, full_name, email, city, country, signup_date
FROM silver.silver_customers;

-- dim_product: all products
DROP TABLE IF EXISTS gold.dim_product;
CREATE TABLE gold.dim_product AS
SELECT ROW_NUMBER() OVER (ORDER BY prod_id) AS product_key,
       prod_id, prod_name, cat_id, vendor_id, unit_price, cost, is_active, is_discontinued_but_sold
FROM silver.silver_products;

-- dim_date: generated over the full source order-date range (not a source table)
DROP TABLE IF EXISTS gold.dim_date;
CREATE TABLE gold.dim_date AS
WITH RECURSIVE dates(d) AS (
    SELECT MIN(order_date) FROM silver.silver_orders
    UNION ALL
    SELECT date(d, '+1 day') FROM dates WHERE d < (SELECT MAX(order_date) FROM silver.silver_orders)
)
SELECT strftime('%Y%m%d', d) AS date_key,
       d AS date,
       CAST(strftime('%Y', d) AS INTEGER) AS year,
       CAST(strftime('%m', d) AS INTEGER) AS month,
       CAST(strftime('%d', d) AS INTEGER) AS day,
       CASE CAST(strftime('%w', d) AS INTEGER) WHEN 0 THEN 'Sunday' WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday' WHEN 3 THEN 'Wednesday' WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday' ELSE 'Saturday' END AS day_of_week,
       CASE WHEN CAST(strftime('%w', d) AS INTEGER) IN (0, 6) THEN 1 ELSE 0 END AS is_weekend,
       (CAST(strftime('%Y', d) AS INTEGER) * 4 + (CAST(strftime('%m', d) AS INTEGER) - 1) / 3 - 1) AS quarter
FROM dates;

-- fact_order_items: line grain, one row per silver order_items row
DROP TABLE IF EXISTS gold.fact_order_items;
CREATE TABLE gold.fact_order_items AS
SELECT oi.item_id,
       oi.order_id,
       dc.customer_key,
       dp.product_key,
       dd.date_key,
       lower(o.status) AS order_status,
       o.is_valid_order,
       oi.quantity,
       oi.unit_price,
       oi.line_revenue
FROM silver.silver_order_items oi
JOIN silver.silver_orders o   ON oi.order_id = o.order_id
JOIN silver.silver_customers c ON o.customer_id = c.cust_id
JOIN gold.dim_customer dc      ON dc.cust_id = c.cust_id
JOIN gold.dim_product dp       ON dp.prod_id = oi.product_id
JOIN gold.dim_date dd          ON dd.date = o.order_date;

-- fact_orders: order grain, one row per silver order
DROP TABLE IF EXISTS gold.fact_orders;
CREATE TABLE gold.fact_orders AS
SELECT o.order_id,
       dc.customer_key,
       dd.date_key,
       o.order_date,
       lower(o.status) AS order_status,
       o.is_valid_order,
       o.has_payment,
       o.total_amount,
       COALESCE(SUM(CASE WHEN pm.status = 'paid' THEN pm.amount END), 0) AS paid_amount
FROM silver.silver_orders o
JOIN silver.silver_customers c ON o.customer_id = c.cust_id
JOIN gold.dim_customer dc      ON dc.cust_id = c.cust_id
JOIN gold.dim_date dd          ON dd.date = o.order_date
LEFT JOIN silver.silver_payments pm ON pm.order_id = o.order_id
GROUP BY o.order_id, dc.customer_key, dd.date_key, o.order_date, o.status, o.is_valid_order, o.has_payment, o.total_amount;

-- mart_vendor_performance: per-vendor revenue/order metrics from the line-grain facts
DROP TABLE IF EXISTS gold.mart_vendor_performance;
CREATE TABLE gold.mart_vendor_performance AS
SELECT dp.vendor_id,
       COUNT(DISTINCT foi.order_id) AS order_count,
       COUNT(*)                     AS line_item_count,
       ROUND(SUM(CASE WHEN foi.is_valid_order = 1 THEN foi.line_revenue ELSE 0 END), 2) AS gross_revenue,
       ROUND(SUM(CASE WHEN foi.is_valid_order = 1 THEN foi.quantity ELSE 0 END), 2)      AS units_sold
FROM gold.fact_order_items foi
JOIN gold.dim_product dp ON foi.product_key = dp.product_key
GROUP BY dp.vendor_id;

-- mart_daily_revenue: per-day revenue from valid (non-cancelled) orders
DROP TABLE IF EXISTS gold.mart_daily_revenue;
CREATE TABLE gold.mart_daily_revenue AS
SELECT dd.date,
       dd.year,
       dd.month,
       dd.day_of_week,
       ROUND(SUM(foi.line_revenue), 2) AS daily_revenue,
       COUNT(DISTINCT foi.order_id)     AS order_count
FROM gold.fact_order_items foi
JOIN gold.dim_date dd ON foi.date_key = dd.date_key
WHERE foi.is_valid_order = 1
GROUP BY dd.date, dd.year, dd.month, dd.day_of_week;
