# Exercises: Unit 03 — Data Profiling

*All exercises run against `dq_learning`. Reference date: 2026-08-03.*

---

## Part A: Write the Query

### Exercise 3.1 — Row counts

Write a single query (using `UNION ALL`) that returns the row count for `customers`, `products`, `orders`, `order_items`, and `daily_sales`. Order results by count descending.

**Expected:** daily_sales (184) > order_items (20) > customers (15) = orders (15) > products (12).

### Exercise 3.2 — NULL-rate report for `orders`

Write a query that returns, for the `orders` table: total rows, NULL count and NULL percentage for `ship_city`, `total_amount`, and `status`.

**Expected:**
- total = 15
- ship_city: 2 NULLs (13.3%)
- total_amount: 1 NULL (6.7%)
- status: 1 NULL (6.7%)

### Exercise 3.3 — Price statistics

Write a query returning `MIN`, `MAX`, `AVG`, `STDDEV_POP` of `products.unit_price`.

**Expected:** min = -5.00, max = 199.99, avg ≈ 40.08. What two defects does this instantly reveal?

### Exercise 3.4 — Frequency of order statuses

Write a query that counts orders by `status`, sorted by count descending.

**Expected:** shipped (9), pending (2), then single rows: Shipped, SHIPPED, shippd, cancelled. What does the distribution tell you?

### Exercise 3.5 — Frequency of product prices (bucketed)

Using `CASE WHEN`, bucket `products.unit_price` into: `negative`, `zero`, `0-50`, `50-100`, `100-200`, `200+`. Count rows per bucket.

**Expected:** negative 1, zero 1, 0-50 8, 100-200 2.

### Exercise 3.6 — Cardinality of customers

Write a query returning for `customers`: total rows, `COUNT(email)`, `COUNT(DISTINCT email)`, `COUNT(phone)`, `COUNT(DISTINCT phone)`.

**Expected:** rows 15, non-null email 13, distinct email 11, non-null phone 12, distinct phone 9.
*Hint: 12 non-null phones, distinct 9 — three phones repeat (customers 1&2, 3&4, 11&12).*

---

## Part B: Translate the Query

### Exercise 3.7

Explain in plain English what this query reports and what a reader should conclude:

```sql
SELECT
    SUM(order_id IS NULL)                  AS null_order_id,
    SUM(customer_id IS NULL)               AS null_customer_id,
    SUM(currency = 'EUR')                  AS eur_orders,
    COUNT(DISTINCT status)                 AS distinct_status,
    MAX(order_date)                        AS latest_order_date
FROM orders;
```

### Exercise 3.8

Explain this query. Which column has a suspicious profile and why?

```sql
SELECT
    ROUND(MIN(weight_kg), 2) AS min_weight,
    ROUND(MAX(weight_kg), 2) AS max_weight,
    ROUND(AVG(weight_kg), 2) AS avg_weight,
    COUNT(DISTINCT category) AS distinct_categories,
    SUM(category IS NULL)    AS null_categories
FROM products;
```

---

## Part C: Debug the Query

### Exercise 3.9 — Buggy NULL percentage

**Intended purpose:** report NULL percentage of `email` in customers.

```sql
SELECT
    COUNT(*) AS total,
    SUM(email IS NULL) AS nulls,
    SUM(email IS NULL) / COUNT(*) AS pct
FROM customers;
```

**Bug:** integer division returns 0. Fix it so `pct` shows `0.13` (i.e., 13.3%).

### Exercise 3.10 — Buggy distinct count

**Intended purpose:** count distinct `state` values in customers.

```sql
SELECT COUNT(DISTINCT state) AS distinct_states
FROM customers
WHERE state = 'CA';
```

**Bug:** the `WHERE` filters to one state first, so `DISTINCT` is meaningless. Remove it and explain why the count (11) is higher than the ~50 US states permit.

### Exercise 3.11 — Buggy frequency query

**Intended purpose:** count orders per status, most frequent first.

```sql
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY cnt
ORDER BY status DESC;
```

**Bug:** two problems — grouping by `cnt` instead of `status`, and the wrong ORDER BY column. Fix both.

---

## Self-Assessment Checkpoint

- [ ] I can write row-count and `UNION ALL` table surveys
- [ ] I can compute NULL counts and NULL percentages for any column
- [ ] I can write MIN/MAX/AVG/STDDEV profiles and interpret them
- [ ] I can build frequency distributions for categorical and numeric columns
- [ ] I can compute and interpret cardinality (COUNT vs COUNT DISTINCT)
- [ ] I can spot profile anomalies that hint at each of the 6 dimensions

**Ready to continue?** Move to **Unit 04 — Completeness**. Your profile report is the map; now write the formal rules.
