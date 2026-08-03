# Lesson 1.3: Your First Window Function

Let's write your first window function step by step, with every query translated to plain English.

---

## Setup: The Business Request

**Scenario:**
Your manager (the HR person) asks:

> "Show me all the orders we have. For each order, I want to see what percentage of our total revenue that order represents. Also show me what percentage of their region's revenue that order represents."

---

## Step 1: Basic Order List

First, let's see what we have in the orders table:

```sql
SELECT 
    ord_id,
    ord_date,
    cust_id,
    store_id,
    total_amount,
    status
FROM orders
ORDER BY ord_date;
```

**English Translation:**
> "Show me every order in our system with its ID, date, customer, store, total amount, and status — sorted by when the order was placed."

**Result Preview:**

| ord_id | ord_date | cust_id | store_id | total_amount | status |
|--------|----------|---------|----------|--------------|--------|
| ORD001 | 2024-01-05 | CST001 | STR001 | 1299.00 | Completed |
| ORD002 | 2024-01-06 | CST002 | STR009 | 2348.00 | Completed |
| ORD003 | 2024-01-07 | CST003 | STR005 | 79.00 | Completed |
| ... | ... | ... | ... | ... | ... |

---

## Step 2: Add Total Revenue (Global Percentage)

Now add a column showing the percentage each order contributes to total revenue:

```sql
SELECT 
    ord_id,
    ord_date,
    cust_id,
    store_id,
    total_amount,
    status,
    SUM(total_amount) OVER () AS total_revenue,
    ROUND(total_amount / SUM(total_amount) OVER () * 100, 2) AS pct_of_total
FROM orders
ORDER BY ord_date;
```

**English Translation:**
> "Show me every order with its details. Also calculate the sum of ALL order amounts (our total revenue) and show what percentage this specific order represents of that grand total."

**Result Preview:**

| ord_id | total_amount | total_revenue | pct_of_total |
|--------|--------------|---------------|--------------|
| ORD001 | 1299.00 | 88947.00 | 1.46 |
| ORD002 | 2348.00 | 88947.00 | 2.64 |
| ORD003 | 79.00 | 88947.00 | 0.09 |
| ... | ... | ... | ... |

---

## Step 3: Add Region Information

Join with stores to get the region for each order:

```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.cust_id,
    o.store_id,
    o.total_amount,
    s.region_id,
    st.region_name,
    s.store_name
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN regions st ON s.region_id = st.region_id
ORDER BY o.ord_date;
```

**English Translation:**
> "Show me every order with its details, including which store it came from and what region that store belongs to — sorted by order date."

---

## Step 4: Add Region Totals (Partitioned Aggregate)

Now calculate the percentage of regional revenue each order represents:

```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.total_amount,
    s.region_id,
    st.region_name,
    SUM(o.total_amount) OVER (PARTITION BY s.region_id) AS region_total,
    ROUND(o.total_amount / SUM(o.total_amount) OVER (PARTITION BY s.region_id) * 100, 2) AS pct_of_region
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN regions st ON s.region_id = st.region_id
ORDER BY s.region_id, o.ord_date;
```

**English Translation:**
> "Show me every order with its details and region. For each order, calculate the total revenue of its region and show what percentage this order represents of that regional total."

**Result Preview:**

| ord_id | total_amount | region_id | region_name | region_total | pct_of_region |
|--------|--------------|-----------|-------------|--------------|---------------|
| ORD001 | 1299.00 | RGN001 | Northeast | 21400.00 | 6.07 |
| ORD007 | 999.00 | RGN001 | Northeast | 21400.00 | 4.67 |
| ORD010 | 999.00 | RGN001 | Northeast | 21400.00 | 4.67 |
| ORD002 | 2348.00 | RGN005 | West Coast | 32100.00 | 7.31 |
| ORD008 | 1999.00 | RGN005 | West Coast | 32100.00 | 6.23 |
| ... | ... | ... | ... | ... | ... |

---

## Step 5: Final Query (Combined)

Putting it all together:

```sql
SELECT 
    o.ord_id,
    o.ord_date,
    o.total_amount,
    s.region_id,
    st.region_name,
    SUM(o.total_amount) OVER () AS total_revenue,
    SUM(o.total_amount) OVER (PARTITION BY s.region_id) AS region_total,
    ROUND(o.total_amount / SUM(o.total_amount) OVER () * 100, 2) AS pct_of_total,
    ROUND(o.total_amount / SUM(o.total_amount) OVER (PARTITION BY s.region_id) * 100, 2) AS pct_of_region
FROM orders o
JOIN stores s ON o.store_id = s.store_id
JOIN regions st ON s.region_id = st.region_id
ORDER BY s.region_id, o.ord_date;
```

**English Translation:**
> "Show me every order with its amount and region. For each order, calculate:
> - The grand total of all orders (across everything)
> - The total of all orders in that order's region
> - What percentage this order is of the grand total
> - What percentage this order is of its regional total"

---

## What Just Happened?

| Concept | Explanation |
|---------|-------------|
| `OVER ()` | Empty parentheses = entire dataset as one group |
| `OVER (PARTITION BY region_id)` | Divide into groups by region |
| Multiple window functions | Can have multiple `SUM() OVER (...)` in same SELECT |
| Running alongside regular columns | Window functions don't remove rows |

---

## Key Observations

1. **Window functions preserve row count** — We still have 90 rows (one per order)

2. **Multiple windows can coexist** — We calculated both global and regional totals in one query

3. **The calculation repeats for each row** — Notice `total_revenue` shows the same value (88947.00) for every row

---

## Coming Up Next

Exercises to reinforce what you've learned. You'll practice:
1. Writing queries from HR-style requirements
2. Translating queries to plain English
3. Debugging broken queries
