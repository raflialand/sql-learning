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

*Happy Learning!*
