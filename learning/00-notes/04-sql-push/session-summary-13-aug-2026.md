# Summary: SQL Skill Push Session

**Date:** 13 Aug 2026
**Track:** SQL Skill Push (sql-push)
**Status:** Advanced Q2 done — saved to `my-solutions.sql`. Advanced Q3–Q20 pending.

---

## Advanced Q2 — Completed (LAG month-over-month)

**Status:** Advanced Q2 solved with LAG; query saved in `03-advanced/solutions/my-solutions.sql`.

### Completed

- Q2 — Month-over-month revenue change: CTE computing `ROUND(SUM(amount), 2)` per `bill_date`, then `ROUND(LAG(SUM(amount), 1) OVER (ORDER BY bill_date), 2)` for the previous month, outer `SELECT` subtracts to get `change`. PASS (2 rows: 2025-12-01 → NULL / 2026-01-01 → -27550.00).

### Examples practiced

```sql
WITH revenue_and_prev_revenue AS (
    SELECT
        bill_date,
        ROUND(SUM(amount), 2) AS revenue,
        ROUND(LAG(SUM(amount), 1) OVER (ORDER BY bill_date), 2) AS prev_month_revenue
    FROM billing
    GROUP BY bill_date
)
SELECT
    bill_date,
    revenue,
    prev_month_revenue,
    revenue - prev_month_revenue AS change
FROM revenue_and_prev_revenue;
```

### Key Takeaways

1. **`LAG(col, offset, default)`** reads a *previous row*'s value into a new column without changing the current row — Feb keeps its own value; LAG copies January into a separate column. Offset = how many rows back (1 = previous row), not "which value".
2. **`LAG()` is a window function → REQUIRES `OVER (...)`** and runs *after* `WHERE`/`GROUP BY`, so `LAG(SUM(amount))` can read the aggregated result. Aliases defined in the same SELECT are NOT visible inside the window — use the raw expression `LAG(SUM(amount), 1)`.
3. **`PARTITION BY` resets the window per group** — `OVER (PARTITION BY bill_date ...)` would give 1 row per partition → LAG always NULL. Only partition when comparing *within* a group (e.g. per plan).
4. **Scattered dates:** if bill dates vary across the month, truncate to month first — `DATE_FORMAT(bill_date, '%Y-%m')` (MySQL) / `strftime('%Y-%m', ...)` (SQLite), `GROUP BY` the truncated expression, `OVER (ORDER BY 'YYYY-MM')`. Never order by `MONTH()` alone (cross-year collision). Aggregate first, window second.
5. **Outer SELECT CAN reuse CTE aliases** (`revenue - prev_month_revenue`) — legal outside the CTE, unlike aliases used inside the same SELECT where they're defined.

### Mistakes / Notes

- Missing `OVER` clause → syntax error (LAG requires it).
- `LAG(revenue)` using the SELECT alias → not visible inside the window.
- Trailing comma after `prev_month_revenue` → syntax error.
- Typo `prev_mont_revenue` → unknown column.
- Parenthesis mismatch `ROUND(LAG(revenue), 1) OVER(...), 2)` → malformed; correct nesting `ROUND( LAG( SUM(amount), 1 ) OVER (ORDER BY bill_date), 2 )`.
- `DATE_FORMAT(bill_date, '%Y-%m')` outputs `2025-12`; expected column was `2025-12-01` — use `'%Y-%m-01'` if truncating while keeping the date format.

## Next Steps

1. Continue Advanced **Q3** (running total of revenue with a cumulative window).
2. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.

---

## Advanced Q3–Q5 — Completed & Verified

**Status:** Advanced Q3, Q4, Q5 done and verified against expected results.

### Completed

- Q3 — Running (cumulative) total of revenue per billing month: CTE aggregating `ROUND(SUM(amount), 2)` per `bill_date`, then `SUM(revenue) OVER (ORDER BY bill_date)`. PASS (2 rows: 203420.00 → 379290.00).
- Q4 — Top 10 data users by total data usage: `RANK() OVER (ORDER BY SUM(data_mb) DESC)` in a CTE + `WHERE usage_rank <= 10` outside. PASS (10 rows: Deborah Rodriguez 59711 rank 1).
- Q5 — Usage quartiles: `NTILE(4) OVER (ORDER BY SUM(data_mb))`. PASS (3,709 rows; buckets 928/927/927/927).

### Key Takeaways

1. **Running total = window `SUM` with an expanding frame** — `SUM(x) OVER (ORDER BY d)` sums "first row → current row" (default `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`); the `ORDER BY` inside `OVER` creates the accumulation. Without it, every row repeats the grand total.
2. **Top-N-with-rank pattern:** aggregate → `RANK()` (or `NTILE`) in a CTE/subquery → filter the rank *outside*. Window aliases are invisible to `WHERE`, and clause order is SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT. `LIMIT 10` returns rows without a rank *number* and is fragile at ties.
3. **`RANK()` vs `ROW_NUMBER()` vs `DENSE_RANK()`** — on ties: gaps (1,1,3) vs arbitrary (1,2) vs no gaps (1,1,2).
4. **`NTILE(n)` = bucketize into n equal-count groups** — `ORDER BY` ascending → bucket 1 = smallest values, bucket n = largest. Statistician's quartile = value boundary; `NTILE` = equal count.
5. **`PARTITION BY`** (preview for Q6) resets a window per group.

### Mistakes / Notes

- Q4 attempt 1: `ORDER BY ... LIMIT 10` only → rows correct but no `usage_rank` column (the rank number was the requirement).
- Q4 attempt 3: `WHERE usage_rank <= 10` placed after `ORDER BY` → syntax error; window aliases can't be used in `WHERE` (subquery/CTE required).
- Q4/Q5: `ROUND(..., 2)` on integer `SUM()` adds float display (`59711.0` vs `59711`); `data_mb` is integer, so plain `SUM()` is cleaner.
- Q5: typo `NITILE` → `NTILE`; missing commas between SELECT columns; `OVER(SUM(...))` missing `ORDER BY` → invalid window.
- Q5: `ORDER BY usage_quartile` alone left within-bucket order undefined → add `, total_data_mb`.

## Next Steps

1. Continue Advanced **Q6** (median usage per region — `ROW_NUMBER() OVER (PARTITION BY region ORDER BY total)`, pick the middle row).
2. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.

---

## Advanced Q6 — Completed & Verified

**Status:** Advanced Q6 done and verified against expected results.

### Completed

- Q6 — Median total data usage per region: CTE computing per-subscriber total usage (`SUM(data_mb)` per `sub_id`/`region`), then `ROW_NUMBER() OVER (PARTITION BY s.region ORDER BY SUM(ul.data_mb))` + `COUNT(*) OVER (PARTITION BY s.region)`, outer `WHERE rn IN (FLOOR((n + 1) / 2), FLOOR((n + 2) / 2))` + `AVG(total_data_mb)`. PASS (5 rows: Southwest 30548.00 → West 29636.00).

### Examples practiced

```sql
WITH ranked AS(
    SELECT s.region, SUM(ul.data_mb) AS total_data_mb,
        ROW_NUMBER() OVER(PARTITION BY s.region ORDER BY SUM(ul.data_mb)) AS rn,
        COUNT(*) OVER(PARTITION BY s.region) AS n
    FROM subscribers s
        JOIN usage_logs ul ON ul.sub_id = s.sub_id
    GROUP BY s.region, s.sub_id
)
SELECT region, ROUND(AVG(total_data_mb), 0) AS median_data_mb
FROM ranked
WHERE rn IN (FLOOR((n + 1) / 2), FLOOR((n + 2) / 2))
GROUP BY region
ORDER BY median_data_mb DESC;
```

### Key Takeaways

1. **No built-in `MEDIAN`** in SQLite/MySQL — compute it: rank rows within the group (`ROW_NUMBER`), count them (`COUNT(*) OVER`), keep only the middle row(s), `AVG` them.
2. **Median position formula** — `FLOOR((n + 1) / 2)` and `FLOOR((n + 2) / 2)`: odd `n` → both collapse to the same single middle row; even `n` → the two middle rows, averaged = true median.
3. **`FLOOR` is for MySQL portability** — SQLite `/` already integer-divides; MySQL `/` returns decimals (445.5) that match no integer `rn`. `FLOOR` (or `DIV`) makes it work on both.
4. Aggregate first, window second — same pattern as Q3–Q5.

### Mistakes / Notes

- Q6 first draft: `s.region AS,` → `AS` with no alias = syntax error.
- `(n + 1) / 2` without `FLOOR` would silently drop the lower middle row on even-count regions in MySQL (Northeast 890, Southeast 940, West 874).

## Next Steps

1. Continue Advanced **Q7** (above plan-average usage — correlated subquery recomputing the plan average per subscriber row).
2. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.

---

## Advanced Q7 — Completed & Verified

**Status:** Advanced Q7 done and verified against expected results.

### Completed

- Q7 — Above plan-average usage: two CTEs — per-subscriber total (`SUM(ul.data_mb)` per `sub_id`), then per-plan average of those totals (`AVG(total_data_mb) GROUP BY plan_name`), outer join computes `total_data_mb - plan_avg_usage`. PASS (3,709 rows: Joshua King Starter 38620/29684/8936 → Stephanie Green Plus 42288/30208/12080).

### Examples practiced

```sql
WITH total_data AS(
    SELECT s.sub_id, s.first_name, s.last_name, p.plan_name,
        ROUND(SUM(ul.data_mb), 0) AS total_data_mb
    FROM subscribers s
        JOIN plans p       ON p.plan_id = s.plan_id
        JOIN usage_logs ul ON ul.sub_id = s.sub_id
    GROUP BY s.sub_id, s.first_name, s.last_name, p.plan_name
), avg_data_plan AS(
    SELECT plan_name, ROUND(AVG(total_data_mb), 0) AS plan_avg_usage
    FROM total_data
    GROUP BY plan_name
)
SELECT td.sub_id, td.first_name, td.last_name, td.plan_name,
       td.total_data_mb, adp.plan_avg_usage,
       td.total_data_mb - adp.plan_avg_usage AS diff_from_plan_avg
FROM total_data td
    JOIN avg_data_plan adp ON adp.plan_name = td.plan_name
ORDER BY td.sub_id;
```

### Key Takeaways

1. **`plan_avg_usage` = average of per-subscriber totals, not raw log rows.** The subquery must `GROUP BY sub_id` *before* `AVG`, else you average each usage-log row (subscribers with many logs skew the result).
2. Question asked for a **correlated subquery**; the two-CTE version is logically equivalent and cleaner (same output). Reference re-computes the plan average per row via `WHERE s2.plan_id = s.plan_id`.
3. `ROUND(..., 0)` on `total_data_mb` and `plan_avg_usage` to match expected whole values; `ORDER BY sub_id` for expected order.
4. `INNER JOIN usage_logs` drops subscribers with no usage (3,709 ≠ 4,500) — matches expected.

### Mistakes / Notes

- Q7 first drafts: typos `tota_data_mb` / `tota_data` → `total_data_mb` / `total_data` (no such column / table).
- `ROUND(AVG(...), 2)` → expected `0` decimals.

## Advanced Q8 — Completed & Verified

**Status:** Advanced Q8 done and verified against expected results.

### Completed

- Q8 — Tickets but never churned (set difference): `WHERE sub_id IN (SELECT sub_id FROM tickets) AND sub_id NOT IN (SELECT sub_id FROM churn)`. PASS (2,304 rows: Joshua King 555-517626 → John Taylor 555-661254).

### Key Takeaways

1. **"X but never Y" = anti-join** — Y belongs in `NOT IN` / `LEFT JOIN ... IS NULL` / `EXCEPT`, never an INNER JOIN.
2. `IN` needs a subquery `(SELECT sub_id FROM tickets)`, not a bare column.

### Mistakes / Notes

- Q8 first attempt: `s.sub_id IN t.sub_id` → syntax error (`IN` with a column, not a subquery).
- Q8 first attempt: `JOIN churn` INNER JOIN kept only churned subscribers, then `NOT IN churn` → 0 rows. Churn check must be an exclusion.

## Advanced Q9 — Completed & Verified

**Status:** Advanced Q9 done and verified against expected results.

### Completed

- Q9 — Next payment (gap spotting): `LEAD(pay_date) / LEAD(amount) OVER (PARTITION BY sub_id ORDER BY pay_date)`. PASS (6,588 rows: 2 → 2025-12-23 20 → 2026-01-16 20; NULL on last payment).

### Key Takeaways

1. **`LEAD` reads the next row** — same `PARTITION BY ... ORDER BY` on both date and amount calls. `NULL` on the last row = no next payment (the gap spotter).
2. `payments` already has `sub_id` — no JOIN needed.
3. `ORDER BY sub_id, pay_date` for expected grouping.

### Mistakes / Notes

- Q9 first attempt: `ORDER BY p.pay_date` sorted by date, expected table grouped by subscriber.
- Q9 attempt with stray `;` after `FROM payments;` → terminated the statement, `ORDER BY` became invalid (same class as Beginner Q15).

## Advanced Q10 — Completed & Verified

**Status:** Advanced Q10 done and verified against expected results.

### Completed

- Q10 — Monthly ticket volume with 3-month moving average: CTE aggregating `COUNT(*)` per `YYYY-MM`, then `ROUND(AVG(ticket_count) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)`. PASS (8 rows: 2025-06 458/458.00 → 2026-01 481/481.33).

### Key Takeaways

1. **3-month moving average = window frame** `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` (current + 2 before). First months average what exists (458.00 = June alone; 454.50 = July+June) — expected table shows partial averages, frame handles it.
2. Aggregate first (CTE), window second — same as Q3–Q5 pattern.

### Mistakes / Notes

- Q10: MySQL `DATE_FORMAT(created_date, '%Y-%m')` vs SQLite `strftime('%Y-%m', created_date)` on the verification DB (recurring dialect note).

## Next Steps

1. Continue Advanced **Q11** (continuous month series — `WITH RECURSIVE` seeded 2025-06 → 2026-01, `LEFT JOIN` counts to include zero-ticket months).
2. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.

---

*Happy Learning!*
