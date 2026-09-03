# SQL Analyst Lab — Progress Notes

Per-session progress notes for the **analyst** track (Data-to-Insight Case Studies module at `learning/02-sql-learning/sql-analyst-lab/`).

## How to use

After each practice session, add a note named `session-summary-<DD-MMM-YYYY>.md` following the format below.

## Template

```markdown
# Summary: SQL Analyst Lab Session

**Date:** <DD Month YYYY>
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case <N> — <phase, e.g. started / completed>

---

## Completed

- Case <N> (<business, e.g. Brew & Co.>): <one-line description of scope/questions/queries covered>

## Key Takeaways

1. ...
2. ...

## Mistakes / Notes

- ...

## Next Steps

1. Case <N+1> (<business>)
```

## Progress snapshot

_Update this table as you go._

| Case | Total | Completed | Notes |
| --- | --- | --- | --- |
| 01 Brew & Co. | 1 | 1 | ✅ COMPLETE (26-aug) — Steps 1–3 + Step 4 (Running Log Buckets 1–4, 5 components, insight paragraph, 4 recommendations, self-check). `work/04-insight.txt` finalized with sections A–E. Postgres verify optional |
| 02 MarketHub | 1 | 1 | ✅ COMPLETE (28-aug) — via `data-to-insight` ecosystem. Stage 0–6 done & approved: Silver `_silver.sql`, Gold `gold.mart_markethub` (line-grain, 7,102 rows), `03-results.md` (13/13), `04-insight.md` (5 components + 4 recommendations; rank error fixed) |
| 03 NovaTel | 1 | 1 | ✅ COMPLETE (02-sep) — via `data-to-insight` ecosystem. Stage 0–6 done & verified: Silver `_silver.sql`, Gold `gold.mart_subscriber_health` (7,996 rows), `03-results.md` (12/12, Q9/Q11 grain fix), `04-insight.md` (5 components + 4 recommendations). Verification PASS-WITH-NOTES. Track 3/3 complete. |

## Mistake Log (cumulative across sessions)

_Append new mistakes here after each session (newest on top). The detailed table lives in the session summary; this is the running list so it carries forward._

| # | Date | Mistake | Root cause | Lesson / Fix |
| --- | --- | --- | --- | --- |
| 23 | 27-Aug | Gold mart omitted `product_id`/`product_name` | Rolled category to top-level only; forgot product is Q9's leaf drill (not a scope dimension) | Trace every mart column to every sub-question before authoring queries |
| 22 | 26-Aug | Q4d mart query counted line items not distinct orders | Forgot mart is line-grain (3,647 rows / 1,200 orders); `SUM(CASE WHEN alone_flag...)` counts rows | Basket-level metric = `COUNT(DISTINCT order_id)`; check grain before aggregating |
| 21 | 20-Aug | Q4d `SUM(CASE...)` counted receipt lines | Product appears twice in one order → double-count | `COUNT(DISTINCT CASE WHEN ... THEN order_id END)` |
| 20 | 20-Aug | Q4b hardcoded `IN ('PRD001','PRD006','PRD015')` | Repeat of #10 — typed the derived set | `underperform` CTE = Q4a flagged set; outer JOIN |
| 19 | 20-Aug | Q4b windows over filtered rows | `WHERE` runs before windows → avg 3.10 vs true 5.25 | Compute windows on the full table, filter after (**windows before WHERE**) |
| 18 | 20-Aug | Assumed `is_active=1` filter harmless | Trusted earlier review, not the data | Verify filter impact on the DB; PRD030/031 DO have sales (236 rows / 215 orders) |
| 17 | 20-Aug | Q3b denominator = `SUM(quantity)` | Definition slip | AOV = revenue ÷ `COUNT(DISTINCT order_id)`, never ÷ items |
| 16 | 19-Aug | `* 100.0` after `/` → all `0.00` | Integer division runs first | `* 100.0` **before** `/` for integers, or cast to numeric |
| 15 | 19-Aug | `count_diff` as absolute orders | Units don't match | Both levers must be **% (MoM)** to compare |
| 14 | 19-Aug | `SELECT *` + `ROUND(...)` without comma | `*` ends the select list | `SELECT *, ROUND(...)` or explicit columns |
| 13 | 19-Aug | Q3c `COUNT(order_id)` double-counts | Multi-line orders count 3× | `COUNT(DISTINCT order_id)` |
| 12 | 19-Aug | Q4a INNER JOIN hides zero-sales products | No `order_items` rows → dropped | LEFT JOIN + `COALESCE(SUM(...),0)` |
| 11 | 19-Aug | Q3b answered category revenue (= Q1b dup) | Missed performance lens | AOV per category = revenue ÷ distinct orders |
| 10 | 19-Aug | Hardcoded `PRD001/006/015` | Typed the flagged set | Derive from Q4a output |
| 9 | 19-Aug | Q2a LAG without `PARTITION BY store_id` | MoM across stores | `OVER(PARTITION BY store_id ORDER BY month)` |
| 8 | 19-Aug | Q2b = total order count by store | Wrong scope for Growth Rates | AOV + count × Month MoM, on flagged store |
| 7 | 19-Aug | Q2b had a Merchandise-quantity query | Unrelated exploration | Remove |
| 6 | 18-Aug | "lowest AOV + highest orders" drafted | Duplicated Bucket 3 contest | That's a contest (B3), not a "why" (B4) |
| 5 | 18-Aug | Q3 = Revenue split (verbatim B1) | Forgot performance lens | Rebuild around AOV / Order count |
| 4 | 18-Aug | Order-count MoM + Revenue MoM (same dims) | Redundant | One headline (Revenue) + one driver (AOV/Count) |
| 3 | 18-Aug | "Month over month" in Trends | Confused level vs change | MoM = Growth Rates (% change) |
| 2 | 18-Aug | Product as a dimension | Same axis as Category | Product = Category drill-down |
| 1 | 18-Aug | Items sold as a metric | Redundant with AOV | Revenue / Order count / AOV only |

### Top 3 patterns to watch

1. **Units must match** — percentages only compare to percentages.
2. **Lens discipline** — each bucket has ONE lens (level / % change / contest / why).
3. **Never hardcode derived values** — let the query compute them.
