# Lesson 6.2: Domain and Range Validation

Beyond format, values must be in the right **domain** (allowed set) and **range** (acceptable bounds). Domain/range checks catch typos in statuses, negative prices, and impossible quantities.

---

## Range Validation — numbers must be plausible

```sql
-- Products with impossible prices (must be > 0)
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE unit_price <= 0;
```

**Expected output (2 rows):**

| product_id | sku | product_name | unit_price |
|------------|-----|--------------|------------|
| 3 | SKU-1002 | USB-C Cable | -5.00 |
| 4 | SKU-1003 | Desk Lamp | 0.00 |

A negative price is impossible; a zero price means the value is missing or placeholder — both are validity defects. **Business rule from Unit 02: `unit_price > 0`.**

---

## Range Validation — quantities

```sql
-- Order items with impossible quantities
SELECT item_id, order_id, qty, unit_price, total_price
FROM order_items
WHERE qty <= 0 OR qty > 100;
```

**Expected output (2 rows):**

| item_id | order_id | qty | unit_price | total_price |
|---------|----------|-----|------------|-------------|
| 11 | 10 | 0 | 149.99 | 0.00 |
| 19 | 15 | -1 | 5.00 | -5.00 |

Zero qty and negative qty are both invalid. **Business rule: `qty > 0`.**

---

## Domain Validation — the status enum

Domain = allowed set of values. `orders.status` should be one of `shipped | pending | cancelled`:

```sql
SELECT order_id, status
FROM orders
WHERE status NOT IN ('shipped', 'pending', 'cancelled');
```

**Expected output (3 rows — note the NULL status is NOT returned):**

| order_id | status |
|----------|--------|
| 8 | Shipped |
| 9 | SHIPPED |
| 10 | shippd |

**Why only 3?** In SQL, `NULL NOT IN (...)` evaluates to *unknown*, and `WHERE` drops unknown rows. So the NULL status (order 4) is silently skipped by `NOT IN` — a classic trap.

Actually in SQL, `NULL NOT IN ('shipped','pending','cancelled')` → NULL (unknown) → filtered out by WHERE. So the `NOT IN` query returns only orders 8, 9, 10 (3 rows), NOT order 4.

Let me correct the expected output to 3 rows: orders 8, 9, 10. And handle NULL separately.

---

## The NULL Trap in NOT IN

```sql
-- This MISSES NULL statuses
SELECT order_id, status
FROM orders
WHERE status NOT IN ('shipped', 'pending', 'cancelled');
-- Returns only: orders 8, 9, 10 (NULLs are silently skipped)

-- This catches everything invalid including NULL
SELECT order_id, status
FROM orders
WHERE status IS NULL
   OR status NOT IN ('shipped', 'pending', 'cancelled');
```

**Always decide:** is a missing status a validity issue (it should have been set) or a completeness issue (separately handled in Unit 04)? In practice, check both:

```sql
-- Complete validity check: missing OR out of domain
SELECT order_id, status,
       CASE
           WHEN status IS NULL THEN 'missing'
           WHEN status NOT IN ('shipped','pending','cancelled') THEN 'invalid value'
           ELSE 'ok'
       END AS status_check
FROM orders
WHERE status IS NULL
   OR status NOT IN ('shipped', 'pending', 'cancelled');
```

**Expected output (4 rows):**

| order_id | status | status_check |
|----------|--------|--------------|
| 4 | NULL | missing |
| 8 | Shipped | invalid value |
| 9 | SHIPPED | invalid value |
| 10 | shippd | invalid value |

---

## Range Validation with CASE diagnostics

```sql
SELECT
    product_id, sku, product_name, unit_price,
    CASE
        WHEN unit_price < 0  THEN 'negative'
        WHEN unit_price = 0  THEN 'zero'
        WHEN unit_price IS NULL THEN 'missing'
        ELSE 'valid'
    END AS price_check
FROM products
WHERE unit_price <= 0 OR unit_price IS NULL;
```

**Expected output:**

| product_id | sku | product_name | unit_price | price_check |
|------------|-----|--------------|------------|-------------|
| 3 | SKU-1002 | USB-C Cable | -5.00 | negative |
| 4 | SKU-1003 | Desk Lamp | 0.00 | zero |

---

## The Domain/Range Check Library

| Rule | SQL |
|------|-----|
| Price must be > 0 | `WHERE unit_price <= 0` |
| Qty must be > 0 | `WHERE qty <= 0` |
| Status in allowed set | `WHERE status IS NULL OR status NOT IN (...)` |
| Weight within bounds | `WHERE weight_kg < 1 OR weight_kg > 50` |
| Date within window | `WHERE order_date NOT BETWEEN ...` (Unit 09) |

---

## English Translation (of this lesson)

> "Domain checks verify values are in the allowed set; range checks verify they're within bounds. I use NOT IN for enums and comparison operators for numeric ranges, always deciding explicitly how to treat NULL. CASE diagnostics classify each violation so the fix is obvious."

---

## Key Takeaways

1. **Range checks** use comparison operators (`<= 0`, `> 100`, `BETWEEN`).
2. **Domain checks** use `NOT IN` for allowed-value sets.
3. **`NULL NOT IN` silently skips NULLs** — add an explicit `IS NULL` if missing is also a violation.
4. Always pair a validity check with a **business rule** (from Unit 02).
5. `CASE` diagnostics make findings actionable.

**Coming up next:** Reference-data validation.
