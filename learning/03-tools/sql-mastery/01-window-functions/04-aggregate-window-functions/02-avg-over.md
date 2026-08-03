# Lesson 4.2: AVG() OVER() — Moving Averages

## What It Does

`AVG()` with `OVER()` calculates **moving averages** — the average of a window of rows around the current row.

**Use Cases:**
- Smoothing out daily fluctuations to see trends
- 7-day, 30-day moving averages for metrics
- Comparing current value to the recent average
- Identifying anomalies (current vs average)

---

## Basic Syntax

```sql
AVG(column) OVER (
    PARTITION BY column
    ORDER BY column
    ROWS BETWEEN lower_bound AND upper_bound
)
```

### Window Frame Options

| Frame | Meaning |
|-------|---------|
| `n PRECEDING` | n rows before current |
| `CURRENT ROW` | The current row |
| `n FOLLOWING` | n rows after current |
| `UNBOUNDED PRECEDING` | All rows from the start |
| `UNBOUNDED FOLLOWING` | All rows to the end |

---

## Example 1: 7-Day Moving Average

**HR Request:**
> "Show me daily sales with a 7-day moving average to smooth out fluctuations and see the underlying trend."

```sql
SELECT 
    sale_date,
    store_id,
    total_revenue,
    AVG(total_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7_day
FROM daily_sales
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY sale_date;
```

**English Translation:**
> "For each day, calculate the average of today plus the 6 days before it (7 days total). This gives us a rolling 7-day average that smooths out daily noise."

**Visual:**
```
Day 1: avg(day1)                                = day1 / 1
Day 2: avg(day1, day2)                          = (day1+day2) / 2
Day 3: avg(day1, day2, day3)                     = (day1+day2+day3) / 3
...
Day 7: avg(day1..day7)                           = (day1+...+day7) / 7
Day 8: avg(day2..day8)                           = (day2+...+day8) / 7
Day 9: avg(day3..day9)                           = (day3+...+day9) / 7
```

---

## Example 2: 7-Day Moving Average Per Store

**HR Request:**
> "Show me daily sales per store with a 7-day moving average."

```sql
SELECT 
    sale_date,
    store_id,
    store_name,
    total_revenue,
    ROUND(AVG(total_revenue) OVER (
        PARTITION BY store_id 
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_7_day
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store, calculate the 7-day rolling average of its daily sales. The calculation restarts for each store (partitioned by)."

---

## Example 3: Centered Moving Average

**HR Request:**
> "Show me a centered 7-day moving average — the average of 3 days before, the current day, and 3 days after."

```sql
SELECT 
    sale_date,
    total_revenue,
    ROUND(AVG(total_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ), 2) AS centered_7_day_avg
FROM daily_sales
WHERE sale_date BETWEEN '2024-01-05' AND '2024-01-25'
ORDER BY sale_date;
```

**English Translation:**
> "For each day, calculate the average of the 3 days before, today, and the 3 days after — a centered window that gives equal weight before and after."

**Note:** First and last 3 rows will have NULL for centered_avg because they don't have enough rows on both sides.

---

## Example 4: Moving Average with Month Context

**HR Request:**
> "Show me daily sales and compare it to the 7-day moving average. Flag days where today's sales were significantly above or below the recent trend."

```sql
SELECT 
    sale_date,
    store_id,
    total_revenue,
    ROUND(AVG(total_revenue) OVER (
        PARTITION BY store_id 
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_7_day,
    ROUND(total_revenue - AVG(total_revenue) OVER (
        PARTITION BY store_id 
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS diff_from_trend,
    CASE 
        WHEN total_revenue > 1.2 * AVG(total_revenue) OVER (
            PARTITION BY store_id 
            ORDER BY sale_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) THEN 'Above Trend'
        WHEN total_revenue < 0.8 * AVG(total_revenue) OVER (
            PARTITION BY store_id 
            ORDER BY sale_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) THEN 'Below Trend'
        ELSE 'Normal'
    END AS trend_status
FROM daily_sales ds
WHERE sale_date BETWEEN '2024-01-05' AND '2024-01-15'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store each day, show the revenue, the 7-day average, the difference between today and the average, and a flag if today is more than 20% above or below that average."

---

## Example 5: 30-Day Moving Average for Revenue

**HR Request:**
> "Show me monthly order totals with a 3-month moving average to see revenue trends."

```sql
SELECT 
    strftime('%Y-%m', ord_date) AS month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS monthly_revenue,
    ROUND(AVG(SUM(total_amount)) OVER (
        ORDER BY strftime('%Y-%m', ord_date)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_3_month
FROM orders
GROUP BY strftime('%Y-%m', ord_date)
ORDER BY month;
```

**English Translation:**
> "Group orders by month to get monthly totals. Calculate the average of the current month plus the 2 previous months to create a 3-month rolling average."

---

## Common Moving Average Windows

| Window | Frame Specification | Use Case |
|--------|--------------------|----------|
| **3-day** | `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` | Very short-term, high sensitivity |
| **7-day** | `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` | Weekly smoothing |
| **14-day** | `ROWS BETWEEN 13 PRECEDING AND CURRENT ROW` | Bi-weekly |
| **30-day** | `ROWS BETWEEN 29 PRECEDING AND CURRENT ROW` | Monthly smoothing |
| **90-day** | `ROWS BETWEEN 89 PRECEDING AND CURRENT ROW` | Quarterly trend |

---

## Moving Average vs Running Average

| Type | Formula | Behavior |
|------|---------|----------|
| **Running Average** | `AVG(col) OVER (ORDER BY date)` | Expands from 1 to n rows |
| **Moving Average** | `AVG(col) OVER (ORDER BY date ROWS BETWEEN n PRECEDING AND CURRENT ROW)` | Fixed window size |

```
Running Average:     1 row: avg(a)         = a/1
                     2 rows: avg(a,b)      = (a+b)/2
                     3 rows: avg(a,b,c)    = (a+b+c)/3
                     n rows: avg(a,b,c...n) = (a+b+...+n)/n

Moving Average:      1 row: avg(last1)      = last1/1
                     2 rows: avg(last2)     = (last2+last1)/2
                     3 rows: avg(last3)     = (last3+last2+last1)/3
```

---

## Coming Up Next

`COUNT() OVER()` — cumulative counts and counting occurrences within windows.
