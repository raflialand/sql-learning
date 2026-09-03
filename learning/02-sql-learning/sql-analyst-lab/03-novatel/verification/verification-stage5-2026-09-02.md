# Verification Report — Stage 5 (Query + Results) Re-verification

**Case:** 03 — NovaTel
**Date:** 2026-09-02
**Trigger:** Re-verification after Q9/Q11 grain-mismatch fix (COUNT → COUNT(DISTINCT sub_id))
**Agent:** progress-evaluator

---

## Verdict: ✅ PASS

All four MANDATORY checks pass. The grain-mismatch fix for Q9 and Q11 is correctly applied and verified.

---

## MANDATORY Check Results

### 1. Completeness — PASS ✅

All 12 sub-questions from `02-questions.md` have corresponding queries in `03-queries.sql` and result tables in `03-results.md`.

| Q# | Question | Query | Results |
|----|----------|-------|---------|
| Q1 | Total billed revenue per month | ✅ | ✅ |
| Q2 | Payment collection rate per month | ✅ | ✅ |
| Q3 | Active subscribers billed per month | ✅ | ✅ |
| Q4 | Billed revenue MoM change | ✅ | ✅ |
| Q5 | Collection rate MoM change | ✅ | ✅ |
| Q6 | Billed revenue by plan | ✅ | ✅ |
| Q7 | Billed revenue by region | ✅ | ✅ |
| Q8 | Collection rate by plan | ✅ | ✅ |
| Q9 | Churn count by region | ✅ | ✅ |
| Q10 | Unpaid/Overdue share by plan | ✅ | ✅ |
| Q11 | Churn reasons by region | ✅ | ✅ |
| Q12 | ARPU by plan | ✅ | ✅ |

---

### 2. Reconciliation — PASS ✅

**Revenue cross-check (Q1 ↔ Q6):**
- Q1 total (Dec + Jan): 203,420 + 175,870 = **379,290**
- Q6 sum across plans: 81,750 + 79,380 + 77,280 + 62,100 + 39,420 + 39,360 = **379,290**
- **Match: ✓**

**MoM consistency (Q1 → Q4):**
- Q1 Dec: 203,420 / Q1 Jan: 175,870
- Q4: revenue_change = -27,550 / revenue_mom_pct = -13.54%
- Manual: (175,870 - 203,420) / 203,420 × 100 = -13.54%
- **Match: ✓**

**Collection rate consistency (Q2 → Q5):**
- Q2 Dec: 82.55% / Q2 Jan: 82.21%
- Q5: prev_month_rate = 82.55 / collection_rate_pct = 82.21 / rate_change = -0.34
- **Match: ✓**

**Regional churn cross-check (Q9 ↔ Q11) — critical fix verification:**
| Region | Q9 churned_subscribers | Q11 sum of churned_subscribers | Match? |
|--------|----------------------|-------------------------------|--------|
| Midwest | 38 | 8+7+7+7+6+3 = **38** | ✓ |
| Northeast | 48 | 11+11+8+7+6+5 = **48** | ✓ |
| Southeast | 39 | 14+8+6+6+3+2 = **39** | ✓ |
| Southwest | 39 | 8+8+7+6+5+5 = **39** | ✓ |
| West | 50 | 9+9+9+8+8+7 = **50** | ✓ |
| **Total** | **214** | **214** | **✓** |

**ARPU spot-check (Q12):**
- Unlimited Max: 39,360 / 173 = 227.51 ✓
- Family: 62,100 / 372 = 166.94 ✓
- Starter: 39,420 / 1,050 = 37.54 ✓

---

### 3. No Unexpected NULLs — PASS ✅

- All division operations use `NULLIF(..., 0)` where appropriate (Q4, Q9, Q12).
- Q2 and Q5 division by `COUNT(*)` is safe — 2-month dataset always has rows.
- Q11 WHERE clause (`has_churned = TRUE`) filters before aggregation — no NULL churn_reason leakage.
- No NULL values observed in any result table.

---

### 4. Metric Definitions Honored — PASS ✅

| Metric | Scope Definition | Query Implementation | Honored? |
|--------|-----------------|---------------------|----------|
| Revenue (billed) | `SUM(amount)` by month | `SUM(billed_amount)` GROUP BY billing_month | ✓ |
| Collection rate | `COUNT(Paid) / COUNT(*) × 100` | `COUNT(CASE WHEN bill_status='Paid') / COUNT(*) * 100` | ✓ |
| Active subscribers | `COUNT(DISTINCT sub_id)` per month | `COUNT(DISTINCT sub_id)` GROUP BY billing_month | ✓ |
| MoM growth | `(Jan − Dec) / Dec × 100` | Correct formula in Q4/Q5 | ✓ |
| Churn count | Subscriber-level count | `COUNT(DISTINCT CASE WHEN has_churned=TRUE THEN sub_id END)` | ✓ |
| Churn reasons | Subscriber-level count | `COUNT(DISTINCT sub_id)` WHERE has_churned=TRUE | ✓ |
| ARPU | `Revenue ÷ Active subscribers` | `SUM(billed_amount) / COUNT(DISTINCT sub_id)` | ✓ |

**Grain fix verification:** Q9 and Q11 correctly use `COUNT(DISTINCT sub_id)` instead of `COUNT(*)` or `COUNT(bill_id)`, resolving the grain mismatch between the bill-level mart grain and the subscriber-level churn metric.

---

## Advisory Notes (non-blocking)

1. **SQL dialect inconsistency:** `03-results.md` shows SQLite-flavored SQL (`SUM(CASE...ELSE 0 END)`) while `03-queries.sql` uses PostgreSQL-correct syntax (`COUNT(CASE...THEN 1 END)`). The results file header confirms "SQLite in-memory for execution." Functionally equivalent but cosmetically inconsistent.

2. **Table naming inconsistency:** Results file references `gold_mart_subscriber_health` (flat) while queries file uses `gold.mart_subscriber_health` (schema-qualified). Same root cause as Note 1 — different execution environments.

3. **Q9/Q11 documentation:** Both result sections include "(FIXED — grain mismatch corrected)" headers, which is helpful audit trail.

---

## Evidence Trail

| Artifact | File | Key Evidence |
|----------|------|-------------|
| Queries | `03-queries.sql` | Lines 147-161 (Q9), Lines 182-191 (Q11): COUNT(DISTINCT sub_id) |
| Results | `03-results.md` | Lines 237-262 (Q9), Lines 295-341 (Q11): Correct subscriber counts |
| Scope | `01-scope.md` | Lines 16-17: Churn count definition; Line 39: ARPU definition |
| Questions | `02-questions.md` | Lines 39, 50-51: Q9 and Q11 metric definitions |

---

## Conclusion

The grain-mismatch fix for Q9 and Q11 has been correctly applied and verified. All 12 sub-questions are complete, all cross-checks reconcile, no unexpected NULLs exist, and all metric definitions from `01-scope.md` are honored. The Stage 5 checkpoint is **PASS** and ready to proceed to Stage 6 (Insight).
