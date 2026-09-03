-- ============================================================================
-- Case 03 — NovaTel Telecom — Silver Cleaning SQL
-- ============================================================================
-- DQ Dimensions Applied: Completeness, Uniqueness, Validity, Accuracy, Consistency
-- DQ Dimensions Skipped:  Timeliness (N/A — see rationale below)
--
-- DESIGN PRINCIPLE: Conform + flag, never drop. Row counts are preserved.
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- DQ EVALUATION SUMMARY (applied dimensions)
-- ────────────────────────────────────────────────────────────────────────────
--
-- 1. COMPLETENESS — EFFECTIVE
--    All required fields populated across all tables. No NULLs in business-
--    critical columns. The 1,149 NULLs in tickets.resolved_date are expected
--    (open tickets), not data-quality gaps.
--
-- 2. UNIQUENESS — EFFECTIVE
--    All PKs unique (bill_id, pay_id, log_id, ticket_id, churn_id, sub_id).
--    No duplicate rows in any table. No duplicate subscribers.
--
-- 3. VALIDITY — EFFECTIVE
--    All FK relationships intact (zero orphans). Status values within expected
--    sets. Amounts positive. No tickets resolved before creation. All plan_ids
--    valid. 2,580 usage_logs exceed plan data allowance — flagged, not dropped.
--
-- 4. ACCURACY — EFFECTIVE
--    Billing status matches payment reality: all Paid bills have a payment; all
--    Unpaid/Overdue bills have zero payments. Payment amounts match bill amounts
--    exactly. Cross-table referential integrity holds.
--
-- 5. CONSISTENCY — EFFECTIVE
--    Status fields use standardized values. Regions use consistent naming.
--    All plan_ids map to valid plans. No cross-table contradictions found.
--
-- 6. TIMELINESS — N/A (SKIPPED)
--    Dataset spans exactly 2 billing months (2025-12, 2026-01) and 2 usage
--    months. There is no temporal granularity issue or freshness problem.
--    Timeliness DQ requires a longer time series to assess — the limitation
--    is structural (dataset design), not a data-quality defect.
-- ────────────────────────────────────────────────────────────────────────────


-- ============================================================================
-- STEP 1: Create silver schema (PostgreSQL)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS silver;


-- ============================================================================
-- STEP 2: Silver — plans (pass-through, no cleaning needed)
-- ============================================================================
-- Plans are reference data with 6 rows, no issues found.
DROP TABLE IF EXISTS silver.plans;
CREATE TABLE silver.plans AS
SELECT
    plan_id,
    plan_name,
    monthly_fee,
    data_gb,
    voice_min
FROM bronze.plans;


-- ============================================================================
-- STEP 3: Silver — subscribers (pass-through, no issues found)
-- ============================================================================
-- All 4,500 subscribers have valid plan_ids, no NULLs, no duplicates.
DROP TABLE IF EXISTS silver.subscribers;
CREATE TABLE silver.subscribers AS
SELECT
    sub_id,
    first_name,
    last_name,
    phone,
    plan_id,
    region,
    signup_date::date   AS signup_date,
    status
FROM bronze.subscribers;


-- ============================================================================
-- STEP 4: Silver — billing (DQ: Validity flag for status)
-- ============================================================================
-- All 7,996 bills pass completeness/uniqueness/validity checks.
-- Status values are clean (Paid/Unpaid/Overdue). No NULLs, no dupes.
-- Added: _status_flag to surface leakage risk for downstream queries.
DROP TABLE IF EXISTS silver.billing;
CREATE TABLE silver.billing AS
SELECT
    bill_id,
    sub_id,
    bill_date::date          AS bill_date,
    period_start::date       AS period_start,
    period_end::date         AS period_end,
    amount,
    status,
    -- DQ Flag: revenue leakage indicator
    CASE
        WHEN status IN ('Unpaid','Overdue') THEN 'REVENUE_LEAK'
        ELSE 'OK'
    END AS _leakage_flag
FROM bronze.billing;


-- ============================================================================
-- STEP 5: Silver — payments (pass-through, no issues found)
-- ============================================================================
-- All 6,588 payments have valid FKs, matching amounts, no NULLs.
-- All payment amounts match their linked bill amount exactly.
DROP TABLE IF EXISTS silver.payments;
CREATE TABLE silver.payments AS
SELECT
    pay_id,
    sub_id,
    bill_id,
    pay_date::date           AS pay_date,
    amount,
    method
FROM bronze.payments;


-- ============================================================================
-- STEP 6: Silver — usage_logs (DQ: Validity flag for over-allowance)
-- ============================================================================
-- All 7,418 logs are complete and unique.
-- ISSUE: 2,580 logs (34.8%) have data_mb exceeding the subscriber's plan
-- data allowance. Flagged for downstream analysis (not dropped).
DROP TABLE IF EXISTS silver.usage_logs;
CREATE TABLE silver.usage_logs AS
SELECT
    u.log_id,
    u.sub_id,
    u.log_date::date         AS log_date,
    u.data_mb,
    u.voice_min,
    u.sms,
    -- DQ Flag: usage exceeding plan data allowance
    CASE
        WHEN u.data_mb > p.data_gb * 1024 THEN 'OVER_ALLOWANCE'
        ELSE 'WITHIN_ALLOWANCE'
    END AS _data_flag,
    -- Enrichment: plan allowance for downstream queries
    p.data_gb * 1024         AS _plan_data_mb_limit,
    ROUND(u.data_mb * 100.0 / NULLIF(p.data_gb * 1024, 0), 1) AS _data_utilization_pct
FROM bronze.usage_logs u
JOIN bronze.subscribers s ON u.sub_id = s.sub_id
JOIN bronze.plans p        ON s.plan_id = p.plan_id;


-- ============================================================================
-- STEP 7: Silver — tickets (DQ: Completeness — resolved_date NULL handling)
-- ============================================================================
-- 1,149 of 3,800 tickets have resolved_date IS NULL (status = 'Open').
-- This is expected behavior, NOT a data-quality gap. We explicitly flag it
-- so downstream queries can distinguish "still open" from "missing data."
DROP TABLE IF EXISTS silver.tickets;
CREATE TABLE silver.tickets AS
SELECT
    ticket_id,
    sub_id,
    created_date::date       AS created_date,
    resolved_date::date      AS resolved_date,
    category,
    status,
    -- DQ Flag: resolution status
    CASE
        WHEN resolved_date IS NULL THEN 'OPEN_NO_RESOLUTION'
        ELSE 'RESOLVED'
    END AS _resolution_flag,
    -- Enrichment: days to resolution (NULL if unresolved)
    CASE
        WHEN resolved_date IS NOT NULL
        THEN resolved_date::date - created_date::date
        ELSE NULL
    END AS _days_to_resolve
FROM bronze.tickets;


-- ============================================================================
-- STEP 8: Silver — churn (pass-through, no issues found)
-- ============================================================================
-- All 427 churn records complete, valid dates, valid reasons.
-- NOTE: 38 churned subscribers have unpaid/overdue bills — flagged in billing
-- layer, not here. Churn table is clean.
DROP TABLE IF EXISTS silver.churn;
CREATE TABLE silver.churn AS
SELECT
    churn_id,
    sub_id,
    churn_date::date         AS churn_date,
    reason
FROM bronze.churn;


-- ============================================================================
-- STEP 9: Silver — cross-table DQ flag view (Uniqueness verification)
-- ============================================================================
-- Verification: each silver table preserves exact row count from bronze.
-- This view lets downstream consumers check DQ flags at a glance.
DROP VIEW IF EXISTS silver.dq_summary;
CREATE VIEW silver.dq_summary AS
SELECT 'plans'       AS table_name, COUNT(*) AS silver_rows, 6   AS bronze_rows FROM silver.plans
UNION ALL
SELECT 'subscribers',  COUNT(*), 4500                          FROM silver.subscribers
UNION ALL
SELECT 'billing',     COUNT(*), 7996                          FROM silver.billing
UNION ALL
SELECT 'payments',    COUNT(*), 6588                          FROM silver.payments
UNION ALL
SELECT 'usage_logs',  COUNT(*), 7418                          FROM silver.usage_logs
UNION ALL
SELECT 'tickets',     COUNT(*), 3800                          FROM silver.tickets
UNION ALL
SELECT 'churn',       COUNT(*), 427                           FROM silver.churn;


-- ============================================================================
-- VERIFICATION QUERIES (run after execution)
-- ============================================================================

-- V1: Row count preservation check (should return all matching)
-- SELECT * FROM silver.dq_summary;

-- V2: Leakage flag distribution in billing
-- SELECT _leakage_flag, COUNT(*) FROM silver.billing GROUP BY _leakage_flag;

-- V3: Over-allowance flag distribution in usage_logs
-- SELECT _data_flag, COUNT(*) FROM silver.usage_logs GROUP BY _data_flag;

-- V4: Ticket resolution flag distribution
-- SELECT _resolution_flag, COUNT(*) FROM silver.tickets GROUP BY _resolution_flag;

-- V5: Uniqueness check — bill_id in silver.billing
-- SELECT COUNT(*), COUNT(DISTINCT bill_id), COUNT(*) - COUNT(DISTINCT bill_id) AS dupes
-- FROM silver.billing;
