-- ============================================================================
-- Case 03 — NovaTel Telecom — Gold Mart DDL
-- ============================================================================
-- GRAIN: One row per bill_id (each billing record is one row)
-- UNIQUE KEY: bill_id
-- ROW COUNT: 7,996 (matches silver.billing)
--
-- DESIGN: Denormalized mart joining billing → subscribers → plans, with
-- LEFT JOINs to churn, aggregated usage_logs, and aggregated tickets.
-- No fan-out: all joins are many-to-one or one-to-one.
--
-- VERIFICATION: COUNT(*) = COUNT(DISTINCT bill_id) must hold before queries.
-- ============================================================================

-- ============================================================================
-- STEP 1: Create gold schema (PostgreSQL)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS gold;


-- ============================================================================
-- STEP 2: Gold mart — one row per bill_id
-- ============================================================================
DROP TABLE IF EXISTS gold.mart_subscriber_health;
CREATE TABLE gold.mart_subscriber_health AS

-- ────────────────────────────────────────────────────────────────────────────
-- CTE 1: Billing + Subscriber + Plan attributes
-- Grain: one row per bill_id (7,996 rows)
-- Joins: billing → subscribers (many-to-one via sub_id)
--         subscribers → plans (many-to-one via plan_id)
-- No fan-out risk.
-- ────────────────────────────────────────────────────────────────────────────
WITH billing_plan AS (
    SELECT
        b.bill_id,
        b.sub_id,
        b.bill_date,
        EXTRACT(YEAR FROM b.bill_date)   AS bill_year,
        EXTRACT(MONTH FROM b.bill_date)  AS bill_month,
        TO_CHAR(b.bill_date, 'YYYY-MM')  AS bill_month_str,
        b.period_start,
        b.period_end,
        b.amount                         AS billed_amount,
        b.status                         AS bill_status,
        b._leakage_flag,

        -- Subscriber attributes
        s.first_name,
        s.last_name,
        s.phone,
        s.region,
        s.signup_date,
        s.status                         AS subscriber_status,

        -- Plan attributes
        p.plan_id,
        p.plan_name,
        p.monthly_fee,
        p.data_gb                        AS plan_data_gb,
        p.voice_min                      AS plan_voice_min
    FROM silver.billing b
    JOIN silver.subscribers s ON b.sub_id = s.sub_id
    JOIN silver.plans p       ON s.plan_id = p.plan_id
),

-- ────────────────────────────────────────────────────────────────────────────
-- CTE 2: Aggregated usage per subscriber per billing month
-- Grain: one row per (sub_id, bill_month_str)
-- Usage logs are 1:1 with active subscribers per month, so aggregation
-- is a safety net for any edge cases.
-- ────────────────────────────────────────────────────────────────────────────
usage_agg AS (
    SELECT
        u.sub_id,
        TO_CHAR(u.log_date, 'YYYY-MM')  AS bill_month_str,
        SUM(u.data_mb)                   AS total_data_mb,
        SUM(u.voice_min)                 AS total_voice_min,
        SUM(u.sms)                       AS total_sms,
        MAX(u._data_flag)                AS _data_flag,
        ROUND(AVG(u._data_utilization_pct), 1) AS _data_utilization_pct
    FROM silver.usage_logs u
    GROUP BY u.sub_id, TO_CHAR(u.log_date, 'YYYY-MM')
),

-- ────────────────────────────────────────────────────────────────────────────
-- CTE 3: Aggregated tickets per subscriber per billing month
-- Grain: one row per (sub_id, bill_month_str)
-- A subscriber can have multiple tickets per month; aggregation prevents
-- fan-out when joining to billing grain.
-- ────────────────────────────────────────────────────────────────────────────
ticket_agg AS (
    SELECT
        t.sub_id,
        TO_CHAR(t.created_date, 'YYYY-MM') AS bill_month_str,
        COUNT(*)                            AS ticket_count,
        SUM(CASE WHEN t.status = 'Open' THEN 1 ELSE 0 END) AS open_ticket_count,
        MAX(t._resolution_flag)             AS _resolution_flag,
        ROUND(AVG(t._days_to_resolve)::numeric, 1) AS avg_days_to_resolve
    FROM silver.tickets t
    WHERE t.created_date IS NOT NULL
    GROUP BY t.sub_id, TO_CHAR(t.created_date, 'YYYY-MM')
),

-- ────────────────────────────────────────────────────────────────────────────
-- CTE 4: Churn records (one row per subscriber)
-- At most 1 churn record per subscriber → no fan-out when joining to billing.
-- ────────────────────────────────────────────────────────────────────────────
churn_info AS (
    SELECT
        c.sub_id,
        c.churn_date,
        c.reason                          AS churn_reason,
        TRUE                              AS has_churned
    FROM silver.churn c
)

-- ────────────────────────────────────────────────────────────────────────────
-- Final SELECT: Denormalized mart at billing grain
-- All LEFT JOINs are many-to-one → no fan-out.
-- Mart row count = silver.billing row count (7,996).
-- ────────────────────────────────────────────────────────────────────────────
SELECT
    -- ── Grain key ──
    bp.bill_id,

    -- ── Billing facts ──
    bp.sub_id,
    bp.bill_date,
    bp.bill_year,
    bp.bill_month,
    bp.bill_month_str                    AS billing_month,
    bp.period_start,
    bp.period_end,
    bp.billed_amount,
    bp.bill_status,
    bp._leakage_flag,

    -- ── Subscriber attributes ──
    bp.first_name,
    bp.last_name,
    bp.phone,
    bp.region,
    bp.signup_date,
    bp.subscriber_status,

    -- ── Plan attributes ──
    bp.plan_id,
    bp.plan_name,
    bp.monthly_fee,
    bp.plan_data_gb,
    bp.plan_voice_min,

    -- ── Usage enrichments (from silver.usage_logs) ──
    ua.total_data_mb,
    ua.total_voice_min,
    ua.total_sms,
    ua._data_flag,
    ua._data_utilization_pct,

    -- ── Ticket enrichments (from silver.tickets) ──
    ta.ticket_count,
    ta.open_ticket_count,
    ta._resolution_flag,
    ta.avg_days_to_resolve,

    -- ── Churn enrichment (from silver.churn) ──
    ci.churn_date,
    ci.churn_reason,
    COALESCE(ci.has_churned, FALSE)      AS has_churned

FROM billing_plan bp
LEFT JOIN usage_agg ua
    ON  bp.sub_id        = ua.sub_id
    AND bp.billing_month = ua.bill_month_str
LEFT JOIN ticket_agg ta
    ON  bp.sub_id        = ta.sub_id
    AND bp.billing_month = ta.bill_month_str
LEFT JOIN churn_info ci
    ON  bp.sub_id        = ci.sub_id;


-- ============================================================================
-- VERIFICATION: Uniqueness check
-- Run this after execution. Must return difference = 0.
-- ============================================================================
-- SELECT
--     COUNT(*)               AS total_rows,
--     COUNT(DISTINCT bill_id) AS unique_bills,
--     COUNT(*) - COUNT(DISTINCT bill_id) AS difference
-- FROM gold.mart_subscriber_health;
-- ============================================================================
