# Verification Report — Stage 2 (Questions) · Case 03 NovaTel Telecom

**Date:** 2026-09-01
**Verifier:** progress-evaluator
**Artifact under inspection:** `learning/02-sql-learning/sql-analyst-lab/03-novatel/work/02-questions.md`
**Upstream inputs:** `case.md` (main question), dataset README, `01-scope.md` (scope pool)

---

## Verdict: **PASS**

All 6 MANDATORY checks are green. No advisory notes.

---

## MANDATORY Check Results

### CHECK 1 — Bucket mapping (every sub-question maps to exactly one bucket)

**Status: PASS**

| Sub-question | Bucket assigned | Verdict |
|---|---|---|
| Q1 | Bucket 1 — Overall Trends | OK |
| Q2 | Bucket 1 — Overall Trends | OK |
| Q3 | Bucket 1 — Overall Trends | OK |
| Q4 | Bucket 2 — Growth Rates | OK |
| Q5 | Bucket 2 — Growth Rates | OK |
| Q6 | Bucket 3 — Performance Measurement | OK |
| Q7 | Bucket 3 — Performance Measurement | OK |
| Q8 | Bucket 3 — Performance Measurement | OK |
| Q9 | Bucket 3 — Performance Measurement | OK |
| Q10 | Bucket 4 — KPI Reporting | OK |
| Q11 | Bucket 4 — KPI Reporting | OK |
| Q12 | Bucket 4 — KPI Reporting | OK |

**Evidence:** Each sub-question appears in exactly one bucket heading. No sub-question is listed under two buckets. All four buckets are populated (3 + 2 + 4 + 3 = 12 sub-questions).

---

### CHECK 2 — Metric × Dimension from Stage 1 scope pool

**Status: PASS**

| Sub-question | Metric declared | Metric traceable to `01-scope.md` | Dimension declared | Dimension traceable to `01-scope.md` |
|---|---|---|---|---|
| Q1 | Revenue (billed) | M1 (Northstar) | Month | D3 |
| Q2 | Collection rate | M2 (Northstar) | Month | D3 |
| Q3 | Active subscribers | M3 (Northstar) | Month | D3 |
| Q4 | Revenue (billed) — MoM % change | M1 + MoM growth definition (lines 38, 43) | Month | D3 |
| Q5 | Collection rate — MoM % change | M2 + MoM growth definition (lines 38, 43) | Month | D3 |
| Q6 | Revenue (billed) | M1 (Northstar) | Plan | D1 |
| Q7 | Revenue (billed) | M1 (Northstar) | Region | D2 |
| Q8 | Collection rate | M2 (Northstar) | Plan | D1 |
| Q9 | Churn count | Secondary metric (line 16) | Region | D2 |
| Q10 | Unpaid/Overdue share | Secondary metric (line 15) | Plan | D1 |
| Q11 | Churn reason | KPI "why" dimension (line 30) | Region | D2 |
| Q12 | ARPU | Secondary metric (line 17) | Plan | D1 |

**Evidence:** All 7 metrics (Revenue, Collection rate, Active subscribers, Churn count, Unpaid/Overdue share, Churn reason, ARPU) and all 3 dimensions (Month, Plan, Region) appear in `01-scope.md`. No metric or dimension outside the scope pool is introduced.

---

### CHECK 3 — Two-way coverage (no orphan scoped metric/dimension, no out-of-scope)

**Status: PASS**

**Scoped metrics accounted for in 02-questions.md:**

| Scope metric | Sub-question(s) using it | Status |
|---|---|---|
| M1 — Revenue (billed) | Q1, Q4, Q6, Q7 | Covered |
| M2 — Collection rate | Q2, Q5, Q8 | Covered |
| M3 — Active subscribers | Q3 | Covered |
| Unpaid/Overdue share (derived) | Q10 | Covered |
| Churn count (derived) | Q9 | Covered |
| ARPU (derived) | Q12 | Covered |
| Churn reason (KPI dimension) | Q11 | Covered |

**Scoped dimensions accounted for in 02-questions.md:**

| Scope dimension | Sub-question(s) using it | Status |
|---|---|---|
| D1 — Plan | Q6, Q8, Q10, Q12 | Covered |
| D2 — Region | Q7, Q9, Q11 | Covered |
| D3 — Month | Q1, Q2, Q3, Q4, Q5 | Covered |

**Out-of-scope check:** No metric or dimension appears in `02-questions.md` that is absent from `01-scope.md`. The four bucket lenses (Trends, Growth, Performance, KPI) are structural containers, not scope elements. The "why" sub-questions (Q10, Q11, Q12) use metrics/dimensions from the scope's "KPI why dimension" section (lines 27–30) and secondary metrics section (lines 14–17).

**Evidence:** All 7 scope metrics and all 3 scope dimensions appear in at least one sub-question. No orphan. No out-of-scope element.

---

### CHECK 4 — Bucket lens correct

**Status: PASS**

| Bucket | Required lens | Sub-questions | Evidence |
|---|---|---|---|
| Bucket 1 — Overall Trends | Level (absolute values) | Q1, Q2, Q3 | Q1: "total billed revenue per month" (absolute); Q2: "payment collection rate per month" (absolute %); Q3: "how many active subscribers" (count) — all report the level, not the change. |
| Bucket 2 — Growth Rates | % change | Q4, Q5 | Q4: "How did billed revenue change MoM?" (MoM % change); Q5: "How did the payment collection rate change MoM?" (MoM % change). Both explicitly ask for the trajectory/change, not the level. |
| Bucket 3 — Performance Measurement | Head-to-head | Q6, Q7, Q8, Q9 | Q6: "which plans generate the most" (plan-vs-plan); Q7: "which regions have the highest" (region-vs-region); Q8: "which plans have the worst" (plan-vs-plan); Q9: "which regions have the highest churn" (region-vs-region). All are cross-segment comparisons. |
| Bucket 4 — KPI Reporting | "Why" analysis | Q10, Q11, Q12 | Q10: "Why is revenue leaking? → unpaid/overdue share by plan" (explains leakage root cause); Q11: "Why are subscribers churning? → churn reasons by region" (explains churn root cause); Q12: "Why is ARPU changing? → ARPU across plans" (explains revenue driver). All dig one layer deeper than reporting the static number. |

**Evidence:** The bucket lenses match the required patterns. Trends report levels; Growth report % change; Performance do head-to-head; KPI explain "why." No lens mismatch.

---

### CHECK 5 — No duplicate sub-question (same metric × dimension × lens)

**Status: PASS**

Unique combinations present:

| # | Metric | Dimension | Bucket/Lens | Duplicate? |
|---|---|---|---|---|
| Q1 | Revenue | Month | Trends | No |
| Q2 | Collection rate | Month | Trends | No |
| Q3 | Active subscribers | Month | Trends | No |
| Q4 | Revenue (MoM%) | Month | Growth | No |
| Q5 | Collection rate (MoM%) | Month | Growth | No |
| Q6 | Revenue | Plan | Performance | No |
| Q7 | Revenue | Region | Performance | No |
| Q8 | Collection rate | Plan | Performance | No |
| Q9 | Churn count | Region | Performance | No |
| Q10 | Unpaid/Overdue share | Plan | KPI | No |
| Q11 | Churn reason | Region | KPI | No |
| Q12 | ARPU | Plan | KPI | No |

**Evidence:** All 12 combinations are unique. No two sub-questions share the same metric × dimension × bucket.

---

### CHECK 6 — Every sub-question serves the main question

**Status: PASS**

**Main question:** "Is the subscriber base healthy, and where is revenue leaking?"

| Sub-question | Serves "subscriber base healthy"? | Serves "revenue leaking"? | Verdict |
|---|---|---|---|
| Q1 — Billed revenue/month | — | Yes (top-line revenue trend) | OK |
| Q2 — Collection rate/month | — | Yes (leakage trajectory) | OK |
| Q3 — Active subscribers/month | Yes (base size trend) | — | OK |
| Q4 — Revenue MoM change | — | Yes (revenue growth direction) | OK |
| Q5 — Collection rate MoM | — | Yes (leakage worsening/improving) | OK |
| Q6 — Revenue by plan | — | Yes (which plans are revenue engines) | OK |
| Q7 — Revenue by region | — | Yes (where revenue concentrates) | OK |
| Q8 — Collection rate by plan | — | Yes (which plans leak most) | OK |
| Q9 — Churn count by region | Yes (where subscribers leave) | — | OK |
| Q10 — Unpaid/overdue by plan | — | Yes (why revenue leaks) | OK |
| Q11 — Churn reasons by region | Yes (why subscribers churn) | — | OK |
| Q12 — ARPU across plans | Partial (revenue per user health) | Yes (revenue driver analysis) | OK |

**Evidence:** Every sub-question maps to either "subscriber base health" (Q3, Q9, Q11), "revenue leaking" (Q1, Q2, Q4, Q5, Q6, Q7, Q8, Q10, Q12), or both. No sub-question is orphaned from the main question.

---

## Summary

| Check | Status |
|---|---|
| 1. Bucket mapping | PASS |
| 2. Metric × Dimension from scope | PASS |
| 3. Two-way coverage | PASS |
| 4. Bucket lens correct | PASS |
| 5. No duplicate | PASS |
| 6. Serves main question | PASS |

**Overall verdict: PASS** — All 6 MANDATORY checks green. The 02-questions.md artifact is well-structured: 12 sub-questions across 4 buckets, all metrics and dimensions traceable to the Stage 1 scope pool, no duplicates, correct bucket lenses, and every sub-question serves the main question "Is the subscriber base healthy, and where is revenue leaking?"
