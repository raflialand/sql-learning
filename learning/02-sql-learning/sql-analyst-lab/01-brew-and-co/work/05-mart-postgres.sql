-- Case 01 — Brew & Co. Mart (PostgreSQL)
-- One mart table that answers every bucket question (Q1a–Q4d) via GROUP BY.
-- Grain: one row per order-item LINE (3,647 rows). Fully denormalized:
--   order dims (month_key, store_id) + product dims (category, price band, is_active)
--   + measures (quantity, line_revenue) + flags (distinct_products, alone_flag).
-- Derived flags computed BEFORE any WHERE (windows over the full tables).
-- Postgres variant of work/05-mart.sql (TO_CHAR instead of strftime).
-- Run in your Postgres instance with the retail data loaded (not via run_query.py).

DROP TABLE IF EXISTS gold.mart_retail;

CREATE TABLE gold.mart_retail AS
WITH basket AS (
    SELECT order_id,
           COUNT(*)                    AS line_count,
           COUNT(DISTINCT product_id)  AS distinct_products
    FROM silver.cleaned_order_items
    GROUP BY order_id
),
price_band AS (
    SELECT product_id,
           CASE NTILE(3) OVER (PARTITION BY category ORDER BY unit_price)
                WHEN 1 THEN 'Cheap' WHEN 2 THEN 'Mid' ELSE 'Expensive' END AS price_band
    FROM silver.cleaned_products
),
mart_order_items AS (
    SELECT oi.item_id,
		   o.order_id,
           o.order_date,
           TO_CHAR(o.order_date, 'YYYY-MM') AS month_key,
           o.store_id,
           p.category,
           p.product_id,
           p.product_name,
           p.is_active,
           p.unit_price AS menu_price,
           pb.price_band,
           oi.quantity,
           ROUND(oi.unit_price * oi.quantity, 2) AS line_revenue,
           b.distinct_products,
           CASE WHEN b.distinct_products = 1 THEN 1 ELSE 0 END AS alone_flag
    FROM silver.cleaned_order_items oi
    JOIN silver.cleaned_orders o  	ON o.order_id 		= oi.order_id
    JOIN silver.cleaned_products p	ON p.product_id  	= oi.product_id
    JOIN basket b   				ON b.order_id		= o.order_id
    LEFT JOIN price_band pb 		ON pb.product_id	= p.product_id
)
SELECT * FROM mart_order_items;

SELECT *
FROM gold.mart_retail;

SELECT DISTINCT item_id
FROM gold.mart_retail;

