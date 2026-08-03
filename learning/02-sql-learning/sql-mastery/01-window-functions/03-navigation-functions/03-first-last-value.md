# Lesson 3.3: FIRST_VALUE() and LAST_VALUE() — Boundary Values

## What They Do

| Function | Returns |
|----------|---------|
| `FIRST_VALUE()` | The first value in the ordered window frame |
| `LAST_VALUE()` | The last value in the ordered window frame |

**Key Difference from LAG/LEAD:**
- LAG/LEAD access **specific adjacent rows** (previous/next by offset)
- FIRST_VALUE/LAST_VALUE access **boundary rows** of the entire window

---

## Basic Syntax

```sql
FIRST_VALUE(column) OVER (
    PARTITION BY column 
    ORDER BY column
    [ROWS BETWEEN ...]  -- optional window frame
)

LAST_VALUE(column) OVER (
    PARTITION BY column 
    ORDER BY column
    [ROWS BETWEEN ...]  -- optional window frame
)
```

---

## Understanding the Default Window Frame

**Important:** By default, `LAST_VALUE()` does NOT return the last row of the partition!

SQL's default window frame is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` — which means:
- FIRST_VALUE gets the first row (correct)
- LAST_VALUE gets the current row, not the last row (often unexpected!)

To get the actual last value, you need to specify: `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`

---

## Example 1: Find Each Employee's First and Most Recent Order

**HR Request:**
> "Show me all employee hires and their first assigned store, as well as their most recent store assignment."

```sql
SELECT 
    e.emp_id,
    e.emp_name,
    e.hire_date,
    d.dept_name,
    FIRST_VALUE(d.dept_name) OVER (
        PARTITION BY e.emp_id 
        ORDER BY e.hire_date
    ) AS first_department,
    LAST_VALUE(d.dept_name) OVER (
        PARTITION BY e.emp_id 
        ORDER BY e.hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS current_department
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;
```

**English Translation:**
> "For each employee, show their hiring info and all departments they've worked in. The first department they joined is shown by FIRST_VALUE, and their most recent/current department is shown by LAST_VALUE."

---

## Example 2: First and Last Sale Per Day Per Store

**HR Request:**
> "For each store, show the first sale and the last sale of each day — along with the daily total."

```sql
SELECT 
    sale_date,
    store_id,
    first_sale_amount,
    total_revenue,
    last_sale_amount
FROM (
    SELECT 
        ds.sale_date,
        ds.store_id,
        ds.total_revenue,
        FIRST_VALUE(ds.total_revenue) OVER (
            PARTITION BY ds.store_id, ds.sale_date 
            ORDER BY ds.sale_date
        ) AS first_sale_amount,
        LAST_VALUE(ds.total_revenue) OVER (
            PARTITION BY ds.store_id, ds.sale_date 
            ORDER BY ds.sale_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_sale_amount
    FROM daily_sales ds
) sub
WHERE sale_date BETWEEN '2024-01-05' AND '2024-01-10';
```

**English Translation:**
> "For each store each day, show the revenue from the first sale of the day, the last sale of the day, and the total daily revenue. (In this dataset, daily_sales is pre-aggregated, so first/last equal the total.)"

---

## Example 3: First and Last Order per Customer

**HR Request:**
> "Show me each customer's first order date and their most recent order date, along with each order's amount."

```sql
SELECT 
    o.ord_id,
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_date,
    o.total_amount,
    FIRST_VALUE(o.ord_date) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
    ) AS first_order_date,
    LAST_VALUE(o.ord_date) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_date
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY o.cust_id, o.ord_date;
```

**English Translation:**
> "For each customer, list their orders chronologically. Mark when they made their very first purchase and when their most recent purchase was."

---

## Example 4: Distance from First Purchase

**HR Request:**
> "Show me each order and how many days have passed since that customer's very first purchase."

```sql
SELECT 
    o.ord_id,
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_date,
    o.total_amount,
    FIRST_VALUE(o.ord_date) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
    ) AS first_purchase_date,
    JULIANDAY(o.ord_date) - JULIANDAY(
        FIRST_VALUE(o.ord_date) OVER (
            PARTITION BY o.cust_id 
            ORDER BY o.ord_date
        )
    ) AS days_since_first_purchase
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY o.cust_id, o.ord_date;
```

**English Translation:**
> "For each order, find when that customer's first ever purchase was, and calculate how many days have passed since that first purchase."

---

## Example 5: First Product in Category by Price

**HR Request:**
> "For each product category, show the cheapest product (first when sorted by price ascending) and the most expensive product (last when sorted by price descending)."

```sql
SELECT 
    c.cat_name,
    p.prod_name,
    p.unit_price,
    FIRST_VALUE(p.prod_name) OVER (
        PARTITION BY c.cat_id 
        ORDER BY p.unit_price
    ) AS cheapest_product,
    LAST_VALUE(p.prod_name) OVER (
        PARTITION BY c.cat_id 
        ORDER BY p.unit_price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS most_expensive_product
FROM products p
JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = TRUE;
```

**English Translation:**
> "Within each category, sort products by price. Show which product is the cheapest (first) and which is the most expensive (last)."

---

## Window Frame Syntax (ROWS BETWEEN)

Sometimes you want the first/last within a specific range, not the entire partition:

| Frame Specifier | Meaning |
|-----------------|---------|
| `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` | Entire partition |
| `ROWS BETWEEN 5 PRECEDING AND CURRENT ROW` | Last 6 rows including current |
| `ROWS BETWEEN CURRENT ROW AND 5 FOLLOWING` | Next 6 rows including current |
| `ROWS BETWEEN 3 PRECEDING AND 2 FOLLOWING` | 6-row window centered on current |

---

## Comparison Table

| Function | What It Gets | Use When |
|----------|--------------|----------|
| `LAG(col, 1)` | Previous row's value | Comparing to immediate previous |
| `LEAD(col, 1)` | Next row's value | Comparing to immediate next |
| `FIRST_VALUE(col)` | First row in window | Finding earliest/maximum in category |
| `LAST_VALUE(col)` | Last row in window | Finding latest/minimum in category |

---

## Common Pitfall: Wrong Frame = Wrong Result

```sql
-- WRONG: Default frame doesn't give you the last row
SELECT 
    cust_id,
    ord_date,
    LAST_VALUE(total_amount) OVER (
        PARTITION BY cust_id 
        ORDER BY ord_date
    ) AS last_order_amount
FROM orders;

-- RIGHT: Explicit full frame gives you the last row
SELECT 
    cust_id,
    ord_date,
    LAST_VALUE(total_amount) OVER (
        PARTITION BY cust_id 
        ORDER BY ord_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_amount
FROM orders;
```

---

## Coming Up Next

Exercises for Module 3: Navigation Functions. You'll practice:
- Using LAG for month-over-month comparisons
- Using LEAD to find next order dates
- Using FIRST_VALUE/LAST_VALUE for boundary analysis
- Combining navigation functions with other window functions
