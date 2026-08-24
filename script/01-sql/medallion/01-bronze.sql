-- medallion-lab · Layer 1: Bronze (raw ingest, immutability proof)
-- Runs against attached schemas: `source` (read-only MarketHub ecommerce.db) -> `bronze` (data/medallion/bronze.db)
-- Each table is a CTAS raw copy of a source table + audit columns _ingest_ts / _source_table.

DROP TABLE IF EXISTS bronze.bronze_categories;
CREATE TABLE bronze.bronze_categories AS
SELECT cat_id, cat_name, parent_cat_id,
       datetime('now') AS _ingest_ts,
       'categories'    AS _source_table
FROM source.categories;

DROP TABLE IF EXISTS bronze.bronze_vendors;
CREATE TABLE bronze.bronze_vendors AS
SELECT vendor_id, vendor_name, country,
       datetime('now') AS _ingest_ts,
       'vendors'       AS _source_table
FROM source.vendors;

DROP TABLE IF EXISTS bronze.bronze_products;
CREATE TABLE bronze.bronze_products AS
SELECT prod_id, prod_name, cat_id, vendor_id, unit_price, cost, is_active,
       datetime('now') AS _ingest_ts,
       'products'      AS _source_table
FROM source.products;

DROP TABLE IF EXISTS bronze.bronze_customers;
CREATE TABLE bronze.bronze_customers AS
SELECT cust_id, first_name, last_name, email, city, country, signup_date,
       datetime('now') AS _ingest_ts,
       'customers'     AS _source_table
FROM source.customers;

DROP TABLE IF EXISTS bronze.bronze_orders;
CREATE TABLE bronze.bronze_orders AS
SELECT order_id, order_date, customer_id, status, total_amount,
       datetime('now') AS _ingest_ts,
       'orders'        AS _source_table
FROM source.orders;

DROP TABLE IF EXISTS bronze.bronze_order_items;
CREATE TABLE bronze.bronze_order_items AS
SELECT item_id, order_id, product_id, quantity, unit_price,
       datetime('now') AS _ingest_ts,
       'order_items'   AS _source_table
FROM source.order_items;

DROP TABLE IF EXISTS bronze.bronze_payments;
CREATE TABLE bronze.bronze_payments AS
SELECT payment_id, order_id, method, amount, status, paid_date,
       datetime('now') AS _ingest_ts,
       'payments'      AS _source_table
FROM source.payments;

DROP TABLE IF EXISTS bronze.bronze_shipments;
CREATE TABLE bronze.bronze_shipments AS
SELECT shipment_id, order_id, carrier, ship_date, delivery_date, address,
       datetime('now') AS _ingest_ts,
       'shipments'     AS _source_table
FROM source.shipments;
