# Lesson 3.1: LAG() — Access Previous Row Values

## What It Does

`LAG()` retrieves a value from the **previous row** in a result set (ordered within a partition).

**Think of it as:** "Look at the row that came before this one."

**Use Cases:**
- Compare current value with previous value (month-over-month, day-over-day)
- Calculate differences between consecutive periods
- Find trends (increasing, decreasing)
- Fill in missing data patterns

---

## Basic Syntax

```sql
LAG(column) OVER (PARTITION BY column ORDER BY column)
LAG(column, offset) OVER (PARTITION BY column ORDER BY column)
LAG(column, offset, default) OVER (PARTITION BY column ORDER BY column)
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `column` | The column to retrieve from previous row | — |
| `offset` | How many rows back (1 = immediately previous) | 1 |
| `default` | Value to use if no previous row exists | NULL |

---

## Example 1: Month-over-Month Revenue Comparison

**HR Request:**
> "Show me the daily sales totals for each store. Also show me what the previous day's sales were for that store."

```sql
SELECT 
    sale_date,
    store_id,
    store_name,
    total_revenue,
    LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) AS prev_day_revenue
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-10'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store, list its daily sales. Look back at the previous day (within the same store) and show what that day's revenue was."

**Result Preview:**

| sale_date | store_id | store_name | total_revenue | prev_day_revenue |
|-----------|----------|------------|---------------|------------------|
| 2024-01-05 | STR001 | Manhattan Flagship | 15230.00 | NULL (first row) |
| 2024-01-06 | STR001 | Manhattan Flagship | 18400.00 | **15230.00** |
| 2024-01-07 | STR001 | Manhattan Flagship | 14200.00 | **18400.00** |
| 2024-01-08 | STR001 | Manhattan Flagship | 16200.00 | **14200.00** |
| 2024-01-09 | STR001 | Manhattan Flagship | 15200.00 | **16200.00** |
| ... | ... | ... | ... | ... |

---

## Example 2: Calculate Day-over-Day Change

**HR Request:**
> "Show me daily sales per store, the previous day's sales, and the dollar change from yesterday."

```sql
SELECT 
    sale_date,
    store_id,
    store_name,
    total_revenue,
    LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) AS prev_day_revenue,
    total_revenue - LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) AS day_over_day_change
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-10'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "Same as before, but also calculate: today's revenue minus yesterday's revenue. A positive number means sales went up; negative means they went down."

**Result Preview:**

| sale_date | store_id | total_revenue | prev_day_revenue | day_over_day_change |
|-----------|----------|---------------|------------------|---------------------|
| 2024-01-05 | STR001 | 15230.00 | NULL | NULL |
| 2024-01-06 | STR001 | 18400.00 | 15230.00 | **+3170.00** |
| 2024-01-07 | STR001 | 14200.00 | 18400.00 | **-4200.00** |
| 2024-01-08 | STR001 | 16200.00 | 14200.00 | **+2000.00** |
| ... | ... | ... | ... | ... |

---

## Example 3: Percentage Change with Default Handling

**HR Request:**
> "Show me the same data, but calculate the percentage change from the previous day. When there's no previous day, show 'N/A' instead of NULL."

```sql
SELECT 
    sale_date,
    store_id,
    total_revenue,
    LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) AS prev_day_revenue,
    CASE 
        WHEN LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) IS NULL THEN 'N/A'
        ELSE ROUND(
            (total_revenue - LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date)) /
            LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) * 100, 
            2
        ) || '%'
    END AS pct_change
FROM daily_sales ds
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-10'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "Show daily sales and the percentage change from yesterday. If there's no previous day (the first day), display 'N/A'."

---

## Example 4: Using Offset to Look Back Further

**HR Request:**
> "Show me daily sales and compare it with the sales from 7 days ago."

```sql
SELECT 
    sale_date,
    store_id,
    total_revenue,
    LAG(total_revenue, 7) OVER (PARTITION BY store_id ORDER BY sale_date) AS revenue_7_days_ago,
    total_revenue - LAG(total_revenue, 7) OVER (PARTITION BY store_id ORDER BY sale_date) AS wow_change
FROM daily_sales ds
WHERE sale_date BETWEEN '2024-01-05' AND '2024-01-15'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store, show today's revenue and what the revenue was exactly 7 days ago. Then calculate the week-over-week difference."

---

## Example 5: LAG with Default Value

**HR Request:**
> "Show me daily sales and the previous day's sales. If there's no previous day, assume the previous day's sales was 0 (not NULL)."

```sql
SELECT 
    sale_date,
    store_id,
    total_revenue,
    LAG(total_revenue, 1, 0) OVER (PARTITION BY store_id ORDER BY sale_date) AS prev_day_revenue,
    total_revenue - LAG(total_revenue, 1, 0) OVER (PARTITION BY store_id ORDER BY sale_date) AS day_change
FROM daily_sales ds
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-10'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store, list daily sales. When looking at the first day (which has no previous), treat the previous day's sales as 0 instead of empty."

---

## Visual Summary: LAG Behavior

```
Row 1: LAG(value, 1) → NULL (no row before)
Row 2: LAG(value, 1) → Row 1's value
Row 3: LAG(value, 1) → Row 2's value
Row 4: LAG(value, 1) → Row 3's value
```

```
Row 1: LAG(value, 2) → NULL (only 1 row before)
Row 2: LAG(value, 2) → NULL (only 1 row before)
Row 3: LAG(value, 2) → Row 1's value
Row 4: LAG(value, 2) → Row 2's value
```

---

## Common Pitfalls

| Pitfall | Wrong | Right |
|---------|-------|-------|
| Forgetting PARTITION BY | LAG across all rows | LAG within each group |
| Wrong ORDER BY | Misaligned previous rows | Correct chronological order |
| NULL handling | Not accounting for first row | Use COALESCE or default value |

---

## Coming Up Next

`LEAD()` — the opposite of LAG. Instead of looking backward, it looks forward to the next row.
