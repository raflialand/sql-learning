# Case 03: NovaTel — Stage 5 (Query + Results) Verification

**Verified:** 2026-09-02
**Artifacts inspected:**
- `03-queries.sql` (12 queries)
- `03-results.md` (12 result blocks)
- `query-analysis.md` (query-inspector report)

**Upstream context:**
- `case.md` — Main question: "Is the subscriber base healthy, and where is revenue leaking?"
- `01-scope.md` — 3 northstar metrics + 3 dimensions + 3 derived metrics
- `02-questions.md` — 12 sub-questions across 4 buckets
- Dataset README — billing grain = 7,996 rows across 2 months; churn = 427 records

---

## MANDATORY Check 1: Completeness

**Condition:** Every sub-question from `02-questions.md` has a corresponding query in `03-queries.sql` with results in `03-results.md`.

| Sub-question | Query present? | Results present? |
|---|---|---|
| Q1 — Total billed revenue per month | ✅ (lines 13–19) | ✅ (2 rows) |
| Q2 — Payment collection rate per month | ✅ (lines 22–33) | ✅ (2 rows) |
| Q3 — Active subscribers billed per month | ✅ (lines 36–42) | ✅ (2 rows) |
| Q4 — Billed revenue MoM change | ✅ (lines 49–75) | ✅ (1 row) |
| Q5 — Collection rate MoM change | ✅ (lines 78–109) | ✅ (1 row) |
| Q6 — Billed revenue by plan | ✅ (lines 116–122) | ✅ (6 rows) |
| Q7 — Billed revenue by region | ✅ (lines 125–131) | ✅ (5 rows) |
| Q8 — Collection rate by plan | ✅ (lines 134–145) | ✅ (6 rows) |
| Q9 — Churn count by region | ✅ (lines 148–159) | ✅ (5 rows) |
| Q10 — Unpaid/Overdue share by plan | ✅ (lines 166–177) | ✅ (6 rows) |
| Q11 — Churn reasons by region | ✅ (lines 181–188) | ✅ (30 rows) |
| Q12 — ARPU by plan | ✅ (lines 191–202) | ✅ (6 rows) |

**Verdict: ✅ PASS** — All 12 sub-questions have queries and results.

---

## MANDATORY Check 2: Reconciliation

**Condition:** Cross-checks between related queries are consistent.

### Check 2a: Σ(revenue by plan) ≈ Q1 total

From Q1 results:
- Dec: 203,420.0
- Jan: 175,870.0
- **Grand total: 379,290.0**

From Q6 results (revenue by plan — all months):
- Plus: 81,750.0
- Standard: 79,380.0
- Premium: 77,280.0
- Family: 62,100.0
- Starter: 39,420.0
- Unlimited Max: 39,360.0
- **Sum: 379,290.0** ✅ Exact match

### Check 2b: Collection rate consistency (Q2 vs Q5)

Q2 results: Dec=82.55%, Jan=82.21%
Q5 results: Jan collection_rate_pct=82.21, prev_month_rate=82.55
- Δ = -0.34 pp ✅ Consistent

### Check 2c: Active subscribers consistency (Q3)

Q3 results: Dec=4,287, Jan=3,709
- Total bills: Dec=4,287 (Q2), Jan=3,709 (Q2) — 1:1 with distinct subscribers
- Implies each subscriber has exactly 1 bill per month at billing grain ✅ Consistent

### Check 2d: Q10 unpaid/overdue + paid ≈ total bills

Q10 results for Premium: unpaid_overdue_bills=210, total_bills=1,104
Q8 results for Premium: paid_bills=894, total_bills=1,104
- 894 + 210 = 1,104 ✅ (Paid + Unpaid/Overdue = Total for plans)

### Check 2e: Revenue by region (Q7) sum

Q7 sum: 77,800 + 77,680 + 77,285 + 73,615 + 72,910 = 379,290 ✅ Matches Q1 grand total

### Check 2f: Q12 ARPU cross-check

Q12 Premium: 77,280 / 594 = 130.10 ✅ (matches reported ARPU)
Q12 Plus: 81,750 / 878 = 93.11 ✅ (matches reported ARPU)
Q12 Standard: 79,380 / 1,220 = 65.07 ✅ (matches reported ARPU)

**Verdict: ✅ PASS** — All cross-checks reconcile.

---

## MANDATORY Check 3: No Unexpected NULLs

**Condition:** Results don't contain unexpected NULL values in key metric columns.

| Query | Key columns checked | NULLs found? |
|---|---|---|
| Q1 | total_billed_revenue | None ✅ |
| Q2 | collection_rate_pct, paid_bills | None ✅ |
| Q3 | active_subscribers | None ✅ |
| Q4 | revenue_change, revenue_mom_pct | None ✅ |
| Q5 | rate_change_pct | None ✅ |
| Q6 | total_billed_revenue | None ✅ |
| Q7 | total_billed_revenue | None ✅ |
| Q8 | collection_rate_pct | None ✅ |
| Q9 | churned_count | None ✅ |
| Q10 | unpaid_overdue_pct | None ✅ |
| Q11 | churn_count | None ✅ |
| Q12 | arpu | None ✅ |

**Verdict: ✅ PASS** — No unexpected NULLs in any result set.

---

## MANDATORY Check 4: Metric Definitions Honored

**Condition:** Queries use the correct definitions from `01-scope.md`.

### M1 — Revenue (billed): `SUM(amount) from billing grouped by bill_date month`

| Query | Implementation | Correct? |
|---|---|---|
| Q1 | `SUM(billed_amount)` grouped by `billing_month` | ✅ |
| Q4 | Same, with MoM calculation | ✅ |
| Q6 | `SUM(billed_amount)` grouped by `plan_name` | ✅ |
| Q7 | `SUM(billed_amount)` grouped by `region` | ✅ |
| Q12 | `SUM(billed_amount)` grouped by `plan_name` (for ARPU numerator) | ✅ |

### M2 — Payment collection rate: `COUNT(bills WHERE status='Paid') / COUNT(*) × 100` per month

| Query | Implementation | Correct? |
|---|---|---|
| Q2 | `COUNT(CASE WHEN bill_status='Paid' THEN 1 END) * 100.0 / COUNT(*)` | ✅ |
| Q5 | Same formula, with MoM difference | ✅ |
| Q8 | Same formula, grouped by plan | ✅ |

### M3 — Active subscriber base: `COUNT(DISTINCT sub_id)` from billing per month

| Query | Implementation | Correct? |
|---|---|---|
| Q3 | `COUNT(DISTINCT sub_id)` grouped by `billing_month` | ✅ |

### Derived: Unpaid/Overdue share: `status IN ('Unpaid','Overdue')`

| Query | Implementation | Correct? |
|---|---|---|
| Q10 | `bill_status IN ('Unpaid', 'Overdue')` count / total | ✅ |

### Derived: Churn count: `COUNT(*) from churn (427 records)`

| Query | Implementation | Correct? |
|---|---|---|
| **Q9** | `COUNT(CASE WHEN has_churned = TRUE THEN 1 END)` — counts **billing records**, not distinct subscribers | ❌ **FAIL** |
| **Q11** | `COUNT(*)` after filtering `has_churned = TRUE` — counts **billing records**, not distinct subscribers | ❌ **FAIL** |

**Q9/Q11 grain mismatch explained:**

The gold mart grain is one row per `bill_id` (7,996 rows). The `has_churned` flag is a subscriber-level attribute LEFT JOINED from `silver.churn`. A churned subscriber with 2 billing records will have `has_churned = TRUE` on **both** rows. Therefore:

- Q9 `churned_count` = billing records from churned subscribers ≠ number of churned subscribers
- Q11 `churn_count` = billing records per reason ≠ number of churn events

The scope defines churn count as `COUNT(*) from churn (427 records)` — 427 is the true churn count. Q9 reports West=50, Northeast=48, etc., which sum to 214 (before deduplication) — but these are billing-record counts, not subscriber counts.

### Derived: ARPU: `Revenue ÷ Active subscribers` per month

| Query | Implementation | Correct? |
|---|---|---|
| Q12 | `SUM(billed_amount) / COUNT(DISTINCT sub_id)` by plan | ✅ (plan-level ARPU across both months is valid for a plan comparison) |

### MoM-only constraint (no YoY)

| Query | Compliance |
|---|---|
| Q4 | Filters to Jan only, compares with Dec ✅ |
| Q5 | Filters to Jan only, compares with Dec ✅ |
| Q6–Q12 | No time comparisons — cross-sectional ✅ |

**Verdict: ❌ FAIL** — Q9 and Q11 do not honor the churn count definition. The `has_churned` flag is a subscriber-level attribute replicated across billing records, causing inflation when counted at billing grain.

---

## Overall Verdict

| MANDATORY Check | Status |
|---|---|
| 1. Completeness | ✅ PASS |
| 2. Reconciliation | ✅ PASS |
| 3. No unexpected NULLs | ✅ PASS |
| 4. Metric definitions honored | ❌ FAIL (Q9, Q11) |

### **Final Verdict: ❌ FAIL**

**Failing checks with evidence:**

| Check | Failure | Evidence | Owning agent |
|---|---|---|---|
| **4. Metric definitions — Q9** | Churn count counts billing records, not distinct subscribers | `COUNT(CASE WHEN has_churned = TRUE THEN 1 END)` at billing grain yields West=50, Northeast=48, etc. (billing-record counts), not distinct churned subscribers. Scope defines churn as 427 total records from `silver.churn`. | `sql-builder` |
| **4. Metric definitions — Q11** | Churn reasons counts billing records, not distinct churn events | `COUNT(*)` after `WHERE has_churned = TRUE` at billing grain inflates counts. Scope defines churn count as 427 total from `silver.churn`. | `sql-builder` |

**Recommended fix (both queries):** Either:
- **Option A (preferred):** Query `silver.churn` joined to `silver.subscribers` directly, bypassing the billing-grain gold mart for churn metrics.
- **Option B:** Use `COUNT(DISTINCT sub_id)` instead of `COUNT(*)` / `COUNT(CASE ...)` in Q9 and Q11 to collapse back to subscriber grain.

### Non-blocking notes (PASS-WITH-NOTES items)

1. **Q9 churn_rate_pct denominator:** Uses `COUNT(*)` (total bills) as denominator, not total subscribers. If churn rate is meant to be % of subscribers who churned, the denominator should be subscriber count. However, the sub-question asks for "churn counts" not "churn rates," so the added rate column is supplementary and not strictly required.

2. **Q11 SQL in results vs. queries file:** The SQL snippet in `03-results.md` uses `has_churned = 1` (numeric) while `03-queries.sql` uses `has_churned = TRUE` (boolean). Both are functionally equivalent in PostgreSQL/SQLite, but the inconsistency is cosmetic.

3. **Gold mart table naming:** The queries reference `gold.mart_subscriber_health` (schema-qualified) while the results SQL uses `gold_mart_subscriber_health` (underscore-joined). This is a cosmetic difference from SQLite execution context and does not affect correctness.
