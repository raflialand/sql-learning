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
