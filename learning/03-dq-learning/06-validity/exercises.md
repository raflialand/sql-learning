# Exercises: Unit 06 — Validity

*All exercises run against `dq_learning`.*

**Business rules (from the expectations sheet):**
- `customers.email` must be well-formed
- `products.unit_price` must be > 0
- `order_items.qty` must be > 0
- `orders.status` must be one of `shipped | pending | cancelled`

---

## Part A: Write the Query

### Exercise 6.1 — Invalid emails

Write a query finding well-formedness violations in `customers.email` using `REGEXP`.

**Expected:** customers 6 (`david.wilson@@example.com`) and 7 (`eve.brown@example`).

### Exercise 6.2 — Diagnose invalid emails

Extend the check with a `CASE` that classifies each invalid email as `double @`, `missing dot`, `missing @`, or `other`.

**Expected:** customer 6 → double @; customer 7 → missing dot.

### Exercise 6.3 — Invalid prices

Write a query finding products with `unit_price <= 0`.

**Expected:** products 3 (−5.00) and 4 (0.00).

### Exercise 6.4 — Invalid quantities

Write a query finding order_items with `qty <= 0` or `qty > 100`.

**Expected:** items 11 (qty 0) and 19 (qty −1).

### Exercise 6.5 — Invalid statuses (NOT IN)

Write a query finding orders whose status is not in the allowed set, using `NOT IN`.

**Expected:** orders 8 (Shipped), 9 (SHIPPED), 10 (shippd). *Why isn't order 4 (NULL) returned?*

### Exercise 6.6 — Invalid statuses (including NULL)

Rewrite the check to also catch the NULL status.

**Expected:** orders 4, 8, 9, 10.

### Exercise 6.7 — Out-of-range weight

Write a query finding products whose `weight_kg` is outside the plausible range for this catalog (use `< 0.1 OR > 50`).

**Expected:** product 5 (150.00).

### Exercise 6.8 — Reference validation of statuses

Using a temporary `ref_status` table, write the LEFT JOIN reference check for `orders.status`.

**Expected:** orders 4, 8, 9, 10.

---

## Part B: Translate the Query

### Exercise 6.9

Explain in plain English, including what the `^` and `$` do:

```sql
SELECT customer_id, email
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
```

### Exercise 6.10

Explain what this returns and why it is more robust than `NOT IN`:

```sql
SELECT o.order_id, o.status
FROM orders o
LEFT JOIN (SELECT 'shipped' AS s UNION ALL SELECT 'pending' UNION ALL SELECT 'cancelled') ref
  ON o.status = ref.s
WHERE ref.s IS NULL;
```

---

## Part C: Debug the Query

### Exercise 6.11 — Buggy domain check

**Intended purpose:** find invalid order statuses.

```sql
SELECT order_id, status
FROM orders
WHERE status NOT IN ('shipped', 'pending', 'cancelled') OR status = NULL;
```

**Bug:** `status = NULL` never matches. Fix with `status IS NULL`.

### Exercise 6.12 — Buggy regex (missing anchors)

**Intended purpose:** find emails that do NOT look like `something@something.something`.

```sql
SELECT customer_id, email
FROM customers
WHERE email NOT REGEXP '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}';
```

**Bug:** without `^` and `$`, the regex matches *substrings*, so even `david.wilson@@example.com` is seen as valid (it contains a valid-looking fragment). Add the anchors.

### Exercise 6.13 — Buggy range check

**Intended purpose:** find invalid quantities (must be > 0).

```sql
SELECT item_id, qty FROM order_items WHERE qty > 0 AND qty < 100;
```

**Bug:** this finds VALID rows, not violations. Invert the logic.

---

## Self-Assessment Checkpoint

- [ ] I can validate formats with `REGEXP` (with `^` and `$` anchors)
- [ ] I can diagnose invalid values with `CASE`
- [ ] I can write range checks with comparison operators
- [ ] I can write domain checks with `NOT IN`
- [ ] I know the `NULL NOT IN` trap and how to fix it
- [ ] I can validate against reference data with `LEFT JOIN ... IS NULL`

**Ready to continue?** Move to **Unit 07 — Accuracy**.
