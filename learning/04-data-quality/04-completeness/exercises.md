# Exercises: Unit 04 — Completeness

*All exercises run against `dq_learning`. Reference date: 2026-08-03.*

**Business context recap:** Marketing needs `customers.email` (≥99% complete). Finance needs `orders.total_amount` (100% complete). Support needs `customers.phone` (≥90% complete).

---

## Part A: Write the Query

### Exercise 4.1 — Missing emails

Write a query listing all customers missing an email (NULL or empty/whitespace). Include customer_id and email.

**Expected:** customers 5 and 14.

### Exercise 4.2 — Missing order fields

Write a query listing orders missing any of: `total_amount`, `customer_id`, `order_date`. Show order_id and the missing-field indicators.

**Expected:** order 4 (missing total_amount).

### Exercise 4.3 — Email completeness ratio

Write a query computing the completeness percentage of `customers.email`.

**Expected:** 86.7%.

### Exercise 4.4 — PASS/FAIL threshold rule

Write a query that returns `PASS` or `FAIL` for the rule *"email completeness ≥ 99%"*.

**Expected:** FAIL.

### Exercise 4.5 — Phone completeness rule

Same pattern for *"phone completeness ≥ 90%"*.

**Expected:** FAIL (80%).

### Exercise 4.6 — Multi-column completeness report

Write a `UNION ALL` report of completeness percentage for: `orders.total_amount`, `orders.status`, `orders.ship_city`.

**Expected:** 93.3 / 93.3 / 86.7.

### Exercise 4.7 — Classify customers by completeness level

Write a query that labels each customer `fully complete`, `partially complete`, or `fully empty` (based on first_name, email, phone, state) and counts by level.

**Expected:** fully complete 8, partially complete 6, fully empty 1.

### Exercise 4.8 — Orders with no items

Write a query to find orders that have no line items in `order_items`.

**Expected:** zero rows — but the check itself matters.

---

## Part B: Translate the Query

### Exercise 4.9

Explain in plain English, and state the business implication:

```sql
SELECT COUNT(*) AS orders_without_amount
FROM orders
WHERE total_amount IS NULL;
```

### Exercise 4.10

Explain what this returns and how you'd act on the result:

```sql
SELECT
    ROUND(COUNT(qty) * 100.0 / COUNT(*), 1) AS qty_completeness,
    ROUND(COUNT(unit_price) * 100.0 / COUNT(*), 1) AS price_completeness,
    ROUND(COUNT(total_price) * 100.0 / COUNT(*), 1) AS total_completeness
FROM order_items;
```

**Expected:** qty 100.0, price 100.0, total 100.0 — no NULLs in order_items.

---

## Part C: Debug the Query

### Exercise 4.11 — Buggy email check

**Intended purpose:** find customers missing an email (NULL or empty).

```sql
SELECT customer_id, email
FROM customers
WHERE email = NULL OR email = '';
```

**Bug:** `= NULL` never matches (must use `IS NULL`). Fix it.

### Exercise 4.12 — Buggy ratio

**Intended purpose:** email completeness percentage in customers.

```sql
SELECT COUNT(email) / COUNT(*) AS pct FROM customers;
```

**Bug:** integer division → 0. Fix with `* 100.0` and `ROUND`.

### Exercise 4.13 — Buggy requirement logic

**Intended purpose:** fail if ANY of total_amount, customer_id, order_date is missing in orders.

```sql
SELECT order_id
FROM orders
WHERE total_amount IS NULL AND customer_id IS NULL AND order_date IS NULL;
```

**Bug:** `AND` requires *all* missing; the rule needs *any*. Fix with `OR`.

---

## Self-Assessment Checkpoint

- [ ] I can find missing required fields with `IS NULL`
- [ ] I can catch empty/whitespace strings as missing (`TRIM(col) = ''`)
- [ ] I can compute completeness ratios with `COUNT(col)/COUNT(*)`
- [ ] I can write PASS/FAIL threshold rules
- [ ] I can classify rows as fully/partially/empty complete
- [ ] I can check cross-table completeness (orders ↔ items)

**Ready to continue?** Move to **Unit 05 — Uniqueness**.
