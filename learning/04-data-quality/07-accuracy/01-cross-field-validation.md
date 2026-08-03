# Lesson 7.1: Cross-Field Validation

**Accuracy** answers: *does the data reflect reality?* The most reliable accuracy checks don't compare against humans — they **recompute** a value from other fields and compare. When two stored fields disagree mathematically, at least one of them is wrong.

---

## The Classic: `qty × unit_price = total_price`

This is the archetypal cross-field accuracy check:

```sql
SELECT
    item_id, order_id, qty, unit_price, total_price,
    qty * unit_price AS expected_total,
    ROUND(qty * unit_price - total_price, 2) AS difference
FROM order_items
WHERE qty * unit_price <> total_price;
```

**Expected output (1 row):**

| item_id | order_id | qty | unit_price | total_price | expected_total | difference |
|---------|----------|-----|------------|-------------|----------------|------------|
| 5 | 4 | 1 | 5.00 | 4.00 | 5.00 | 1.00 |

Item 5 stores `total_price = 4.00`, but `1 × 5.00 = 5.00`. **One of the two values is wrong** — the check found it without needing to know which.

> **Note on DECIMAL vs FLOAT:** `unit_price` and `total_price` are `DECIMAL(10,2)`, so `qty * unit_price` is exact. If they were `FLOAT`/`DOUBLE`, a *correct* row could show a difference like `0.0000001` — in real systems use `ABS(qty * unit_price - total_price) > 0.01` to stay safe.

---

## Order Total vs Sum of Items

A higher-level accuracy check: the `orders.total_amount` should equal the sum of its line items.

```sql
SELECT
    o.order_id,
    o.total_amount,
    COALESCE(SUM(oi.qty * oi.unit_price), 0) AS items_total,
    ROUND(o.total_amount - COALESCE(SUM(oi.qty * oi.unit_price), 0), 2) AS diff
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount IS NULL
    OR ROUND(o.total_amount - COALESCE(SUM(oi.qty * oi.unit_price), 0), 2) <> 0;
```

**Expected output:**

| order_id | total_amount | items_total | diff |
|----------|--------------|-------------|------|
| 4 | NULL | 4.00 | NULL |
| 15 | 0.00 | 19.95 | -19.95 |

**Decode:**
- **Order 4** has `total_amount = NULL` but its item sums to 4.00 — a completeness + accuracy problem.
- **Order 15** has `total_amount = 0.00` but items total 19.95 (5×4.99 + (−1×5.00) = 24.95 − 5.00 = 19.95). The order total contradicts its own items.

> **The NULL trap:** the naive `HAVING ... <> 0` would *silently skip* order 4, because `NULL - 4.00 = NULL` and `NULL <> 0` evaluates to UNKNOWN, which `HAVING` drops. Always add an explicit `IS NULL` check on the compared column. (This is the same trap we met with `NOT IN` in Unit 06.)

This check catches *aggregate* level errors that the row-level check misses.

---

## The Cross-Field Pattern Library

| Check | Pattern |
|-------|---------|
| Line total | `qty * unit_price = total_price` |
| Order total | `orders.total_amount = SUM(items.qty × unit_price)` |
| Date order | `ship_date >= order_date` |
| Range subsumption | `child.min <= child.max` |
| Status-flow | `shipped` only after `paid` |

```sql
-- Date-order check (if we had ship dates)
SELECT order_id
FROM orders
WHERE shipped_date IS NOT NULL
  AND shipped_date < order_date;
```

The unifying idea: **if the data contradicts itself, it can't all be accurate.**

---

## Why Cross-Field Beats Manual Review

- It's **automatic and exhaustive** — every row checked every run.
- It catches **silent logic errors** (off-by-one, currency, tax miscalculations).
- It produces **evidence** (the recomputed value) — no "trust me" needed.
- It scales to millions of rows.

---

## English Translation (of this lesson)

> "Cross-field validation recomputes a value from other fields and compares it to the stored value. qty × unit_price should equal total_price; an order total should equal the sum of its items. When stored values contradict each other, at least one is wrong. This is the strongest form of accuracy checking because the data judges itself."

---

## Key Takeaways

1. **Recompute and compare** — the data tests itself.
2. Row-level (`qty × price`) and **aggregate-level** (order vs items) checks are complementary.
3. Beware **float precision** — use `ABS(diff) > 0.01` or DECIMAL types.
4. Cross-field checks are **automatic, exhaustive, and evidence-producing**.

**Coming up next:** Master-data comparison.
