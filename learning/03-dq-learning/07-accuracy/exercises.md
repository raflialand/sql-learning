# Exercises: Unit 07 — Accuracy

*All exercises run against `dq_learning`. The clean reference tables (`dq_clean_*`) come from `dq_dataset_clean.sql`.*

---

## Part A: Write the Query

### Exercise 7.1 — Line-item total mismatch

Write a query finding `order_items` where `total_price <> qty * unit_price`.

**Expected:** item 5 (5.00 vs 4.00).

### Exercise 7.2 — Order total vs items

Write a query finding orders whose `total_amount` differs from the sum of their items' `qty * unit_price` (be sure to catch NULL totals too).

**Expected:** orders 4 (NULL vs 4.00) and 15 (0.00 vs 19.95).

### Exercise 7.3 — Price vs master data

Write a query comparing `products.unit_price` to `dq_clean_products.unit_price` on `product_id`, showing both values.

**Expected:** products 3 (-5.00 vs 9.99) and 4 (0.00 vs 24.99).

### Exercise 7.4 — Weight vs master data

Write a query finding products whose `weight_kg` differs from master data.

**Expected:** product 5 (150.00 vs 12.00).

### Exercise 7.5 — Customer email vs master data

Write a query finding customers whose `email` differs from `dq_clean_customers.email` (use `COALESCE` to catch NULLs too).

**Expected:** customers 5, 6, 7.

### Exercise 7.6 — Product lifecycle rule

Write a query finding products that violate the rule *"inactive products must have a discontinuation date, and active products must not be discontinued in the past."*

**Expected:** product 6 (active but discontinued 2025-01-01).

### Exercise 7.7 — Currency mismatch rule

Write a query finding order items whose currency differs from their parent order's currency.

**Expected:** item 14 (USD) under order 12 (EUR).

### Exercise 7.8 — Business-rule scorecard

Write a query computing: total products, count of products violating the price/weight business rule, and the violation percentage.

**Expected:** 12 total, 3 violations, 25.0%.

---

## Part B: Translate the Query

### Exercise 7.9

Explain in plain English, including what `HAVING` does here:

```sql
SELECT o.order_id, o.total_amount, COALESCE(SUM(oi.qty * oi.unit_price), 0) AS items_total
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING COALESCE(SUM(oi.qty * oi.unit_price), 0) <> o.total_amount;
```

### Exercise 7.10

Explain what this returns and why `COALESCE` matters:

```sql
SELECT c.customer_id, c.email AS op_email, m.email AS master_email
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.email, '') <> COALESCE(m.email, '');
```

---

## Part C: Debug the Query

### Exercise 7.11 — Buggy float comparison

**Intended purpose:** find line items with mismatched totals.

```sql
SELECT item_id, qty, unit_price, total_price
FROM order_items
WHERE qty * unit_price <> total_price;
```

**Bug (conceptual):** if these were FLOAT columns, tiny precision differences could produce false positives. Rewrite it to be float-safe with `ROUND(...)` and `ABS(...) > 0.01`.

### Exercise 7.12 — Buggy NULL comparison

**Intended purpose:** compare product prices to master data.

```sql
SELECT p.product_id, p.unit_price, m.unit_price
FROM products p
JOIN dq_clean_products m ON p.product_id = m.product_id
WHERE p.unit_price <> m.unit_price;
```

**Bug (hidden):** this misses NULL operational prices. Write a version using `COALESCE` that catches them too.

### Exercise 7.13 — Buggy business rule

**Intended purpose:** find products that are active but should be discontinued.

```sql
SELECT product_id, is_active, discontinued_at
FROM products
WHERE is_active = 1 AND discontinued_at > CURRENT_DATE;
```

**Bug:** a *past* discontinuation means "should be inactive", not a future one. Fix the comparison (`discontinued_at <= CURRENT_DATE`).

---

## Self-Assessment Checkpoint

- [ ] I can validate `qty × unit_price = total_price`
- [ ] I can compare order totals to summed line items
- [ ] I can compare operational data to master data on a business key
- [ ] I handle NULLs with `COALESCE` in comparisons
- [ ] I can encode business rules (lifecycle, currency, plausibility) as queries
- [ ] I can build violation scorecards with percentages

**Ready to continue?** Move to **Unit 08 — Consistency**.
