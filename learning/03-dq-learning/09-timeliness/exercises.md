# Exercises: Unit 09 — Timeliness

*All exercises run against `dq_learning`. Reference date: **2026-08-03**.*

---

## Part A: Write the Query

### Exercise 9.1 — Freshness of orders

Write a query returning `MAX(order_date)` and `DATEDIFF('2026-08-03', MAX(order_date))` for orders.

**Expected:** latest 2026-08-15, days -12.

### Exercise 9.2 — Freshness report

Write a `UNION ALL` freshness report for `orders` and `daily_sales`.

**Expected:** orders → days -12; daily_sales → max 2026-07-31, days 3.

### Exercise 9.3 — Future-dated orders

Write a query finding orders with `order_date > '2026-08-03'`.

**Expected:** order 5.

### Exercise 9.4 — Future-date percentage

Write a query computing total orders, future orders, and future percentage.

**Expected:** 15 / 1 / 6.7.

### Exercise 9.5 — Future-date PASS/FAIL

Write a query returning PASS/FAIL for "no future-dated orders".

**Expected:** FAIL.

### Exercise 9.6 — Expired-but-active products

Write a query finding products discontinued in the past that are still active.

**Expected:** product 6 (Coffee Maker).

### Exercise 9.7 — Missing time buckets

Using a recursive `date_spine` CTE for `2026-07-20` .. `2026-07-31`, find days missing from `daily_sales`.

**Expected:** none (0 rows) — every day has data.

### Exercise 9.8 — Combined timeliness report

Write a `UNION ALL` report combining: future-dated orders count and expired-but-active products count.

**Expected:** 1 / 1.

---

## Part B: Translate the Query

### Exercise 9.9

Explain in plain English:

```sql
SELECT
    'orders' AS dataset,
    MAX(order_date) AS max_date,
    DATEDIFF('2026-08-03', MAX(order_date)) AS days_behind
FROM orders;
```

### Exercise 9.10

Explain what this does and what a reader should conclude:

```sql
WITH RECURSIVE date_spine AS (
    SELECT '2026-07-20' AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM date_spine WHERE d < '2026-07-31'
)
SELECT s.d
FROM date_spine s
LEFT JOIN daily_sales ds ON ds.sale_date = s.d
WHERE ds.sale_date IS NULL;
```

---

## Part C: Debug the Query

### Exercise 9.11 — Buggy future-date check

**Intended purpose:** find future-dated orders.

```sql
SELECT order_id, order_date
FROM orders
WHERE order_date > 20260803;
```

**Bug:** `20260803` is a number, not a date. Fix by quoting it as a string or using `CURDATE()`.

### Exercise 9.12 — Buggy freshness (wrong direction)

**Intended purpose:** days since the latest order.

```sql
SELECT DATEDIFF(MAX(order_date), '2026-08-03') AS days_since
FROM orders;
```

**Bug:** arguments are reversed — this returns a positive number for a future date instead of negative. Swap them: `DATEDIFF('2026-08-03', MAX(order_date))`.

### Exercise 9.13 — Buggy expired-product check

**Intended purpose:** find expired-but-active products.

```sql
SELECT product_id, discontinued_at, is_active
FROM products
WHERE discontinued_at IS NOT NULL AND is_active = 1;
```

**Bug:** missing the "in the past" condition — this would also match future discontinuations. Add `AND discontinued_at < CURDATE()`.

---

## Self-Assessment Checkpoint

- [ ] I can compute freshness with `MAX(date)` and `DATEDIFF`
- [ ] I can find future-dated records with `date > CURDATE()`
- [ ] I can compute future-date percentages
- [ ] I can write PASS/FAIL freshness and future-date rules
- [ ] I can detect expired-but-active records
- [ ] I can build a date spine and find missing time buckets

**Ready to continue?** Move to **Unit 10 — Anomaly Detection**.
