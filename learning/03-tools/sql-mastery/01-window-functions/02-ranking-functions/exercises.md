# Exercises: Module 2 - Ranking Functions

---

## Part A: Write the Query

---

### Exercise 2.1: Assign Order Numbers to Store Purchases

**HR Request:**
> "Show me all orders for each customer, numbered sequentially by order date. For each customer, their first order should be number 1, second order number 2, and so on."

**Expected Columns:** cust_id, customer_name, ord_id, ord_date, order_sequence

**Hint:** You'll need to join customers and orders.

---

### Exercise 2.2: Find Each Product's Best-Selling Month

**HR Request:**
> "For each product, find the month (year-month format) when it sold the most quantity. Show the product name, the month, quantity sold, and rank it as #1."

**Expected Columns:** prod_name, best_month, qty_sold, is_top_month

**Hint:** Join order_items with orders to get dates, then group by product and month.

---

### Exercise 2.3: Top 3 Products Per Category by Revenue

**HR Request:**
> "Within each product category, show me the top 3 products ranked by total revenue. Only include active products."

**Expected Columns:** cat_name, prod_name, total_revenue, revenue_rank

**Hint:** Use ROW_NUMBER() or RANK() partitioned by category.

---

### Exercise 2.4: DENSE RANK Employees by Salary Within Department

**HR Request:**
> "Rank employees within each department by their salary. Higher salary gets rank 1. When salaries are equal, they share the same rank, and the next rank should be consecutive (no gaps)."

**Expected Columns:** dept_name, emp_name, job_title, salary, salary_rank

---

### Exercise 2.5: Customer Spending Quintiles

**HR Request:**
> "Divide our customers into 5 equal spending groups based on their total order amounts. Label them Group 1 (highest spenders) through Group 5 (lowest spenders)."

**Expected Columns:** cust_id, customer_name, total_spent, spending_group (1-5)

---

### Exercise 2.6: Identify Outlier Revenue Days

**HR Request:**
> "For each store, flag days where the revenue was in the top 10% of that store's history as 'High Performer'. Show the date, store, revenue, and the flag."

**Expected Columns:** sale_date, store_id, store_name, total_revenue, performance_flag

**Hint:** Use NTILE(10) and check for NTILE = 1.

---

## Part B: Translate the Query

---

### Exercise 2.7

```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.total_amount,
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    RANK() OVER (PARTITION BY c.cust_id ORDER BY o.ord_date) AS order_sequence,
    SUM(o.total_amount) OVER (PARTITION BY c.cust_id ORDER BY o.ord_date) AS running_total_spent
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY c.cust_id, o.ord_date;
```

**Your English Translation:**
> 

---

### Exercise 2.8

```sql
SELECT 
    prod_name,
    unit_price,
    brand,
    cat_id,
    RANK() OVER (PARTITION BY cat_id ORDER BY unit_price DESC) AS price_rank_in_cat,
    DENSE_RANK() OVER (ORDER BY unit_price DESC) AS price_rank_overall,
    NTILE(4) OVER (ORDER BY unit_price) AS price_quartile
FROM products
WHERE is_active = TRUE;
```

**Your English Translation:**
> 

---

### Exercise 2.9

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    s.store_name,
    ds.total_revenue,
    NTILE(3) OVER (
        PARTITION BY ds.store_id 
        ORDER BY ds.total_revenue DESC
    ) AS revenue_tier,
    ROUND(ds.total_revenue / AVG(ds.total_revenue) OVER (PARTITION BY ds.store_id) * 100, 2) AS pct_of_store_avg
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE ds.sale_date BETWEEN '2024-01-01' AND '2024-01-31';
```

**Your English Translation:**
> 

---

## Part C: Debug the Query

---

### Exercise 2.10: Wrong Ranking Function

**Intended Purpose:** "Assign each customer a rank based on their total spending. Customers with equal spending should share the same rank."

**Buggy Query:**
```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) DESC) AS spend_rank
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY spend_rank;
```

**Bug:** ROW_NUMBER() is used instead of RANK() or DENSE_RANK(). ROW_NUMBER() gives unique numbers even when values are equal.

**Fix:**
```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    RANK() OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) DESC) AS spend_rank
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY spend_rank;
```

---

### Exercise 2.11: Missing PARTITION BY

**Intended Purpose:** "Within each region, rank stores by their total revenue. The highest-revenue store in each region gets rank 1."

**Buggy Query:**
```sql
SELECT 
    s.store_id,
    s.store_name,
    s.region_id,
    SUM(ds.total_revenue) AS store_revenue,
    RANK() OVER (ORDER BY SUM(ds.total_revenue) DESC) AS revenue_rank
FROM stores s
JOIN daily_sales ds ON s.store_id = ds.store_id
GROUP BY s.store_id, s.store_name, s.region_id;
```

**Bug:** No PARTITION BY, so it ranks ALL stores globally instead of within each region.

**Fix:**
```sql
SELECT 
    s.store_id,
    s.store_name,
    s.region_id,
    SUM(ds.total_revenue) AS store_revenue,
    RANK() OVER (PARTITION BY s.region_id ORDER BY SUM(ds.total_revenue) DESC) AS revenue_rank_in_region
FROM stores s
JOIN daily_sales ds ON s.store_id = ds.store_id
GROUP BY s.store_id, s.store_name, s.region_id;
```

---

### Exercise 2.12: NTILE Wrong Order Direction

**Intended Purpose:** "Divide customers into quartiles where Q1 = highest spenders and Q4 = lowest spenders."

**Buggy Query:**
```sql
SELECT 
    c.cust_id,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    NTILE(4) OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) ASC) AS spending_quartile
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id;
```

**Bug:** ORDER BY is ASC (ascending), so lowest spenders get quartile 1, highest spenders get quartile 4 — the opposite of what's intended.

**Fix:**
```sql
SELECT 
    c.cust_id,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    NTILE(4) OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) DESC) AS spending_quartile
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id;
```

---

### Exercise 2.13: ROW_NUMBER Without Tiebreaker

**Intended Purpose:** "Assign each order a unique sequence number within each customer, ordered by date. When orders have the same date, use order_id as a tiebreaker."

**Buggy Query:**
```sql
SELECT 
    cust_id,
    ord_id,
    ord_date,
    ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY ord_date) AS order_seq
FROM orders;
```

**Bug:** If two orders have the same date, the assignment of row numbers is non-deterministic.

**Fix:**
```sql
SELECT 
    cust_id,
    ord_id,
    ord_date,
    ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY ord_date, ord_id) AS order_seq
FROM orders;
```

---

## Answers

Answers are provided in the `solutions/` folder.

| Exercise | Solution File |
|----------|--------------|
| 2.1 | solution_2.1.sql |
| 2.2 | solution_2.2.sql |
| 2.3 | solution_2.3.sql |
| 2.4 | solution_2.4.sql |
| 2.5 | solution_2.5.sql |
| 2.6 | solution_2.6.sql |
| 2.7-2.9 | translation_2.7_2.9.md |
| 2.10-2.13 | debug_2.10_2.13.md |
