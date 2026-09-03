# Case 03: NovaTel — Query Results

**Generated:** 2026-09-02 09:45:07

**Gold Mart:** `gold.mart_subscriber_health` (SQLite in-memory for execution)

**Grain:** One row per bill_id

**Limitation:** MoM only (Dec-2025 → Jan-2026). NO YoY comparisons.

---

## Q1: Total billed revenue per month

```sql
SELECT
    billing_month,
    SUM(billed_amount) AS total_billed_revenue
FROM gold_mart_subscriber_health
GROUP BY billing_month
ORDER BY billing_month;
```

| billing_month | total_billed_revenue |
| --- | --- |
| 2025-12 | 203420.0 |
| 2026-01 | 175870.0 |

**Total rows:** 2

---

## Q2: Payment collection rate per month

```sql
SELECT
    billing_month,
    COUNT(*) AS total_bills,
    SUM(CASE WHEN bill_status = 'Paid' THEN 1 ELSE 0 END) AS paid_bills,
    ROUND(
        SUM(CASE WHEN bill_status = 'Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS collection_rate_pct
FROM gold_mart_subscriber_health
GROUP BY billing_month
ORDER BY billing_month;
```

| billing_month | total_bills | paid_bills | collection_rate_pct |
| --- | --- | --- | --- |
| 2025-12 | 4287 | 3539 | 82.55 |
| 2026-01 | 3709 | 3049 | 82.21 |

**Total rows:** 2

---

## Q3: Active subscribers billed per month

```sql
SELECT
    billing_month,
    COUNT(DISTINCT sub_id) AS active_subscribers
FROM gold_mart_subscriber_health
GROUP BY billing_month
ORDER BY billing_month;
```

| billing_month | active_subscribers |
| --- | --- |
| 2025-12 | 4287 |
| 2026-01 | 3709 |

**Total rows:** 2

---

## Q4: Billed revenue MoM change

```sql
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
    FROM gold_mart_subscriber_health
    GROUP BY billing_month
) curr
LEFT JOIN (
    SELECT billing_month, SUM(billed_amount) AS total_billed_revenue
    FROM gold_mart_subscriber_health
    GROUP BY billing_month
) prev
    ON prev.billing_month = CASE
        WHEN curr.billing_month = '2026-01' THEN '2025-12'
        ELSE NULL
    END
WHERE curr.billing_month = '2026-01'
ORDER BY curr.billing_month;
```

| billing_month | total_billed_revenue | prev_month_revenue | revenue_change | revenue_mom_pct |
| --- | --- | --- | --- | --- |
| 2026-01 | 175870.0 | 203420.0 | -27550.0 | -13.54 |

**Total rows:** 1

---

## Q5: Collection rate MoM change

```sql
SELECT
    curr.billing_month,
    curr.collection_rate_pct,
    prev.collection_rate_pct AS prev_month_rate,
    ROUND(curr.collection_rate_pct - prev.collection_rate_pct, 2) AS rate_change_pct
FROM (
    SELECT
        billing_month,
        ROUND(
            SUM(CASE WHEN bill_status = 'Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
            2
        ) AS collection_rate_pct
    FROM gold_mart_subscriber_health
    GROUP BY billing_month
) curr
LEFT JOIN (
    SELECT
        billing_month,
        ROUND(
            SUM(CASE WHEN bill_status = 'Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
            2
        ) AS collection_rate_pct
    FROM gold_mart_subscriber_health
    GROUP BY billing_month
) prev
    ON prev.billing_month = CASE
        WHEN curr.billing_month = '2026-01' THEN '2025-12'
        ELSE NULL
    END
WHERE curr.billing_month = '2026-01'
ORDER BY curr.billing_month;
```

| billing_month | collection_rate_pct | prev_month_rate | rate_change_pct |
| --- | --- | --- | --- |
| 2026-01 | 82.21 | 82.55 | -0.34 |

**Total rows:** 1

---

## Q6: Billed revenue by plan

```sql
SELECT
    plan_name,
    SUM(billed_amount) AS total_billed_revenue
FROM gold_mart_subscriber_health
GROUP BY plan_name
ORDER BY total_billed_revenue DESC;
```

| plan_name | total_billed_revenue |
| --- | --- |
| Plus | 81750.0 |
| Standard | 79380.0 |
| Premium | 77280.0 |
| Family | 62100.0 |
| Starter | 39420.0 |
| Unlimited Max | 39360.0 |

**Total rows:** 6

---

## Q7: Billed revenue by region

```sql
SELECT
    region,
    SUM(billed_amount) AS total_billed_revenue
FROM gold_mart_subscriber_health
GROUP BY region
ORDER BY total_billed_revenue DESC;
```

| region | total_billed_revenue |
| --- | --- |
| Southwest | 77800.0 |
| Southeast | 77680.0 |
| Northeast | 77285.0 |
| Midwest | 73615.0 |
| West | 72910.0 |

**Total rows:** 5

---

## Q8: Collection rate by plan

```sql
SELECT
    plan_name,
    COUNT(*) AS total_bills,
    SUM(CASE WHEN bill_status = 'Paid' THEN 1 ELSE 0 END) AS paid_bills,
    ROUND(
        SUM(CASE WHEN bill_status = 'Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS collection_rate_pct
FROM gold_mart_subscriber_health
GROUP BY plan_name
ORDER BY collection_rate_pct DESC;
```

| plan_name | total_bills | paid_bills | collection_rate_pct |
| --- | --- | --- | --- |
| Family | 690 | 588 | 85.22 |
| Unlimited Max | 328 | 277 | 84.45 |
| Plus | 1635 | 1348 | 82.45 |
| Standard | 2268 | 1864 | 82.19 |
| Starter | 1971 | 1617 | 82.04 |
| Premium | 1104 | 894 | 80.98 |

**Total rows:** 6

---

## Q9: Churn count by region (FIXED — grain mismatch corrected)

```sql
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
```

| region | churned_subscribers | total_subscribers | churn_rate_pct |
| --- | --- | --- | --- |
| West | 50 | 830 | 6.02 |
| Northeast | 48 | 847 | 5.67 |
| Southwest | 39 | 867 | 4.50 |
| Southeast | 39 | 904 | 4.31 |
| Midwest | 38 | 839 | 4.53 |

**Total rows:** 5

---

## Q10: Unpaid/Overdue share by plan

```sql
SELECT
    plan_name,
    COUNT(*) AS total_bills,
    SUM(CASE WHEN bill_status IN ('Unpaid', 'Overdue') THEN 1 ELSE 0 END) AS unpaid_overdue_bills,
    ROUND(
        SUM(CASE WHEN bill_status IN ('Unpaid', 'Overdue') THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS unpaid_overdue_pct
FROM gold_mart_subscriber_health
GROUP BY plan_name
ORDER BY unpaid_overdue_pct DESC;
```

| plan_name | total_bills | unpaid_overdue_bills | unpaid_overdue_pct |
| --- | --- | --- | --- |
| Premium | 1104 | 210 | 19.02 |
| Starter | 1971 | 354 | 17.96 |
| Standard | 2268 | 404 | 17.81 |
| Plus | 1635 | 287 | 17.55 |
| Unlimited Max | 328 | 51 | 15.55 |
| Family | 690 | 102 | 14.78 |

**Total rows:** 6

---

## Q11: Churn reasons by region (FIXED — grain mismatch corrected)

```sql
SELECT
    region,
    churn_reason,
    COUNT(DISTINCT sub_id) AS churned_subscribers
FROM gold_mart_subscriber_health
WHERE has_churned = TRUE
GROUP BY region, churn_reason
ORDER BY region, churned_subscribers DESC;
```

| region | churn_reason | churned_subscribers |
| --- | --- | --- |
| Midwest | Price | 8 |
| Midwest | Other | 7 |
| Midwest | Moving | 7 |
| Midwest | Coverage | 7 |
| Midwest | Competitor Offer | 6 |
| Midwest | Service Quality | 3 |
| Northeast | Moving | 11 |
| Northeast | Competitor Offer | 11 |
| Northeast | Service Quality | 8 |
| Northeast | Coverage | 7 |
| Northeast | Price | 6 |
| Northeast | Other | 5 |
| Southeast | Moving | 14 |
| Southeast | Other | 8 |
| Southeast | Service Quality | 6 |
| Southeast | Price | 6 |
| Southeast | Competitor Offer | 3 |
| Southeast | Coverage | 2 |
| Southwest | Service Quality | 8 |
| Southwest | Price | 8 |
| Southwest | Other | 7 |
| Southwest | Coverage | 6 |
| Southwest | Moving | 5 |
| Southwest | Competitor Offer | 5 |
| West | Service Quality | 9 |
| West | Price | 9 |
| West | Moving | 9 |
| West | Other | 8 |
| West | Competitor Offer | 8 |
| West | Coverage | 7 |

**Total rows:** 30

---

## Q12: ARPU by plan

```sql
SELECT
    plan_name,
    SUM(billed_amount) AS total_billed_revenue,
    COUNT(DISTINCT sub_id) AS unique_subscribers,
    ROUND(
        SUM(billed_amount) / NULLIF(COUNT(DISTINCT sub_id), 0),
        2
    ) AS arpu
FROM gold_mart_subscriber_health
GROUP BY plan_name
ORDER BY arpu DESC;
```

| plan_name | total_billed_revenue | unique_subscribers | arpu |
| --- | --- | --- | --- |
| Unlimited Max | 39360.0 | 173 | 227.51 |
| Family | 62100.0 | 372 | 166.94 |
| Premium | 77280.0 | 594 | 130.1 |
| Plus | 81750.0 | 878 | 93.11 |
| Standard | 79380.0 | 1220 | 65.07 |
| Starter | 39420.0 | 1050 | 37.54 |

**Total rows:** 6

---

