# Capstone Exercise: Monthly Sales Analytics Report

## The Challenge

Build a comprehensive monthly sales analytics report combining all window function concepts learned in this module.

---

## Business Request

**Your manager asks:**
> "I need a complete monthly sales report for our executive meeting. Show me daily sales performance with trends, comparisons, and rankings. Include both absolute numbers and relative performance metrics."

---

## Requirements

### Part A: Daily Sales Dashboard (Build the Query)

Create a query that produces a daily sales dashboard with the following columns for each store each day:

| Column | Description |
|--------|-------------|
| `sale_date` | The date |
| `store_id` | Store identifier |
| `store_name` | Store name |
| `region_name` | Region the store belongs to |
| `daily_revenue` | Revenue for that day |
| `daily_orders` | Number of orders that day |
| `daily_profit` | Profit for that day |
| `prev_day_revenue` | Revenue from the previous day |
| `dod_change` | Day-over-day revenue change (today - yesterday) |
| `dod_pct_change` | Day-over-day percentage change |
| `7_day_avg` | 7-day rolling average of revenue |
| `running_total` | Month-to-date running total of revenue |
| `pct_of_month_target` | Percentage of monthly target achieved (assume $500,000 target) |
| `revenue_rank_region` | Revenue rank within the region for that day |
| `revenue_rank_all` | Revenue rank among all stores for that day |
| `cume_dist` | Cumulative distribution of this store's revenue today |

### Part B: Translate the Query

```sql
-- This query is designed to show customer order analytics
-- Translate what it does in plain English

SELECT 
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.membership_level,
    o.ord_id,
    o.ord_date,
    o.total_amount,
    ROW_NUMBER() OVER (
        PARTITION BY o.cust_id ORDER BY o.ord_date
    ) AS order_sequence,
    SUM(o.total_amount) OVER (
        PARTITION BY o.cust_id ORDER BY o.ord_date
    ) AS running_total,
    SUM(o.total_amount) OVER (
        PARTITION BY o.cust_id
    ) AS lifetime_value,
    ROUND(
        o.total_amount / SUM(o.total_amount) OVER (PARTITION BY o.cust_id) * 100, 
    2) AS pct_of_lifetime,
    LAG(o.total_amount) OVER (
        PARTITION BY o.cust_id ORDER BY o.ord_date
    ) AS prev_order_amount,
    o.total_amount - LAG(o.total_amount) OVER (
        PARTITION BY o.cust_id ORDER BY o.ord_date
    ) AS order_to_order_change,
    RANK() OVER (
        PARTITION BY c.membership_level 
        ORDER BY SUM(o.total_amount) OVER (PARTITION BY o.cust_id) DESC
    ) AS rank_in_membership,
    CUME_DIST() OVER (
        ORDER BY SUM(o.total_amount) OVER (PARTITION BY o.cust_id)
    ) AS value_cume_dist
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
WHERE o.status = 'Completed'
ORDER BY o.cust_id, o.ord_date;
```

**Your English Translation:**
> 

---

### Part C: Debug the Query

**Intended Purpose:** "Find each store's top-selling product by revenue"

**Buggy Query:**
```sql
SELECT 
    s.store_id,
    s.store_name,
    p.prod_name,
    SUM(oi.qty * oi.unit_price) AS product_revenue,
    RANK() OVER (
        PARTITION BY s.store_id 
        ORDER BY SUM(oi.qty * oi.unit_price)
    ) AS revenue_rank
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_items oi ON o.ord_id = oi.ord_id
JOIN products p ON oi.prod_id = p.prod_id
WHERE o.status = 'Completed'
GROUP BY s.store_id, s.store_name, p.prod_id, p.prod_name;
```

**Bug:** 

---

## Bonus Challenge: Executive Summary View

Create a single query that produces an executive summary showing:

1. Total company revenue for the period
2. Total orders count
3. Average order value
4. Top performing store
5. Bottom performing store
6. Store with best month-over-month growth
7. Top 5 customers by lifetime value
8. Most popular product category

---

## Expected Output Structure

```
learning/02-sql-learning/sql-mastery/
└── 01-window-functions/
    └── solutions/
        ├── capstone_query.sql
        ├── translation_part_b.md
        ├── debug_part_c.md
        └── bonus_executive_summary.sql
```

---

## Hints

1. **Start simple** — Build the base query first, then add window function columns one by one
2. **Use CTEs** — Break complex queries into logical steps using Common Table Expressions
3. **Test in pieces** — Verify each window function works correctly before combining
4. **Handle NULLs** — First rows will have NULL for LAG values — decide how to handle
5. **Check your ORDER BY** — Ensure rankings are in the correct direction

---

## Success Criteria

Your report is successful if it can answer these questions:

1. Which store generated the most revenue yesterday?
2. Which store had the best day-over-day growth?
3. What was the company-wide 7-day rolling average yesterday?
4. Which region has the most stores in the top 10% by revenue?
5. How is today's revenue tracking against the monthly target?
