# Summary: SQL Skill Push Session

**Date:** 10 Aug 2026
**Track:** SQL Skill Push (sql-push)
**Status:** Beginner Q1–Q20 — in review (14/20 verified, 6 fixes pending)

---

## Completed

- Beginner Q1–Q20: wrote all 20 solutions in `01-beginner/solutions/my-solutions.sql` and submitted them to the query-inspector for verification against the reference solutions (`solution_01.sql` … `solution_20.sql`) on `datasets/01-beginner/retail.db`.

## Key Takeaways

1. The `retail.db` / Brew & Co. schema uses `is_active`, not `active` (Q1).
2. `YEAR()` / `MONTH()` are MySQL-only; SQLite requires `strftime('%Y', ...)` / `strftime('%m', ...)` (Q3, Q18, Q19).
3. Table aliases must match the `FROM` clause — `oi.quantity` with no `oi` alias breaks the query (Q14); unqualified `unit_price` is ambiguous when both joined tables share it.
4. A stray `;` mid-statement turns the rest of the query into a standalone (invalid) statement (Q15).

## Mistakes / Notes

- Q1: `WHERE active = 1` → should be `WHERE is_active = 1`.
- Q3: `WHERE YEAR(signup_date) = 2025` → SQLite `strftime` equivalent needed.
- Q14: missing `AS oi` alias on `order_items`; `unit_price` must be qualified (e.g. `p.unit_price`).
- Q15: stray `;` after `GROUP BY payment_method` split the query in two → syntax error.
- Q18: `MONTH()`/`YEAR()` not supported in SQLite; expected output format is `YYYY-MM`.
- Q19: `YEAR()`/`MONTH()` not supported in SQLite; ordering should surface the global highest month first.
- Verified correct: Q20 anti-join (`LEFT JOIN` + `WHERE o.order_id IS NULL`), Q17 `HAVING` aggregate alias, Q19 all-years scope.
- Full analysis: `docs/03-query-inspector/query-analysis-2026-08-10.md`.

## Next Steps

1. Fix Q1, Q3, Q14, Q15, Q18, Q19 in `my-solutions.sql` (SQLite-compatible) and re-run verification.
2. Re-submit the corrected file to `@query-inspector` to confirm 20/20 PASS.

---

## Intermediate Q1–Q5 — Completed & Verified

**Status:** Intermediate started — Q1–Q5 done and verified against expected results in `02-intermediate/challenges.md`.

### Completed

- Intermediate Q1–Q5 on `datasets/02-intermediate/ecommerce.db` (MarketHub marketplace), each compared against the expected result and reference solutions.

### Key Takeaways

1. Q1 — orders→customers join (`CONCAT(c.first_name, ' ', c.last_name)`, `LEFT JOIN c.cust_id = o.customer_id`) is valid; backtick identifiers and `CONCAT` are accepted by SQLite.
2. Q2 — "not been paid yet" = **anti-join**: `orders LEFT JOIN payments WHERE p.payment_id IS NULL` → 517 rows. In this question "paid" means "has any payment row" — `Failed`/`Refunded` rows still count, so they are excluded. `status != 'Paid'` would wrongly return 935 (misses the 517 orders with no row and mislabels refunded as unpaid).
3. Q3 — `LEFT JOIN` + `GROUP BY` keeps parent categories with zero products; join on `p.cat_id`, count `p.prod_id` (16 rows).
4. Q4 — `ROUND(SUM(quantity*unit_price), 2)` removes floating-point artifacts (e.g. `1003865.0299999999` → `1003865.03`); `HAVING total_revenue > 500000` on the alias works (8 rows).
5. Q5 — subquery in `HAVING`: `AVG(o.total_amount) > (SELECT AVG(total_amount) FROM orders)`; overall avg ≈ 2996.32, only Australia/USA/Canada pass (3 rows).

### Mistakes / Notes

- Q3: stray `;` mid-statement split the query (same class of bug as Beginner Q15); wrong join column `p.category_id` → `p.cat_id`.
- Q4: typo `oi.poduct_id` → `oi.product_id`; missing `ROUND(..., 2)` leaked float artifacts in Fitness / Women's Clothing.
- Q5: missing `ORDER BY avg_order_value DESC` (expected output is sorted high→low).

### Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) and re-verify to 20/20.
2. Continue with Intermediate Q6–Q20.

---

## Intermediate Q6–Q8 — Completed & Verified

**Status:** Intermediate Q6–Q8 done; Q8 dialect clarified — real workflow is MySQL, so study the MySQL dialect going forward.

### Completed

- Intermediate Q6–Q8 on `datasets/02-intermediate/ecommerce.db` (MarketHub), each verified against the expected result / reference solutions.

### Key Takeaways

1. Q6 — "customers with an order above the overall AOV" returns **unique customers** (453), not qualifying orders (1,257). Key: `DISTINCT` over *only* customer columns; keep `total_amount` in the `WHERE` filter and out of the `SELECT` (selecting it blocks dedup). "Avg spend per customer > AOV" is a different question (239 rows).
2. Q7 — "still ordered" = the product has a line item: `LEFT JOIN order_items` + `oi.order_id IS NOT NULL` (equivalent to the hint's `EXISTS`). Add `categories` join for `cat_name`; `is_active = 0`; 9 products.
3. Q8 — running total = `SUM(revenue) OVER (ORDER BY month)` applied to a **pre-aggregated CTE** (aggregate first, window second — they don't mix in one pass). The `OVER`'s `ORDER BY` defines an expanding window (first row → current row); it must order by the *full* `YYYY-MM` (or year+month), or the 2025/2026 Januarys collide and the accumulation order is wrong.
4. Dialect — CTEs and window functions work in **both** MySQL 8+ and SQLite 3.25+; only the date functions differ: `YEAR()`/`MONTH()`/`DATE_FORMAT(order_date, '%Y-%m')` (MySQL) vs `strftime('%Y-%m', order_date)` (SQLite). Study the MySQL version since the real workflow is MySQL.

### Mistakes / Notes

- Q6: first attempts selected `order_id`/`total_amount` → 1,257 rows instead of 453 distinct customers.
- Q8: `ORDER BY MONTH(order_date)` (month number only) mixes 2025-01 and 2026-01 → wrong running total; `OVER(MONTH(order_date))` was invalid; missing the plain `revenue` column.

### Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
2. Continue Intermediate Q9–Q20 in **MySQL dialect** on the MySQL copy of the ecommerce dataset.

---

## Intermediate Q9–Q11 — Completed & Verified

**Status:** Intermediate Q9–Q11 done and verified against expected results in `02-intermediate/challenges.md`.

### Completed

- Q9 — Top 2 orders per customer, `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_amount DESC)` + `WHERE rn <= 2` (990 rows).
- Q10 — Price vs category average, `AVG(unit_price) OVER (PARTITION BY cat_id)` + `ROUND(..., 2)` (111 rows).
- Q11 — Revenue by order status via conditional aggregation (1 row).

### Key Takeaways

1. Q9 — ranking via `ROW_NUMBER()` in a CTE, filter `rn <= 2`. The outer `SELECT` must emit the **expected columns** — I first output `customer_name` instead of `rn`. Joining `customers LEFT JOIN orders` works here (every customer has ≥2 orders) but the reference ranks from `orders` alone; a customer with zero orders would leak a spurious `rn=1` NULL row.
2. Q10 — "active product" is a **business filter**: without `WHERE is_active = 1` the query returns 120 rows, expected 111. Window `AVG` emits float artifacts (`488.86800000000005`) → always `ROUND(..., 2)`. Reference sorts `ORDER BY cat_id, unit_price DESC`.
3. Q11 — conditional aggregation = **pivot**: four `SUM(CASE WHEN status = '...' THEN total_amount ELSE 0 END)` columns in one `SELECT`, no `GROUP BY`, single row. Status literal must match exactly — `'Complete'` (typo) silently returned `completed_rev = 0`; correct is `'Completed'`.

### Mistakes / Notes

- Q9: selected `customer_name` instead of `rn` → columns didn't match expected; fixed.
- Q10: no `WHERE is_active = 1` (120 vs 111 rows); no `ROUND` (float artifacts); missing `FROM`/`WHERE` in an early draft → syntax error.
- Q11: `status = 'Complete'` → 0 for `completed_rev`; corrected to `'Completed'`.

### Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
2. Continue Intermediate Q12–Q20 (Q12: order size labels via `CASE WHEN`).

---
