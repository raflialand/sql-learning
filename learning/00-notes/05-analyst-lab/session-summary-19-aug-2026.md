# Summary: SQL Analyst Lab Session

**Date:** 19 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3 queries drafted (Postgres) and reviewed vs sub-questions; fix plan agreed but NOT applied

---

## Completed

- Drafted Step 3 SQL queries in `work/03-queries.sql` (PostgreSQL dialect, `TO_CHAR`).
- Reviewed each query against the 12 sub-questions in `work/02-questions.md`.
- Verified two logic bugs against the actual SQLite data (read-only checks) and confirmed the dialect constraint (`TO_CHAR` does not exist in SQLite — verified `no such function: TO_CHAR`).

## Query review verdicts (12 sub-questions)

| # | Verdict | Note |
| --- | --- | --- |
| Q1a | ✅ logic | stray BRW001-only extra query should be removed |
| Q1b | ✅ | `is_active=1` filter harmless (inactive products have no sales) |
| Q1c | ✅ | — |
| Q2a | ❌ bug | `LAG OVER(ORDER BY month)` missing `PARTITION BY store_id` → MoM compares across stores |
| Q2b | ❌ missing | needs AOV + Order count × Store × Month MoM %, on the flagged store |
| Q3a | ✅ | — |
| Q3b | ❌ wrong | query = category revenue (duplicate of Q1b); needs AOV per category |
| Q3c | ⚠️ | `COUNT(order_id)` double-counts → use `COUNT(DISTINCT order_id)` |
| Q4a | ⚠️ | INNER JOIN hides zero-sales products; need LEFT JOIN + COALESCE + decile rule |
| Q4b | ✅ | — |
| Q4c | ✅ | — |
| Q4d | ✅ | — |

## Bug proof (from the data)

- Q2a as-written: BRW002 Jan-2025 shows MoM −6.1% (against BRW001!) when its first month must be `NULL`; BRW001 Feb shows +50.2% instead of true +51.8%.
- Q3c as-written: Beverage order count = 1,397 vs true 861 distinct orders.

## Key Takeaways

1. "Growing/shrinking" (Bucket 2) = MoM % change, not level — a high-revenue store can be shrinking; focus = largest absolute dollar loss (size × change), not lowest revenue and not steepest %.
2. Q4a has two requirements: bottom-decile band (~10% of 31 ≈ 3 products) PLUS an explicit zero-sales flag.
3. Basket context (Q4d) = distinct product count per order (1 → bought alone, >1 → add-on).
4. This project's verified dataset is SQLite; `work/03-queries.sql` is intentionally PostgreSQL (`TO_CHAR`), so it can't be verified with the SQLite helper `run_query.py` — verify in the user's Postgres instance instead.

## Mistakes / Notes

- None (review-only session; no queries executed against the lab DB by the user).

## Next Steps (fix plan — approved but NOT applied yet)

1. Q2a: `LAG(revenue) OVER(PARTITION BY store_id ORDER BY month)`.
2. Q2b: rebuild as AOV + Order count by Store × Month with MoM %; remove the two unrelated queries (order count by store; Merchandise quantity).
3. Q3b: AOV per Category = category revenue ÷ `COUNT(DISTINCT order_id)`.
4. Q3c: `COUNT(oi.order_id)` → `COUNT(DISTINCT oi.order_id)`.
5. Q4a: LEFT JOIN + `COALESCE(SUM(...),0)` to flag zero-sales products; keep bottom-decile (~3 of 31); derive flagged set for Q4b/c/d instead of hardcoding `PRD001/006/015`.
6. Cleanup: remove exploratory `SELECT *` statements; split file so each query is one standalone statement; remove stray BRW001-only query.
7. Verify queries in Postgres against `expected/03-results.md` data (load same retail data).
8. Then Step 4: insights + recommendations, and compare `work/` vs `expected/`.

---

*Happy Learning!*
