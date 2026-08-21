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

# Summary: SQL Analyst Lab Session (continued — Bucket 3 Running Log drafted & reviewed)

**Date:** 21 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 4, Step A: Running Log **Buckets 1–3 drafted**; Bucket 4 (Q4a–d) pending; Steps B–E pending

---

## Completed

- **Bucket 2 corrected lines applied** to `work/04-insight.txt` (Q2a/Q2b now carry the verified per-store numbers).
- **Drafted Bucket 3** in `work/04-insight.txt` (Q3a AOV by Store, Q3b AOV by Category, Q3c Order count by Category) and had it reviewed.
- **All Bucket 3 numbers verified against `retail.db`** (recomputed AOV from raw `orders`):
  - Q3a — BRW001 $24,189.20/407 = **$59.43**, BRW002 $21,963.25/384 = **$57.20**, BRW003 $24,081.65/409 = **$58.88** ✓
  - Q3b — Merchandise $57.18 ≫ Food $18.08 > Beverage $17.13 ✓ (matches verified reference)
  - Q3c — Beverage 861 > Food 738 > Merchandise 737 ✓
- **Coach feedback locked (narrative misses to fix next session):**
  1. Q3a's real finding = **AOV is effectively flat** (spread < $2.25) — the contest is a tie; "BRW001 highest" buries it. This flatness powers **Anomaly 1** (BRW002 revenue gap is *orders*, not baskets).
  2. Q3b+Q3c cross-bucket tension: **Merchandise = highest basket / fewest orders** (737) → wins via basket; **Beverage = highest orders / lowest basket** → wins via traffic. Categories use **opposite levers** → Step B root-cause fodder.
  3. Typos: "Merchendise" → "Merchandise" (×3), "volume-drive" → "volume driver", "average of order" → "average order value".

## Suggested Bucket 3 fact lines (apply next session)

```
Q3a: "AOV effectively flat across stores — BRW001 $59.43 ≈ BRW003 $58.88 >
      BRW002 $57.20 (spread < $2.25); no store wins on basket efficiency."
Q3b: "Basket strength: Merchandise $57.18 ≫ Food $18.08 > Beverage $17.13 —
      Merchandise baskets are ~3× the other categories."
Q3c: "Volume: Beverage 861 orders > Food 738 > Merchandise 737 — Beverage wins on
      traffic, Merchandise wins on basket despite fewest orders."
```

## Key Takeaways

1. **Flat AOV is a finding, not a non-result** — when a contest ends in a tie, the tie *is* the insight (baskets are equal → revenue differences = volume).
2. **Cross-bucket synthesis starts in Step A** — Q3b + Q3c side by side show opposite levers (Merchandise basket / Beverage traffic); capture the pairing now, classify in Step B.
3. "≫" = "much greater than" — used for the ~3× Merchandise basket gap.

## Next Steps

1. **Bucket 4 (Q4a–d)** — bottom-decile products: revenue + zero-sales flag, price band (cheap/mid/expensive), active/inactive, basket context (alone vs add-on). Reference values in the 20-aug guide table.
2. Apply the corrected Bucket 3 lines + typos to `work/04-insight.txt`.
3. **Step B** — classify facts into the 5 components (Trend / Fluctuation / Anomaly / Root cause / Recommendation).
4. **Step C** — strong insight paragraph (Trend → Fluctuation → Anomaly → Root cause → Recommendation); **Step D** — 2–4 recommendations (compute BRW002 opportunity yourself, don't copy $2,200); **Step E** — self-check.
5. Compare `work/04-insight.md` vs `expected/04-insight.md`; reconcile seasonal-items discrepancy.
6. Close Case 01 → update progress snapshot → Case 02.

---

*Happy Learning!*
