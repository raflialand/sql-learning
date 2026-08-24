-- medallion-lab · Layer 2: Silver (cleaned, conformed, one row per source row)
-- Runs against attached schemas: `bronze` (data/medallion/bronze.db) -> `silver` (data/medallion/silver.db)
-- Applies the data-quality discipline from the dq track: normalized enums, DECIMAL money,
-- explicit DQ flags per known dataset quirk, and a per-row `_quality_issues` column.

-- categories: flatten the parent/child tree into parent_cat_name
DROP TABLE IF EXISTS silver.silver_categories;
CREATE TABLE silver.silver_categories AS
SELECT c.cat_id,
       c.cat_name,
       c.parent_cat_id,
       p.cat_name AS parent_cat_name,
       CASE WHEN c.parent_cat_id IS NOT NULL AND p.cat_name IS NULL
            THEN 'missing_parent'
            ELSE NULL END AS _quality_issues
FROM bronze.bronze_categories c
LEFT JOIN bronze.bronze_categories p ON c.parent_cat_id = p.cat_id;

-- vendors: standardize country abbreviations
DROP TABLE IF EXISTS silver.silver_vendors;
CREATE TABLE silver.silver_vendors AS
SELECT vendor_id,
       vendor_name,
       CASE country WHEN 'USA' THEN 'United States'
                    WHEN 'UK'  THEN 'United Kingdom'
                    ELSE country END AS country,
       CASE WHEN country IN ('USA','UK') THEN 'country_standardized'
            ELSE NULL END AS _quality_issues
FROM bronze.bronze_vendors;

-- products: money DECIMAL, is_active flag, discontinued-but-sold flag
DROP TABLE IF EXISTS silver.silver_products;
CREATE TABLE silver.silver_products AS
SELECT p.prod_id,
       p.prod_name,
       p.cat_id,
       p.vendor_id,
       ROUND(p.unit_price, 2) AS unit_price,
       ROUND(p.cost, 2)       AS cost,
       CASE WHEN p.is_active = 1 THEN 1 ELSE 0 END AS is_active,
       CASE WHEN p.is_active = 0 AND EXISTS (SELECT 1 FROM bronze.bronze_order_items oi WHERE oi.product_id = p.prod_id)
            THEN 1 ELSE 0 END AS is_discontinued_but_sold,
       CASE WHEN p.is_active = 0 THEN 'inactive' ELSE NULL END AS _quality_issues
FROM bronze.bronze_products p;

-- customers: trim, full_name, dedup by natural key (cust_id is PK here)
DROP TABLE IF EXISTS silver.silver_customers;
CREATE TABLE silver.silver_customers AS
SELECT cust_id,
       trim(first_name) AS first_name,
       trim(last_name)  AS last_name,
       lower(trim(email)) AS email,
       trim(city)       AS city,
       trim(country)    AS country,
       signup_date,
       trim(first_name) || ' ' || trim(last_name) AS full_name,
       CASE WHEN cust_id IN (SELECT cust_id FROM bronze.bronze_customers GROUP BY cust_id HAVING COUNT(*) > 1)
            THEN 'duplicate_cust_id'
            ELSE NULL END AS _quality_issues
FROM bronze.bronze_customers
GROUP BY cust_id;

-- orders: normalized enum, DECIMAL money, is_valid_order (excludes Cancelled), has_payment
DROP TABLE IF EXISTS silver.silver_orders;
CREATE TABLE silver.silver_orders AS
SELECT o.order_id,
       o.order_date,
       o.customer_id,
       lower(o.status) AS status,
       ROUND(o.total_amount, 2) AS total_amount,
       CASE WHEN lower(o.status) <> 'cancelled' THEN 1 ELSE 0 END AS is_valid_order,
       CASE WHEN EXISTS (SELECT 1 FROM bronze.bronze_payments p WHERE p.order_id = o.order_id)
            THEN 1 ELSE 0 END AS has_payment,
       CASE WHEN lower(o.status) = 'cancelled' THEN 'cancelled'
            ELSE NULL END AS _quality_issues
FROM bronze.bronze_orders o;

-- payments: payment completeness vs order total
DROP TABLE IF EXISTS silver.silver_payments;
CREATE TABLE silver.silver_payments AS
SELECT pm.payment_id,
       pm.order_id,
       lower(pm.method) AS method,
       ROUND(pm.amount, 2) AS amount,
       lower(pm.status) AS status,
       pm.paid_date,
       CASE WHEN lower(pm.status) = 'paid'
                 AND ROUND(pm.amount, 2) = ROUND(o.total_amount, 2)
            THEN 1 ELSE 0 END AS is_payment_complete,
       CASE WHEN lower(pm.status) = 'failed'   THEN 'payment_failed'
            WHEN lower(pm.status) = 'refunded' THEN 'payment_refunded'
            WHEN lower(pm.status) = 'paid' AND ROUND(pm.amount, 2) <> ROUND(o.total_amount, 2)
            THEN 'payment_amount_mismatch'
            ELSE NULL END AS _quality_issues
FROM bronze.bronze_payments pm
LEFT JOIN bronze.bronze_orders o ON pm.order_id = o.order_id;

-- shipments: in_transit flag for NULL delivery_date
DROP TABLE IF EXISTS silver.silver_shipments;
CREATE TABLE silver.silver_shipments AS
SELECT shipment_id,
       order_id,
       carrier,
       ship_date,
       delivery_date,
       address,
       CASE WHEN delivery_date IS NULL THEN 1 ELSE 0 END AS in_transit,
       CASE WHEN delivery_date IS NULL THEN 'in_transit'
            ELSE NULL END AS _quality_issues
FROM bronze.bronze_shipments;

-- order_items: line_revenue at line grain
DROP TABLE IF EXISTS silver.silver_order_items;
CREATE TABLE silver.silver_order_items AS
SELECT item_id,
       order_id,
       product_id,
       quantity,
       ROUND(unit_price, 2) AS unit_price,
       ROUND(quantity * unit_price, 2) AS line_revenue,
       NULL AS _quality_issues
FROM bronze.bronze_order_items;
