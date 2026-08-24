# Running Log Narrative Guide

**Topic:** How to write a good narrative of findings in a Running Log (Step A of the Data-to-Insight framework) — one factual line per sub-question, traceable to exactly one query result.

---

## 1. What a Running Log line is

A Running Log is **facts only, no interpretation**. Each line answers one sub-question in the shape:

> **[Subject] [changed] [by how much] [relative to what]** — *(optional)* **[second evidence point if the pattern repeats]**

Three rules govern everything that follows:

1. The line is a **conclusion with its numbers attached** — never an opinion, never a summary without evidence.
2. Every clause must **trace to a query-output cell** (or one obvious arithmetic step on it). If you can't point to the number, delete the clause.
3. Interpretation ("this means customers stopped coming", "this is volume-driven") belongs in **Step B**, where facts get classified into Trend / Fluctuation / Anomaly / Root cause / Recommendation. Step A carries the evidence only.

---

## 2. The sentence skeleton

```
[Subject] [verb of change] [magnitude + unit] [reference point]   [second evidence point if recurring]
```

| Slot | What goes here | Example (Q2a) |
| --- | --- | --- |
| Subject | the metric/entity being measured | BRW003 |
| Verb of change | grew / fell / trails / split / equals | largest recurring $ loss |
| Magnitude + unit | the number, always with a unit or % | −51.7% MoM (−$1,129.30) |
| Reference point | what it's compared against (prior month, other store, other category) | vs Apr $2,182.60 |
| Second evidence (optional) | a repeat of the same pattern → shows it's a trend, not a one-off | Sep −39.2%, Oct −27.3% — dips recur |

If a slot is empty, the clause is probably an opinion. Fill it with a number or cut it.

---

## 3. The five rules

1. **One line = one finding.** Never two findings per line. If you have two, split them.
2. **Numbers before adjectives.** "sharp decline" → "−51.7%". Adjectives carry no evidence; numbers do.
3. **A number is meaningless without a reference.** A lone "−51.7%" tells nothing. "−51.7% MoM" (vs the prior month) and "vs BRW001/BRW002" give it meaning. State the comparison.
4. **Every clause must trace to a query cell.** Unsourced = delete. This is the discipline that makes the log verifiable.
5. **Comparisons do the thinking.** When diagnosing levers (e.g. volume vs basket), line them up side by side: `count −37.5% vs AOV −22.8%`. The conclusion emerges from the comparison — you don't have to argue it.

---

## 4. Construction steps (from raw output to one line)

1. **Compute the change** — e.g. MoM % = (cur − prev) / prev × 100. First month = `NULL`, expected.
2. **Attach a $ so it has weight** — a percentage alone can hide a trivial or huge impact. −51.7% becomes real when it's −$1,129.30.
3. **Compare across time** — is this the worst month? Best? Part of a pattern?
4. **Compare across entities** — is this store/category the worst, or average? Use the locked focus rule (e.g. "largest absolute $ loss", not steepest %).
5. **Check recurrence** — does it repeat (May AND Sep)? Recurrence turns a one-off into a trend worth flagging.
6. **Assemble one line** — subject → status → anchor number → worst moment → recurrence. Each piece is one query-output cell.

---

## 5. Worked examples (real, from Case 01)

### Q1a — level trend
```
Vague:    "Revenue went up and down during the year."
One line: "Revenue rose $4,000 (Jan) → $6,360 peak (Aug), fell to $4,519 (Oct)."
```
Every number is a monthly total from the query. No adjectives, no interpretation.

### Q2a — growth rates, the per-store trap
```
Vague:    "BRW003 exhibits higher revenue trend fluctuations; it experienced its
           sharpest revenue decline in May, and revenue has also been falling lately."
One line: "BRW003 = largest recurring $ loss (−$2,848.75/yr); worst month May 2025,
           revenue −51.7% MoM (−$1,129.30); Sep −39.2%, Oct −27.3% — May & Sep dips recur."
```
Why the fix worked:
- "higher fluctuations" → **no number** → cut.
- "sharpest decline in May" → correct, but the number (−51.7%) was missing → attached.
- "falling lately" → no number, and contradicted by data (Nov +83.4%) → cut.
- Added the reference point (MoM, vs prior month) and the recurrence (Sep, Oct) so the magnitude is real and the pattern is visible.

### Q2b — the comparison IS the conclusion
```
Vague:    "Both AOV and the number of orders have declined; therefore, the working
           hypothesis is that the drop is not due to cheaper items but fewer orders."
One line: "BRW003 collapses: May count −37.5% vs AOV −22.8%; Sep count −28.6% vs
           AOV −14.9%. Count fell more than AOV both times → volume-driven (traffic)."
```
Why it works:
- Lining up count vs AOV side by side makes the conclusion self-evident (Rule 5).
- Both collapse months are included — one month is a data point, two is a pattern.
- The "therefore, the working hypothesis is…" sentence is interpretation → belongs in Step B, not Step A.

---

## 6. Weak vs strong — quick reference

| Weak | Strong |
| --- | --- |
| "Revenue fluctuated a lot." | "Revenue rose $4,000 → $6,360 → $4,519 over the year." |
| "BRW002 is lagging." | "BRW002 trails ~9% ($21,963 vs ~$24,190 across the other two stores)." |
| "May was a bad month." | "May revenue −51.7% MoM (−$1,129.30), the largest single-month drop." |
| "The drop was probably about fewer orders." | "May count −37.5% vs AOV −22.8% → count fell more; volume-driven." |

---

## 7. Anti-patterns (things that fail review)

1. **Adjectives without numbers** — "higher fluctuations", "significant decline".
2. **Claims not traceable to a query** — "falling lately", "customers lost interest".
3. **Interpretation in a facts log** — "therefore, the working hypothesis is…", "this means…".
4. **Missing reference point** — a number with no "vs what".
5. **Two findings crammed into one line** — pick the strongest; the other becomes a separate line.
6. **Only one occurrence of a pattern** — a single bad month is a data point; show the repeat to call it a trend.
7. **Trusting a written reference over your query output** — always verify per-store/per-segment values against the DB (Case 01 lesson: chain-wide numbers were mislabeled as per-store).

---

## 8. Self-check checklist (run before submitting a Bucket)

- [ ] One line = one finding?
- [ ] Every clause has a number attached?
- [ ] Every number has a reference point (MoM / vs store / vs category / vs prior)?
- [ ] Every claim traces to exactly one query result?
- [ ] No interpretation ("this means…", "therefore…") — moved to Step B?
- [ ] Recurring patterns shown with 2+ occurrences, not 1?
- [ ] No unsourced adjectives ("higher", "significant", "falling lately")?
- [ ] Values match the actual DB output, not the reference table, when they disagree?

---

*Happy Learning!*
