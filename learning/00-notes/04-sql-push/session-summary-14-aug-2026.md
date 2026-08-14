# Summary: SQL Skill Push Session

**Date:** 14 Aug 2026
**Track:** SQL Skill Push (sql-push)
**Status:** Advanced Q11–Q15 done and verified against expected results.

---

## Advanced Q11 — Completed & Verified

**Status:** Advanced Q11 solved (MySQL dialect) and verified. First recursive CTE of the module.

### Completed

- Q11 — Continuous month series with zero-ticket months: `WITH RECURSIVE months(month)` seeded `2025-06-01`, stepping `DATE_ADD(month, INTERVAL 1 MONTH)` while `month < '2026-01-01'`, then `LEFT JOIN` the per-month `COUNT(*)` subquery with `COALESCE(t.ticket_count, 0)`. PASS (8 rows: 2025-06 458 → 2025-07 451 → 2025-08 459 → 2025-09 483 → 2025-10 505 → 2025-11 454 → 2025-12 509 → 2026-01 481).

### Examples practiced

```sql
WITH RECURSIVE months(month) AS(
    SELECT '2025-06-01'
    UNION ALL
    SELECT DATE_ADD(month, INTERVAL 1 MONTH)
    FROM months
    WHERE month < '2026-01-01'
)
SELECT
    DATE_FORMAT(m.month, '%Y-%m') AS month,
    COALESCE(t.ticket_count, 0) AS ticket_count
FROM months m
    LEFT JOIN(
        SELECT
            DATE_FORMAT(created_date, '%Y-%m') AS month,
            COUNT(*) AS ticket_count
        FROM tickets
        GROUP BY DATE_FORMAT(created_date, '%Y-%m')
    ) t ON t.month = DATE_FORMAT(m.month, '%Y-%m')
ORDER BY month;
```

### Key Takeaways (recursive CTE concepts, discussed in depth)

1. **`WITH RECURSIVE` = two `SELECT`s joined by `UNION ALL`** — an *anchor* (seed row, no `FROM`, e.g. `SELECT '2025-06-01'`) plus a *recursive step* that reads the CTE's own previous output. Each iteration re-runs the step against the prior rows until `WHERE` yields none.
2. **`RECURSIVE` is a keyword, not a name** — it *permits* the CTE to reference itself. Without it, the self-reference errors (`no such table: months`). Plain `WITH` = named subquery with no self-access.
3. **`date(month, '+1 month')` is SQLite-only syntax** — `date(X, modifier)`; MySQL's `date()` takes one arg, so use `DATE_ADD(month, INTERVAL 1 MONTH)`. The modifier string must be quoted (`'+1 month'`, not `+1 month`). `month` here is the CTE's own column, not a function.
4. **Gap-fill chain (3 parts, all needed):** generate the missing months (`WITH RECURSIVE`) → keep them via `LEFT JOIN` (INNER would drop them) → show missing as `0` via `COALESCE(x, 0)`.
5. **`COALESCE(a, b)` = first non-NULL** — returns `t.ticket_count` if present, else `0`.
6. **`ticket_count` is a derived alias, not a base column** — built with `COUNT(*) AS ticket_count` inside the subquery; `tickets` table has only `ticket_id, sub_id, created_date, resolved_date, category, status`.
7. **ISO date strings sort correctly lexicographically** — `WHERE month < '2026-01-01'` works as string comparison.
8. `DATE_FORMAT(created_date, '%Y-%m')` (MySQL) vs `strftime('%Y-%m', ...)` (SQLite) — recurring dialect note.

### Mistakes / Notes (from my 1st draft)

- `date(month, +1 month)` — unquoted modifier → syntax error; must be `'+1 month'` (or MySQL `DATE_ADD`).
- `WHERE months < '2026-01-01'` — used CTE *name* instead of the *column* `month` → `no such column: months`.
- Dialect mixing: SQLite `date(X, modifier)` combined with MySQL `DATE_FORMAT` — pick one dialect.

---

## Advanced Q12 — Completed & Verified (after 3 attempts)

**Status:** Advanced Q12 solved and verified. Debugged from 3 drafts.

### Completed

- Q12 — Churn rate per region: CTE joining `subscribers s LEFT JOIN churn c ON c.sub_id = s.sub_id`, `COUNT(DISTINCT s.sub_id)` total / `COUNT(DISTINCT c.sub_id)` churned, `GROUP BY s.region`, `ROUND(churned * 100.0 / total_subs, 2)`. PASS (5 rows: West 874/94/10.76 → Northeast 890/91/10.22 → Midwest 887/86/9.70 → Southwest 909/81/8.91 → Southeast 940/75/7.98).

### Key Takeaways

1. **INNER JOIN = filter, LEFT JOIN = attach.** Churn rate needs the *total* denominator, so non-churned subscribers must be kept → `LEFT JOIN churn`. Draft 2 used `JOIN churn` (INNER) → only churned subs survived → every region showed 100%. Same pattern as Q8/Q11: optional detail, attach don't filter.
2. **`COUNT(DISTINCT ...)` = entity count, `COUNT(...)` = row count.** The join creates one row per (subscriber × churn record); a subscriber with 2 churn rows would be counted twice by plain `COUNT`. `COUNT(DISTINCT s.sub_id)` / `COUNT(DISTINCT c.sub_id)` collapse duplicates. In this dataset no subscriber has 2 churn rows, so plain COUNT *happened* to match — but it's fragile. One-to-many joins: use DISTINCT when counting the *one* side.
3. **Integer division trap (3rd occurrence):** `churned * 100 / total_subs` → `10` not `10.76` in SQLite (9400/874 truncates). Use `* 100.0`. MySQL `/` is real division, but `100.0` keeps it portable.
4. CTE + outer SELECT keeps the percentage math readable and reuses the alias (`churned * 100.0 / total_subs`).

### Mistakes / Notes (from my 3 drafts)

- Draft 1: CTE missing `FROM`/`JOIN`/`GROUP BY` → `no such column: s.region`.
- Draft 2: INNER `JOIN churn` → churn rate 100% for every region.
- Draft 3: `churned * 100 / total_subs` integer division → `10.0` instead of `10.76`.

---

## Advanced Q13 — Completed & Verified

**Status:** Advanced Q13 solved and verified. First pivot/crosstab of the module.

### Completed

- Q13 — Ticket status pivot (cross-tabulate category by status): `SUM(CASE WHEN status = '...' THEN 1 ELSE 0 END)` per status + `COUNT(*)`, `GROUP BY category`. PASS (5 rows: Billing 268/241/279/788 → Technical 246/271/264/781 → Network 243/261/260/764 → Account 248/268/243/759 → Device 227/258/223/708).

### Key Takeaways (cross-tabulation concept, discussed)

1. **Crosstab / pivot = turning row values into column headings** — long format (one status per row) → wide format (each status a column). The three values of `status` ('Open','Resolved','Closed') become `open_count`/`resolved_count`/`closed_count`.
2. **Conditional aggregation = the PIVOT technique in MySQL/SQLite** — each `SUM(CASE WHEN status = 'X' THEN 1 ELSE 0 END)` is a filtered counter; three side-by-side collapse 5×3 long rows into 5 wide rows.
3. **Status literals must match the data exactly** — `'Open'`, `'Resolved'`, `'Closed'` (verified). Same bug class as Intermediate Q11 (`'Complete'` vs `'Completed'`): a typo silently returns 0.

### Examples practiced

```sql
SELECT
    category,
    SUM(CASE WHEN status = 'Open'     THEN 1 ELSE 0 END) AS open_count,
    SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) AS resolved_count,
    SUM(CASE WHEN status = 'Closed'   THEN 1 ELSE 0 END) AS closed_count,
    COUNT(*) AS total
FROM tickets
GROUP BY category
ORDER BY total DESC;
```

---

## Advanced Q14 — Completed & Verified

**Status:** Advanced Q14 solved and verified (set intersection).

### Completed

- Q14 — Churned AND still unpaid/overdue: `WHERE sub_id IN (SELECT sub_id FROM churn) AND sub_id IN (SELECT sub_id FROM billing WHERE status IN ('Unpaid','Overdue'))`. PASS (38 rows: 395 Cynthia Robinson → 1218 Frank Clark …).

### Key Takeaways

1. **"X AND Y" = set intersection.** `IN + IN` is logically equivalent to the hint's `INTERSECT` — both return 38 rows here. Same family as Q8's "X but NOT Y" (difference, `IN + NOT IN`).
2. `billing` statuses are `Paid / Unpaid / Overdue` (verified) — filter matched the data exactly.

---

## Advanced Q15 — Completed & Verified

**Status:** Advanced Q15 solved and verified. Simple aggregate, no joins.

### Completed

- Q15 — First/last payment + payment count per subscriber: `GROUP BY sub_id` with `MIN(pay_date)`, `MAX(pay_date)`, `COUNT(*)`. PASS (4,071 rows: 2 → 2025-12-23/2026-01-16/2 …).

### Key Takeaways

1. `MIN`/`MAX` on a date column = first/last — no window function needed for this "per group" summary; plain aggregate with `GROUP BY`.
2. `payments` already carries `sub_id` — no join required.

---

## Next Steps

1. Continue Advanced **Q16** (billed but never paid — set difference with `EXCEPT`/`NOT IN`).
2. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.

---

## Advanced Q16 — Completed & Verified (anti-join)

**Status:** Advanced Q16 solved and verified. Anti-join — the module's set-difference family continued from Q8/Q14.

### Completed
- Q16 — Billed but never paid: `JOIN billing` (the "billed" filter) + `NOT EXISTS (SELECT 1 FROM payments p WHERE p.sub_id = s.sub_id)` (the "never paid" exclusion), `COUNT(b.bill_id) AS bills_issued`, `GROUP BY` subscriber cols. PASS (**216 rows**: David Flores 79 → …).

### Key Takeaways
1. **Anti-join = rows with no match in another table = set difference (A − B).** The three equivalent forms: `NOT EXISTS` (safest — handles NULLs, stops at first match, usually fastest), `NOT IN` (breaks if the subquery returns a NULL — only safe on NOT NULL columns), `LEFT JOIN ... IS NULL` (visual, but duplicates need `DISTINCT`).
2. **Q16 chains two requirements:** `JOIN billing` is an inner-join *filter*; `NOT EXISTS` is the anti-join *exclusion*. Both needed.
3. `bills_issued` counts **bills** (`b.bill_id`), not payments — these subscribers have zero payments by definition.

### Mistakes / Notes
- Draft: `COUNT(p.pay_id)` — `p` undefined in outer scope (and semantically 0); `p.sub_id` referenced while `FROM payments` had no alias (same class as Beginner Q14); column `bill_issued` vs expected `bills_issued`.
- Also wrote the `NOT IN` variant — valid here since `payments.sub_id` is non-NULL.

---

## Advanced Q17 — Completed & Verified (window ratio via CTE chain)

**Status:** Advanced Q17 solved and verified.

### Completed
- Q17 — Share of region data usage: two-CTE chain — `sub_data_logs` (per-sub `SUM(ul.data_mb)`), then `region_logs` (`SUM(sub_data)` per region from the first CTE), outer `JOIN` computes `ROUND(sub_data * 100.0 / region_data, 2)`, `ORDER BY pct_of_region DESC`. PASS (**3,709 rows**: 1298 West 58862/21002724 → 0.28).

### Key Takeaways
1. **Second CTE reads from the first CTE** (`SUM(sub_data) FROM sub_data_logs`), not base tables — the whole "per-region total" flows through the chain.
2. `* 100.0` keeps the division real (3rd recurrence of the integer-division trap).
3. `ROUND(..., 2)` for clean percentages; `ORDER BY ... DESC` to match expected high→low.

### Mistakes / Notes
- Stray `;` after the first CTE terminated the statement (same class as Beginner Q15); `JOIN region logs` missing underscore → syntax error; missing `ROUND`; `ORDER BY` missing `DESC`.

---

## Advanced Q18 — Completed & Verified (over plan allowance)

**Status:** Advanced Q18 solved and verified.

### Completed
- Q18 — Over plan allowance: `subscribers → plans → usage_logs`, `SUM(ul.data_mb)`, `ROUND(SUM/1024.0, 2) AS total_data_gb`, `GROUP BY` non-aggregates, `HAVING SUM(ul.data_mb) > plan_data_gb * 1024.0`, `ORDER BY total_data_gb DESC`. PASS (**2,177 rows**: Deborah Rodriguez 1575 → 59711 MB / 58.31 GB).

### Key Takeaways
1. **`HAVING` filters after aggregation** — `WHERE` can't see `SUM()`. New clause in the toolchain.
2. **Units must match on both sides of a comparison** — data is MB, plan is GB → convert with `* 1024`. 1 GB = 1024 MB (also `/ 1024.0`, not `/ 1000`).
3. Aliases in `GROUP BY`/`HAVING` work in MySQL/SQLite; reference repeats the real column for strict-mode portability.

### Mistakes / Notes
- Draft: no `GROUP BY` (single-row/error); no `HAVING` (returned all 3,709); `/1000` → 59.71 instead of 58.31; `HAVING SUM > plan_data_gb` compared MB vs GB directly.

---

## Next Steps

1. Continue Advanced **Q19** (ticket resolution days — datediff/CASE on `tickets`).
2. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.

---

## Advanced Q19 — Completed & Verified

**Status:** Advanced Q19 solved and verified (date diff on `tickets`). Second session of the day.

### Completed

- Q19 — Ticket handling time (days per resolved ticket): `DATEDIFF(resolved_date, created_date)` (MySQL), `WHERE resolved_date IS NOT NULL`, `CAST(... AS DECIMAL(10,2))` to match the `62.00` format, `ORDER BY handling_days DESC`. PASS (2,651 rows: 215 → 62.00 …).

### Key Takeaways

1. **Gap between two dates** = `DATEDIFF(resolved_date, created_date)` (MySQL, end − start, integer) / `julianday(resolved_date) - julianday(created_date)` (SQLite, includes fractional). The question is exactly the resolved_date − created_date gap.
2. **Filter first:** `tickets` has 3,800 rows but only 2,651 resolved — without `WHERE resolved_date IS NOT NULL` you return 3,800 rows with NULL handling_days. "Each resolved ticket" = the filter.
3. **`DECIMAL(10,2)`** = 10 total digits, 2 after the decimal → fixed-point exact arithmetic, displays `62.00` (not float). Converts `DATEDIFF`'s integer `62` into the expected format.
4. **ORDER BY matters for verification:** expected sample lists 62.00 first → order by `handling_days DESC`, not `ticket_id`.
5. **Argument order:** `DATEDIFF(date1, date2)` = date1 − date2, so resolved first, created second.

### Mistakes / Notes

- Draft 1: missing `WHERE resolved_date IS NOT NULL` → 3,800 rows vs expected 2,651.
- Draft 1: `ORDER BY ticket_id` → sample order wrong (expected high→low by days).
- Draft 1: bare `DATEDIFF` → integer `62`, not `62.00`.
- `DECIMAL (10,2)` with a space before `(` works but is non-standard — write `DECIMAL(10,2)`.

---

## Advanced Q20 — Completed & Verified · Advanced Level Complete 🎉

**Status:** Advanced Q20 solved and verified. Advanced Q1–Q20 ALL done → Advanced level complete.

### Completed

- Q20 — Signup cohort retention: cohort label `CONCAT(YEAR(signup_date), '-Q', QUARTER(signup_date))`, `GROUP BY cohort`, `COUNT(*)` total vs `SUM(CASE WHEN status='Active' THEN 1 ELSE 0 END)` still_active, `ROUND(... * 100.0 / COUNT(*), 2)` active_pct. PASS (19 rows: 2021-Q1 247/197/79.76 → 2023-Q2 250/220/88.00).

### Key Takeaways

1. **Cohort** = a group sharing a defining event in the same period (signup quarter). **Retention** = % of that cohort still active today (`still_active / total_subs`). Comparing raw numbers across cohorts is unfair (older cohorts had more time to churn) — percentages level the field.
2. **MySQL quarter label is easy:** `QUARTER(date)` returns 1–4, `YEAR(date)` the year → `CONCAT(YEAR(signup_date), '-Q', QUARTER(signup_date))` = `2021-Q1`. SQLite has no `QUARTER()`, so the reference builds it via `strftime('%Y-Q' || ((month+2)/3))` — same output, both 19 rows.
3. Conditional aggregation (`SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END)`) for "count where condition" — same pivot pattern as Q13 / Intermediate Q20.
4. `* 100.0` avoids integer division (4th recurrence of the trap).
5. **CTE column vs CTE name** can share the name (`cohort`) legally — different namespaces.

### Mistakes / Notes

- Draft 1: `COUNT(*) AS total)subs` — `)` typo → must be `total_subs`.
- Draft 1 was otherwise correct (label, conditional agg, 100.0, GROUP BY/ORDER BY cohort).

---

## Beginner Fixes — Completed & Verified (20/20)

**Status:** Beginner Q1–Q20 ALL pass. Fixed the remaining 4 queries in `my-solutions.sql` and re-verified against `retail.db`.

### Completed

- Q3 — `YEAR(signup_date)` → `WHERE signup_date BETWEEN '2025-01-01' AND '2025-12-31'` (portable, no dialect function).
- Q14 — `unit_price` → `oi.unit_price` (resolves the ambiguity between `order_items.unit_price` and `products.unit_price`).
- Q18 — `MONTH()/YEAR()` → `strftime('%Y-%m', order_date)` + `BETWEEN` for 2025.
- Q19 — `YEAR()/MONTH()` → `strftime('%Y-%m', order_date)`; `ORDER BY avg_order_value DESC` (global sort guarantees the global highest month surfaces first).
- Q1 (`is_active`) and Q15 (stray `;`) were already fixed in the file; confirmed passing.

### Key Takeaways

1. The only remaining Beginner failures were the MySQL-only `YEAR()`/`MONTH()` date functions (Q3/Q18/Q19) plus the ambiguous unqualified column (Q14) — all localized, mechanical fixes.
2. `strftime('%Y-%m', date)` (SQLite) / `DATE_FORMAT(date, '%Y-%m')` (MySQL) — recurring dialect note.
3. Qualify columns with the table alias when a JOIN shares column names.

## Session Stats (14 Aug 2026)

- Completed: **Advanced Q11–Q20** (10 challenges) + **Beginner fixes Q1/Q3/Q14/Q15/Q18/Q19** → **Beginner 20/20**
- Intermediate: 20/20 complete · Advanced: 20/20 complete · Beginner: 20/20 complete → **module complete 60/60** 🎉

## Next Steps

1. Full module recap / next module planning (60/60 done).

---

*Happy Learning!*
