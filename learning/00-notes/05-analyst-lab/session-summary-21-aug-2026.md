# Summary: SQL Analyst Lab Session

**Date:** 21 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 4: Running Log (Step A) drafted for Bucket 1; Buckets 2–4 pending

---

## Completed

- Drafted the Step A Running Log for **Bucket 1** (Q1a–Q1c) and refined the format with coach feedback:

  - **Q1a** — "What is the chain-wide Revenue trend over time?" | Revenue · Month
    Revenue increased from $4,000 (Jan 2025) to $6,360 (Aug 2025), declined to $4,519 (Oct 2025). (Q4 recovery tail still to add.)
  - **Q1b** — "How is Revenue split across menu categories?" | Revenue · Category
    Merchandise $42,145 (60%) ≫ Beverage $14,748 (21%) > Food $13,342 (19%).
  - **Q1c** — "How is Revenue split across the 3 stores?" | Revenue · Store
    BRW002 trails the other two stores by ~9% ($21,963 vs ~$24,190); BRW002 $21,963.25, BRW001 $24,189.20, BRW003 $24,081.65.

- Locked the clean Running Log format: **one line = conclusion + supporting values**, facts only, no interpretation.

## Key Takeaways

1. Running Log = facts only — one factual line per sub-question, each traceable to exactly one query result; interpretation is deferred to Step B.
2. Capture the numbers later steps reuse: Merchandise 60% share (root cause), ~9% BRW002 gap (Anomaly 1), full Jan→Aug→Oct→Q4 arc (Trend).
3. Avoid redundancy — if the share is in the split, don't restate the winner + total separately.

## Mistakes / Notes

- None (draft/review-only session, no queries run).

## Next Steps

1. Running Log **Bucket 2**: Q2a (BRW003 biggest recurring $ loss; Feb +22% / Aug +15% / May −17% / Sep −17%) and Q2b (volume-driven: May count −37.5% vs AOV −22.8%; Sep count −28.6% vs AOV −14.9%).
2. Running Log **Buckets 3–4** (Q3a–c, Q4a–d) using the verified reference table.
3. **Step B** — classify facts into the 5 components (Trend / Fluctuation / Anomaly / Root cause / Recommendation).
4. **Step C** — strong insight paragraph (Trend → Fluctuation → Anomaly → Root cause → Recommendation).
5. **Step D** — 2–4 numbered recommendations (compute BRW002 opportunity yourself, don't copy $2,200); **Step E** — self-check (5 components present, claims traceable, flag PRD030/031 discrepancy).
6. Compare `work/04-insight.md` vs `expected/04-insight.md`; reconcile seasonal-items discrepancy.
7. Close Case 01 → update progress snapshot → next case.

---

*Happy Learning!*
