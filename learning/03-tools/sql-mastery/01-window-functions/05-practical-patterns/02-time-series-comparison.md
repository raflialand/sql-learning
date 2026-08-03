# Lesson 5.2: Time Series Comparison Patterns

## Overview

Time series data is among the most common analytical workloads. Window functions make comparisons across time periods elegant and efficient.

---

## Core Patterns

| Pattern | Functions | Use Case |
|---------|-----------|----------|
| **Period-over-Period** | LAG, LEAD | Compare to previous/next period |
| **Running Comparison** | SUM OVER, AVG OVER | Cumulative vs previous periods |
| **Growth Rate** | (current - previous) / previous | Trend analysis |
| **Streak Detection** | Conditional logic with LAG | Consecutive periods above/below threshold |

---

## Example 1: Month-over-Month Revenue Comparison

**HR Request:**
> "Show monthly revenue for each store. Compare each month to the previous month — what was the dollar change and percentage change?"

```sql
SELECT 
    strftime('%Y-%m', ds.sale_date) AS month,
    ds.store_id,
    s.store_name,
    SUM(ds.total_revenue) AS monthly_revenue,
    LAG(SUM(ds.total_revenue)) OVER (
        PARTITION BY ds.store_id 
        ORDER BY strftime('%Y-%m', ds.sale_date)
    ) AS prev_month_revenue,
    SUM(ds.total_revenue) - LAG(SUM(ds.total_revenue)) OVER (
        PARTITION BY ds.store_id 
        ORDER BY strftime('%Y-%m', ds.sale_date)
    ) AS mom_dollar_change,
    ROUND(
        (SUM(ds.total_revenue) - LAG(SUM(ds.total_revenue)) OVER (
            PARTITION BY ds.store_id 
            ORDER BY strftime('%Y-%m', ds.sale_date)
        )) / NULLIF(LAG(SUM(ds.total_revenue)) OVER (
            PARTITION BY ds.store_id 
            ORDER BY strftime('%Y-%m', ds.sale_date)
        ), 0) * 100, 2
    ) AS mom_pct_change
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
GROUP BY strftime('%Y-%m', ds.sale_date), ds.store_id, s.store_name
ORDER BY store_id, month;
```

**English Translation:**
> "Calculate monthly revenue per store. Look back at each store's previous month and show the dollar difference and percentage change. Use NULLIF to avoid division by zero errors."

**Note:** We GROUP BY month first, then use LAG on the aggregated monthly values.

---

## Example 2: Week-over-Week Comparison

**HR Request:**
> "Show daily sales with the same day from the previous week side by side."

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    ds.total_revenue,
    ds.total_orders,
    LAG(ds.total_revenue, 7) OVER (
        PARTITION BY ds.store_id 
        ORDER BY ds.sale_date
    ) AS revenue_same_day_last_week,
    ROUND(
        (ds.total_revenue - LAG(ds.total_revenue, 7) OVER (
            PARTITION BY ds.store_id 
            ORDER BY ds.sale_date
        )) / NULLIF(LAG(ds.total_revenue, 7) OVER (
            PARTITION BY ds.store_id 
            ORDER BY ds.sale_date
        ), 0) * 100, 2
    ) AS wow_pct_change
FROM daily_sales ds
WHERE ds.sale_date BETWEEN '2024-01-12' AND '2024-01-31'
ORDER BY ds.store_id, ds.sale_date;
```

**English Translation:**
> "For each store each day, show today's revenue and orders alongside the revenue from exactly 7 days ago. Calculate the week-over-week percentage change."

---

## Example 3: Quarter-over-Quarter Analysis

**HR Request:**
> "Compare each quarter's performance to the same quarter last year."

```sql
SELECT 
    strftime('%Y', ds.sale_date) AS year,
    'Q' || ((CAST(strftime('%m', ds.sale_date) AS INTEGER) - 1) / 3 + 1) AS quarter,
    r.region_name,
    SUM(ds.total_revenue) AS quarterly_revenue,
    LAG(SUM(ds.total_revenue)) OVER (
        PARTITION BY r.region_id 
        ORDER BY strftime('%Y', ds.sale_date), 
                  ((CAST(strftime('%m', ds.sale_date) AS INTEGER) - 1) / 3 + 1)
    ) AS same_qtr_prev_year,
    SUM(ds.total_revenue) - LAG(SUM(ds.total_revenue)) OVER (
        PARTITION BY r.region_id 
        ORDER BY strftime('%Y', ds.sale_date), 
                  ((CAST(strftime('%m', ds.sale_date) AS INTEGER) - 1) / 3 + 1)
    ) AS qoq_dollar_change
FROM daily_sales ds
JOIN regions r ON ds.region_id = r.region_id
GROUP BY strftime('%Y', ds.sale_date), 
         ((CAST(strftime('%m', ds.sale_date) AS INTEGER) - 1) / 3 + 1),
         r.region_id, r.region_name
ORDER BY r.region_name, year, quarter;
```

**English Translation:**
> "Group sales by year and quarter for each region. Compare to the same quarter from the previous year to see year-over-year growth."

---

## Example 4: Running Total vs Target

**HR Request:**
> "Show daily cumulative revenue per store against a monthly target of $500,000. Flag days when we were on track to meet the target."

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    s.store_name,
    SUM(ds.total_revenue) AS daily_revenue,
    SUM(SUM(ds.total_revenue)) OVER (
        PARTITION BY ds.store_id, strftime('%Y-%m', ds.sale_date)
        ORDER BY ds.sale_date
    ) AS month_to_date,
    500000 AS monthly_target,
    ROUND(
        SUM(SUM(ds.total_revenue)) OVER (
            PARTITION BY ds.store_id, strftime('%Y-%m', ds.sale_date)
            ORDER BY ds.sale_date
        ) / 500000 * 100, 2
    ) AS pct_of_target,
    CASE 
        WHEN SUM(SUM(ds.total_revenue)) OVER (
            PARTITION BY ds.store_id, strftime('%Y-%m', ds.sale_date)
            ORDER BY ds.sale_date
        ) >= 500000 THEN 'Target Reached'
        WHEN SUM(SUM(ds.total_revenue)) OVER (
            PARTITION BY ds.store_id, strftime('%Y-%m', ds.sale_date)
            ORDER BY ds.sale_date
        ) / 500000 * 100 >= 
            (CAST(strftime('%d', ds.sale_date) AS INTEGER) * 100.0 / 
             CAST(strftime('%d', '2024-01-31') AS INTEGER)) 
        THEN 'On Track'
        ELSE 'Behind Target'
    END AS status
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE strftime('%Y-%m', ds.sale_date) = '2024-01'
GROUP BY ds.sale_date, ds.store_id, s.store_name
ORDER BY ds.store_id, ds.sale_date;
```

**English Translation:**
> "For each store each day, calculate the cumulative month-to-date revenue. Compare this to the monthly target of $500,000 and to where we should be based on the day of the month. Flag if we're on track, behind, or have already reached the target."

---

## Example 5: Streak Detection — Consecutive Days Above Threshold

**HR Request:**
> "Identify when stores had 3 or more consecutive days with revenue above $15,000."

```sql
SELECT 
    sale_date,
    store_id,
    total_revenue,
    CASE 
        WHEN total_revenue >= 15000 AND 
             LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) >= 15000 AND
             LEAD(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) >= 15000
        THEN 'Middle of Streak'
        WHEN total_revenue >= 15000 AND 
             LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) >= 15000 AND
             LAG(total_revenue, 2) OVER (PARTITION BY store_id ORDER BY sale_date) >= 15000
        THEN 'Start of Streak'
        WHEN total_revenue >= 15000 AND 
             LEAD(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) >= 15000 AND
             LEAD(total_revenue, 2) OVER (PARTITION BY store_id ORDER BY sale_date) >= 15000
        THEN 'End of Streak'
        WHEN total_revenue >= 15000
        THEN 'Isolated High Day'
        ELSE 'Below Threshold'
    END AS streak_status
FROM daily_sales
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store each day, check if the revenue is above $15,000. Also check the previous and next days to identify if this is part of a 3+ day streak of high-performing days."

---

## Key Takeaways: Time Series Comparisons

| Technique | Why It Matters |
|-----------|---------------|
| `LAG(value, 1)` | Previous period comparison |
| `LAG(value, 7)` | Same period last week |
| `LAG(value, 30)` | Same day last month approximation |
| `NULLIF(..., 0)` | Avoid division by zero |
| `PARTITION BY store_id` | Compare within each entity, not across all |
| `ORDER BY date` | Ensure chronological correctness |

---

## Coming Up Next

Running metrics and dashboards — combining multiple window functions to create comprehensive analytics.
