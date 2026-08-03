# Exercises: Module 1 - Foundations

---

## Part A: Write the Query

For each exercise, translate the HR request into a SQL query using window functions.

---

### Exercise 1.1: Count of Orders per Store

**HR Request:**
> "Show me all our stores. For each store, I want to know how many orders were placed at that store overall."

**Tables Available:** `orders`, `stores`

**Expected Columns:** store_id, store_name, order_count

---

### Exercise 1.2: Running Total of Order Amounts

**HR Request:**
> "List all orders in chronological order. Next to each order, show what the cumulative total is from the first order up to that order."

**Tables Available:** `orders`

**Expected Columns:** ord_id, ord_date, total_amount, running_total

---

### Exercise 1.3: Average Order Value by Customer Membership

**HR Request:**
> "Show me all customers. For each customer, I want to see their membership level and the average order value for customers in the same membership level."

**Tables Available:** `customers`, `orders`

**Hint:** You'll need to join customers with orders first to get membership info per order.

---

### Exercise 1.4: Product Price Ranking

**HR Request:**
> "Show me all our active products. For each product, tell me what rank it has when we sort by price within its category (most expensive gets rank 1)."

**Tables Available:** `products`, `categories`

**Expected Columns:** prod_name, cat_name, unit_price, price_rank

---

### Exercise 1.5: Employee Salary Context

**HR Request:**
> "Show me all our employees. For each employee, show their salary and the minimum, maximum, and average salary of their department."

**Tables Available:** `employees`, `departments`, `job_titles`

**Expected Columns:** emp_name, dept_name, job_title, salary, dept_min_sal, dept_max_sal, dept_avg_sal

---

## Part B: Translate the Query

For each query, write what it does in plain English (like an HR person explaining what data they need).

---

### Exercise 1.6

```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.total_amount,
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.membership_level,
    SUM(o.total_amount) OVER (PARTITION BY c.membership_level) AS level_total_sales
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY c.membership_level, o.ord_date;
```

**Your English Translation:**
> 

---

### Exercise 1.7

```sql
SELECT 
    p.prod_name,
    p.unit_price,
    p.brand,
    c.cat_name,
    AVG(p.unit_price) OVER (PARTITION BY p.brand) AS brand_avg_price,
    p.unit_price - AVG(p.unit_price) OVER (PARTITION BY p.brand) AS diff_from_brand_avg
FROM products p
JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = TRUE
ORDER BY p.brand, p.unit_price DESC;
```

**Your English Translation:**
> 

---

### Exercise 1.8

```sql
SELECT 
    e.emp_id,
    e.emp_name,
    d.dept_name,
    e.salary,
    RANK() OVER (PARTITION BY d.dept_id ORDER BY e.salary DESC) AS salary_rank_in_dept,
    ROUND(e.salary / SUM(e.salary) OVER (PARTITION BY d.dept_id) * 100, 2) AS pct_of_dept_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
```

**Your English Translation:**
> 

---

## Part C: Debug the Query

Each query below has a bug. Find and fix it.

---

### Exercise 1.9: Broken Running Total

**Intended Purpose:** "Show each order with a running total of amounts sorted by date"

**Buggy Query:**
```sql
SELECT 
    ord_id,
    ord_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY ord_id) AS running_total
FROM orders;
```

**Bug:** The running total is ordered by `ord_id` (alphabetical) instead of `ord_date` (chronological).

**Fix:**
```sql
SELECT 
    ord_id,
    ord_date,
    total_amount,
    SUM(total_amount) OVER (ORDER BY ord_date) AS running_total
FROM orders;
```

---

### Exercise 1.10: Missing Partition

**Intended Purpose:** "Show each employee's salary and the average salary of their department"

**Buggy Query:**
```sql
SELECT 
    e.emp_name,
    d.dept_name,
    e.salary,
    AVG(e.salary) OVER () AS dept_avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
```

**Bug:** The AVG is calculated over the entire dataset (empty OVER()) instead of partitioned by department.

**Fix:**
```sql
SELECT 
    e.emp_name,
    d.dept_name,
    e.salary,
    AVG(e.salary) OVER (PARTITION BY e.dept_id) AS dept_avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
```

---

### Exercise 1.11: Wrong Column in Partition

**Intended Purpose:** "Show each product's price and how it compares to other products in the same category"

**Buggy Query:**
```sql
SELECT 
    p.prod_name,
    p.unit_price,
    p.cat_id,
    AVG(p.unit_price) OVER (PARTITION BY p.brand) AS category_avg_price,
    p.unit_price - AVG(p.unit_price) OVER (PARTITION BY p.brand) AS diff_from_category_avg
FROM products p
WHERE p.is_active = TRUE;
```

**Bug:** The PARTITION BY is using `brand` instead of `cat_id`, so we're comparing products within the same brand, not the same category.

**Fix:**
```sql
SELECT 
    p.prod_name,
    p.unit_price,
    p.cat_id,
    AVG(p.unit_price) OVER (PARTITION BY p.cat_id) AS category_avg_price,
    p.unit_price - AVG(p.unit_price) OVER (PARTITION BY p.cat_id) AS diff_from_category_avg
FROM products p
WHERE p.is_active = TRUE;
```

---

### Exercise 1.12: Incorrect Window Syntax

**Intended Purpose:** "Show each store's total orders and the percentage of total orders"

**Buggy Query:**
```sql
SELECT 
    store_id,
    COUNT(*) AS store_orders,
    COUNT(*) OVER (PARTITION BY store_id) / COUNT(*) OVER () * 100 AS pct_of_total
FROM orders;
```

**Bug:** Using COUNT(*) without a column reference, and the percentage calculation needs parentheses around the division.

**Fix:**
```sql
SELECT 
    store_id,
    COUNT(*) AS store_orders,
    ROUND(COUNT(*) * 100.0 / COUNT(*) OVER (), 2) AS pct_of_total
FROM orders
GROUP BY store_id;
```

---

## Answers

Answers are provided in the `solutions/` folder.

| Exercise | Solution File |
|----------|--------------|
| 1.1 | solution_1.1.sql |
| 1.2 | solution_1.2.sql |
| 1.3 | solution_1.3.sql |
| 1.4 | solution_1.4.sql |
| 1.5 | solution_1.5.sql |
| 1.6-1.8 | translation_1.6_1.8.md |
| 1.9-1.12 | debug_1.9_1.12.md |
