-- ============================================================================
-- Case 02 — MarketHub · Stage 4: Silver → Gold mart
-- ============================================================================
-- Pipeline: data-to-insight (sql-builder). DB: datainsight_markethub (PostgreSQL)
-- Input : silver.cleaned_*  (8 conformed tables, Stage 3 output — verified)
-- Output: gold.mart_markethub  (ONE ROW PER ORDER-ITEM LINE, fully denormalized)
--
-- AUTHORING ONLY: this file is written to be executed by a human via psql;
-- the VERIFICATION block at the bottom is run and its output pasted back.
--
-- ----------------------------------------------------------------------------
-- GRAIN + UNIQUE KEY (declared before any column is written)
-- ----------------------------------------------------------------------------
--   GRAIN      : one row per order-item LINE.
--                Base table = silver.cleaned_order_items (7,102 lines).
--   UNIQUE KEY : item_id  (order_items PK) — verified via
--                COUNT(*) = COUNT(DISTINCT item_id) below.
--   FAN-OUT    : NONE. Every join off the line is 1:1 (products, categories,
--                orders, customers, vendors) or 1:0..1 (payments, shipments),
--                so row count MUST stay 7,102 after the joins.
--
-- ----------------------------------------------------------------------------
-- DESIGN DECISIONS (approved — followed exactly)
-- ----------------------------------------------------------------------------
--   1. Line grain, unique key = item_id (see above).
--   2. KEEP ALL ORDERS (Completed/Shipped/Pending/Cancelled). The mart does
--      NOT filter; `is_fulfilled` carries the GMV/count scope and Stage 5
--      filters `is_fulfilled = 1`. Cancelled/Pending stay available for Q9.
--   3. GMV at ANY slice = SUM(line_revenue) over fulfilled lines (README
--      guarantees orders.total_amount = SUM(line_revenue) per order).
--      `total_amount` is kept as a REFERENCE column only and is NEVER
--      aggregated after the joins (it is an order-level value repeated on
--      every line of that order — summing it at line grain would fan out).
--
-- ----------------------------------------------------------------------------
-- DENORMALIZATION JOINS (all LEFT JOIN, keyed off the line)
-- ----------------------------------------------------------------------------
--   cleaned_order_items  (base)        item_id (PK), order_id, product_id,
--                                      quantity, unit_price (LINE-level price —
--                                      the price charged on this line;
--                                      authoritative for line_revenue),
--                                      line_revenue
--   → cleaned_products   ON product_id vendor_id, prod_name, is_active,
--                                      is_discontinued_but_sold   [1:1]
--   → cleaned_categories ON cat_id     category = COALESCE(parent_cat_name,
--                                      cat_name) → TOP-LEVEL category (Q3/Q9)
--   → cleaned_orders     ON order_id   order_date, month, customer_id,
--                                      is_fulfilled, total_amount   [1:1]
--                                      (status folded into is_fulfilled in
--                                       silver; kept as a flag, not a filter)
--   → cleaned_customers  ON customer_id country                     [1:1]
--   → cleaned_vendors    ON vendor_id  vendor_name                  [1:1]
--   → cleaned_payments   ON order_id   payment_method = method,
--                                      payment_status = status      [1:0..1]
--                                      (verified 2283 = 2800 - 517; NO fan-out.
--                                       NULL payment_* = no payment row)
--   → cleaned_shipments  ON order_id   carrier, in_transit          [1:1 fulfilled]
--                                      (verified 1864 = fulfilled orders; the 95
--                                       in_transit rows are a real state for Q9)
-- ============================================================================

DROP TABLE IF EXISTS gold.mart_markethub CASCADE;

CREATE TABLE gold.mart_markethub AS
SELECT
    oi.item_id,
    oi.order_id,
    oi.product_id,                                          -- leaf-level product (Q9 product drill)
    o.customer_id,
    o.order_date,
    TO_CHAR(o.order_date, 'YYYY-MM') AS month,
    p.vendor_id,
    v.vendor_name,
    p.prod_name AS product_name,                            -- leaf-level product name (Q9)
    COALESCE(c.parent_cat_name, c.cat_name) AS category,    -- top-level roll-up (Q3)
    cu.country,
    oi.quantity,
    oi.unit_price,                                          -- line-level price
    oi.line_revenue,
    o.total_amount,                                         -- REFERENCE ONLY (order-level)
    o.is_fulfilled,
    p.is_active,
    p.is_discontinued_but_sold,
    pm.method   AS payment_method,
    pm.status   AS payment_status,
    s.carrier,
    s.in_transit
FROM silver.cleaned_order_items oi
LEFT JOIN silver.cleaned_products   p  ON p.prod_id    = oi.product_id
LEFT JOIN silver.cleaned_categories c  ON c.cat_id     = p.cat_id
LEFT JOIN silver.cleaned_orders     o  ON o.order_id   = oi.order_id
LEFT JOIN silver.cleaned_customers  cu ON cu.cust_id   = o.customer_id
LEFT JOIN silver.cleaned_vendors    v  ON v.vendor_id  = p.vendor_id
LEFT JOIN silver.cleaned_payments   pm ON pm.order_id  = oi.order_id   -- 1:0..1
LEFT JOIN silver.cleaned_shipments  s  ON s.order_id   = oi.order_id;  -- 1:1 (fulfilled)

-- ============================================================================
-- VERIFICATION (run this; paste output back at the Gold checkpoint)
-- Expected values are per the verified silver layer / dataset README. Treat any
-- deviation as a new hypothesis to investigate, NOT to silently patch.
-- ============================================================================

-- 1) Uniqueness — the grain key (item_id) must be distinct.
--    EXPECT: total = distinct_item = 7102.
SELECT COUNT(*)                AS total,
       COUNT(DISTINCT item_id) AS distinct_item
FROM gold.mart_markethub;

-- 2) Fan-out check — payments/shipments must NOT fan out lines into extra rows.
--    EXPECT: distinct_orders = 2800 (equals silver.cleaned_orders row count).
--    A value > 2800 would mean order rows were duplicated by the LEFT JOINs;
--    a value < 2800 would mean lines were dropped (neither should happen).
SELECT COUNT(DISTINCT order_id) AS distinct_orders
FROM gold.mart_markethub;

-- 3) GMV consistency — fulfilled GMV computed two ways MUST agree (diff = 0.00).
--    README guarantees orders.total_amount = SUM(line_revenue) per order.
--    IMPORTANT: total_amount is order-level and is REPEATED on every line of
--    that order, so it is summed only after de-duplicating orders — otherwise
--    it would fan out (order total × line count). This enforces design
--    decision #3 ("never aggregate total_amount after joins that fan out").
WITH line_gmv AS (
    SELECT ROUND(SUM(line_revenue), 2) AS gmv
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
),
order_gmv AS (
    SELECT ROUND(SUM(total_amount), 2) AS gmv
    FROM (
        SELECT DISTINCT order_id, total_amount
        FROM gold.mart_markethub
        WHERE is_fulfilled = 1
    ) d
)
SELECT line_gmv.gmv                              AS gmv_from_line_revenue,
       order_gmv.gmv                             AS gmv_from_order_total,
       ROUND(line_gmv.gmv - order_gmv.gmv, 2)    AS difference
FROM line_gmv
CROSS JOIN order_gmv;

-- 4) Row count — mart must carry every line, no more and no less.
--    EXPECT: mart_rows = silver_order_items_rows = 7102.
SELECT (SELECT COUNT(*) FROM gold.mart_markethub)          AS mart_rows,
       (SELECT COUNT(*) FROM silver.cleaned_order_items)   AS silver_order_items_rows;
