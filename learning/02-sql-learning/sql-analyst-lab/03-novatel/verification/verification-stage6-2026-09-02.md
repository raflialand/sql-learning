# Stage 6 (Insight) — Verification Report

**Case:** 03 (NovaTel)
**Date:** 2026-09-02
**Evaluator:** progress-evaluator
**Trigger:** Re-verification after fix applied to line 38 (arithmetic error in unpaid/overdue bills)

---

## Verdict: **FAIL**

One MANDATORY check fails. The fix on line 38 corrected the Immediate Findings table, but the Fluctuation section (line 66) still contains the old incorrect value.

---

## Fix History

| Line | Before | After |
|------|--------|-------|
| 38 (Immediate Findings table) | `Unpaid/overdue bills \| 748 \| 659 \| -11.90%` | `Unpaid/overdue bills \| 748 \| 660 \| -11.76%` |

---

## MANDATORY Check Results

### ✅ 1. Five components in canonical order

| Component | Present | Order |
|-----------|---------|-------|
| Trend | ✅ (line 63) | 1 |
| Fluctuation | ✅ (line 66) | 2 |
| Anomaly | ✅ (line 69) | 3 |
| Root Cause | ✅ (line 74) | 4 |
| Recommendation | ✅ (line 82) | 5 |

**Result:** PASS — all five components present in canonical order.

---

### ❌ 2. Every claim traces to results

Spot-checked every numerical claim against `03-results.md`. The following claim does **not** trace correctly:

**FAILING CLAIM — Line 66 (Fluctuation section):**

> "the absolute number of unpaid/overdue bills fell from 748 to **659** (-11.9%)"

| Field | Insight (line 66) | Correct value (line 38 / Q2 results) | Status |
|-------|-------------------|---------------------------------------|--------|
| Jan-2026 unpaid/overdue | 659 | 660 (3,709 − 3,049 = 660) | ❌ OFF BY 1 |
| MoM % | -11.9% | -11.76% (660/748 − 1 = −11.76%) | ❌ INCORRECT |

**Root cause:** The fix on line 38 was applied to the Immediate Findings table, but the Fluctuation prose on line 66 was **not updated** — it still carries the pre-fix values.

**All other claims verified correct:**

| Claim | Source | Verified |
|-------|--------|----------|
| Billed revenue: $203,420 → $175,870, −13.54% | Q1, Q4 | ✅ |
| Active subscribers: 4,287 → 3,709, −13.48% | Q3 | ✅ |
| Collection rate: 82.55% → 82.21%, −0.34pp | Q2, Q5 | ✅ |
| Unpaid/overdue bills: 748 → 660, −11.76% | Q2 (line 38) | ✅ (line 38 correct) |
| Plan revenue ranking | Q6 | ✅ |
| Region revenue ranking | Q7 | ✅ |
| West churn: 6.02%, 50 churned | Q9 | ✅ |
| Northeast churn: 5.67%, 48 churned | Q9 | ✅ |
| Premium unpaid/overdue: 19.02% (210 of 1,104) | Q10 | ✅ |
| Premium collection rate: 80.98% | Q8 | ✅ |
| Premium ARPU: $130.10 | Q12 | ✅ |
| Northeast churn reasons: 11 Competitor Offer, 11 Moving | Q11 | ✅ |
| West churn reasons: 9 Service Quality, 9 Price, 9 Moving | Q11 | ✅ |

**Result:** FAIL — line 66 contains a stale (pre-fix) value that contradicts the corrected line 38 and Q2 results.

---

### ✅ 3. Categorical accuracy

All plan names (Plus, Standard, Premium, Family, Starter, Unlimited Max) and region names (Southwest, Southeast, Northeast, Midwest, West) match Q6–Q12 results exactly. No misspellings or invented categories.

**Result:** PASS.

---

### ✅ 4. No weak-insight filler

Every section provides substantive analysis:
- Trend: diagnoses volume-driven vs. value-driven decline with specific figures
- Fluctuation: identifies the "stable collection rate is an illusion" insight
- Anomaly: names Premium as counterintuitive (high ARPU + worst collection)
- Root Cause: multi-factor churn diagnosis with Q11 breakdown by region
- Recommendation: four concrete targets with quantified expected impact

No "X is higher than Y; it's working" filler detected.

**Result:** PASS.

---

### ✅ 5. Seasonality not overclaimed

Dataset limitation (MoM only, Dec → Jan) is explicitly stated on line 6 and respected throughout. No seasonal claims are made. All comparisons are strictly MoM.

**Result:** PASS.

---

## Summary

| # | Check | Result |
|---|-------|--------|
| 1 | Five components in canonical order | ✅ PASS |
| 2 | Every claim traces to results | ❌ FAIL |
| 3 | Categorical accuracy | ✅ PASS |
| 4 | No weak-insight filler | ✅ PASS |
| 5 | Seasonality not overclaimed | ✅ PASS |

**Overall verdict:** **FAIL**

---

## Required Fix

**Owning agent:** insight-writer

**Action:** Update line 66 in `04-insight.md` to replace:

```
the absolute number of unpaid/overdue bills fell from 748 to 659 (-11.9%)
```

with:

```
the absolute number of unpaid/overdue bills fell from 748 to 660 (-11.76%)
```

This aligns line 66 with the corrected line 38 and the Q2 results (3,709 total − 3,049 paid = 660 unpaid/overdue).
