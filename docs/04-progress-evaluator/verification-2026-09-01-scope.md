# Verification Report — Stage 1 (Scope) Checkpoint

**Case:** Case 03 — NovaTel Telecom  
**Artifact:** `learning/02-sql-learning/sql-analyst-lab/03-novatel/work/01-scope.md`  
**Date:** 2026-09-01  
**Verifier:** progress-evaluator  

---

## Verdict: **PASS**

All five MANDATORY checks pass. The scope document is well-structured, traceable to the main question, and respects the dataset's hard limitation (MoM-only).

---

## MANDATORY Check Results

### ✅ CHECK 1: Every metric/dimension traceable to main question and justified

**Status:** PASS

| Element | Traceability to Main Question | Justification |
|---------|-------------------------------|---------------|
| **M1: Revenue (billed)** | Directly addresses "where is revenue leaking?" | "The top line — how much the business bills each cycle. The primary revenue health indicator." |
| **M2: Payment collection rate** | Directly addresses "where is revenue leaking?" | "The inverse of leakage — what percentage of billed revenue actually gets collected." |
| **M3: Active subscriber base** | Directly addresses "subscriber base healthy" | "The engine of recurring revenue — whether the paying base is growing or shrinking." |
| **D1: Plan** | Slices revenue/health by product | "Product segmentation — which plans generate or leak revenue." |
| **D2: Region** | Slices health/leakage by geography | "Geographic health — where churn concentrates, where revenue leakage is worst." |
| **D3: Month** | Time axis for trend analysis | "The only trend axis available. Two-point comparison: Dec → Jan." |

All derived metrics (Unpaid/Overdue share, Churn count, ARPU) and KPI "why" dimensions (Usage tier, Ticket category) are also justified against the main question.

**Evidence:** Lines 8–17 (metrics), Lines 21–31 (dimensions), Line 3 (main question restated).

---

### ✅ CHECK 2: ≥3 metrics AND ≥3 dimensions floor met

**Status:** PASS

| Count | Items | Floor | Result |
|-------|-------|-------|--------|
| Northstar metrics | M1, M2, M3 = **3** | ≥3 | ✅ Met |
| Main dimensions | D1, D2, D3 = **3** | ≥3 | ✅ Met |

Additionally, 3 derived metrics and 2 KPI "why" dimensions are provided as supplementary scope (not counted toward floor).

**Evidence:** Lines 6–18 (3 northstar metrics), Lines 19–31 (3 main dimensions + 2 KPI "why" dimensions).

---

### ✅ CHECK 3: Metrics are numbers, dimensions are slices (no metric-as-dimension confusion)

**Status:** PASS

| Element | Type | Validation |
|---------|------|------------|
| M1: Revenue (billed) | Number (SUM) | ✅ Numeric aggregation |
| M2: Payment collection rate | Number (percentage) | ✅ Numeric ratio |
| M3: Active subscriber base | Number (COUNT) | ✅ Numeric count |
| D1: Plan | Categorical slice | ✅ 6 plan values (Starter → Unlimited Max) |
| D2: Region | Categorical slice | ✅ 5 region values |
| D3: Month | Time slice | ✅ 2 months (Dec-2025, Jan-2026) |

No metric is treated as a dimension, and no dimension is treated as a metric.

**Evidence:** Lines 8–18 (metric definitions are numeric), Lines 21–31 (dimension values are categorical/temporal).

---

### ✅ CHECK 4: Ambiguous metrics have explicit definitions

**Status:** PASS

All six metrics (3 northstar + 3 derived) have explicit definitions:

| Metric | Definition Provided | Location |
|--------|---------------------|----------|
| M1: Revenue (billed) | `SUM(amount)` from `billing` grouped by `bill_date` month | Line 9, Line 34 |
| M2: Payment collection rate | `COUNT(bills WHERE status='Paid') / COUNT(*) × 100` per month | Line 10, Line 35 |
| M3: Active subscriber base | `COUNT(DISTINCT sub_id)` from `billing` (per month) | Line 11, Line 36 |
| Unpaid/Overdue share | billing rows with `status IN ('Unpaid','Overdue')` | Line 15 |
| Churn count | `COUNT(*)` from `churn` (427 records) | Line 16 |
| ARPU | Billed revenue ÷ active subscribers per `bill_date` month | Line 17, Line 39 |

"Revenue leak" is also explicitly defined on Line 37: `billing.status IN ('Unpaid','Overdue')`.

**Evidence:** Lines 8–18 (metric table with definitions), Lines 33–39 (formal definitions section).

---

### ✅ CHECK 5: No forbidden comparison introduced (no YoY claims)

**Status:** PASS

The scope document explicitly acknowledges and enforces the MoM-only constraint:

1. **Line 25 (D3 dimension):** "2025-12, 2026-01 (MoM only — dataset limitation)"
2. **Line 38 (MoM growth definition):** "NO YoY — the dataset has only two billing months (stated in `case.md`)."
3. **Line 43 (Hard constraint #1):** "MoM-only: No YoY comparisons. All time-series analysis is limited to Dec-2025 → Jan-2026."

No YoY comparison is introduced anywhere in the scope document.

**Evidence:** Lines 25, 38, 43.

---

## ADVISORY Notes (non-blocking)

1. **Churn count scope ambiguity (minor):** Line 16 states "Churn count: `COUNT(*)` from `churn` (427 records)" — this appears to be a total count across all time, not a monthly breakdown. Since churn dates span multiple months (signup dates 2021–2025 per README), a monthly churn count would be more useful for MoM trend analysis. However, this is a derived/secondary metric and does not affect the mandatory floor.

2. **Usage tier definition deferred:** The "Usage tier" dimension (Line 29) is described conceptually ("buckets of avg monthly data_mb per subscriber") but specific tier boundaries (low/medium/high/excessive) are not defined yet. This is acceptable at the Scope stage — concrete boundaries would be defined at the Questions or Silver stage.

3. **Ticket category labeled as "dimension" but positioned as "KPI why":** Lines 30–31 position Ticket category as a "KPI 'why' dimension" rather than a main dimension. This is a reasonable structural choice (it's a drill-down for explaining root causes, not a primary slicing axis), but the naming could cause confusion in downstream stages. Not a blocking issue.

---

## Summary

| Check | Status | Evidence |
|-------|--------|----------|
| 1. Traceability + justification | ✅ PASS | All 6 metrics + 5 dimensions trace to main question with justifications |
| 2. Floor (≥3 metrics, ≥3 dimensions) | ✅ PASS | 3 northstar metrics, 3 main dimensions |
| 3. Metric-as-dimension confusion | ✅ PASS | All metrics numeric, all dimensions categorical/temporal |
| 4. Explicit definitions | ✅ PASS | All 6 metrics defined with formulas/logic |
| 5. No forbidden comparison | ✅ PASS | MoM-only enforced; no YoY claims |

**Final Verdict: PASS** — The scope artifact is ready to proceed to Stage 2 (Questions).
