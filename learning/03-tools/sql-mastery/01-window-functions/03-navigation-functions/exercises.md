# Exercises: Module 3 - Navigation Functions

---

## Part A: Write the Query

---

### Exercise 3.1: Month-over-Month Revenue Growth

**HR Request:**
> "Show me each store's monthly revenue. Also show me the previous month's revenue and calculate whether revenue went up or down compared to the previous month."

**Hint:** Group by store and month first, then use LAG().

---

### Exercise 3.2: Time Since Last Customer Purchase

**HR Request:**
> "For each customer, show me their orders with how many days have passed since their previous order. For their first order, show 'N/A'."

**Expected Columns:** cust_id, customer_name, ord_id, ord_date, days_since_last_order

---

### Exercise 3.3: Identify Price Changes Over Time

**HR Request:**
> "Track product price changes over time. For each product sale, show the current sale's price, the previous sale price for that product, and whether the price went up, down, or stayed the same."

**Expected Columns:** prod_name, ord_date, current_price, prev_price, price_change

---

### Exercise 3.4: Customer Lifetime Value Journey

**HR Request:**
> "Show me each order a customer makes and calculate their running total spending from their first purchase to the current purchase."

**Expected Columns:** cust_id, customer_name, ord_date, order_amount, running_total, pct_of_total

---

### Exercise 3.5: Next Employee Hire by Department

**HR Request:**
> "List employees hired in each department chronologically. For each employee, show who was hired immediately after them in the same department."

**Expected Columns:** emp_name, dept_name, hire_date, next_hire_name, next_hire_date

---

### Exercise 3.6: First and Last Order Details

**HR Request:**
> "Show each customer's purchase history with their first order details (date, amount) and their most recent order details. Include the customer's total lifetime spending."

**Expected Columns:** cust_id, customer_name, first_ord_date, first_ord_amount, last_ord_date, last_ord_amount, lifetime_spending

---

## Part B: Translate the Query

---

### Exercise 3.7

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    s.store_name,
    ds.total_revenue,
    LAG(ds.total_revenue, 7) OVER (PARTITION BY ds.store_id ORDER BY ds.sale_date) AS revenue_last_week,
    ds.total_revenue - LAG(ds.total_revenue, 7) OVER (PARTITION BY ds.store_id ORDER BY ds.sale_date) AS wow_difference,
    ROUND(
        (ds.total_revenue - LAG(ds.total_revenue, 7) OVER (PARTITION BY ds.store_id ORDER BY ds.sale_date)) /
        LAG(ds.total_revenue, 7) OVER (PARTITION BY ds.store_id ORDER BY ds.sale_date) * 100, 
        2
    ) AS wow_pct_change
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE ds.sale_date BETWEEN '2024-01-12' AND '2024-01-15'
ORDER BY ds.store_id, ds.sale_date;
```

**Your English Translation:**
> 

---

### Exercise 3.8

```sql
SELECT 
    o.ord_id,
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_date,
    o.total_amount,
    FIRST_VALUE(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS first_order_date,
    LAST_VALUE(o.ord_date) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_date,
    SUM(o.total_amount) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    SUM(o.total_amount) OVER (PARTITION BY o.cust_id) AS lifetime_value
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY o.cust_id, o.ord_date;
```

**Your English Translation:**
> 

---

### Exercise 3.9

```sql
SELECT 
    e.emp_id,
    e.emp_name,
    d.dept_name,
    e.hire_date,
    e.salary,
    LEAD(e.salary) OVER (PARTITION BY d.dept_id ORDER BY e.hire_date) AS next_employee_salary,
    e.salary - LEAD(e.salary) OVER (PARTITION BY d.dept_id ORDER BY e.hire_date) AS salary_diff_vs_next,
    ROUND(e.salary / AVG(e.salary) OVER (PARTITION BY d.dept_id) * 100, 2) AS dept_salary_pct
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.hire_date;
```

**Your English Translation:**
> 

---

## Part C: Debug the Query

---

### Exercise 3.10: Missing Window Frame for LAST_VALUE

**Intended Purpose:** "For each customer, find the amount of their most recent order."

**Buggy Query:**
```sql
SELECT 
    o.ord_id,
    o.cust_id,
    o.ord_date,
    o.total_amount,
    LAST_VALUE(o.total_amount) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
    ) AS most_recent_order_amount
FROM orders o;
```

**Bug:** Without `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`, LAST_VALUE returns the current row's value (or default frame behavior), not the actual last value.

**Fix:**
```sql
SELECT 
    o.ord_id,
    o.cust_id,
    o.ord_date,
    o.total_amount,
    LAST_VALUE(o.total_amount) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS most_recent_order_amount
FROM orders o;
```

---

### Exercise 3.11: Incorrect Partition BY

**Intended Purpose:** "Show each order with the previous order's date from the SAME store, ordered by date."

**Buggy Query:**
```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.store_id,
    LAG(o.ord_date) OVER (ORDER BY o.ord_date) AS prev_order_date_same_store
FROM orders o;
```

**Bug:** Missing `PARTITION BY o.store_id`, so LAG looks at the previous order globally, not the previous order at the same store.

**Fix:**
```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.store_id,
    LAG(o.ord_date) OVER (PARTITION BY o.store_id ORDER BY o.ord_date) AS prev_order_date_same_store
FROM orders o;
```

---

### Exercise 3.12: Wrong Offset Direction

**Intended Purpose:** "Show each customer their next order date to help us plan follow-up marketing."

**Buggy Query:**
```sql
SELECT 
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_date AS current_order,
    LAG(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS next_order_to_expect
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id;
```

**Bug:** LAG looks backward (previous), but we need LEAD to look forward (next order date).

**Fix:**
```sql
SELECT 
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_date AS current_order,
    LEAD(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS next_order_to_expect
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id;
```

---

### Exercise 3.13: First Value Not in Order

**Intended Purpose:** "Find the cheapest product in each category."

**Buggy Query:**
```sql
SELECT 
    c.cat_name,
    p.prod_name,
    p.unit_price,
    FIRST_VALUE(p.prod_name) OVER (PARTITION BY c.cat_id) AS cheapest_product
FROM products p
JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = TRUE;
```

**Bug:** FIRST_VALUE without ORDER BY returns an arbitrary value from the partition, not necessarily the first (cheapest).

**Fix:**
```sql
SELECT 
    c.cat_name,
    p.prod_name,
    p.unit_price,
    FIRST_VALUE(p.prod_name) OVER (
        PARTITION BY c.cat_id 
        ORDER BY p.unit_price
    ) AS cheapest_product
FROM products p
JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = TRUE;
```

---

## Answers

Answers are provided in the `solutions/` folder.

| Exercise | Solution File |
|----------|--------------|
| 3.1 | solution_3.1.sql |
| 3.2 | solution_3.2.sql |
| 3.3 | solution_3.3.sql |
| 3.4 | solution_3.4.sql |
| 3.5 | solution_3.5.sql |
| 3.6 | solution_3.6.sql |
| 3.7-3.9 | translation_3.7_3.9.md |
| 3.10-3.13 | debug_3.10_3.13.md |
