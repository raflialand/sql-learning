-- [create table bronze.categories]
CREATE TABLE bronze.categories (LIKE public.categories INCLUDING ALL);
-- [input data]
INSERT INTO bronze.categories
SELECT * FROM public.categories;
-- [check]
SELECT * FROM bronze.categories;
--
--
-- [create table bronze.customers]
CREATE TABLE bronze.customers (LIKE public.customers INCLUDING ALL);
-- [input data]
INSERT INTO bronze.customers
SELECT * FROM public.customers;
-- [check]
SELECT * FROM bronze.customers;
--
--
-- [create table bronze.order_items]
CREATE TABLE bronze.order_items (LIKE public.order_items INCLUDING ALL);
-- [input data]
INSERT INTO bronze.order_items
SELECT * FROM public.order_items;
-- [check]
SELECT * FROM bronze.order_items;
--
--
-- [create table bronze.orders]
CREATE TABLE bronze.orders (LIKE public.orders INCLUDING ALL);
-- [input data]
INSERT INTO bronze.orders
SELECT * FROM public.orders;
-- [check]
SELECT * FROM bronze.orders;
--
--
-- [create table bronze.payments]
CREATE TABLE bronze.payments (LIKE public.payments INCLUDING ALL);
-- [input data]
INSERT INTO bronze.payments
SELECT * FROM public.payments;
-- [check]
SELECT * FROM bronze.payments;
--
--
-- [create table bronze.products]
CREATE TABLE bronze.products (LIKE public.products INCLUDING ALL);
-- [input data]
INSERT INTO bronze.products
SELECT * FROM public.products;
-- [check]
SELECT * FROM bronze.products;
--
--
-- [create table bronze.shipments]
CREATE TABLE bronze.shipments (LIKE public.shipments INCLUDING ALL);
-- [input data]
INSERT INTO bronze.shipments
SELECT * FROM public.shipments;
-- [check]
SELECT * FROM bronze.shipments;
--
--
-- [create table bronze.vendors]
CREATE TABLE bronze.vendors (LIKE public.vendors INCLUDING ALL);
-- [input data]
INSERT INTO bronze.vendors
SELECT * FROM public.vendors;
-- [check]
SELECT * FROM bronze.vendors;
--
--
-- [expected row check]
SELECT 'categories' t,	COUNT(*) FROM bronze.categories 	UNION ALL
SELECT 'vendors', 		COUNT(*) FROM bronze.vendors 		UNION ALL
SELECT 'products', 		COUNT(*) FROM bronze.products 		UNION ALL
SELECT 'customers', 	COUNT(*) FROM bronze.customers 		UNION ALL
SELECT 'orders', 		COUNT(*) FROM bronze.orders 		UNION ALL
SELECT 'order_items', 	COUNT(*) FROM bronze.order_items	UNION ALL
SELECT 'payments',	 	COUNT(*) FROM bronze.payments 		UNION ALL
SELECT 'shipments', 	COUNT(*) FROM bronze.shipments;