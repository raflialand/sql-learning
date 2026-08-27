-- ============================================================================
-- Case 02 — MarketHub · Stage 5: Query the gold mart (sub-question queries)
-- ============================================================================
-- Pipeline: data-to-insight (sql-builder). DB: datainsight_markethub (PostgreSQL)
-- Input : gold.mart_markethub  (Stage 4 output — VERIFIED: 7,102 rows,
--         grain = one row per order-item LINE, unique key = item_id,
--         2,800 distinct orders; all order statuses kept).
-- Output: 03-queries.sql  (ONE query per sub-question Q1..Q9)
--
-- AUTHORING ONLY: this file is written to be executed by a HUMAN via psql,
-- statement-by-statement. Results are captured by the human + orchestrator into
-- 03-results.md (NOT authored here — this file contains no execution output).
--
-- ----------------------------------------------------------------------------
-- INVARIANTS (enforced in every query)
-- ----------------------------------------------------------------------------
--   SOURCE    : gold.mart_markethub ONLY (never raw/bronze/silver).
--   GRAIN     : one row per order-item LINE. Therefore any "count of orders"
--               or "distinct buyers" uses COUNT(DISTINCT order_id) /
--               COUNT(DISTINCT customer_id) — NEVER COUNT(*) (which would
--               count line rows, not baskets).
--   GMV       : SUM(line_revenue) WHERE is_fulfilled = 1. `total_amount` is an
--               order-level value REPEATED on every line and is NEVER aggregated
--               after the joins (fan-out hazard) — reference only.
--   FULFILLED : is_fulfilled = 1 (Completed/Shipped). Applied to every GMV,
--               order-count, AOV, and repeat-rate query.
--
-- ----------------------------------------------------------------------------
-- METRIC DEFINITIONS (from work/01-scope.md — followed exactly)
-- ----------------------------------------------------------------------------
--   GMV     = SUM(line_revenue) over is_fulfilled = 1.
--   Orders  = COUNT(DISTINCT order_id) over is_fulfilled = 1.
--   AOV     = GMV ÷ Orders (same grouping scope).
--   Repeat% = (distinct customers w/ ≥2 fulfilled orders ÷ distinct customers
--             w/ ≥1 fulfilled order) × 100, expressed as a percentage.
--   Dimensions: Vendor, Country, Category (top-level), Month.
--   Product is a Q9-only drill-down.
-- ============================================================================

-- ============================================================================
-- BUCKET 1 — OVERALL TRENDS (level splits; no time axis except Q1; no % change)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q1 (Overall Trends) — GMV by month, 13 months, chronological.
-- answers: the marketplace's level arc across 2025-01 .. 2026-01.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per month.
-- ----------------------------------------------------------------------------
SELECT
    month,
    ROUND(SUM(line_revenue), 2) AS gmv
FROM gold.mart_markethub
WHERE is_fulfilled = 1
GROUP BY month
ORDER BY month;

-- ----------------------------------------------------------------------------
-- Q2 (Overall Trends) — GMV by vendor, ranked DESC.
-- answers: size ranking — which sellers carry the top line today.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per vendor.
-- ----------------------------------------------------------------------------
SELECT
    vendor_id,
    vendor_name,
    ROUND(SUM(line_revenue), 2) AS gmv
FROM gold.mart_markethub
WHERE is_fulfilled = 1
GROUP BY vendor_id, vendor_name
ORDER BY gmv DESC;

-- ----------------------------------------------------------------------------
-- Q3 (Overall Trends) — GMV by top-level category, ranked DESC.
-- answers: catalog mix — which product lines drive GMV.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per category
--           (`category` is already the TOP-LEVEL roll-up from the gold mart).
-- ----------------------------------------------------------------------------
SELECT
    category,
    ROUND(SUM(line_revenue), 2) AS gmv
FROM gold.mart_markethub
WHERE is_fulfilled = 1
GROUP BY category
ORDER BY gmv DESC;

-- ----------------------------------------------------------------------------
-- Q4 (Overall Trends) — GMV by buyer country, ranked DESC.
-- answers: geography — where the buyers (and growth) come from.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per country.
-- ----------------------------------------------------------------------------
SELECT
    country,
    ROUND(SUM(line_revenue), 2) AS gmv
FROM gold.mart_markethub
WHERE is_fulfilled = 1
GROUP BY country
ORDER BY gmv DESC;

-- ============================================================================
-- BUCKET 2 — GROWTH RATES (% change lens; both MoM and YoY, 13-month span)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q5 (Growth Rates) — Monthly GMV + MoM% + YoY%.
-- answers: is the marketplace growing, and is there a repeating rhythm?
-- grain   : SUM(line_revenue) over fulfilled LINES → one row per month, then
--           LAG(gmv,1) = prior month, LAG(gmv,12) = same month prior year.
-- NULLs   : the FIRST month has no prior month (mom_pct NULL) and the first
--           12 months have no prior-year month (yoy_pct NULL). The NULLs
--           propagate through the division naturally — no divide-by-zero.
-- ----------------------------------------------------------------------------
WITH monthly AS (
    SELECT
        month,
        SUM(line_revenue) AS gmv
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY month
),
with_lags AS (
    SELECT
        month,
        gmv,
        LAG(gmv, 1)  OVER (ORDER BY month) AS prev_month_gmv,
        LAG(gmv, 12) OVER (ORDER BY month) AS prev_year_gmv
    FROM monthly
)
SELECT
    month,
    ROUND(gmv, 2)                                                   AS gmv,
    ROUND(100.0 * (gmv - prev_month_gmv) / prev_month_gmv, 2)      AS mom_pct,
    ROUND(100.0 * (gmv - prev_year_gmv)  / prev_year_gmv,  2)      AS yoy_pct
FROM with_lags
ORDER BY month;

-- ----------------------------------------------------------------------------
-- Q6 (Growth Rates) — GMV by vendor × month + MoM% + YoY% per vendor.
-- answers: which vendor is growing vs shrinking — who has momentum?
-- grain   : SUM(line_revenue) over fulfilled LINES → one row per vendor-month.
-- HARDENED: builds a dense vendor × month grid (vendors CROSS JOIN months) so
--           LAG walks TRUE calendar months — a vendor that skips a month still
--           shows gmv=0 for that month, and MoM/YoY compares against the real
--           prior month/year, not the last selling month (no silent gap-span).
--           NULLIF guards the denominator when the prior period has zero GMV
--           (→ NULL, honest "cannot divide by zero").
-- ----------------------------------------------------------------------------
WITH months AS (
    SELECT DISTINCT month
    FROM gold.mart_markethub
),
vendors AS (
    SELECT DISTINCT vendor_id, vendor_name
    FROM gold.mart_markethub
),
actual AS (
    SELECT
        vendor_id,
        vendor_name,
        month,
        SUM(line_revenue) AS gmv
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY vendor_id, vendor_name, month
),
grid AS (
    SELECT v.vendor_id, v.vendor_name, m.month
    FROM vendors v
    CROSS JOIN months m
),
with_lags AS (
    SELECT
        g.vendor_id,
        g.vendor_name,
        g.month,
        COALESCE(a.gmv, 0) AS gmv,
        LAG(COALESCE(a.gmv, 0), 1)  OVER (PARTITION BY g.vendor_id ORDER BY g.month) AS prev_month_gmv,
        LAG(COALESCE(a.gmv, 0), 12) OVER (PARTITION BY g.vendor_id ORDER BY g.month) AS prev_year_gmv
    FROM grid g
    LEFT JOIN actual a
           ON a.vendor_id = g.vendor_id
          AND a.month     = g.month
)
SELECT
    vendor_id,
    vendor_name,
    month,
    ROUND(gmv, 2)                                                   AS gmv,
    ROUND(100.0 * (gmv - prev_month_gmv) / NULLIF(prev_month_gmv, 0), 2) AS mom_pct,
    ROUND(100.0 * (gmv - prev_year_gmv)  / NULLIF(prev_year_gmv, 0), 2)  AS yoy_pct
FROM with_lags
ORDER BY vendor_id, month;

-- ============================================================================
-- BUCKET 3 — PERFORMANCE (snapshot head-to-head; no time axis)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q7 (Performance) — AOV by vendor, ranked DESC.
-- answers: which vendor has the strongest basket (value lever vs volume lever)?
-- grain   : AOV = SUM(line_revenue) ÷ COUNT(DISTINCT order_id), over fulfilled
--           scope. The numerator sums LINES; the denominator counts BASKETS
--           (COUNT(DISTINCT order_id)) so a multi-line order is one basket.
-- ----------------------------------------------------------------------------
SELECT
    vendor_id,
    vendor_name,
    ROUND(SUM(line_revenue) / COUNT(DISTINCT order_id), 2) AS aov
FROM gold.mart_markethub
WHERE is_fulfilled = 1
GROUP BY vendor_id, vendor_name
ORDER BY aov DESC;

-- ----------------------------------------------------------------------------
-- Q8 (Performance) — Repeat purchase rate by vendor (%), ranked DESC.
-- answers: which vendor has the most loyal buyers (the "invest here" signal)?
-- grain   : per vendor-customer, count DISTINCT order_id (fulfilled). Then per
--           vendor: distinct customers w/ ≥2 fulfilled orders ÷ distinct
--           customers w/ ≥1 fulfilled order × 100.
-- NOTE    : an order spanning multiple vendors is counted toward EACH vendor it
--           touches (the mart's line grain already attributes each line to its
--           vendor, so a cross-vendor order appears once per vendor).
-- ----------------------------------------------------------------------------
WITH buyer_orders AS (
    SELECT
        vendor_id,
        vendor_name,
        customer_id,
        COUNT(DISTINCT order_id) AS fulfilled_orders
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY vendor_id, vendor_name, customer_id
)
SELECT
    vendor_id,
    vendor_name,
    SUM(CASE WHEN fulfilled_orders >= 2 THEN 1 ELSE 0 END)                    AS repeat_buyers,
    COUNT(*)                                                                  AS total_buyers,
    ROUND(100.0 * SUM(CASE WHEN fulfilled_orders >= 2 THEN 1 ELSE 0 END)
               / COUNT(*), 2)                                                 AS repeat_rate_pct
FROM buyer_orders
GROUP BY vendor_id, vendor_name
ORDER BY repeat_rate_pct DESC;

-- ============================================================================
-- BUCKET 4 — KPI REPORTING (the "why" behind a flagged number)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q9 (0) — identify the BOTTOM vendor by fulfilled GMV (same ranking as Q2,
--         ascending). This is the anchor for the drills (a)-(d) below.
-- answers: WHICH vendor underperforms.
-- ----------------------------------------------------------------------------
SELECT
    vendor_id,
    vendor_name,
    ROUND(SUM(line_revenue), 2) AS gmv
FROM gold.mart_markethub
WHERE is_fulfilled = 1
GROUP BY vendor_id, vendor_name
ORDER BY gmv ASC
LIMIT 1;

-- ----------------------------------------------------------------------------
-- Q9 (a) — category mix: GMV + share% by top-level category for the bottom
--          vendor. Scope: fulfilled orders only (GMV = line_revenue).
-- ----------------------------------------------------------------------------
WITH bottom_vendor AS (
    SELECT vendor_id
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY vendor_id
    ORDER BY SUM(line_revenue) ASC
    LIMIT 1
),
category_gmv AS (
    SELECT
        m.category,
        ROUND(SUM(m.line_revenue), 2) AS gmv
    FROM gold.mart_markethub m
    JOIN bottom_vendor bv ON bv.vendor_id = m.vendor_id
    WHERE m.is_fulfilled = 1
    GROUP BY m.category
)
SELECT
    category,
    gmv,
    ROUND(100.0 * gmv / SUM(gmv) OVER (), 2) AS share_pct
FROM category_gmv
ORDER BY gmv DESC;

-- ----------------------------------------------------------------------------
-- Q9 (b) — product mix: GMV + units by product_name for the bottom vendor
--          (top ~10 by GMV). Scope: fulfilled orders only.
-- ----------------------------------------------------------------------------
WITH bottom_vendor AS (
    SELECT vendor_id
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY vendor_id
    ORDER BY SUM(line_revenue) ASC
    LIMIT 1
)
SELECT
    m.product_name,
    ROUND(SUM(m.line_revenue), 2) AS gmv,
    SUM(m.quantity)               AS units
FROM gold.mart_markethub m
JOIN bottom_vendor bv ON bv.vendor_id = m.vendor_id
WHERE m.is_fulfilled = 1
GROUP BY m.product_name
ORDER BY gmv DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Q9 (c) — shipment health: count of lines/orders by carrier and in_transit
--          status. Scope: fulfilled orders only (shipments exist ONLY for
--          fulfilled orders; Pending/Cancelled have NULL carrier). in_transit=1
--          means shipped-but-not-yet-delivered (delivery_date IS NULL).
-- grain   : lines = COUNT(*) (line rows); orders = COUNT(DISTINCT order_id).
-- ----------------------------------------------------------------------------
WITH bottom_vendor AS (
    SELECT vendor_id
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY vendor_id
    ORDER BY SUM(line_revenue) ASC
    LIMIT 1
)
SELECT
    m.carrier,
    m.in_transit,
    COUNT(*)                   AS lines,
    COUNT(DISTINCT m.order_id) AS orders
FROM gold.mart_markethub m
JOIN bottom_vendor bv ON bv.vendor_id = m.vendor_id
WHERE m.is_fulfilled = 1
GROUP BY m.carrier, m.in_transit
ORDER BY m.carrier, m.in_transit;

-- ----------------------------------------------------------------------------
-- Q9 (d) — payment health: count of ORDERS (DISTINCT order_id) by
--          payment_status (paid / failed / refunded / NULL). Scope: ALL orders
--          (NO is_fulfilled filter) — payment_status IS NULL means the order
--          has NO payment row, which is a finding for Q9, not an error.
-- grain   : orders = COUNT(DISTINCT order_id), never COUNT(*) (line grain).
-- ----------------------------------------------------------------------------
WITH bottom_vendor AS (
    SELECT vendor_id
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY vendor_id
    ORDER BY SUM(line_revenue) ASC
    LIMIT 1
)
SELECT
    m.payment_status,
    COUNT(DISTINCT m.order_id) AS orders
FROM gold.mart_markethub m
JOIN bottom_vendor bv ON bv.vendor_id = m.vendor_id
GROUP BY m.payment_status
ORDER BY orders DESC;

-- ============================================================================
-- END OF 03-queries.sql — 9 sub-questions, 13 runnable statements (Q1..Q8, Q9
-- split into 0/a/b/c/d). Run statement-by-statement in psql and paste output
-- back; the human + orchestrator capture it into 03-results.md.
-- ============================================================================
