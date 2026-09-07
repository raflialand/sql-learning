# Summary: SQL Analyst Lab Session

**Date:** 6 September 2026
**Track:** Data-to-Insight Case Studies (analyst) — Generated Case 00
**Status:** Case 00 (Bookstore) — Stage 3 complete (PASS-WITH-NOTES). Ready to continue at Stage 4.

---

## Completed

- **Database fix applied** — `data/02-bookstore/bookstore-postgres.sql` created from original `bookstore.sql`. All columns receiving dirty data (`'n/a'`, `'NA'`, `'NULL'`, `'999'`, `'-'`, `'undefined'`, `'MISSING'`, `'missing'`, `'null'`, `'--'`, `'0'`, `'TBD'`) changed to `TEXT` type.
- **Row counts verified** — All 15 tables match between SQLite `bookstore.db` and PostgreSQL (40,348 total rows).
- **Root cause identified** — `reviews.rating` was the last remaining `INTEGER` column with dirty data (315 rows). This was the first INSERT to fail, aborting the entire transaction.
- **Raw schema created** — `data/02-bookstore/bookstore-raw-schema.sql` copies all tables from `public` → `raw` schema as identical backup.
- **Stage 3 Silver cleaning** — `_silver.sql` written (1,101 lines). All 6 DQ dimensions applied (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness). All 15 tables cleaned with sentinel→NULL, type casting, text standardization.
- **Stage 3 verification** — PASS-WITH-NOTES. 3 advisory notes: (1) date regex LOW, (2) '0' sentinel on inventory.quantity MEDIUM, (3) bronze vs silver comparison LOW.

## Files Modified

| File | Change |
|------|--------|
| `data/02-bookstore/bookstore-postgres.sql` | Fixed DDL with TEXT columns for dirty data |
| `data/02-bookstore/bookstore-raw-schema.sql` | New — raw schema copy script |
| `work/00-context.md` | Added Section 7: Database Setup |
| `work/_silver.sql` | New — Stage 3 silver cleaning SQL |
| `verification/stage-3-silver.md` | New — Stage 3 verification report |

## Case 00 Current State

| Stage | Status |
|-------|--------|
| Stage 0 — Context | ✅ Complete |
| Stage 1 — Scope | ✅ Complete |
| Stage 2 — Questions | ✅ Complete (PASS-WITH-NOTES) |
| Stage 3 — Silver | ✅ Complete (PASS-WITH-NOTES) |
| Stage 4 — Gold | ⏳ Ready to start |
| Stage 5 — Queries | ⏸ Pending |
| Stage 6 — Insight | ⏸ Pending |

## Next Steps

1. Load `_silver.sql` into PostgreSQL (requires `bronze` schema — load `bookstore-postgres.sql` into `bronze` schema first, or adjust silver SQL to read from `public`)
2. Continue Case 00 at Stage 4 (Gold mart)
