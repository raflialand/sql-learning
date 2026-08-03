# Lesson 4.1: SUM() OVER() — Running Totals

## What It Does

`SUM()` with `OVER()` calculates a **running total** — accumulating values as you move through ordered rows.

**Use Cases:**
- Cumulative revenue over time
- Running totals of purchases
- Cumulative quantities in inventory
- Growth tracking

---

## Basic Syntax

```sql
SUM(column) OVER (
    [PARTITION BY column]
    ORDER BY column
    [ROWS BETWEEN frame_spec]
)
```

---

## Example 1: Running Total of Daily Sales Per Store

**HR Request:**
> "Show me the daily sales for each store in chronological order. Also calculate what the cumulative total is from the first day up to each day."

```sql
SELECT 
    sale_date,
    store_id,
    store_name,
    total_revenue,
    SUM(total_revenue) OVER (
        PARTITION BY store_id 
        ORDER BY sale_date
    ) AS running_total_revenue
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE sale_date BETWEEN '2024-01-05' AND '2024-01-12'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store, list its daily revenue. Add up all revenue from the first day up to and including the current day. Show this as a running total alongside each day's revenue."

**Result Preview:**

| sale_date | store_id | store_name | total_revenue | running_total_revenue |
|-----------|----------|------------|---------------|----------------------|
| 2024-01-05 | STR001 | Manhattan Flagship | 15230.00 | **15230.00** |
| 2024-01-06 | STR001 | Manhattan Flagship | 18400.00 | **33630.00** |
| 2024-01-07 | STR001 | Manhattan Flagship | 14200.00 | **47830.00** |
| 2024-01-08 | STR001 | Manhattan Flagship | 16200.00 | **64030.00** |
| 2024-01-09 | STR001 | Manhattan Flagship | 15200.00 | **79230.00** |
| ... | ... | ... | ... | ... |

---

## Example 2: Running Total Across All Stores (No Partition)

**HR Request:**
> "Show me the total company revenue day by day, accumulating over time."

```sql
SELECT 
    sale_date,
    SUM(total_revenue) AS daily_total,
    SUM(SUM(total_revenue)) OVER (ORDER BY sale_date) AS running_total_revenue
FROM daily_sales
WHERE sale_date BETWEEN '2024-01-05' AND '2024-01-12'
GROUP BY sale_date
ORDER BY sale_date;
```

**English Translation:**
> "Group by date to get each day's total revenue. Then accumulate day by day from the earliest date to show a company-wide running total."

---

## Example 3: Running Total with Month-to-Date

**HR Request:**
> "Show me daily sales and the cumulative monthly total."

```sql
SELECT 
    ds.sale_date,
    strftime('%Y-%m', ds.sale_date) AS month,
    ds.total_revenue,
    SUM(ds.total_revenue) OVER (
        PARTITION BY strftime('%Y-%m', ds.sale_date), ds.store_id 
        ORDER BY ds.sale_date
    ) AS month_to_date_revenue
FROM daily_sales ds
WHERE ds.sale_date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY ds.store_id, ds.sale_date;
```

**English Translation:**
> "For each store each month, calculate a running total of revenue from the first day of the month to the current day. This shows 'month-to-date' performance."

---

## Example 4: Running Total as Percentage of Total

**HR Request:**
> "Show me each order in chronological order with the running total, and show what percentage of total revenue has been accumulated by that point."

```sql
SELECT 
    o.ord_date,
    o.ord_id,
    o.total_amount,
    SUM(o.total_amount) OVER (ORDER BY o.ord_date) AS running_total,
    ROUND(
        SUM(o.total_amount) OVER (ORDER BY o.ord_date) / 
        SUM(o.total_amount) OVER () * 100, 
    2) AS pct_of_annual_total
FROM orders o
ORDER BY o.ord_date;
```

**English Translation:**
> "List all orders by date. Calculate the running total of all order amounts, and express each running total as a percentage of the grand total revenue."

---

## Example 5: Running Total by Category and Region

**HR Request:**
> "Show me running totals of product sales within each region and category combination."

```sql
SELECT 
    c.cat_name,
    r.region_name,
    o.ord_date,
    oi.qty * oi.unit_price AS line_total,
    SUM(oi.qty * oi.unit_price) OVER (
        PARTITION BY c.cat_id, r.region_id 
        ORDER BY o.ord_date
    ) AS running_total
FROM order_items oi
JOIN orders o ON oi.ord_id = o.ord_id
JOIN products p ON oi.prod_id = p.prod_id
JOIN categories c ON p.cat_id = c.cat_id
JOIN stores s ON o.store_id = s.store_id
JOIN regions r ON s.region_id = r.region_id
ORDER BY c.cat_name, r.region_name, o.ord_date;
```

---

## Visual: How Running Total Accumulates

```
Date       | Amount | Running Total (Ordered by Date)
-----------|--------|-------------------------------
2024-01-01 | 1000   | 1000                           (1st row = itself)
2024-01-02 | 1500   | 2500                           (1000 + 1500)
2024-01-03 | 800    | 3300                           (2500 + 800)
2024-01-04 | 2000   | 5300                           (3300 + 2000)
```

---

## Common Patterns

| Pattern | Syntax | Use Case |
|---------|--------|----------|
| **Running total** | `SUM(val) OVER (ORDER BY date)` | Cumulative growth |
| **Running total per group** | `SUM(val) OVER (PARTITION BY group ORDER BY date)` | Per-category cumulative |
| **Running count** | `COUNT(*) OVER (ORDER BY date)` | Cumulative count |
| **Running % of total** | `SUM(val) OVER (ORDER BY date) / SUM(val) OVER ()` | Progress tracking |

---

## Pitfall: ORDER BY is Required for Running Totals

Without `ORDER BY`, you get a **grand total per partition** instead of a running total:

```sql
-- This gives a fixed total per region, not a running total
SUM(total_amount) OVER (PARTITION BY region_id)

-- This gives a running total within each region
SUM(total_amount) OVER (PARTITION BY region_id ORDER BY ord_date)
```

---

## Coming Up Next

`AVG() OVER()` — calculating moving averages and rolling averages for trend analysis.
