# Summary: SQL Analyst Lab Session

**Date:** 20 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3: Q3b & Q3c corrected + verified against expected results; Q1b filter bug found; Q4a next

---

## Completed

- **Q3b (AOV · Category) corrected:** revised to AOV per category = category revenue ÷ `COUNT(DISTINCT order_id)` (previous draft divided by `SUM(quantity)` = revenue per *item*, not per order).
- **Q3c (Order count · Category) corrected:** `COUNT(oi.order_id)` → `COUNT(DISTINCT oi.order_id)` (double-count fix).
- **Verified both against `retail.db`** (read-only) and they reproduce the model's expected Q3 exactly:

| category | order_count | revenue | AOV |
| --- | --- | --- | --- |
| Merchandise | 737 | 42,145.00 | 57.18 |
| Food | 738 | 13,341.50 | 18.08 |
| Beverage | 861 | 14,747.60 | 17.13 |

- Confirmed Q2a already carries `PARTITION BY store_id` in `work/03-queries.sql`.
- Wrote the corrected Q3b/Q3c into `work/03-queries.sql` (self-applied).

## Key Takeaways

1. **AOV is per ORDER, never per item.** The denominator is `COUNT(DISTINCT order_id)`; `SUM(quantity)` gives average unit price, not basket strength. (Repeat of the "units must match" pattern — #11, #16.)
2. **New dataset finding — `is_active` is NOT harmless.** PRD030 (Seasonal Pumpkin Latte) and PRD031 (Limited Holiday Blend) are `is_active=0` but DO have sales: 236 `order_items` rows across 215 distinct orders (PRD030: 220 units / $1,210.00; PRD031: 244 units / $3,904.00). The expected `03-results.md` note claiming they have "0 units" is wrong for this database.
3. **Therefore Q1b is still wrong.** It filters `WHERE p.is_active = 1`, undercounting Beverage revenue to $9,633.60 instead of the true $14,747.60 (861 → 768 orders). The filter must be removed to match the true category revenue split.
4. **Verify dataset quirks against data, never assume.** The 19-Aug review verdict "is_active=1 harmless (inactive products have no sales)" was assumption-based and is now disproven by the data.
5. Filtering for `is_active` may be intentional for a *sales/performance* question (only sellable items), but it changes the answer — decide deliberately and document it, don't leave it as an invisible filter.

## Mistakes / Notes

- **#17 — Q3b denominator = `SUM(oi.quantity)`:** computed revenue-per-item, labeled it AOV. Root cause: definition slip while rebuilding the query. Fix: revenue ÷ `COUNT(DISTINCT order_id)`.
- **#18 — assumed `is_active=1` filter harmless** (carried over from the 19-Aug review) without re-checking the data. Root cause: trusted an earlier assumption instead of the dataset. Fix: prove filter impact on the DB first.

## Next Steps

1. Q1b: remove `WHERE p.is_active = 1` (verify Beverage returns to 861 / $14,747.60).
2. Q4a: LEFT JOIN + `COALESCE(SUM(...),0)` to flag true zero-sales products (do NOT assume inactive = zero-sales); derive bottom-decile (~3 of 31) from the query.
3. Q4b/c/d: derive the flagged set from Q4a output instead of hardcoding `PRD001/006/015`.
4. Cleanup: remove stray BRW001-only query (Q1a), remove exploratory `SELECT *` statements, split file into one statement per query for the SQLite helper.
5. Verify in Postgres against `expected/03-results.md`; then Step 4 insights + recommendations; compare `work/` vs `expected/`.

---

*Happy Learning!*
