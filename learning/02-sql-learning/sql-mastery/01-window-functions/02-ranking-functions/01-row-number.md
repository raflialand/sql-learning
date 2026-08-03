# Lesson 2.1: ROW_NUMBER() — Unique Sequential IDs

## What It Does

Assigns a **unique sequential integer** to each row within a partition. No two rows get the same number.

**Use Cases:**
- Assign unique IDs to rows (e.g., "This is customer #1", "This is order #5")
- Deduplication (keep only the first occurrence of duplicates)
- Creating surrogate keys for reporting

---

## Basic Syntax

```sql
ROW_NUMBER() OVER (PARTITION BY column ORDER BY column)
```

---

## Example 1: Rank Orders by Date Within Each Store

**HR Request:**
> "Show me all orders for each store. Number them sequentially from 1 to however many orders that store has, ordered by order date."

```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.store_id,
    s.store_name,
    ROW_NUMBER() OVER (PARTITION BY o.store_id ORDER BY o.ord_date) AS order_sequence
FROM orders o
JOIN stores s ON o.store_id = s.store_id
ORDER BY o.store_id, o.ord_date;
```

**English Translation:**
> "For each store, list all its orders chronologically and assign each order a number starting from 1."

**Result Preview:**

| ord_id | ord_date | store_id | store_name | order_sequence |
|--------|----------|----------|------------|----------------|
| ORD001 | 2024-01-05 | STR001 | Manhattan Flagship | 1 |
| ORD007 | 2024-01-15 | STR001 | Manhattan Flagship | 2 |
| ORD010 | 2024-01-22 | STR001 | Manhattan Flagship | 3 |
| ORD025 | 2024-03-01 | STR001 | Manhattan Flagship | 4 |
| ORD042 | 2024-04-15 | STR001 | Manhattan Flagship | 5 |
| ORD062 | 2024-06-05 | STR001 | Manhattan Flagship | 6 |
| ORD081 | 2024-07-22 | STR001 | Manhattan Flagship | 7 |
| ORD002 | 2024-01-06 | STR009 | Los Angeles Hub | 1 |
| ORD014 | 2024-02-03 | STR009 | Los Angeles Hub | 2 |
| ... | ... | ... | ... | ... |

---

## Example 2: Find the First Order per Customer (Deduplication)

**HR Request:**
> "For each customer, show me their very first order — the one with the earliest order date."

```sql
SELECT *
FROM (
    SELECT 
        o.*,
        c.first_name || ' ' || c.last_name AS customer_name,
        ROW_NUMBER() OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS order_num
    FROM orders o
    JOIN customers c ON o.cust_id = c.cust_id
) sub
WHERE order_num = 1;
```

**English Translation:**
> "For each customer, number their orders from earliest to latest. Then only keep the ones numbered 1 — those are their first orders."

**Result Preview:**

| cust_id | customer_name | ord_id | ord_date | order_num |
|---------|---------------|--------|----------|-----------|
| CST001 | John Smith | ORD001 | 2024-01-05 | 1 |
| CST002 | Sarah Johnson | ORD002 | 2024-01-06 | 1 |
| CST003 | Michael Williams | ORD003 | 2024-01-07 | 1 |
| CST004 | Emily Brown | ORD004 | 2024-01-08 | 1 |
| CST005 | David Jones | ORD005 | 2024-01-09 | 1 |
| ... | ... | ... | ... | ... |

---

## Example 3: Top N Rows Per Group

**HR Request:**
> "Show me the top 3 best-selling products by total revenue in each category."

```sql
SELECT *
FROM (
    SELECT 
        p.prod_name,
        c.cat_name,
        SUM(oi.qty * oi.unit_price) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY c.cat_id ORDER BY SUM(oi.qty * oi.unit_price) DESC) AS revenue_rank
    FROM order_items oi
    JOIN products p ON oi.prod_id = p.prod_id
    JOIN categories c ON p.cat_id = c.cat_id
    GROUP BY p.prod_id, p.prod_name, c.cat_id, c.cat_name
) ranked
WHERE revenue_rank <= 3;
```

**English Translation:**
> "For each category, rank products by their total revenue from highest to lowest. Then only show the top 3 in each category."

---

## Key Characteristics of ROW_NUMBER()

| Property | Description |
|----------|-------------|
| Always unique | No two rows get the same number |
| Sequential | Always 1, 2, 3, 4... without gaps |
| Partition-dependent | Resets to 1 for each partition |
| Non-deterministic with ties | If two rows have the same ORDER BY value, which gets #1 is undefined — use additional ORDER BY columns to break ties |

---

## Common Pitfall: Ties Are Arbitrary

```sql
-- Problem: If two orders have same date, which gets row 1?
SELECT 
    ord_id,
    ord_date,
    ROW_NUMBER() OVER (ORDER BY ord_date) AS row_num
FROM orders
WHERE ord_id IN ('ORD003', 'ORD004');  -- Both have same date
```

**Result might be:**
| ord_id | ord_date | row_num |
|--------|----------|---------|
| ORD003 | 2024-01-07 | 1 |
| ORD004 | 2024-01-08 | 2 |

Or it could be swapped. **Always include a tiebreaker** in ORDER BY if uniqueness matters:

```sql
ROW_NUMBER() OVER (ORDER BY ord_date, ord_id)
```

---

## Coming Up Next

`RANK()` and `DENSE_RANK()` — what happens when values tie and you need a specific ranking behavior.
