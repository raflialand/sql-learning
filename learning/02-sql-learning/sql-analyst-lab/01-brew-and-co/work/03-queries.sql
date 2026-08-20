-- [Case 01 Step 3 — write one SQL query per sub-question]
-- [Bucket 1: Overal Trends (level)]
-- Q1a. What is the chain-wide Revenue trend over time? | Revenue · Month
SELECT
	TO_CHAR(order_date, 'YYYY-MM') AS date,
	ROUND(SUM(total_amount), 2) AS revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY TO_CHAR(order_date, 'YYYY-MM');
--
SELECT
	TO_CHAR(order_date, 'YYYY-MM') AS date,
	store_id,
	ROUND(SUM(total_amount), 2) AS revenue
FROM orders
WHERE store_id = 'BRW001'
GROUP BY 
	TO_CHAR(order_date, 'YYYY-MM'),
	store_id
ORDER BY 
	TO_CHAR(order_date, 'YYYY-MM'),
	store_id;
-- Q1b. How is Revenue split across menu categories? | Revenue · Category
SELECT
	p.category,
	ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_revenue
FROM products p
	JOIN order_items oi ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY category_revenue DESC;
--
-- Q1c. How is Revenue split across the 3 stores? | Revenue · Store
SELECT
	store_id,
	ROUND(SUM(total_amount), 2) AS store_revenue
FROM orders
GROUP BY store_id
ORDER BY store_revenue DESC;
--
-- [Bucket 2: Growth Rates (% change)]
-- Q2a.	Which store is growing/shrinking Revenue MoM — where should next month's focus go? | Revenue · Store × Month, MoM % change
WITH monthly AS(
	SELECT
		TO_CHAR(order_date, 'YYYY-MM') AS month,
		store_id,
		SUM(total_amount) AS revenue
	FROM orders
	GROUP BY TO_CHAR(order_date, 'YYYY-MM'), store_id
	ORDER BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
	month,
	store_id,
	ROUND(revenue, 2) AS revenue,
	ROUND((revenue - LAG(revenue) OVER(PARTITION BY store_id ORDER BY month)) / LAG(revenue) OVER(PARTITION BY store_id ORDER BY month) * 100, 2) AS mom_growth_change
FROM monthly
ORDER BY month, store_id;
--
-- Q2b.	For the flagged store: did the change come from order volume or basket size? | AOV vs Order count · Store × Month, MoM % change
WITH monthly_order_count AS(
	SELECT 
		TO_CHAR(order_date, 'YYYY-MM') AS month,
		store_id,
		COUNT(*) AS order_count
	FROM orders
	WHERE store_id = 'BRW003'
	GROUP BY
		month,
		store_id
	ORDER BY month
)
SELECT *,
	ROUND((order_count - LAG(order_count) OVER(PARTITION BY store_id ORDER BY month)) * 100.0 / LAG(order_count) OVER(PARTITION BY store_id ORDER BY month), 2) AS count_mom_pct
FROM monthly_order_count;
--
WITH monthly_revenue AS(	
	SELECT 
		TO_CHAR(order_date, 'YYYY-MM') AS month,
		store_id,
		COUNT(*) AS order_count,
		ROUND(SUM(total_amount),2) AS revenue,
		ROUND(SUM(total_amount) / COUNT(*), 2) AS avg_order_value
	FROM orders
	WHERE store_id = 'BRW003'
	GROUP BY
		month,
		store_id
	ORDER BY month
)
SELECT *,
	ROUND((avg_order_value - LAG(avg_order_value) OVER(PARTITION BY store_id ORDER BY month)) / LAG(avg_order_value) OVER(PARTITION BY store_id ORDER BY month) * 100.0, 2) AS aov_diff_pct
FROM monthly_revenue;
--
-- [Bucket 3: Performance Measurement (snapshot head-to-head)]
-- Q3a. Which store earns the most per order (efficiency contest, best vs worst)? | AOV · Store
SELECT
	store_id,
	ROUND(SUM(total_amount), 2) AS revenue,
	COUNT(*) AS order_count,
	ROUND(SUM(total_amount) / COUNT(*), 2) AS avg_order_value
FROM orders
GROUP BY store_id
ORDER BY avg_order_value DESC;
--
-- Q3b. Which category has the stronger basket? | AOV · Category
WITH cat_revenue AS(
	SELECT
		p.category,
		ROUND(SUM(oi.unit_price * oi.quantity), 2) AS category_revenue,
		COUNT(DISTINCT oi.order_id) AS order_count
	FROM products p
		JOIN order_items oi ON oi.product_id = p.prod_id
	GROUP BY p.category
)
SELECT *,
	ROUND(category_revenue / order_count, 2) AS aov_per_category
FROM cat_revenue
ORDER BY aov_per_category DESC;
--
-- Q3c. Which category drives the volume (traffic/quantity side)? | Order count · Category
SELECT
	p.category,
	COUNT(DISTINCT oi.order_id) AS order_count
FROM products p
	JOIN order_items oi ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY order_count DESC;
--
-- [Bucket 4: KPI Reporting (the "why")]
-- Q4a. Which products underperform? | 	Product Revenue, bottom-decile (~3 of 31); flag zero-sales products
SELECT
	p.prod_id,
	p.prod_name,
	ROUND(COALESCE(SUM(oi.unit_price * oi.quantity), 0), 2) AS revenue
FROM products p
	LEFT JOIN order_items oi ON oi.product_id = p.prod_id
GROUP BY
	p.prod_id,
	p.prod_name
ORDER BY revenue ASC
LIMIT 3;
--
-- Q4b. Are the underperformers cheap, mid, or expensive relative to the menu? | Revenue · unit_price band
WITH price_bands AS(
	SELECT
		prod_id,
		prod_name,
		category,
		unit_price,
		ROUND(AVG(unit_price) OVER(PARTITION BY category), 2) AS avg_category_price,
		CASE NTILE(3) OVER(PARTITION BY category ORDER BY unit_price)
			WHEN 1 THEN 'Cheap'
			WHEN 2 THEN 'Mid'
			ELSE 'Expensive'
			END AS price_band
	FROM products
),
underperform AS(
	SELECT
		p.prod_id,
		p.prod_name,
		ROUND(COALESCE(SUM(oi.unit_price * oi.quantity), 0), 2) AS revenue
	FROM products p
		LEFT JOIN order_items oi ON oi.product_id = p.prod_id
	GROUP BY
		p.prod_id,
		p.prod_name
	ORDER BY revenue ASC
	LIMIT 3
)
SELECT
	pb.prod_id,
	pb.prod_name,
	pb.category,
	pb.unit_price,
	pb.avg_category_price,
	pb.price_band
FROM price_bands pb
	JOIN underperform up ON up.prod_id = pb.prod_id;
--
-- Q4c. Are the underperformers active or inactive products? | Revenue · is_active
SELECT
	prod_id AS product_id,
	prod_name AS product_name,
	CASE
		WHEN is_active = 1 THEN 'Active'
		WHEN is_active = 0 THEN 'Not Active'
		ELSE NULL
		END AS product_status
FROM products
WHERE prod_id IN ('PRD001', 'PRD006', 'PRD015');
--
-- Q4d. Are the underperformers bought alone or as add-ons inside bigger orders? | Revenue · basket context
WITH item_per_order AS(
	SELECT 
		order_id,
		COUNT(DISTINCT product_id) AS product_in_order
	FROM order_items
	GROUP BY order_id
)
SELECT 
	oi.product_id,
	p.prod_name AS product_name,
	COUNT(*) AS total_orders,
	SUM(CASE WHEN ipo.product_in_order = 1 THEN 1 ELSE 0 END) AS bought_alone,
	SUM(CASE WHEN ipo.product_in_order > 1 THEN 1 ELSE 0 END) AS add_on
FROM item_per_order ipo
	JOIN order_items oi ON oi.order_id = ipo.order_id
	JOIN products p ON p.prod_id = oi.product_id
WHERE oi.product_id IN ('PRD001', 'PRD015', 'PRD006')
GROUP BY 
	oi.product_id, 
	p.prod_name
ORDER BY total_orders ASC;
--