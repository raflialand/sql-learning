# Lesson 4.3: COUNT() OVER() — Cumulative Counts

## What It Does

`COUNT()` with `OVER()` counts rows within a window frame — useful for cumulative counts, frequency analysis, and understanding record distributions.

**Use Cases:**
- Cumulative order count over time
- Counting occurrences within groups
- Understanding data density
- Finding how many records precede/succeed current row

---

## Basic Syntax

```sql
COUNT(*) OVER (PARTITION BY column ORDER BY column [frame_spec])
COUNT(column) OVER (PARTITION BY column ORDER BY column [frame_spec])
```

| Difference | COUNT(*) | COUNT(column) |
|------------|----------|--------------|
| Counts | All rows | Only non-NULL values |
| Use when | Every row matters | Only populated values matter |

---

## Example 1: Cumulative Order Count

**HR Request:**
> "Show me all orders in chronological order with a running count — how many orders have been placed up to and including this date."

```sql
SELECT 
    ord_date,
    ord_id,
    cust_id,
    total_amount,
    COUNT(*) OVER (ORDER BY ord_date) AS cumulative_order_count
FROM orders
ORDER BY ord_date;
```

**English Translation:**
> "List all orders by date. Count how many orders exist from the very first order up to this order. This shows order volume growth over time."

**Result Preview:**

| ord_date | ord_id | cust_id | total_amount | cumulative_order_count |
|----------|--------|---------|--------------|------------------------|
| 2024-01-05 | ORD001 | CST001 | 1299.00 | **1** |
| 2024-01-06 | ORD002 | CST002 | 2348.00 | **2** |
| 2024-01-07 | ORD003 | CST003 | 79.00 | **3** |
| 2024-01-08 | ORD004 | CST004 | 458.00 | **4** |
| 2024-01-09 | ORD005 | CST005 | 89.00 | **5** |
| ... | ... | ... | ... | ... |

---

## Example 2: Order Count Per Customer Over Time

**HR Request:**
> "Show each customer's orders in chronological order. For each order, also show how many orders that customer has placed up to that point."

```sql
SELECT 
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_id,
    o.ord_date,
    o.total_amount,
    COUNT(*) OVER (
        PARTITION BY o.cust_id 
        ORDER BY o.ord_date
    ) AS customer_order_count
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY o.cust_id, o.ord_date;
```

**English Translation:**
> "For each customer, list their orders. Within that customer's history, count how many orders they've placed up to and including this order."

---

## Example 3: Count of Products Per Category

**HR Request:**
> "Show me all active products. For each product in its category, count how many active products exist in that category."

```sql
SELECT 
    p.prod_name,
    p.unit_price,
    c.cat_name,
    COUNT(*) OVER (PARTITION BY c.cat_id) AS products_in_category
FROM products p
JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = TRUE
ORDER BY c.cat_name, p.unit_price DESC;
```

**English Translation:**
> "For each active product, also show how many active products belong to the same category. This count repeats for every product in that category."

---

## Example 4: Count of Orders Per Day Per Store

**HR Request:**
> "Show me the daily order counts per store and calculate the running total of orders for each store."

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    s.store_name,
    ds.total_orders,
    SUM(ds.total_orders) OVER (
        PARTITION BY ds.store_id 
        ORDER BY ds.sale_date
    ) AS running_order_total
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE ds.sale_date BETWEEN '2024-01-01' AND '2024-01-15'
ORDER BY ds.store_id, ds.sale_date;
```

**English Translation:**
> "For each store each day, show how many orders it had and a running total of all orders that store has accumulated from the earliest date."

---

## Example 5: Percentage of Total Count

**HR Request:**
> "Show me each order with what percentage of all orders it represents, and what percentage of its store's orders it represents."

```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.store_id,
    COUNT(*) OVER () AS total_orders_all_time,
    COUNT(*) OVER (PARTITION BY o.store_id) AS total_orders_this_store,
    COUNT(*) OVER (PARTITION BY o.store_id ORDER BY o.ord_date) AS running_order_num,
    ROUND(COUNT(*) OVER (PARTITION BY o.store_id ORDER BY o.ord_date) * 100.0 / 
          COUNT(*) OVER (PARTITION BY o.store_id), 2) AS pct_of_store_total
FROM orders o
ORDER BY o.store_id, o.ord_date;
```

**English Translation:**
> "For each order, show the total number of orders ever placed (constant), the total orders for that store, this order's position in the store's history, and what percentage of the store's total this order represents."

---

## Example 6: COUNT with Non-NULL Values

**HR Request:**
> "Show me all customers and how many orders they have. Some customers may never have ordered — show 0 for them."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.membership_level,
    COUNT(o.ord_id) OVER (PARTITION BY c.cust_id) AS order_count,
    RANK() OVER (ORDER BY COUNT(o.ord_id) OVER (PARTITION BY c.cust_id) DESC) AS order_frequency_rank
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name, c.membership_level
ORDER BY order_frequency_rank;
```

**English Translation:**
> "List all customers. Count how many orders each has (0 if none). Rank customers by how frequently they order, with most frequent at rank 1."

**Note:** `COUNT(o.ord_id)` counts only non-NULL order IDs, so customers with no orders get 0.

---

## COUNT(*) vs COUNT(column)

```sql
-- COUNT(*): Counts every row
COUNT(*) OVER () = Total number of rows

-- COUNT(column): Counts only non-NULL values
COUNT(order_id) OVER () = Total rows where order_id is not NULL
```

**Example demonstrating the difference:**

| cust_id | order_id | email |
|---------|----------|-------|
| CST001 | ORD001 | john@email.com |
| CST002 | NULL | sarah@email.com |
| CST003 | ORD003 | mike@email.com |

```
COUNT(*) OVER () = 3
COUNT(order_id) OVER () = 2  (CST002's order_id is NULL)
```

---

## Example 7: Finding Duplicate Records

**HR Request:**
> "Find customers who have multiple orders on the exact same date. Show the duplicate dates and which orders are affected."

```sql
SELECT *
FROM (
    SELECT 
        cust_id,
        ord_date,
        COUNT(*) AS orders_on_date,
        COUNT(*) OVER (PARTITION BY cust_id, ord_date) AS order_count_for_that_day
    FROM orders
    GROUP BY cust_id, ord_date
) sub
WHERE order_count_for_that_day > 1;
```

**English Translation:**
> "Group orders by customer and date to count how many orders each customer placed on each date. Only show records where that count is greater than 1 — those are the duplicate order dates."

---

## Common Patterns Summary

| Pattern | Syntax | Result |
|---------|--------|--------|
| Total count (fixed) | `COUNT(*) OVER ()` | Same number for every row |
| Count per group (fixed) | `COUNT(*) OVER (PARTITION BY col)` | Same number within each group |
| Running count | `COUNT(*) OVER (ORDER BY col)` | Increments with each row |
| Count per group running | `COUNT(*) OVER (PARTITION BY col ORDER BY col2)` | Increments within each group |

---

## Coming Up Next

Exercises for Module 4: Aggregate Window Functions. You'll practice:
- Creating running totals with SUM OVER
- Calculating moving averages with AVG OVER
- Using COUNT OVER for cumulative and grouped counts
- Combining multiple aggregate window functions
