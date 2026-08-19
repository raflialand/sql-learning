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
| 01 Brew & Co. | 1 | 0 | Steps 1–2 done; Step 3 queries drafted (Postgres) + reviewed, fix plan pending (see 19-aug summary) |
| 02 MarketHub | 1 | 0 | — |
| 03 NovaTel | 1 | 0 | — |

## Mistake Log (cumulative across sessions)

_Append new mistakes here after each session (newest on top). The detailed table lives in the session summary; this is the running list so it carries forward._

| # | Date | Mistake | Root cause | Lesson / Fix |
| --- | --- | --- | --- | --- |
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
