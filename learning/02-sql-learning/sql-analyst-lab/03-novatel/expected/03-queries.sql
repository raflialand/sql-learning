-- Case 03 — NovaTel Model Queries (SQLite)
-- One query per sub-question (metric × dimension). Run statement-by-statement
-- with the same helper used for expected results:
--   python ../sql-skill-push/_tools/run_query.py ../sql-skill-push/datasets/03-advanced/telecom.db <this-file>
-- DATASET LIMITATION: billing spans ONLY 2025-12-01 and 2026-01-01 → MoM only, NO YoY.

-- Q1 (Overall Trends): billed revenue by plan
SELECT pl.plan_name,
       COUNT(b.bill_id) AS bills,
       ROUND(SUM(b.amount), 2) AS revenue
FROM billing b
JOIN subscribers s ON b.sub_id = s.sub_id
JOIN plans pl ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name
ORDER BY revenue DESC;

-- Q2 (Overall Trends): monthly revenue + distinct billed subscribers (base shape)
SELECT strftime('%Y-%m', bill_date) AS month,
       COUNT(*) AS bills,
       COUNT(DISTINCT sub_id) AS billed_subs,
       ROUND(SUM(amount), 2) AS revenue
FROM billing
GROUP BY strftime('%Y-%m', bill_date)
ORDER BY month;

-- Q3 (Growth Rates): MoM revenue + ARPU (Dec-2025 → Jan-2026) — MoM ONLY
WITH monthly AS (
    SELECT strftime('%Y-%m', bill_date) AS month,
           SUM(amount) AS revenue,
           COUNT(DISTINCT sub_id) AS subs
    FROM billing
    GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       subs,
       ROUND(revenue / subs, 2) AS arpu,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- Q4 (Performance Measurement): ARPU by plan
SELECT pl.plan_name,
       COUNT(DISTINCT b.sub_id) AS subs,
       ROUND(SUM(b.amount) / COUNT(DISTINCT b.sub_id), 2) AS arpu
FROM billing b
JOIN subscribers s ON b.sub_id = s.sub_id
JOIN plans pl ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name
ORDER BY arpu DESC;

-- Q5 (Performance Measurement): active subscriber base + billed revenue by region
SELECT s.region,
       COUNT(DISTINCT CASE WHEN s.status = 'Active' THEN s.sub_id END) AS active_subs,
       COUNT(DISTINCT b.sub_id) AS billed_subs,
       ROUND(SUM(b.amount), 2) AS revenue
FROM subscribers s
LEFT JOIN billing b ON s.sub_id = b.sub_id
GROUP BY s.region
ORDER BY revenue DESC;

-- Q6 (KPI Reporting): revenue leak — unpaid/overdue bills by plan (the "why")
SELECT pl.plan_name,
       SUM(CASE WHEN b.status IN ('Unpaid', 'Overdue') THEN 1 ELSE 0 END) AS leak_bills,
       COUNT(b.bill_id) AS total_bills,
       ROUND(100.0 * SUM(CASE WHEN b.status IN ('Unpaid', 'Overdue') THEN 1 ELSE 0 END) / COUNT(b.bill_id), 2) AS leak_rate_pct,
       ROUND(SUM(CASE WHEN b.status IN ('Unpaid', 'Overdue') THEN b.amount ELSE 0 END), 2) AS leaked_amount
FROM billing b
JOIN subscribers s ON b.sub_id = s.sub_id
JOIN plans pl ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name
ORDER BY leaked_amount DESC;

-- Q7 (KPI Reporting): churn by plan × reason (the "why" for base shrink)
SELECT pl.plan_name,
       ch.reason,
       COUNT(*) AS churned
FROM churn ch
JOIN subscribers s ON ch.sub_id = s.sub_id
JOIN plans pl ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name, ch.reason
ORDER BY churned DESC
LIMIT 10;

-- Q8 (KPI Reporting): avg data usage by usage tier × plan (dig one dimension deeper)
WITH sub_usage AS (
    SELECT u.sub_id,
           s.plan_id,
           AVG(u.data_mb) AS avg_data_mb
    FROM usage_logs u
    JOIN subscribers s ON u.sub_id = s.sub_id
    GROUP BY u.sub_id
)
SELECT pl.plan_name,
       CASE
           WHEN avg_data_mb < 5000 THEN 'Low (<5GB)'
           WHEN avg_data_mb < 15000 THEN 'Medium (5-15GB)'
           WHEN avg_data_mb < 25000 THEN 'High (15-25GB)'
           ELSE 'Excessive (>25GB)'
       END AS usage_tier,
       COUNT(*) AS subs,
       ROUND(AVG(avg_data_mb), 0) AS avg_data_mb
FROM sub_usage su
JOIN plans pl ON su.plan_id = pl.plan_id
GROUP BY pl.plan_name, usage_tier
ORDER BY pl.plan_name, avg_data_mb DESC;
