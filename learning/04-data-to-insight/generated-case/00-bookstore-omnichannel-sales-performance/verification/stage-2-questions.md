# Verification Report — Stage 2: Questions

**Case**: 00-bookstore-omnichannel-sales-performance
**Artifact verified**: `work/02-questions.md`
**Date**: 2026-09-06
**Evaluator**: progress-evaluator

---

## Verdict: **PASS-WITH-NOTES**

All 6 MANDATORY checks are green. Advisory notes flagged below are non-blocking.

---

## Check Results

### 1. Bucket Mapping — PASS

Every sub-question (Q1–Q12) is mapped to exactly one of the four buckets: Overall Trends, Growth Rates, Performance Measurement, or KPI Reporting. No unmapped questions.

| Bucket | Questions | Count |
|--------|-----------|-------|
| Overall Trends | Q1, Q2, Q3 | 3 |
| Growth Rates | Q4, Q5, Q6 | 3 |
| Performance Measurement | Q7, Q8, Q9 | 3 |
| KPI Reporting | Q10, Q11, Q12 | 3 |

**Result**: All 12 questions mapped. No orphans.

---

### 2. Metric × Dimension from Scope — PASS

Every sub-question maps to metrics and dimensions defined in `01-scope.md` (M1–M5, D1–D5). No invented metrics or dimensions.

| Question | Metric(s) | Dimension | Source |
|----------|-----------|-----------|--------|
| Q1 | M1 — Total Revenue | D2 — Channel | Scope lines 12, 27 |
| Q2 | M1 — Total Revenue + M3 — Order Volume | D1 — Time Period | Scope lines 12, 14, 26 |
| Q3 | M1 — Total Revenue | D3 — Customer Segment | Scope lines 12, 28 |
| Q4 | M1 — Total Revenue (MoM) | D1 — Time Period | Scope lines 12, 26 |
| Q5 | M2 — AOV + M3 — Order Volume (MoM) | D1 — Time Period | Scope lines 13, 14, 26 |
| Q6 | M1 — Total Revenue (YoY) | D1 — Time Period | Scope lines 12, 26 |
| Q7 | M2 — AOV + M3 — Order Volume | D2 — Channel | Scope lines 13, 14, 27 |
| Q8 | M2 — AOV | D3 — Customer Segment | Scope lines 13, 28 |
| Q9 | M1 — Total Revenue | D5 — Store Location | Scope lines 12, 30 |
| Q10 | M4 — Repeat Purchase Rate | D3 — Customer Segment | Scope lines 15, 28 |
| Q11 | M5 — Inventory Turnover | D4 — Book Category | Scope lines 16, 29 |
| Q12 | M1 — Total Revenue | D4 — Book Category | Scope lines 12, 29 |

**Notes**:
- Three questions (Q2, Q5, Q7) combine two metrics in a single sub-question. The scope does not prohibit multi-metric expressions, and the compound mapping is traceable to defined scope metrics. This is consistent with the artifact's own coverage check.
- All metrics and dimensions trace back to `01-scope.md` M1–M5 and D1–D5. No invented elements.

---

### 3. Two-Way Coverage — PASS

Every metric and every dimension from the scope appears in at least one sub-question. No orphans.

| Metric | Sub-questions | Covered? |
|--------|---------------|----------|
| M1 — Total Revenue | Q1, Q2, Q3, Q4, Q6, Q9, Q12 | Yes |
| M2 — AOV | Q5, Q7, Q8 | Yes |
| M3 — Order Volume | Q2, Q5, Q7 | Yes |
| M4 — Repeat Purchase Rate | Q10 | Yes |
| M5 — Inventory Turnover | Q11 | Yes |

| Dimension | Sub-questions | Covered? |
|-----------|---------------|----------|
| D1 — Time Period | Q2, Q4, Q5, Q6 | Yes |
| D2 — Channel | Q1, Q7 | Yes |
| D3 — Customer Segment | Q3, Q8, Q10 | Yes |
| D4 — Book Category | Q11, Q12 | Yes |
| D5 — Store Location | Q9 | Yes |

**Result**: 5/5 metrics consumed. 5/5 dimensions consumed. Zero orphans.

---

### 4. Lens Correct — PASS

Each bucket uses the correct analytical lens:

| Bucket | Expected Lens | Actual | Correct? |
|--------|---------------|--------|----------|
| Overall Trends | Absolute level | Level | Yes |
| Growth Rates | % change | % change | Yes |
| Performance Measurement | Head-to-head comparison | Head-to-head | Yes |
| KPI Reporting | "Why" (drill one dimension deeper) | Why | Yes |

| Question | Bucket | Lens | Correct? |
|----------|--------|------|----------|
| Q1 | Overall Trends | Level | Yes |
| Q2 | Overall Trends | Level | Yes |
| Q3 | Overall Trends | Level | Yes |
| Q4 | Growth Rates | % change | Yes |
| Q5 | Growth Rates | % change | Yes |
| Q6 | Growth Rates | % change | Yes |
| Q7 | Performance Measurement | Head-to-head | Yes |
| Q8 | Performance Measurement | Head-to-head | Yes |
| Q9 | Performance Measurement | Head-to-head | Yes |
| Q10 | KPI Reporting | Why | Yes |
| Q11 | KPI Reporting | Why | Yes |
| Q12 | KPI Reporting | Why | Yes |

**Result**: All 12 questions use the correct lens for their bucket.

---

### 5. No Duplicates — PASS

Every sub-question has a unique combination of metric × dimension × bucket:

| Question | Metric | Dimension | Bucket | Unique? |
|----------|--------|-----------|--------|---------|
| Q1 | M1 | D2 | Overall Trends | Yes |
| Q2 | M1+M3 | D1 | Overall Trends | Yes |
| Q3 | M1 | D3 | Overall Trends | Yes |
| Q4 | M1 | D1 | Growth Rates | Yes |
| Q5 | M2+M3 | D1 | Growth Rates | Yes |
| Q6 | M1 | D1 | Growth Rates | Yes |
| Q7 | M2+M3 | D2 | Performance Measurement | Yes |
| Q8 | M2 | D3 | Performance Measurement | Yes |
| Q9 | M1 | D5 | Performance Measurement | Yes |
| Q10 | M4 | D3 | KPI Reporting | Yes |
| Q11 | M5 | D4 | KPI Reporting | Yes |
| Q12 | M1 | D4 | KPI Reporting | Yes |

**Result**: Zero duplicates. All 12 sub-questions are distinct.

---

### 6. Serves Main Question — PASS

The main business question asks: *"How is PageTurner Books performing across its omnichannel operations, and which levers — store locations, customer segments, product categories, or promotional strategies — should leadership prioritize to improve profitability and customer loyalty over the next 12 months?"*

Coverage of the main question's components:

| Main Question Component | Addressed By | Covered? |
|------------------------|--------------|----------|
| "How is PageTurner performing?" (baseline) | Q1, Q2 (revenue trend, volume trend) | Yes |
| Growth trajectory | Q4, Q5, Q6 (MoM and YoY growth) | Yes |
| "store locations" lever | Q9 (store performance ranking) | Yes |
| "customer segments" lever | Q3, Q8, Q10 (segment revenue, AOV, repeat rate) | Yes |
| "product categories" lever | Q11, Q12 (inventory turnover, category revenue) | Yes |
| "promotional strategies" lever | No dedicated sub-question | **See Advisory Note 1** |
| Channel comparison (omnichannel) | Q1, Q7 (channel revenue, AOV, volume) | Yes |

**Result**: The sub-questions cover the main question's core components. One lever (promotional strategies) is not explicitly addressed as a standalone sub-question — see Advisory Note 1.

---

## Advisory Notes

### Advisory Note 1: Promotional Strategies Lever — No Dedicated Sub-Question

The main question names four levers: *store locations, customer segments, product categories, or promotional strategies*. The scope (`01-scope.md`) chose not to elevate promotional strategy to a standalone dimension (D1–D5), noting that `order_items.discount > 0` would be handled ad-hoc in queries. The questions artifact follows this decision.

However, this means no sub-question explicitly investigates promotional impact (e.g., "Do promoted orders have higher AOV than non-promoted orders?" or "Which customer segments respond most to promotions?").

**Impact**: The main question is still broadly answered because Q1–Q12 cover the other three levers comprehensively, and promotional analysis can be layered into downstream queries. This is a **scope design choice**, not an error in the questions artifact.

**Recommendation (advisory)**: Consider adding a sub-question like:
- *"Do promoted orders (discount > 0) have higher AOV than non-promoted orders, by customer segment?"* — M2 × D3 with discount flag.

This would require expanding the scope to include a promotional flag dimension or adding it as an ad-hoc dimension at query time.

---

## Summary

The Stage 2 questions artifact (`02-questions.md`) is well-structured: 12 sub-questions across 4 buckets, all 5 metrics and 5 dimensions consumed, no duplicates, correct bucket lenses, and full traceability to the scope. All 6 MANDATORY checks pass.

The single advisory note concerns the promotional strategies lever named in the main question — it is not represented by a dedicated sub-question, though this is consistent with the scope's design decision to handle promotions ad-hoc. This is non-blocking but worth flagging for completeness.

**Verdict: PASS-WITH-NOTES**
