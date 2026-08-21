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

# Summary: SQL Analyst Lab Session (continued — Bucket 2 Running Log drafted & reviewed; narrative guide locked)

**Date:** 21 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 4, Step A: Running Log Buckets 1 & 2 drafted; Q2a data-vs-notes discrepancy found & verified; narrative construction method locked

---

## Completed

- **Drafted Bucket 2** in `work/04-insight.txt` (Q2a, Q2b) and had it reviewed.
- **Coach review verified a data-vs-notes discrepancy** — the session reference for Q2a was WRONG: the "Feb +22% / Aug +15% / May −17% / Sep −17%" values are **chain-wide** MoM, mislabeled under the per-store Q2a row. Verified per-store on `retail.db` (read-only):
  - **BRW003 May 2025: revenue $2,182.60 → $1,053.30 = −51.7% MoM (−$1,129.30)** — biggest single-month drop and largest $ loss. (My query test said ~−51%; correct.)
  - **BRW003 Sep: −39.2%** ($2,864.80 → $1,741.60); **Oct: −27.3%**; Nov bounces **+83.4%** (so "revenue falling over the last two months" is wrong).
  - Chain-level values (Feb +22%, Aug +15%, May −17%, Sep −17%) remain valid as **chain-wide** Q1a/trend facts.
- **Locked corrected fact lines:**
  - Q2a: "BRW003 = largest recurring $ loss (−$2,848.75/yr); worst month May 2025, revenue −51.7% MoM (−$1,129.30); Sep −39.2%, Oct −27.3% — May & Sep dips recur."
  - Q2b: "BRW003 collapses: May count −37.5% vs AOV −22.8%; Sep count −28.6% vs AOV −14.9%. Count fell more than AOV both times → volume-driven (traffic), basket held up."
- **Q2b verified correct** against data (count/AOV MoM pairs confirmed).

## Narrative Guide (sentence skeleton + 5 rules)

> **[Subject] [changed] [by how much] [relative to what]** — *(optional)* **[second evidence point if the pattern repeats]**

1. **One line = one finding.** Never two per line.
2. **Numbers before adjectives.** "sharp decline" → "−51.7%".
3. **A number is meaningless without a reference** (MoM, vs other store, vs prior month).
4. **Every clause must trace to a query cell** — if you can't point to it, delete it.
5. **Comparisons do the thinking.** Line up levers side by side (e.g. count vs AOV) and the conclusion emerges.

Construction steps: compute the change → attach a $ so it has weight → compare across time → compare across stores → check recurrence → assemble one line (each piece = one query-output cell).

## Key Takeaways

1. **Data over notes, again (like PRD030/031).** Store-scoped query output overrides summary references — always verify per-store against the DB before trusting a written reference.
2. Running Log = facts only; "therefore, the working hypothesis is…" is Step B interpretation — keep it out of Step A.
3. Volume vs basket: when both levers fall, the one that fell proportionally more explains the change (Revenue = count × AOV).

## Mistakes / Notes

- **Notes-reference bug:** the 21-aug morning reference table labeled chain-wide MoM as Q2a per-store values. Fix applied in this summary's verified lines; keep an eye out for other mislabeled references.
- `work/04-insight.txt` Bucket 2 still has the older vague lines — apply the corrected fact lines above next session.

## Next Steps

1. Running Log **Buckets 3–4**: Q3a–c (AOV by Store, AOV by Category, Order count by Category) and Q4a–d (bottom-decile products: revenue, price band, active flag, basket context) using the verified reference table.
2. **Step B** — classify facts into the 5 components (Trend / Fluctuation / Anomaly / Root cause / Recommendation).
3. **Step C** — strong insight paragraph (Trend → Fluctuation → Anomaly → Root cause → Recommendation); **Step D** — 2–4 recommendations (compute BRW002 opportunity yourself, don't copy $2,200); **Step E** — self-check.
4. Compare `work/04-insight.md` vs `expected/04-insight.md`; reconcile seasonal-items discrepancy.
5. Apply corrected Q2a/Q2b lines to `work/04-insight.txt`.
6. Close Case 01 → update progress snapshot → Case 02.

---

*Happy Learning!*
