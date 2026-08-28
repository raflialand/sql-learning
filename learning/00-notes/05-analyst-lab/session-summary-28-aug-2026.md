# Summary: SQL Analyst Lab Session

**Date:** 28 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 — Stage 5 (Queries) COMPLETE: user ran `03-queries.sql` against `datainsight_markethub`, all 13 statements captured in `03-results.md` (Q1–Q8, Q9(0), Q9(a–d)). Checkpoint 5 closed. Stage 6 (Insight) next.

---

## Completed

- **Q6 (vendor momentum) reviewed in depth** — walked the dense-grid pattern line by line and clarified why the grid is required.
- **Q8 (repeat purchase rate) reviewed in depth** — walked the two-`COUNT(DISTINCT)` pattern line by line.
- **Stage 5 executed & captured** — user ran all 13 statements; results saved to `work/03-results.md` (Q1–Q8, Q9(0), Q9(a–d)). Verified 13/13 present, including the Q9(0) bottom-vendor anchor (VEN009 "Metro Distributors" $186,564.18).

## Key Takeaways (conceptual this session)

1. **`COALESCE` fills a missing VALUE; the grid fills a missing ROW — and `LAG` only sees rows.** That's why you can't fix a skipped month with `COALESCE(LAG(...))` alone: `LAG` skips over the absent row and compares to the last *selling* period. The `vendors CROSS JOIN months` grid manufactures the gap month as `gmv=0` so "previous month" literally means the previous calendar month.
2. **Momentum (Q6) needs the grid most** because a growth rate is a comparison between two periods — if those aren't the true adjacent calendar periods, every % is wrong, and vendors with irregular sales (the exact ones the invest-next decision hinges on) are the most exposed.
3. **Q8 repeat rate = a two-step `COUNT(DISTINCT)`.** Step 1 (CTE): `COUNT(DISTINCT order_id)` per vendor-customer = baskets, not line rows (mart is line-grain). Step 2: `SUM(CASE WHEN fulfilled_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*) × 100` per vendor.

## Mistakes / Notes

- None (review + execution session; queries authored earlier, run by the user this session).

## Next Steps

1. **Stage 6 — Insight** (`@insight-writer`): 5-component insight (Trend / Fluctuation / Anomaly / Root cause / Recommendation) + recommendations + self-check → `work/04-insight.md` → checkpoint.
2. Then Case 03 (NovaTel), then archive the OpenSpec change once both pilots validate.

---

*Happy Learning!*
