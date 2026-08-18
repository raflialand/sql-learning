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
-- Q1b. How is Revenue split across menu categories? | Revenue · Category
SELECT
	p.category,
	ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_revenue
FROM products p
	JOIN order_items oi ON oi.product_id = p.prod_id
WHERE p.is_active = 1
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
	ROUND((revenue - LAG(revenue) OVER(ORDER BY month)) / LAG(revenue) OVER(ORDER BY month) * 100, 2) AS mom_growth_change
FROM monthly
WHERE store_id = 'BRW003'
ORDER BY month, store_id;
--
-- Q2b.	For the flagged store: did the change come from order volume or basket size? | AOV vs Order count · Store × Month, MoM % change
SELECT
	store_id,
	COUNT(*) AS order_count
FROM orders
GROUP BY store_id
ORDER BY order_count DESC;
--
WITH category_quantity AS(
	SELECT 
		o.store_id,
		p.category,
		SUM(oi.quantity) AS total_quantity
	FROM orders o
		JOIN order_items oi ON oi.order_id = o.order_id
		JOIN products p ON p.prod_id = oi.product_id
	GROUP BY
		o.store_id,
		p.category
	ORDER BY
		o.store_id,
	total_quantity DESC
)
SELECT *
FROM category_quantity
WHERE category = 'Merchandise';