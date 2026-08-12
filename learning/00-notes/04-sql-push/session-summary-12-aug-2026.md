# Summary: SQL Skill Push Session

**Date:** 12 Aug 2026
**Track:** SQL Skill Push (sql-push)
**Status:** Intermediate Q12–Q13 done and verified against expected results.

---

## Completed

- Q12 — Order size labels via `CASE WHEN` (Large ≥ 4000, Medium ≥ 1500, else Small) on `orders`, 2,800 rows. PASS.
- Q13 — Order-size buckets: count + total revenue per bucket. PASS.

### Examples practiced

```sql
-- Q13 via CTE reuse of Q12's CASE (DRY)
WITH order_bucket AS (
    SELECT order_id, order_date, total_amount,
        CASE
            WHEN total_amount >= 4000 THEN 'Large'
            WHEN total_amount >= 1500 THEN 'Medium'
            ELSE 'Small'
        END AS order_size
    FROM orders
)
SELECT order_size,
    COUNT(*) AS order_count,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM order_bucket
GROUP BY order_size
ORDER BY order_count DESC;
```

---

## Key Takeaways

1. **Window vs aggregate with GROUP BY:** `COUNT(*) OVER(PARTITION BY order_size)` evaluated together with `GROUP BY order_size` returns 1 per bucket — window functions run *after* grouping, so each partition has a single row. Use a plain `COUNT(*)` aggregate instead.
2. **CTE reuse (DRY):** reusing Q12's `CASE` as a CTE avoids re-typing thresholds; a CTE is reusable only within the same query (temp tables/views needed across queries). No `ORDER BY` needed inside a CTE.
3. **Rounding:** `ROUND(SUM(total_amount), 2)` to match expected revenue (`3651768.83 / 4139038.41 / 598891.25`).

## Mistakes / Notes

- Q13: first draft mixed `COUNT(*) OVER(PARTITION BY order_size)` with `GROUP BY order_size` → order_count = 1 for every bucket.
- Reference solution repeats the full `CASE` in `GROUP BY` for portability; `GROUP BY order_size` (alias) also works in MySQL/SQLite.

## Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
2. Continue Intermediate Q14 (vendors with priciest products).

---

## Intermediate Q14–Q15 — Completed & Verified

**Status:** Intermediate Q14–Q15 done and verified against expected results / reference solutions.

### Completed

- Q14 — Vendors with priciest products: top 5 by average price (JOIN + GROUP BY + `LIMIT 5`). PASS.
- Q15 — Power customers: customers with > 3 orders + total spend, CTE + `WHERE order_count > 3`. PASS (400 rows).

### Key Takeaways

1. Q14 — "active product" is a business filter: `WHERE p.is_active = 1`. Without it, inactive products inflate avg + count (Harbor Trade 747.30/10 and Vista Market 673.91/7 instead of 727.26/9 and 655.63/5). Join type ≠ WHERE filter: `INNER JOIN` decides which rows match; `WHERE is_active = 1` decides which products count — both needed.
2. Q14 — reference groups by `v.vendor_id, v.vendor_name` (avoids ambiguity in strict modes); `GROUP BY vendor_name` alone also works here.
3. Q15 — CTE to compute per-customer order_count + total_spent, then outer `WHERE order_count > 3`; `LEFT JOIN customers` is fine (inner-equivalent here since customers with >3 orders obviously have orders).

### Mistakes / Notes

- Q14: first draft had no `WHERE is_active = 1` → wrong rows for Harbor Trade and Vista Market.
- Q15: column alias `total_spend` → renamed to `total_spent` to match the expected column name.

### Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
2. Continue Intermediate Q16 (orders above their own customer's average — correlated subquery).

---

## Intermediate Q16–Q17 — Completed & Verified

**Status:** Intermediate Q16–Q17 done and verified against expected results / reference solutions.

### Completed

- Q16 — Orders above their own customer's average: window `AVG OVER(PARTITION BY customer_id)` in a CTE + outer `WHERE total_amount > customer_avg`. PASS (1,289 rows).
- Q17 — 2025 monthly orders: `DATE_FORMAT(order_date, '%Y-%m')` + `COUNT`/`ROUND(SUM)`. PASS (12 rows).

### Key Takeaways

1. Q16 — per-customer average via window function, NOT correlated subquery (reference uses the correlated version; window + CTE is the cleaner equivalent). Both give the same 1,289 rows.
2. **Window functions and SELECT aliases can't be used in WHERE** — window results are computed after WHERE, and aliases aren't visible to WHERE. Wrap the window in a CTE/subquery, then filter outside.
3. Q17 — MySQL date formatting: `DATE_FORMAT(order_date, '%Y-%m')` produces `YYYY-MM`. `MONTH()`/`YEAR()` are MySQL-only; SQLite needs `strftime('%Y-%m', order_date)`. Consistent `GROUP BY` expression (or alias) avoids merging years.
4. Q17 — `GROUP BY month` (alias) is valid in MySQL/SQLite; standard SQL requires repeating the expression — reference repeats it for portability.

### Mistakes / Notes

- Q16: first drafts had `SELECT(ROUND(AVG(...)) OVER(...) FROM orders)` syntax errors — stray `SELECT(` and `FROM` inside the window parentheses.
- Q17: initial answer used `MONTH(order_date)` — wrong format (bare month number) and MySQL-only in a SQLite verification context.

### Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
2. Continue Intermediate Q18 (late or missing deliveries — CASE + date functions).

---

## Intermediate Q18–Q19 — Completed & Verified

**Status:** Intermediate Q18–Q19 done and verified against expected results / reference solutions. Q20 still pending.

### Completed

- Q18 — Late or missing deliveries: `CASE` on `delivery_date` (NULL → 'In transit', `DATEDIFF > 7` → 'Late', else 'On time') + `WHERE delivery_status IN ('Late','In transit')`. PASS (1,787 rows = 1,692 Late + 95 In transit).
- Q19 — Active products above their category's average sale price: two CTEs — per-product `AVG(oi.unit_price)`, then `AVG(avg_sale_price)` per category from the first CTE, joined on `cat_id`, filtered `avg_sale_price > category_avg_sale`. PASS (55 rows, 0 value diffs vs reference).

### Key Takeaways

1. Q18 — "late OR not delivered" means the outer filter must include **both** statuses: `WHERE delivery_status IN ('Late','In transit')`. First drafts filtered only 'Late' → lost the 95 In-transit rows. Prefer `delivery_date IS NULL` over `DATEDIFF(...) IS NULL` (clearer, no double computation).
2. Q19 — **the second CTE reads from the first CTE** (`FROM unit_avg_sale`), not from base tables — that's what produces the "average of per-product averages" (category avg 489.76), not a line-item average. Join on `cat_id` (the actual key), not `prod_id`.
3. Q19 — recurring active-product filter `WHERE p.is_active = 1`; per-product "average sale price" = `AVG(oi.unit_price)`, not `AVG(unit_price * quantity)` (revenue-weighted).

### Mistakes / Notes

- Q18: `s.carried` typo → `s.carrier`; outer filter only `'Late'` initially → missed In-transit.
- Q19 (multiple drafts): `GROUP BY cat_id` while projecting `prod_id`; joined CTEs on `prod_id` instead of `cat_id`; `cat_avg_sale` recomputed from `order_items` instead of `unit_avg_sale`; stray `SELECT(`/`oi` reference errors; column name `category_avg_price` vs `category_avg_sale`; `p.ias_active` typo.
- Strict-mode note: include `cat_id` in `GROUP BY` when selecting it (avoids `ONLY_FULL_GROUP_BY` errors).

### Next Steps

1. Answer Intermediate **Q20** (payment method success rates — conditional aggregation, 4 rows) → completes Intermediate.
2. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
3. Then Advanced level (telecom) or Beginner fixes first.

---

## Intermediate Q20 — Completed · Level Complete 🎉

**Status:** Intermediate Q1–Q20 ALL done and verified. Level complete.

### Completed

- Q20 — Payment method success rates: conditional aggregation `SUM(CASE WHEN status=... THEN 1 ELSE 0 END) * 100.0 / COUNT(*)` per method + `ROUND(..., 2)`. PASS (4 rows: PayPal 60.04 / COD 58.85 / Bank Transfer 58.82 / Card 58.73 paid_pct).

### Key Takeaways

1. **Integer division trap:** `* 100 / COUNT(*)` truncates to integers (58, not 58.82) — both operands are integers. Use `* 100.0` to keep decimals. Multiply before dividing.
2. **Conditional aggregation = COUNTIF:** `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` counts rows matching a condition without a WHERE. Several of these per SELECT + `GROUP BY method` = per-method breakdown (pivot pattern, same as Q11).
3. **String literals are case-sensitive:** `'failed'` ≠ `'Failed'` in MySQL — always match the exact data values.
4. **SQL formatting standards:** dbt-style — uppercase keywords, one column per line, leading/trailing comma (pick one), 2/4-space indent, `CASE`/`WHEN`/`ELSE`/`END` on own lines, clause order SELECT→FROM→WHERE→GROUP BY→HAVING→ORDER BY→LIMIT. Flatten deep nesting with a CTE. Auto-format with sqlfluff/sqlfmt.

### Mistakes / Notes

- Q20: integer division `* 100` → 58/20/20 instead of 58.82/20.59/20.59; fixed with `* 100.0`.
- Q20 refactor: forgot `END` in `SUM(CASE ... THEN 1 ELSE 0)` (syntax error); lowercase `'failed'`/`'refunded'` literals → 0 buckets (case-sensitive).
- Q20 refactor: `ORDER BY total_payments DESC` sorts Card first; expected table lists PayPal first (order not specified by the request).

### Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
2. Start Advanced level (03-advanced, NovaTel telecom — window funcs, correlated subs, recursive CTE, set ops, pivots, cohorts).

---

*Happy Learning!*
