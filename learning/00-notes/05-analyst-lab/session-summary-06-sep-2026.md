# Summary: SQL Analyst Lab Session

**Date:** 6 September 2026
**Track:** Data-to-Insight Case Studies (analyst) — Generated Case 00
**Status:** Case 00 (Bookstore) — Stage 0-2 complete. Database fix applied. Ready to continue at Stage 3.

---

## Completed

- **Database fix applied** — `data/02-bookstore/bookstore-postgres.sql` created from original `bookstore.sql`. All columns receiving dirty data (`'n/a'`, `'NA'`, `'NULL'`, `'999'`, `'-'`, `'undefined'`, `'MISSING'`, `'missing'`, `'null'`, `'--'`, `'0'`, `'TBD'`) changed to `TEXT` type.
- **Row counts verified** — All 15 tables match between SQLite `bookstore.db` and PostgreSQL (40,348 total rows).
- **Root cause identified** — `reviews.rating` was the last remaining `INTEGER` column with dirty data (315 rows). This was the first INSERT to fail, aborting the entire transaction.
- **Context file updated** — `00-context.md` now includes database setup notes and PostgreSQL connection info.

## Files Modified

| File | Change |
|------|--------|
| `data/02-bookstore/bookstore-postgres.sql` | New file — fixed DDL with TEXT columns for dirty data |
| `learning/04-data-to-insight/generated-case/00-bookstore-omnichannel-sales-performance/work/00-context.md` | Added Section 7: Database Setup |

## Case 00 Current State

| Stage | Status |
|-------|--------|
| Stage 0 — Context | ✅ Complete |
| Stage 1 — Scope | ✅ Complete |
| Stage 2 — Questions | ✅ Complete (PASS-WITH-NOTES) |
| Stage 3 — Silver | ⏳ Ready to start |
| Stage 4 — Gold | ⏸ Pending |
| Stage 5 — Queries | ⏸ Pending |
| Stage 6 — Insight | ⏸ Pending |

## Next Steps

1. Load `bookstore-postgres.sql` into PostgreSQL
2. Continue Case 00 at Stage 3 (Silver cleaning)
