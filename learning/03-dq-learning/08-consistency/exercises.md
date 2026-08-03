# Exercises: Unit 08 — Consistency

*All exercises run against `dq_learning`. The `dq_clean_*` tables come from `dq_dataset_clean.sql`.*

---

## Part A: Write the Query

### Exercise 8.1 — Orphan orders

Write a query finding orders whose `customer_id` has no matching customer.

**Expected:** order 3 (customer_id 99).

### Exercise 8.2 — Orphan order items (product side)

Write a query finding `order_items` whose `product_id` has no matching product.

**Expected:** item 4 (product_id 99).

### Exercise 8.3 — Orphan order items (order side)

Write a query finding `order_items` whose `order_id` has no matching order.

**Expected:** item 20 (order_id 999).

### Exercise 8.4 — Full RI report

Combine the three orphan checks (8.1–8.3) into one `UNION ALL` report.

**Expected:** 3 rows.

### Exercise 8.5 — Currency inconsistency (items vs orders)

Write a query finding order items whose currency differs from their parent order.

**Expected:** item 14 (USD vs EUR order 12).

### Exercise 8.6 — State inconsistency (operational vs master)

Write a query finding customers whose `state` differs from `dq_clean_customers.state`.

**Expected:** customers 4 (California vs CA), 6 (tx vs TX), 12 (Oregon vs OR).

### Exercise 8.7 — Phone format consistency

Write a query grouping `customers.phone` by format (`parens` / `dot` / `dash`) and counting.

**Expected:** dash 9, parens 2, dot 1.

### Exercise 8.8 — Canonicalized phones

Write a query returning `customer_id`, `phone`, and the phone with all non-digits stripped.

**Expected:** e.g., customer 1 → `5551234567`, customer 9 → `5557778888`.

### Exercise 8.9 — Non-USD orders

Write a query finding orders not priced in USD.

**Expected:** orders 12, 13 (EUR).

---

## Part B: Translate the Query

### Exercise 8.10

Explain what this returns and why it matters:

```sql
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

### Exercise 8.11

Explain the purpose of `COALESCE` and what the query reports:

```sql
SELECT c.customer_id, c.state AS operational_state, m.state AS master_state
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.state, '') <> COALESCE(m.state, '');
```

### Exercise 8.12

Explain what `REGEXP_REPLACE` is doing and why it enables phone dedup:

```sql
SELECT customer_id, phone,
       REGEXP_REPLACE(phone, '[^0-9]', '') AS canonical_phone
FROM customers
WHERE phone IS NOT NULL;
```

---

## Part C: Debug the Query

### Exercise 8.13 — Buggy orphan check

**Intended purpose:** find orders without a valid customer.

```sql
SELECT o.order_id
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
```

**Bug:** an INNER JOIN *keeps only matching rows* — it can never return orphans. Fix with LEFT JOIN + `IS NULL`.

### Exercise 8.14 — Buggy NULL-safe comparison

**Intended purpose:** compare customer state to master data.

```sql
SELECT c.customer_id
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE c.state <> m.state;
```

**Bug:** NULL states silently pass (`NULL <> 'x'` is UNKNOWN, not true). Fix with `COALESCE`.

### Exercise 8.15 — Buggy canonicalization

**Intended purpose:** strip non-digits from phones.

```sql
SELECT customer_id, phone, REPLACE(phone, '-', '') AS cleaned
FROM customers;
```

**Bug:** only replaces dashes — dots and parentheses remain. Fix with `REGEXP_REPLACE(phone, '[^0-9]', '')`.

---

## Self-Assessment Checkpoint

- [ ] I can find orphans with `LEFT JOIN ... IS NULL`
- [ ] I can write a combined RI report with `UNION ALL`
- [ ] I can compare shared attributes across tables (currency, state)
- [ ] I use `COALESCE` so NULLs count as differences
- [ ] I can detect format inconsistency (phones) and canonicalize it
- [ ] I understand why orphans are silently dangerous in INNER JOINs

**Ready to continue?** Move to **Unit 09 — Timeliness**.
