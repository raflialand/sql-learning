# Lesson 5.4: Percentile and Statistical Functions

## Overview

Beyond basic aggregations, window functions enable statistical analysis like percentiles, cumulative distributions, and relative standing.

---

## Functions Covered

| Function | Returns |
|----------|---------|
| `CUME_DIST()` | Cumulative distribution (0 to 1) |
| `PERCENT_RANK()` | Percentile rank (0 to 1, exclusive at bottom) |
| `PERCENTILE_CONT()` | Continuous percentile value (interpolated) |
| `PERCENTILE_DISC()` | Discrete percentile value (actual nearest) |

---

## Example 1: CUME_DIST() — Cumulative Distribution

**What it does:** Returns the percentage of rows that are less than or equal to the current row's value.

**HR Request:**
> "Show each customer's total spending and what percentage of customers spent less than or equal to that amount."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    ROUND(CUME_DIST() OVER (ORDER BY COALESCE(SUM(o.total_amount), 0)), 4) AS cumulative_distribution
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

**English Translation:**
> "Calculate each customer's lifetime spending. Then for each customer, calculate what percentage of ALL customers spent LESS THAN OR EQUAL to their amount."

**Result Preview:**

| cust_id | customer_name | total_spent | cumulative_distribution |
|---------|---------------|-------------|------------------------|
| CST006 | Jessica Garcia | 9293.00 | 1.0000 (100% spent ≤ this) |
| CST002 | Sarah Johnson | 3454.00 | 0.8500 (85% spent ≤ this) |
| CST001 | John Smith | 3227.00 | 0.7500 (75% spent ≤ this) |
| ... | ... | ... | ... |

---

## Example 2: PERCENT_RANK() — Percentile Rank

**What it does:** Returns the percentage rank of a value, ranging from 0 to 1 (0th percentile to 100th percentile).

**Difference from CUME_DIST:**
- `CUME_DIST`: % of values ≤ current value
- `PERCENT_RANK`: % of values < current value (rank / (n-1))

**HR Request:**
> "Rank customers by spending and show their percentile rank — how they compare to all other customers."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    ROUND(PERCENT_RANK() OVER (ORDER BY COALESCE(SUM(o.total_amount), 0)), 4) AS percentile_rank
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

**English Translation:**
> "Rank customers by total spending. Calculate what percentile each customer falls into — a customer at the 100th percentile is the top spender."

---

## Example 3: Finding Median Using Percentile Functions

**HR Request:**
> "Find the median order amount — the value where half of orders are below and half are above."

```sql
-- Method 1: PERCENTILE_CONT (interpolated median)
SELECT 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) AS median_order_value_cont
FROM orders;

-- Method 2: Using window function approach
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) OVER () AS median_value
FROM orders;
```

**Note:** `PERCENTILE_CONT` interpolates between values, while `PERCENTILE_DISC` would return an actual value from the dataset.

---

## Example 4: Segmenting by Percentile

**HR Request:**
> "Divide customers into 5 segments based on spending: Top 20%, Next 20%, Middle 20%, Next 20%, Bottom 20%."

```sql
SELECT 
    cust_id,
    customer_name,
    total_spent,
    CASE 
        WHEN ntile = 1 THEN 'Top 20%'
        WHEN ntile = 2 THEN 'Next 20%'
        WHEN ntile = 3 THEN 'Middle 20%'
        WHEN ntile = 4 THEN 'Next 20%'
        ELSE 'Bottom 20%'
    END AS spending_segment,
    ntile AS quintile
FROM (
    SELECT 
        c.cust_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        COALESCE(SUM(o.total_amount), 0) AS total_spent,
        NTILE(5) OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) DESC) AS ntile
    FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.cust_id
    GROUP BY c.cust_id, c.first_name, c.last_name
) sub
ORDER BY ntile, total_spent DESC;
```

**English Translation:**
> "Sort customers by spending from highest to lowest. Divide them into 5 equal groups and label each group (Top 20%, Next 20%, etc.)."

---

## Example 5: Finding Top 10% and Bottom 10%

**HR Request:**
> "Identify the top 10% performing stores by revenue and the bottom 10% that might need attention."

```sql
SELECT 
    store_id,
    store_name,
    region_name,
    total_revenue,
    CUME_DIST() OVER (ORDER BY total_revenue) AS revenue_cume_dist,
    CASE 
        WHEN CUME_DIST() OVER (ORDER BY total_revenue) >= 0.9 THEN 'Top 10%'
        WHEN CUME_DIST() OVER (ORDER BY total_revenue) <= 0.1 THEN 'Bottom 10%'
        ELSE 'Middle 80%'
    END AS performance_tier
FROM (
    SELECT 
        s.store_id,
        s.store_name,
        r.region_name,
        COALESCE(SUM(ds.total_revenue), 0) AS total_revenue
    FROM stores s
    LEFT JOIN daily_sales ds ON s.store_id = ds.store_id
    JOIN regions r ON s.region_id = r.region_id
    GROUP BY s.store_id, s.store_name, r.region_name
) sub
ORDER BY total_revenue DESC;
```

**English Translation:**
> "Calculate each store's total revenue across all time. Find the cumulative distribution — stores at 0.90 or higher are in the top 10%, stores at 0.10 or lower are in the bottom 10%."

---

## Example 6: Tracking Distribution Over Time

**HR Request:**
> "Track how the distribution of daily revenue across stores changes over time — are stores becoming more equal or more unequal?"

```sql
SELECT 
    sale_date,
    COUNT(*) AS num_stores,
    SUM(total_revenue) AS total_revenue,
    MAX(total_revenue) AS max_store_revenue,
    MIN(total_revenue) AS min_store_revenue,
    ROUND(MAX(total_revenue) / MIN(total_revenue), 2) AS max_min_ratio,
    ROUND(STDDEV(total_revenue) / AVG(total_revenue) * 100, 2) AS coefficient_of_variation,
    MAX(CUME_DIST() OVER (PARTITION BY sale_date ORDER BY total_revenue)) AS gini_approximation
FROM daily_sales
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-31'
GROUP BY sale_date
ORDER BY sale_date;
```

**English Translation:**
> "Each day, measure how unevenly revenue is distributed across stores. Look at the ratio of max to min revenue, the coefficient of variation (standard deviation / mean), and how concentrated the distribution is."

---

## Comparison: CUME_DIST vs PERCENT_RANK

| Customer | Spent | CUME_DIST | PERCENT_RANK |
|----------|-------|-----------|--------------|
| A | $5000 | 1.00 | 1.00 |
| B | $3000 | 0.67 | 0.67 |
| C | $2000 | 0.33 | 0.33 |
| D | $1000 | 0.00 | 0.00 |

- **CUME_DIST**: % of values ≤ this value
- **PERCENT_RANK**: % of values < this value (rank-1 / n-1)

---

## Key Takeaways: Statistical Window Functions

| Function | Best Use |
|----------|----------|
| `CUME_DIST()` | Finding top/bottom X% |
| `PERCENT_RANK()` | Percentile ranking |
| `PERCENTILE_CONT()` | Interpolated percentiles (median, quartiles) |
| `PERCENTILE_DISC()` | Discrete percentiles (actual values) |
| `NTILE(n)` | Creating equal-sized buckets |

---

## Coming Up Next

Capstone Exercise — a comprehensive challenge that combines all window function concepts you've learned.
