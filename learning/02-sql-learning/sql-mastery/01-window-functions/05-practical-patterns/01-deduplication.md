# Lesson 5.1: Deduplication Pattern

## The Problem

Real-world data often has **duplicate records** — the same entity appearing multiple times due to:
- Data entry errors
- System bugs
- Slowly changing dimensions
- Duplicate transaction records

Window functions are the **most elegant solution** for deduplication.

---

## The Pattern

```
1. Assign a row number to each record within the group that defines "uniqueness"
2. Keep only rows where row number = 1 (the first/selected record)
```

---

## Example 1: Keep Most Recent Order Per Customer

**HR Request:**
> "We need a list of customers with their most recent order details. Each customer should appear only once."

**The Problem:** A simple JOIN gives us duplicate customer rows:

```sql
-- This returns multiple rows per customer
SELECT c.cust_id, c.first_name, c.last_name, o.ord_id, o.ord_date
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id;
-- CST001 appears 7 times (has 7 orders)
```

**The Solution:**

```sql
SELECT *
FROM (
    SELECT 
        c.cust_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.email,
        c.membership_level,
        o.ord_id AS latest_ord_id,
        o.ord_date AS latest_order_date,
        o.total_amount AS latest_order_amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.cust_id 
            ORDER BY o.ord_date DESC
        ) AS row_num
    FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.cust_id
) sub
WHERE row_num = 1;
```

**English Translation:**
> "For each customer, number their orders from most recent (1) to oldest (2, 3, 4...). Then only keep the order numbered 1 for each customer — that's their most recent order."

---

## Example 2: Keep First Order Per Customer (Acquisition)

**HR Request:**
> "Show each customer's first purchase — when they became a customer."

```sql
SELECT *
FROM (
    SELECT 
        c.cust_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.signup_date,
        o.ord_id AS first_ord_id,
        o.ord_date AS first_order_date,
        o.total_amount AS first_order_amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.cust_id 
            ORDER BY o.ord_date ASC
        ) AS first_order_num
    FROM customers c
    INNER JOIN orders o ON c.cust_id = o.cust_id
) sub
WHERE first_order_num = 1;
```

**English Translation:**
> "Find each customer's earliest order. That's their acquisition order — when they made their first purchase."

---

## Example 3: Remove Duplicate Product Entries in Orders

**HR Request:**
> "We noticed some order_items might have duplicate entries (same product, same order). Show us only the first occurrence of each product within each order."

```sql
SELECT *
FROM (
    SELECT 
        item_id,
        ord_id,
        prod_id,
        qty,
        unit_price,
        discount_pct,
        ROW_NUMBER() OVER (
            PARTITION BY ord_id, prod_id 
            ORDER BY item_id
        ) AS duplicate_rank
    FROM order_items
) sub
WHERE duplicate_rank = 1;
```

**English Translation:**
> "Within each order, if the same product appears multiple times, only keep the first occurrence (lowest item_id). This removes duplicate product lines in orders."

---

## Example 4: Find Customers with Multiple Accounts (Same Email)

**HR Request:**
> "Detect potential duplicate customer accounts — customers who have registered with the same email address multiple times."

```sql
SELECT *
FROM (
    SELECT 
        email,
        cust_id,
        first_name || ' ' || last_name AS customer_name,
        signup_date,
        COUNT(*) OVER (PARTITION BY email) AS accounts_with_same_email
    FROM customers
) sub
WHERE accounts_with_same_email > 1
ORDER BY email, signup_date;
```

**English Translation:**
> "Find customers who share an email with another customer. Count how many accounts use each email, and flag emails used by more than one person."

---

## Example 5: Deduplicate Based on Multiple Columns

**HR Request:**
> "We ran a promotion where customers could win a prize once per region. Find which customers have won multiple times in the same region."

```sql
SELECT *
FROM (
    SELECT 
        cust_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        s.region_id,
        r.region_name,
        o.ord_id,
        o.ord_date,
        COUNT(*) OVER (
            PARTITION BY cust_id, s.region_id
        ) AS win_count_per_region
    FROM orders o
    JOIN customers c ON o.cust_id = c.cust_id
    JOIN stores s ON o.store_id = s.store_id
    JOIN regions r ON s.region_id = r.region_id
    WHERE o.ord_date BETWEEN '2024-01-01' AND '2024-12-31'
) sub
WHERE win_count_per_region > 1
ORDER BY cust_id, region_name;
```

---

## Key Takeaways: Deduplication Pattern

| Step | What To Do |
|------|------------|
| 1 | Identify what makes a record unique (usually cust_id, ord_id, or combination) |
| 2 | Partition BY that unique identifier |
| 3 | ORDER BY the criteria for "which one to keep" (usually date DESC for latest) |
| 4 | Assign ROW_NUMBER() |
| 5 | Filter WHERE row_num = 1 |

---

## Common Variations

| Scenario | Partition By | Order By | Keeps |
|----------|--------------|----------|-------|
| Most recent | cust_id | ord_date DESC | Latest order |
| First occurrence | cust_id | ord_date ASC | Earliest order |
| Cheapest product | cat_id | unit_price ASC | Lowest price |
| Most expensive | cat_id | unit_price DESC | Highest price |
| Duplicate removal | ord_id, prod_id | item_id ASC | First occurrence |

---

## Coming Up Next

Time series comparison patterns — comparing values across time periods using LAG and LEAD.
