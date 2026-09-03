-- ============================================================================
-- Case 02 — MarketHub · Stage 3: Bronze → Silver
-- ============================================================================
-- Pipeline: data-to-insight (sql-builder). DB: datainsight_markethub (PostgreSQL)
-- Input : bronze.*  (8 tables, loaded from ecommerce_pg.sql)
-- Output: silver.cleaned_*  (8 conformed tables, ONE ROW PER SOURCE ROW — no rows dropped)
--
-- Philosophy for THIS dataset: every documented quirk is a legitimate business
-- state (in-transit shipments, no-payment Pending orders, discontinued-but-sold
-- products, Cancelled orders without payment/shipment) — NOT a defect to remove.
-- Silver therefore CONFORMS + FLAGS, and NEVER drops. GMV filtering
-- (status IN ('Completed','Shipped')) and the multi-row join strategy are pushed
-- to the gold mart (Stage 4); silver only encodes the flags that make those safe.
--
-- ----------------------------------------------------------------------------
-- DQ EVALUATION SUMMARY (all 6 dimensions evaluated; effective subset applied)
-- ----------------------------------------------------------------------------
-- | Dimension    | Verdict  | Reason (MarketHub actual quirk)                                | Encoded rule                                                            |
-- |--------------|----------|----------------------------------------------------------------|-------------------------------------------------------------------------|
-- | Completeness | APPLIED  | 95 shipments have delivery_date IS NULL (in transit — real    | Flag `in_transit` on shipments. Preserve all 95 rows; NO impute/drop.  |
-- |              |          | business state, not a defect).                                |                                                                         |
-- | Uniqueness   | N/A      | All 8 tables declare PKs; documented row counts = distinct-key | No dedup rule. Child tables (order_items 7102 / payments 2283 /        |
-- |              |          | counts. Multi-row child tables are legitimate one-to-many,     | shipments 1864) are one-to-many, NOT duplicates. Verify only.          |
-- |              |          | not duplicates. No duplicate rows are documented.              |                                                                         |
-- | Validity     | APPLIED  | Enum domains (orders.status ×4, payments.status ×3,           | Conform status/method to single lowercase canonical form; coerce       |
-- |              |          | payments.method ×4, shipments.carrier ×4, is_active {0,1});   | is_active to clean 0/1. Validate FK references + date bounds. Drop     |
-- |              |          | date range 2025-01-01..2026-01-31.                            | nothing (all documented values in-domain).                              |
-- | Accuracy     | APPLIED  | orders.total_amount should equal SUM(order_items qty×price);  | VERIFY total_amount = line-item sum (no recompute — scope fixes GMV as  |
-- |              |          | 9 products inactive (is_active=0) yet still sold.             | orders.total_amount). Flag `is_discontinued_but_sold`; preserve them.  |
-- | Consistency  | APPLIED  | 517 orders have NO payment row; Cancelled orders have no       | Flag `has_payment`/`has_shipment` on orders (drives gold LEFT-JOIN      |
-- |              |          | payment/shipment; payments 2283 < orders 2800, shipments      | strategy so GMV/counts are not inflated). Preserve all orders.         |
-- |              |          | 1864 < orders 2800 (cardinality).                             |                                                                         |
-- | Timeliness   | N/A      | Static analytical snapshot (2025-01-01..2026-01-31); no       | No freshness/lag rule. Date bounds validated under Validity (range).    |
-- |              |          | now-relative freshness requirement.                           |                                                                         |
-- ----------------------------------------------------------------------------
-- IDEMPOTENCY: children dropped before parents (logical FK order).
--               CTAS copies carry no FK constraints, so CASCADE is belt-and-braces
--               in case a later stage (gold mart) adds dependent objects.
-- ============================================================================

DROP TABLE IF EXISTS silver.cleaned_order_items CASCADE;
DROP TABLE IF EXISTS silver.cleaned_payments    CASCADE;
DROP TABLE IF EXISTS silver.cleaned_shipments   CASCADE;
DROP TABLE IF EXISTS silver.cleaned_orders      CASCADE;
DROP TABLE IF EXISTS silver.cleaned_products    CASCADE;
DROP TABLE IF EXISTS silver.cleaned_customers   CASCADE;
DROP TABLE IF EXISTS silver.cleaned_vendors     CASCADE;
DROP TABLE IF EXISTS silver.cleaned_categories  CASCADE;

-- ----------------------------------------------------------------------------
-- categories (16) — Validity (self-referencing parent) → flatten tree
-- 8 parents + 8 subcategories; products live in subcategories. Add parent name
-- and a level tag so the gold mart can roll up to the top-level category (Q3).
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_categories AS
SELECT
    c.cat_id,
    c.cat_name,
    c.parent_cat_id,
    p.cat_name AS parent_cat_name,
    CASE WHEN c.parent_cat_id IS NULL THEN 'parent' ELSE 'subcategory' END AS cat_level
FROM bronze.categories c
LEFT JOIN bronze.categories p ON p.cat_id = c.parent_cat_id;

-- ----------------------------------------------------------------------------
-- vendors (14) — Validity (trim) only. Country kept as-is: the abbreviation
-- set (NL/DE/FR/UK/USA) is consistent across BOTH vendors and customers, so
-- standardizing to long-form would break join/group semantics with
-- customers.country (D2) and is not required by any sub-question.
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_vendors AS
SELECT
    vendor_id,
    trim(vendor_name) AS vendor_name,
    trim(country)     AS country
FROM bronze.vendors;

-- ----------------------------------------------------------------------------
-- products (120) — Validity (is_active domain) + Accuracy (master-data rule)
-- Preserve ALL 120 rows. Inactive-but-sold products (Q9 drill) survive via
-- the `is_discontinued_but_sold` flag; is_active is coerced to a clean 0/1.
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_products AS
SELECT
    p.prod_id,
    p.prod_name,
    p.cat_id,
    p.vendor_id,
    ROUND(p.unit_price, 2) AS unit_price,
    ROUND(p.cost, 2)       AS cost,
    CASE WHEN p.is_active = 1 THEN 1 ELSE 0 END AS is_active,
    CASE WHEN p.is_active = 0
               AND EXISTS (SELECT 1 FROM bronze.order_items oi WHERE oi.product_id = p.prod_id)
         THEN 1 ELSE 0 END AS is_discontinued_but_sold
FROM bronze.products p;

-- ----------------------------------------------------------------------------
-- customers (500) — Validity (trim / lowercase conform) only
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_customers AS
SELECT
    cust_id,
    trim(first_name)     AS first_name,
    trim(last_name)      AS last_name,
    lower(trim(email))   AS email,
    trim(city)           AS city,
    trim(country)        AS country,
    signup_date
FROM bronze.customers;

-- ----------------------------------------------------------------------------
-- orders (2800) — Validity (enum conform) + Consistency (cross-table coverage)
-- Preserve ALL 2800 rows (Cancelled 456 + Pending 480 stay available for Q9 /
-- any drill). `is_fulfilled` encodes the GMV scope (Completed + Shipped) once;
-- `has_payment` / `has_shipment` encode the coverage quirks the gold mart uses
-- to keep multi-row joins from inflating GMV / order counts.
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_orders AS
SELECT
    o.order_id,
    o.order_date,
    o.customer_id,
    lower(o.status)        AS status,
    ROUND(o.total_amount, 2) AS total_amount,
    CASE WHEN lower(o.status) IN ('completed','shipped') THEN 1 ELSE 0 END AS is_fulfilled,
    CASE WHEN EXISTS (SELECT 1 FROM bronze.payments  pm WHERE pm.order_id = o.order_id) THEN 1 ELSE 0 END AS has_payment,
    CASE WHEN EXISTS (SELECT 1 FROM bronze.shipments s  WHERE s.order_id  = o.order_id) THEN 1 ELSE 0 END AS has_shipment
FROM bronze.orders o;

-- ----------------------------------------------------------------------------
-- order_items (7102) — Validity (round money) + Accuracy (line revenue)
-- Grain is one row per line item. line_revenue = quantity × unit_price, the
-- basis for the Accuracy cross-check against orders.total_amount.
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_order_items AS
SELECT
    item_id,
    order_id,
    product_id,
    quantity,
    ROUND(unit_price, 2)            AS unit_price,
    ROUND(quantity * unit_price, 2) AS line_revenue
FROM bronze.order_items;

-- ----------------------------------------------------------------------------
-- payments (2283) — Validity (enum conform) + Consistency (coverage)
-- Conform method/status. Keep all rows: Failed(482) + Refunded(453) are needed
-- for Q9 payment-health drill; Paid(1348) for any payment success view.
-- Note: 2283 rows == 2800 - 517, so payments is effectively 1:0..1 per order
-- (verify) — gold mart must NOT fan out payments into GMV.
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_payments AS
SELECT
    payment_id,
    order_id,
    lower(method) AS method,
    ROUND(amount, 2) AS amount,
    lower(status) AS status,
    paid_date
FROM bronze.payments;

-- ----------------------------------------------------------------------------
-- shipments (1864) — Completeness (delivery_date NULL) → in_transit flag
-- Preserve ALL 1864 rows; the 95 in-transit (delivery_date IS NULL) rows are a
-- real fulfillment state (Q9 needs them to separate delivered vs in-transit).
-- ----------------------------------------------------------------------------
CREATE TABLE silver.cleaned_shipments AS
SELECT
    shipment_id,
    order_id,
    carrier,
    ship_date,
    delivery_date,
    address,
    CASE WHEN delivery_date IS NULL THEN 1 ELSE 0 END AS in_transit
FROM bronze.shipments;

-- ============================================================================
-- VERIFICATION (run this; paste output back at the Silver checkpoint)
-- Expected values are per the dataset README; treat any deviation as a new
-- hypothesis to investigate, NOT to silently patch.
-- ============================================================================

-- 1) Row counts — proves NO rows were dropped (expect 16/14/120/500/2800/7102/2283/1864)
SELECT 'categories'  AS t, COUNT(*) AS rows FROM silver.cleaned_categories
UNION ALL SELECT 'vendors',   COUNT(*) FROM silver.cleaned_vendors
UNION ALL SELECT 'products',  COUNT(*) FROM silver.cleaned_products
UNION ALL SELECT 'customers', COUNT(*) FROM silver.cleaned_customers
UNION ALL SELECT 'orders',    COUNT(*) FROM silver.cleaned_orders
UNION ALL SELECT 'order_items', COUNT(*) FROM silver.cleaned_order_items
UNION ALL SELECT 'payments',  COUNT(*) FROM silver.cleaned_payments
UNION ALL SELECT 'shipments', COUNT(*) FROM silver.cleaned_shipments;

-- 2) Flag counts (hypotheses to confirm)
--    in_transit shipments: expect 95
--    is_discontinued_but_sold: expect 1..9 (9 inactive, "some" still sold)
--    is_fulfilled orders: expect 1864 (1388 Completed + 476 Shipped)
--    has_payment: expect 2283 (2800 - 517 no-payment)
--    has_shipment: expect ~1864 (verify 1:1 vs 1:many)
SELECT
    (SELECT COUNT(*) FROM silver.cleaned_shipments  WHERE in_transit = 1) AS in_transit_shipments,
    (SELECT COUNT(*) FROM silver.cleaned_products   WHERE is_discontinued_but_sold = 1) AS discontinued_but_sold,
    (SELECT COUNT(*) FROM silver.cleaned_orders     WHERE is_fulfilled = 1) AS fulfilled_orders,
    (SELECT COUNT(*) FROM silver.cleaned_orders     WHERE has_payment  = 1) AS orders_with_payment,
    (SELECT COUNT(*) FROM silver.cleaned_orders     WHERE has_shipment = 1) AS orders_with_shipment;

-- 3) Accuracy — orders whose total_amount disagrees with the sum of line items
--    (expect 0 rows per README: total_amount == SUM(quantity × unit_price))
SELECT COUNT(*) AS total_amount_mismatch_rows
FROM (
    SELECT o.order_id, o.total_amount, ROUND(SUM(oi.line_revenue), 2) AS items_total
    FROM silver.cleaned_orders o
    LEFT JOIN silver.cleaned_order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.total_amount
    HAVING o.total_amount <> ROUND(SUM(oi.line_revenue), 2)
) m;

-- 4) Validity — confirm enum domains are the documented canonical sets
SELECT 'orders.status'   AS col, string_agg(DISTINCT status,  ' | ') AS values FROM silver.cleaned_orders
UNION ALL SELECT 'payments.status', string_agg(DISTINCT status,  ' | ') FROM silver.cleaned_payments
UNION ALL SELECT 'payments.method', string_agg(DISTINCT method,  ' | ') FROM silver.cleaned_payments
UNION ALL SELECT 'shipments.carrier', string_agg(DISTINCT carrier, ' | ') FROM silver.cleaned_shipments;

-- 5) Uniqueness — confirm PKs are still unique after conforming (expect equal counts)
SELECT 'products'  AS pk, COUNT(*) AS total, COUNT(DISTINCT prod_id)   AS distinct_pk FROM silver.cleaned_products
UNION ALL SELECT 'orders',     COUNT(*), COUNT(DISTINCT order_id)      FROM silver.cleaned_orders
UNION ALL SELECT 'order_items',COUNT(*), COUNT(DISTINCT item_id)       FROM silver.cleaned_order_items
UNION ALL SELECT 'payments',   COUNT(*), COUNT(DISTINCT payment_id)    FROM silver.cleaned_payments
UNION ALL SELECT 'shipments',  COUNT(*), COUNT(DISTINCT shipment_id)   FROM silver.cleaned_shipments;
