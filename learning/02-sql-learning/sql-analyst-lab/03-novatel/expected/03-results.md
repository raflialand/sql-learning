# Case 03 — Verified Expected Results

Captured by executing `03-queries.sql` statement-by-statement against `sql-skill-push/datasets/03-advanced/telecom.db` (read-only, reused) with the `run_query.py` output format. Re-running the same queries reproduces these rows and counts exactly.

**Dataset limitation:** billing spans ONLY `2025-12-01` and `2026-01-01` → MoM only, NO YoY anywhere in this case.

## Q1 (Overall Trends) — Billed revenue by plan

```sql
SELECT pl.plan_name,
       COUNT(b.bill_id) AS bills,
       ROUND(SUM(b.amount), 2) AS revenue
FROM billing b
JOIN subscribers s ON b.sub_id = s.sub_id
JOIN plans pl ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name
ORDER BY revenue DESC;
```

| plan_name | bills | revenue |
| --- | --- | --- |
| Plus | 1635 | 81750.00 |
| Standard | 2268 | 79380.00 |
| Premium | 1104 | 77280.00 |
| Family | 690 | 62100.00 |
| Starter | 1971 | 39420.00 |
| Unlimited Max | 328 | 39360.00 |

(6 rows)

## Q2 (Overall Trends) — Monthly revenue + distinct billed subscribers

```sql
SELECT strftime('%Y-%m', bill_date) AS month,
       COUNT(*) AS bills,
       COUNT(DISTINCT sub_id) AS billed_subs,
       ROUND(SUM(amount), 2) AS revenue
FROM billing
GROUP BY strftime('%Y-%m', bill_date)
ORDER BY month;
```

| month | bills | billed_subs | revenue |
| --- | --- | --- | --- |
| 2025-12 | 4287 | 4287 | 203420.00 |
| 2026-01 | 3709 | 3709 | 175870.00 |

(2 rows)

## Q3 (Growth Rates) — MoM revenue + ARPU (Dec-2025 → Jan-2026) — MoM ONLY

```sql
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
```

| month | revenue | subs | arpu | mom_growth_pct |
| --- | --- | --- | --- | --- |
| 2025-12 | 203420.00 | 4287 | 47.45 | NULL |
| 2026-01 | 175870.00 | 3709 | 47.42 | -13.54 |

(2 rows)

## Q4 (Performance Measurement) — ARPU by plan

```sql
SELECT pl.plan_name,
       COUNT(DISTINCT b.sub_id) AS subs,
       ROUND(SUM(b.amount) / COUNT(DISTINCT b.sub_id), 2) AS arpu
FROM billing b
JOIN subscribers s ON b.sub_id = s.sub_id
JOIN plans pl ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name
ORDER BY arpu DESC;
```

| plan_name | subs | arpu |
| --- | --- | --- |
| Unlimited Max | 173 | 227.51 |
| Family | 372 | 166.94 |
| Premium | 594 | 130.10 |
| Plus | 878 | 93.11 |
| Standard | 1220 | 65.07 |
| Starter | 1050 | 37.54 |

(6 rows)

## Q5 (Performance Measurement) — Active subscriber base + billed revenue by region

```sql
SELECT s.region,
       COUNT(DISTINCT CASE WHEN s.status = 'Active' THEN s.sub_id END) AS active_subs,
       COUNT(DISTINCT b.sub_id) AS billed_subs,
       ROUND(SUM(b.amount), 2) AS revenue
FROM subscribers s
LEFT JOIN billing b ON s.sub_id = b.sub_id
GROUP BY s.region
ORDER BY revenue DESC;
```

| region | active_subs | billed_subs | revenue |
| --- | --- | --- | --- |
| Southwest | 741 | 867 | 77800.00 |
| Southeast | 793 | 904 | 77680.00 |
| Northeast | 735 | 847 | 77285.00 |
| Midwest | 730 | 839 | 73615.00 |
| West | 710 | 830 | 72910.00 |

(5 rows)

## Q6 (KPI Reporting) — Revenue leak: unpaid/overdue bills by plan (the "why")

```sql
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
```

| plan_name | leak_bills | total_bills | leak_rate_pct | leaked_amount |
| --- | --- | --- | --- | --- |
| Premium | 210 | 1104 | 19.02 | 14700.00 |
| Plus | 287 | 1635 | 17.55 | 14350.00 |
| Standard | 404 | 2268 | 17.81 | 14140.00 |
| Family | 102 | 690 | 14.78 | 9180.00 |
| Starter | 354 | 1971 | 17.96 | 7080.00 |
| Unlimited Max | 51 | 328 | 15.55 | 6120.00 |

(6 rows)

## Q7 (KPI Reporting) — Churn by plan × reason (the "why" for base shrink)

```sql
SELECT pl.plan_name,
       ch.reason,
       COUNT(*) AS churned
FROM churn ch
JOIN subscribers s ON ch.sub_id = s.sub_id
JOIN plans pl ON s.plan_id = pl.plan_id
GROUP BY pl.plan_name, ch.reason
ORDER BY churned DESC
LIMIT 10;
```

| plan_name | reason | churned |
| --- | --- | --- |
| Standard | Moving | 30 |
| Starter | Moving | 26 |
| Standard | Price | 22 |
| Standard | Coverage | 20 |
| Standard | Other | 20 |
| Plus | Service Quality | 19 |
| Starter | Other | 19 |
| Starter | Coverage | 18 |
| Starter | Service Quality | 17 |
| Standard | Competitor Offer | 16 |

(10 rows)

## Q8 (KPI Reporting) — Avg data usage by usage tier × plan (one dimension deeper)

```sql
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
```

| plan_name | usage_tier | subs | avg_data_mb |
| --- | --- | --- | --- |
| Family | Excessive (>25GB) | 19 | 26618.00 |
| Family | High (15-25GB) | 146 | 19639.00 |
| Family | Medium (5-15GB) | 139 | 10628.00 |
| Family | Low (<5GB) | 14 | 3295.00 |
| Plus | Excessive (>25GB) | 39 | 26642.00 |
| Plus | High (15-25GB) | 342 | 19220.00 |
| Plus | Medium (5-15GB) | 335 | 11013.00 |
| Plus | Low (<5GB) | 41 | 3220.00 |
| Premium | Excessive (>25GB) | 30 | 26511.00 |
| Premium | High (15-25GB) | 209 | 19277.00 |

(24 rows total; 10 shown)
