# Exercises: Module 4 - Aggregate Window Functions

---

## Part A: Write the Query

---

### Exercise 4.1: Running Total of Customer Spending

**HR Request:**
> "Show me each customer's purchases in chronological order. Calculate their running total spending from their first purchase to their current purchase."

**Expected Columns:** cust_id, customer_name, ord_id, ord_date, order_amount, running_total, pct_of_total

---

### Exercise 4.2: 7-Day Moving Average of Daily Sales

**HR Request:**
> "Show daily sales totals across all stores with a 7-day moving average to smooth out the data and show the trend."

**Expected Columns:** sale_date, daily_total_revenue, moving_avg_7_day

---

### Exercise 4.3: Order Count Progress Per Customer

**HR Request:**
> "For each customer, show their orders with a running count (1st order, 2nd order, 3rd order, etc.) and also show what percentage of their lifetime orders this represents."

**Expected Columns:** cust_id, customer_name, ord_id, ord_date, order_num, pct_of_lifetime_orders

---

### Exercise 4.4: Cumulative Revenue Per Store Per Month

**HR Request:**
> "Show monthly revenue per store with a running total of revenue from the first month up to the current month."

**Expected Columns:** month, store_id, store_name, monthly_revenue, cumulative_revenue

---

### Exercise 4.5: Moving Average Comparison Per Product Category

**HR Request:**
> "For each product category, show daily sales totals and a 7-day moving average. Compare today's sales to the moving average and flag if it's above or below average."

**Expected Columns:** sale_date, cat_name, daily_sales, moving_avg_7_day, vs_avg_diff, status

---

### Exercise 4.6: Percentage of Total Revenue Per Region

**HR Request:**
> "Show me each order with: the order amount, total revenue across all time, total revenue for that region, and what percentage this order is of its region's total."

**Expected Columns:** ord_id, ord_date, region_name, total_amount, total_revenue, region_total, pct_of_region

---

## Part B: Translate the Query

---

### Exercise 4.7

```sql
SELECT 
    o.ord_date,
    o.ord_id,
    o.cust_id,
    o.total_amount,
    SUM(o.total_amount) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS customer_running_total,
    SUM(o.total_amount) OVER (ORDER BY o.ord_date) AS company_running_total,
    SUM(o.total_amount) OVER (PARTITION BY o.cust_id) AS customer_lifetime_value,
    ROUND(
        SUM(o.total_amount) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) /
        SUM(o.total_amount) OVER (PARTITION BY o.cust_id) * 100, 
    2) AS pct_of_customer_lifetime
FROM orders o
ORDER BY o.cust_id, o.ord_date;
```

**Your English Translation:**
> 

---

### Exercise 4.8

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    s.store_name,
    ds.total_revenue,
    ds.total_orders,
    AVG(ds.total_revenue) OVER (
        PARTITION BY ds.store_id 
        ORDER BY ds.sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS revenue_ma_7_day,
    AVG(ds.total_orders) OVER (
        PARTITION BY ds.store_id 
        ORDER BY ds.sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS orders_ma_7_day,
    COUNT(*) OVER (
        PARTITION BY ds.store_id 
        ORDER BY ds.sale_date
    ) AS days_with_sales
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE ds.sale_date BETWEEN '2024-01-05' AND '2024-01-31'
ORDER BY ds.store_id, ds.sale_date;
```

**Your English Translation:**
> 

---

### Exercise 4.9

```sql
SELECT 
    c.cat_name,
    p.prod_name,
    p.unit_price,
    COUNT(*) OVER (PARTITION BY c.cat_id) AS products_in_category,
    SUM(p.unit_price) OVER (PARTITION BY c.cat_id) AS category_total_value,
    ROUND(p.unit_price / SUM(p.unit_price) OVER (PARTITION BY c.cat_id) * 100, 2) AS pct_of_category_value,
    AVG(p.unit_price) OVER (PARTITION BY c.cat_id) AS category_avg_price,
    ROUND(p.unit_price - AVG(p.unit_price) OVER (PARTITION BY c.cat_id), 2) AS diff_from_avg
FROM products p
JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = TRUE
ORDER BY c.cat_name, p.unit_price DESC;
```

**Your English Translation:**
> 

---

## Part C: Debug the Query

---

### Exercise 4.10: Missing ORDER BY for Running Total

**Intended Purpose:** "Show each customer's running total of their order amounts."

**Buggy Query:**
```sql
SELECT 
    o.cust_id,
    o.ord_id,
    o.ord_date,
    o.total_amount,
    SUM(o.total_amount) OVER (PARTITION BY o.cust_id) AS running_total
FROM orders o;
```

**Bug:** Without ORDER BY, this gives a FIXED total per customer (sum of all their orders), not a RUNNING total that grows row by row.

**Fix:**
```sql
SELECT 
    o.cust_id,
    o.ord_id,
    o.ord_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
    ) AS running_total
FROM orders o;
```

---

### Exercise 4.11: Wrong Window Frame for Moving Average

**Intended Purpose:** "Calculate a 7-day moving average of sales."

**Buggy Query:**
```sql
SELECT 
    sale_date,
    total_revenue,
    AVG(total_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN CURRENT ROW AND 6 FOLLOWING
    ) AS moving_avg_7_day
FROM daily_sales;
```

**Bug:** This looks FORWARD (current + 6 AFTER) instead of BACKWARD (current + 6 BEFORE). The resulting average is a "forward-looking" average, not the typical trailing moving average.

**Fix:**
```sql
SELECT 
    sale_date,
    total_revenue,
    AVG(total_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7_day
FROM daily_sales;
```

---

### Exercise 4.12: Confusing COUNT(*) with COUNT(column)

**Intended Purpose:** "Count how many orders each customer has placed."

**Buggy Query:**
```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(*) OVER (PARTITION BY c.cust_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id;
```

**Bug:** COUNT(*) counts every row in the joined result, not every order. A customer with 3 orders would show 3 rows joined, and COUNT(*) would return 3 for each row, but the real issue is that this query returns all rows (not aggregated) and COUNT(*) on a joined row gives unexpected results.

**Fix (proper aggregation approach):**
```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.ord_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name;
```

Or using window function (without GROUP BY):
```sql
SELECT DISTINCT
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.ord_id) OVER (PARTITION BY c.cust_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id;
```

---

### Exercise 4.13: Accumulating the Wrong Value

**Intended Purpose:** "Show running total of profit, not revenue."

**Buggy Query:**
```sql
SELECT 
    ds.sale_date,
    ds.total_revenue,
    SUM(ds.total_revenue) OVER (ORDER BY ds.sale_date) AS running_profit
FROM daily_sales ds;
```

**Bug:** The column is named `running_profit` but it's summing `total_revenue`, not `total_profit`. These are different columns!

**Fix:**
```sql
SELECT 
    ds.sale_date,
    ds.total_revenue,
    ds.total_profit,
    SUM(ds.total_profit) OVER (ORDER BY ds.sale_date) AS running_profit
FROM daily_sales ds;
```

---

## Answers

Answers are provided in the `solutions/` folder.

| Exercise | Solution File |
|----------|--------------|
| 4.1 | solution_4.1.sql |
| 4.2 | solution_4.2.sql |
| 4.3 | solution_4.3.sql |
| 4.4 | solution_4.4.sql |
| 4.5 | solution_4.5.sql |
| 4.6 | solution_4.6.sql |
| 4.7-4.9 | translation_4.7_4.9.md |
| 4.10-4.13 | debug_4.10_4.13.md |
