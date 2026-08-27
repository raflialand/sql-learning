-- [SILVER LAYER ARCHITECTURE: CLEANING THE RAW DATASETS] --

-- [LOAD RAW TABLES] --

-- [customers]
DROP TABLE IF EXISTS silver.cleaned_customers;
DROP TABLE IF EXISTS silver.customers;
CREATE TABLE silver.customers AS SELECT * FROM bronze.customers;

-- [order_items]
DROP TABLE IF EXISTS silver.cleaned_order_items;
DROP TABLE IF EXISTS silver.order_items;
CREATE TABLE silver.order_items AS SELECT * FROM bronze.order_items;

-- [orders]
DROP TABLE IF EXISTS silver.cleaned_orders;
DROP TABLE IF EXISTS silver.orders;
CREATE TABLE silver.orders AS SELECT * FROM bronze.orders;

-- [products]
DROP TABLE IF EXISTS silver.cleaned_products;
DROP TABLE IF EXISTS silver.products;
CREATE TABLE silver.products AS SELECT * FROM bronze.products;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- [DATA CLEANING] --

-- [North Star Metrics]
-- Revenue 				= SUM(total_amount)
-- Order count			= COUNT(*)
-- Average Order Value	= Revenue / Order count

-- [Dimensions]
-- Store
-- Category
-- Month

-- [customers table check]
SELECT *
FROM silver.customers;

-- [completeness] | [customers table]
SELECT *
FROM silver.customers
WHERE
	cust_id			IS NULL
	OR first_name	IS NULL
	OR last_name	IS NULL
	OR signup_date	IS NULL
	OR cust_id		= ' '
	OR first_name	= ' '
	OR last_name	= ' '
	OR cust_id		= ''
	OR first_name	= ''
	OR last_name	= '';
	
-- [uniqueness] | [customers table]
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

-- [Create Table: cleaned_customers]
CREATE TABLE silver.cleaned_customers AS
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

-- [cleaned_customers check]
SELECT *
FROM silver.cleaned_customers;

--
-- [order_items check]
SELECT *
FROM silver.order_items;

-- [completeness] | [order_items table]
SELECT *
FROM silver.order_items
WHERE
	item_id			IS NULL
	OR order_id		IS NULL
	OR product_id	IS NULL
	OR quantity		IS NULL
	OR unit_price	IS NULL
	OR product_id	= ' '
	OR product_id	= '';
	
-- [uniqueness] | [order_items table]
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

-- [validity] | [order_items table]
SELECT *
FROM silver.order_items
WHERE
	quantity < 0
	OR unit_price <= 0;
	
-- [Create Table: cleaned_order_items]
CREATE TABLE silver.cleaned_order_items AS
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

-- [cleaned_order_items check]
SELECT *
FROM silver.cleaned_order_items;

--
-- [orders check]
SELECT *
FROM silver.orders;

-- [completeness] | [orders table]
SELECT *
FROM silver.orders
WHERE
	order_id			IS NULL
	OR order_date		IS NULL
	OR customer_id		IS NULL
	OR store_id			IS NULL
	OR total_amount		IS NULL
	OR customer_id		= ' '
	OR store_id			= ' '
	OR customer_id		= ''
	OR store_id			= '';

-- [uniqueness] | [orders table]
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

-- [validity - accuracy] | [orders table]
WITH 
	total_amount_compare AS(
	SELECT
		o.order_id,
		o.total_amount,
		ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_amount_check
	FROM silver.orders o
		LEFT JOIN silver.order_items oi ON oi.order_id = o.order_id
	GROUP BY
		o.order_id,
		o.total_amount
), 
	accuracy_table AS(
	SELECT *,
		CASE
			WHEN total_amount = total_amount_check AND total_amount > 0 THEN 1
			ELSE 0
			END AS is_accurate
	FROM total_amount_compare
)
SELECT *
FROM accuracy_table
WHERE is_accurate = 0;

-- [Create Table: cleaned_orders]
CREATE TABLE silver.cleaned_orders AS
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

-- [cleaned_orders check]
SELECT *
FROM silver.cleaned_orders;

--
-- [products check]
SELECT * 
FROM silver.products;

-- [completeness] | [products table]
SELECT *
FROM silver.products
WHERE
	prod_id IS NULL
	OR prod_name IS NULL
	OR category IS NULL
	OR unit_price IS NULL
	OR is_active IS NULL
	OR prod_id = ' '
	OR prod_name = ' '
	OR category = ' '
	OR prod_id = ''
	OR prod_name = ''
	OR category = '';
	
-- [uniqueness] | [products table]
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

-- [Create Table: cleaned_products]
CREATE TABLE silver.cleaned_products AS
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

-- [cleaned_products check]
SELECT *
FROM silver.cleaned_products;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

-- [DROP RAW TABLES] --

-- [customers]
DROP TABLE IF EXISTS silver.customers	-- [optional]

-- [order_items]
DROP TABLE IF EXISTS silver.order_items	-- [optional]

-- [orders]
DROP TABLE IF EXISTS silver.orders		-- [optional]

-- [products]
DROP TABLE IF EXISTS silver.products	-- [optional]

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------