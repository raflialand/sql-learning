-- Load customers table
DROP TABLE IF EXISTS silver.cleaned_customers;
CREATE TABLE silver.cleaned_customers AS SELECT * FROM bronze.customers;

-- Load order_items table
DROP TABLE IF EXISTS silver.cleaned_order_items;
CREATE TABLE silver.cleaned_order_items AS SELECT * FROM bronze.order_items;

-- Load orders table
DROP TABLE IF EXISTS silver.cleaned_orders;
CREATE TABLE silver.cleaned_orders AS SELECT * FROM bronze.orders;

-- Load products table
DROP TABLE IF EXISTS silver.cleaned_products;
CREATE TABLE silver.cleaned_products AS SELECT * FROM bronze.products;