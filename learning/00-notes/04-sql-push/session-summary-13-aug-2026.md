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

*Happy Learning!*
