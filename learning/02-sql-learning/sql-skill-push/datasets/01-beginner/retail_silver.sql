-- [LOAD RAW TABLES]
-- Load customers table
DROP TABLE IF EXISTS silver.cleaned_customers;
DROP TABLE IF EXISTS silver.customers;
CREATE TABLE silver.customers AS SELECT * FROM bronze.customers;

-- Load order_items table
DROP TABLE IF EXISTS silver.cleaned_order_items;
DROP TABLE IF EXISTS silver.order_items;
CREATE TABLE silver.order_items AS SELECT * FROM bronze.order_items;

-- Load orders table
DROP TABLE IF EXISTS silver.cleaned_orders;
DROP TABLE IF EXISTS silver.orders;
CREATE TABLE silver.orders AS SELECT * FROM bronze.orders;

-- Load products table
DROP TABLE IF EXISTS silver.cleaned_products;
DROP TABLE IF EXISTS silver.products;
CREATE TABLE silver.products AS SELECT * FROM bronze.products;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- [DATA CLEANING]
-- [uniqueness] | [customers table]
SELECT *
FROM silver.customers;

-- [pk: customer_id]
SELECT
	cust_id,
	COUNT(*) AS row_num
FROM silver.customers
GROUP BY cust_id
HAVING COUNT(*) > 1;

-- [customers grain: cust_id AS customer_id]
WITH customer_uniqueness AS(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY signup_date) AS row_num
	FROM silver.customers
)
SELECT
	cust_id AS customer_id,
	first_name, 
	last_name,
	email,
	city,
	signup_date,
	loyalty_points
FROM customer_uniqueness
WHERE row_num = 1;

--
-- [uniqueness] | [order_items table]
SELECT *
FROM silver.order_items;

-- [pk: item_id]
SELECT
	item_id,
	COUNT(*) AS row_num
FROM silver.order_items
GROUP BY item_id
HAVING COUNT(*) > 1;

-- [order_items grain: item_id]
WITH order_item_uniqueness AS(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY item_id ORDER BY order_id) AS row_num
	FROM silver.order_items
)
SELECT
	item_id,
	order_id,
	product_id,
	quantity,
	unit_price
FROM order_item_uniqueness
WHERE row_num = 1;

--
-- [uniqueness] | [orders table]
SELECT *
FROM silver.orders;

-- [pk: order_id]
SELECT
	order_id,
	COUNT(*) AS row_num
FROM silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- [orders grain: order_id]
WITH order_uniqueness AS(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY order_date) AS row_num
	FROM silver.orders
)
SELECT
	order_id,
	order_date,
	customer_id,
	store_id,
	payment_method,
	total_amount
FROM order_uniqueness
WHERE row_num = 1;

--
-- [uniqueness] | [products table]
SELECT * 
FROM silver.products;

-- [pk: product_id]
SELECT
	prod_id,
	COUNT(*) AS row_num
FROM silver.products
GROUP BY prod_id
HAVING COUNT(*) > 1;

-- [products grain: prod_id AS product_id]
WITH product_uniqueness AS(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY prod_id ORDER BY prod_id) AS row_num
	FROM silver.products
)
SELECT 
	prod_id AS product_id,
	prod_name AS product_name,
	category,
	unit_price,
	is_active
FROM product_uniqueness
WHERE row_num = 1;