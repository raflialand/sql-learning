-- [EDA test of retail dataset]
-- [customers table]

SELECT *
FROM customers;

--

SELECT
	cust_id AS customer_id,
	CONCAT(first_name, ' ', last_name) AS customer_name,
	email,
	city,
	signup_date,
	loyalty_points
FROM customers;

--
-- [order_items table]

SELECT *
FROM order_items;

--

SELECT
	product_id,
	SUM(quantity) AS total_sold
FROM order_items
GROUP BY product_id
ORDER BY total_sold DESC
LIMIT 10;

--
-- [orders table]

SELECT *
FROM orders;

--

SELECT
	TO_CHAR(order_date, 'YYYY-MM') AS year_month,
	ROUND(SUM(total_amount), 2) AS revenue
FROM orders
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY TO_CHAR(order_date, 'YYYY-MM');

--

SELECT
	store_id,
	ROUND(SUM(total_amount), 2) AS revenue
FROM orders
GROUP BY store_id
ORDER BY revenue DESC;

--
-- [products table]

SELECT *
FROM products;

--

SELECT
	p.category,
	p.prod_name AS product_name, 
	SUM(oi.quantity * oi.unit_price) AS total_amount
FROM products p
	JOIN order_items oi ON oi.product_id = p.prod_id
WHERE p.is_active = 1
GROUP BY
	p.category,
	p.prod_name
ORDER BY
	p.category,
	total_amount DESC;

--

SELECT
	p.category, 
	SUM(oi.quantity * oi.unit_price) AS total_amount
FROM products p
	JOIN order_items oi ON oi.product_id = p.prod_id
WHERE p.is_active = 1
GROUP BY p.category
ORDER BY total_amount DESC;