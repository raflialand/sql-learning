-- =============================================================================
-- Case 03: NovaTel — 12 Sub-question Queries
-- Gold Mart: gold.mart_subscriber_health
-- Grain: one row per bill_id
-- Limitation: MoM only (Dec-2025 → Jan-2026). NO YoY comparisons.
-- =============================================================================

-- =============================================================================
-- BUCKET 1: Overall Trends
-- =============================================================================

-- Q1: Total billed revenue per month
-- Business question: What is the total billed revenue for each month?
SELECT
    billing_month,
    SUM(billed_amount) AS total_billed_revenue
FROM gold.mart_subscriber_health
GROUP BY billing_month
ORDER BY billing_month;

-- Q2: Payment collection rate per month
-- Business question: What percentage of bills were paid on time each month?
SELECT
    billing_month,
    COUNT(*) AS total_bills,
    COUNT(CASE WHEN bill_status = 'Paid' THEN 1 END) AS paid_bills,
    ROUND(
        COUNT(CASE WHEN bill_status = 'Paid' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS collection_rate_pct
FROM gold.mart_subscriber_health
GROUP BY billing_month
ORDER BY billing_month;

-- Q3: Active subscribers billed per month
-- Business question: How many unique subscribers were billed each month?
SELECT
    billing_month,
    COUNT(DISTINCT sub_id) AS active_subscribers
FROM gold.mart_subscriber_health
GROUP BY billing_month
ORDER BY billing_month;

-- =============================================================================
-- BUCKET 2: Growth Rates
-- =============================================================================

-- Q4: Billed revenue MoM change
-- Business question: What is the month-over-month change in total billed revenue?
SELECT
    curr.billing_month,
    curr.total_billed_revenue,
    prev.total_billed_revenue AS prev_month_revenue,
    curr.total_billed_revenue - prev.total_billed_revenue AS revenue_change,
    ROUND(
        (curr.total_billed_revenue - prev.total_billed_revenue) * 100.0
        / NULLIF(prev.total_billed_revenue, 0),
        2
    ) AS revenue_mom_pct
FROM (
    SELECT billing_month, SUM(billed_amount) AS total_billed_revenue
    FROM gold.mart_subscriber_health
    GROUP BY billing_month
) curr
LEFT JOIN (
    SELECT billing_month, SUM(billed_amount) AS total_billed_revenue
    FROM gold.mart_subscriber_health
    GROUP BY billing_month
) prev
    ON prev.billing_month = CASE
        WHEN curr.billing_month = '2026-01' THEN '2025-12'
        ELSE NULL
    END
WHERE curr.billing_month = '2026-01'
ORDER BY curr.billing_month;

-- Q5: Collection rate MoM change
-- Business question: What is the month-over-month change in payment collection rate?
SELECT
    curr.billing_month,
    curr.collection_rate_pct,
    prev.collection_rate_pct AS prev_month_rate,
    ROUND(curr.collection_rate_pct - prev.collection_rate_pct, 2) AS rate_change_pct
FROM (
    SELECT
        billing_month,
        ROUND(
            COUNT(CASE WHEN bill_status = 'Paid' THEN 1 END) * 100.0 / COUNT(*),
            2
        ) AS collection_rate_pct
    FROM gold.mart_subscriber_health
    GROUP BY billing_month
) curr
LEFT JOIN (
    SELECT
        billing_month,
        ROUND(
            COUNT(CASE WHEN bill_status = 'Paid' THEN 1 END) * 100.0 / COUNT(*),
            2
        ) AS collection_rate_pct
    FROM gold.mart_subscriber_health
    GROUP BY billing_month
) prev
    ON prev.billing_month = CASE
        WHEN curr.billing_month = '2026-01' THEN '2025-12'
        ELSE NULL
    END
WHERE curr.billing_month = '2026-01'
ORDER BY curr.billing_month;

-- =============================================================================
-- BUCKET 3: Performance Measurement
-- =============================================================================

-- Q6: Billed revenue by plan
-- Business question: Which plans generate the most billed revenue?
SELECT
    plan_name,
    SUM(billed_amount) AS total_billed_revenue
FROM gold.mart_subscriber_health
GROUP BY plan_name
ORDER BY total_billed_revenue DESC;

-- Q7: Billed revenue by region
-- Business question: Which regions generate the most billed revenue?
SELECT
    region,
    SUM(billed_amount) AS total_billed_revenue
FROM gold.mart_subscriber_health
GROUP BY region
ORDER BY total_billed_revenue DESC;

-- Q8: Collection rate by plan
-- Business question: Which plans have the best/worst payment collection rates?
SELECT
    plan_name,
    COUNT(*) AS total_bills,
    COUNT(CASE WHEN bill_status = 'Paid' THEN 1 END) AS paid_bills,
    ROUND(
        COUNT(CASE WHEN bill_status = 'Paid' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS collection_rate_pct
FROM gold.mart_subscriber_health
GROUP BY plan_name
ORDER BY collection_rate_pct DESC;

-- Q9: Churn count by region
-- Business question: Which regions have the most churned subscribers?
-- FIX: Use COUNT(DISTINCT sub_id) to avoid grain mismatch (mart grain = bill_id, churn is subscriber-level)
SELECT
    region,
    COUNT(DISTINCT CASE WHEN has_churned = TRUE THEN sub_id END) AS churned_subscribers,
    COUNT(DISTINCT sub_id) AS total_subscribers,
    ROUND(
        COUNT(DISTINCT CASE WHEN has_churned = TRUE THEN sub_id END) * 100.0
        / NULLIF(COUNT(DISTINCT sub_id), 0),
        2
    ) AS churn_rate_pct
FROM gold.mart_subscriber_health
GROUP BY region
ORDER BY churned_subscribers DESC;

-- =============================================================================
-- BUCKET 4: KPI Reporting
-- =============================================================================

-- Q10: Unpaid/Overdue share by plan
-- Business question: Which plans have the highest non-payment rates?
SELECT
    plan_name,
    COUNT(*) AS total_bills,
    COUNT(CASE WHEN bill_status IN ('Unpaid', 'Overdue') THEN 1 END) AS unpaid_overdue_bills,
    ROUND(
        COUNT(CASE WHEN bill_status IN ('Unpaid', 'Overdue') THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS unpaid_overdue_pct
FROM gold.mart_subscriber_health
GROUP BY plan_name
ORDER BY unpaid_overdue_pct DESC;

-- Q11: Churn reasons by region
-- Business question: What are the main churn reasons across regions?
-- FIX: Use COUNT(DISTINCT sub_id) to avoid grain mismatch (mart grain = bill_id, churn is subscriber-level)
SELECT
    region,
    churn_reason,
    COUNT(DISTINCT sub_id) AS churned_subscribers
FROM gold.mart_subscriber_health
WHERE has_churned = TRUE
GROUP BY region, churn_reason
ORDER BY region, churned_subscribers DESC;

-- Q12: ARPU by plan
-- Business question: What is the average revenue per user for each plan?
SELECT
    plan_name,
    SUM(billed_amount) AS total_billed_revenue,
    COUNT(DISTINCT sub_id) AS unique_subscribers,
    ROUND(
        SUM(billed_amount) / NULLIF(COUNT(DISTINCT sub_id), 0),
        2
    ) AS arpu
FROM gold.mart_subscriber_health
GROUP BY plan_name
ORDER BY arpu DESC;
