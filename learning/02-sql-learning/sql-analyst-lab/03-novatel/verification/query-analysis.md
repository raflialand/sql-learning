# Case 03: NovaTel — Query Analysis

**Generated:** 2026-09-02
**Gold Mart:** `gold.mart_subscriber_health` (grain: one row per `bill_id`, 7,996 rows)
**Dataset limitation:** MoM only (Dec-2025 → Jan-2026). NO YoY comparisons.

---

## Summary Table

| Query | Sub-question | Verdict | Notes |
|-------|-------------|---------|-------|
| Q1 | Total billed revenue per month | **PASS** | Correct metric, correct dimension, correct aggregation |
| Q2 | Payment collection rate per month | **PASS** | Correct metric, correct dimension, correct aggregation |
| Q3 | Active subscribers billed per month | **PASS** | Correct metric, correct dimension, correct aggregation |
| Q4 | Billed revenue MoM change | **PASS** | Correct MoM calculation, NULLIF guard, correct month filter |
| Q5 | Collection rate MoM change | **PASS** | Correct MoM calculation, correct month filter |
| Q6 | Billed revenue by plan | **PASS** | Correct metric, correct dimension, correct sort |
| Q7 | Billed revenue by region | **PASS** | Correct metric, correct dimension, correct sort |
| Q8 | Collection rate by plan | **PASS** | Correct metric, correct dimension, correct sort |
| Q9 | Churn count by region | **FAIL** | Grain mismatch — counts billing records, not distinct subscribers |
| Q10 | Unpaid/Overdue share by plan | **PASS** | Correct metric definition, correct filter, correct dimension |
| Q11 | Churn reasons by region | **FAIL** | Grain mismatch — duplicates churn reasons per billing record |
| Q12 | ARPU by plan | **PASS** | Correct formula: billed revenue ÷ distinct subscribers |

---

## Detailed Analysis

### Q1: Total billed revenue per month — ✅ PASS

```sql
SELECT billing_month, SUM(billed_amount) AS total_billed_revenue
FROM gold.mart_subscriber_health
GROUP BY billing_month ORDER BY billing_month;
```

- **Query logic:** Correct. `SUM(billed_amount)` grouped by `billing_month` produces total billed revenue per month.
- **Business alignment:** Matches sub-question "What is the total billed revenue per month?" and metric M1 from scope (`SUM(amount) from billing grouped by bill_date month`).
- **Result verification:** Dec=203,420, Jan=175,870 — matches expected results exactly.
- **MoM constraint:** No YoY attempted. ✓

### Q2: Payment collection rate per month — ✅ PASS

```sql
SELECT billing_month, COUNT(*), COUNT(CASE WHEN bill_status='Paid' THEN 1 END),
    ROUND(COUNT(CASE WHEN bill_status='Paid' THEN 1 END) * 100.0 / COUNT(*), 2) AS collection_rate_pct
FROM gold.mart_subscriber_health GROUP BY billing_month ORDER BY billing_month;
```

- **Query logic:** Correct. Uses `bill_status` (the renamed `status` column from the gold mart) with `COUNT(CASE WHEN ...)` pattern for conditional aggregation.
- **Business alignment:** Matches sub-question "What is the payment collection rate per month?" and metric M2 from scope (`COUNT(bills WHERE status='Paid') / COUNT(*) × 100`).
- **Result verification:** Dec=82.55%, Jan=82.21% — matches expected results.
- **Note:** The `COUNT(CASE WHEN ... THEN 1 END)` pattern is valid and equivalent to `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` — both count non-null values.

### Q3: Active subscribers billed per month — ✅ PASS

```sql
SELECT billing_month, COUNT(DISTINCT sub_id) AS active_subscribers
FROM gold.mart_subscriber_health GROUP BY billing_month ORDER BY billing_month;
```

- **Query logic:** Correct. `COUNT(DISTINCT sub_id)` at billing grain correctly counts unique subscribers billed each month.
- **Business alignment:** Matches sub-question "How many active subscribers are billed per month?" and metric M3 from scope (`COUNT(DISTINCT sub_id) from billing per month`).
- **Result verification:** Dec=4,287, Jan=3,709 — matches expected results.
- **Design note:** The gold mart's billing grain means each subscriber appears once per billing record. Since the scope defines active subscribers as "distinct sub_id with a bill in that month," this is correct.

### Q4: Billed revenue MoM change — ✅ PASS

```sql
-- Self-join pattern: curr = Jan, prev = Dec
WHERE curr.billing_month = '2026-01'
```

- **Query logic:** Correct. Uses a self-join with a CASE-based month mapping to pair Jan with Dec. `NULLIF(prev, 0)` prevents division-by-zero. The WHERE clause correctly filters to only the Jan row (MoM = Dec→Jan change).
- **Business alignment:** Matches "How did billed revenue change MoM?" — reports the Dec→Jan change as a single row for Jan.
- **Result verification:** Revenue dropped 27,550 (-13.54%) — matches expected results.
- **MoM constraint:** Correctly implements `(Jan − Dec) / Dec × 100` with no YoY. ✓

### Q5: Collection rate MoM change — ✅ PASS

```sql
-- Same self-join pattern as Q4
ROUND(curr.collection_rate_pct - prev.collection_rate_pct, 2) AS rate_change_pct
```

- **Query logic:** Correct. Same self-join architecture as Q4. Reports the absolute percentage-point change (not a relative % change), which is appropriate for rates.
- **Business alignment:** Matches "How did the payment collection rate change MoM?" — reports the trajectory of leakage.
- **Result verification:** Rate dropped 0.34 pp (82.55% → 82.21%) — matches expected results.
- **Design note:** The absolute difference is correct here; a relative % change on a rate would be misleading.

### Q6: Billed revenue by plan — ✅ PASS

```sql
SELECT plan_name, SUM(billed_amount) AS total_billed_revenue
FROM gold.mart_subscriber_health GROUP BY plan_name ORDER BY total_billed_revenue DESC;
```

- **Query logic:** Correct. Simple group-by with descending sort.
- **Business alignment:** Matches "Which plans generate the most billed revenue?" — head-to-head comparison by plan.
- **Result verification:** Plus (81,750) > Standard (79,380) > Premium (77,280) > Family (62,100) > Starter (39,420) > Unlimited Max (39,360) — matches expected.

### Q7: Billed revenue by region — ✅ PASS

```sql
SELECT region, SUM(billed_amount) AS total_billed_revenue
FROM gold.mart_subscriber_health GROUP BY region ORDER BY total_billed_revenue DESC;
```

- **Query logic:** Correct.
- **Business alignment:** Matches "Which regions generate the most billed revenue?" — geographic segmentation.
- **Result verification:** Southwest (77,800) > Southeast (77,680) > Northeast (77,285) > Midwest (73,615) > West (72,910) — matches expected.

### Q8: Collection rate by plan — ✅ PASS

```sql
SELECT plan_name, COUNT(*), COUNT(CASE WHEN bill_status='Paid' THEN 1 END),
    ROUND(COUNT(CASE WHEN bill_status='Paid' THEN 1 END) * 100.0 / COUNT(*), 2) AS collection_rate_pct
FROM gold.mart_subscriber_health GROUP BY plan_name ORDER BY collection_rate_pct DESC;
```

- **Query logic:** Correct. Same pattern as Q2 but grouped by plan instead of month.
- **Business alignment:** Matches "Which plans have the worst payment collection rates?" — product-level leakage identification.
- **Result verification:** Family (85.22%) best, Premium (80.98%) worst — matches expected.

### Q9: Churn count by region — ❌ FAIL

```sql
SELECT region,
    COUNT(CASE WHEN has_churned = TRUE THEN 1 END) AS churned_count,
    COUNT(*) AS total_bills,
    ROUND(COUNT(CASE WHEN has_churned = TRUE THEN 1 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM gold.mart_subscriber_health
GROUP BY region ORDER BY churned_count DESC;
```

**Issue: Grain mismatch — counts billing records, not distinct churned subscribers.**

The gold mart has grain = one row per `bill_id`. The `has_churned` flag is a subscriber-level attribute (TRUE/FALSE) LEFT JOINED from `silver.churn`. This means:
- A subscriber with `has_churned = TRUE` who has 2 billing records will have `has_churned = TRUE` on **both** rows.
- `COUNT(CASE WHEN has_churned = TRUE THEN 1 END)` counts **billing records** from churned subscribers, not the number of churned subscribers.

**Impact:** The "churned_count" values (West=50, Northeast=48, etc.) represent billing records from churned subscribers, not the actual churned subscriber count. The 427 total churn records in `silver.churn` would not sum to these values.

**Business alignment failure:** The sub-question asks "Which regions have the highest churn counts?" — this implies counting distinct subscribers who churned, not billing records. The scope defines churn count as `COUNT(*) from churn (427 records)`.

**Recommended fix:**

```sql
-- Option A: Query the churn table directly (matches scope definition)
SELECT s.region, COUNT(*) AS churn_count
FROM silver.churn c
JOIN silver.subscribers s ON c.sub_id = s.sub_id
GROUP BY s.region
ORDER BY churn_count DESC;

-- Option B: Use the gold mart but count DISTINCT subscribers
SELECT region,
    COUNT(DISTINCT CASE WHEN has_churned = TRUE THEN sub_id END) AS churned_count,
    COUNT(DISTINCT sub_id) AS total_subscribers,
    ROUND(
        COUNT(DISTINCT CASE WHEN has_churned = TRUE THEN sub_id END) * 100.0
        / COUNT(DISTINCT sub_id), 2
    ) AS churn_rate_pct
FROM gold.mart_subscriber_health
GROUP BY region
ORDER BY churned_count DESC;
```

### Q10: Unpaid/Overdue share by plan — ✅ PASS

```sql
SELECT plan_name, COUNT(*),
    COUNT(CASE WHEN bill_status IN ('Unpaid','Overdue') THEN 1 END) AS unpaid_overdue_bills,
    ROUND(COUNT(CASE WHEN bill_status IN ('Unpaid','Overdue') THEN 1 END) * 100.0 / COUNT(*), 2) AS unpaid_overdue_pct
FROM gold.mart_subscriber_health GROUP BY plan_name ORDER BY unpaid_overdue_pct DESC;
```

- **Query logic:** Correct. The `bill_status IN ('Unpaid','Overdue')` filter matches the scope definition of revenue leak.
- **Business alignment:** Matches "What is the unpaid/overdue share by plan?" — drives into the "why" of leakage.
- **Result verification:** Premium (19.02%) worst, Family (14.78%) best — matches expected.
- **Metric definition:** Correctly uses `status IN ('Unpaid','Overdue')` per scope.

### Q11: Churn reasons by region — ❌ FAIL

```sql
SELECT region, churn_reason, COUNT(*) AS churn_count
FROM gold.mart_subscriber_health
WHERE has_churned = TRUE
GROUP BY region, churn_reason
ORDER BY region, churn_count DESC;
```

**Issue: Grain mismatch — duplicates churn reasons per billing record.**

Same root cause as Q9. After filtering `has_churned = TRUE`, each churned subscriber's billing records remain. A subscriber with 3 billing records and reason "Price" will produce 3 rows for "Price" in their region. The `COUNT(*)` then counts billing records, not distinct churn events.

**Impact:** The churn counts are inflated. For example, if a churned subscriber in "West" has 3 billing records with reason "Service Quality," the count for West/Service Quality is 3 instead of 1.

**Business alignment failure:** The sub-question asks "What are the churn reasons by region?" — this implies counting distinct churn events (each subscriber churns once). The 427 churn records should map to 427 total counts across all region×reason combinations.

**Recommended fix:**

```sql
-- Option A: Query the churn table directly (cleanest)
SELECT s.region, c.reason AS churn_reason, COUNT(*) AS churn_count
FROM silver.churn c
JOIN silver.subscribers s ON c.sub_id = s.sub_id
GROUP BY s.region, c.reason
ORDER BY s.region, churn_count DESC;

-- Option B: Use the gold mart but count DISTINCT subscribers
SELECT region, churn_reason,
    COUNT(DISTINCT sub_id) AS churn_count
FROM gold.mart_subscriber_health
WHERE has_churned = TRUE
GROUP BY region, churn_reason
ORDER BY region, churn_count DESC;
```

### Q12: ARPU by plan — ✅ PASS

```sql
SELECT plan_name,
    SUM(billed_amount) AS total_billed_revenue,
    COUNT(DISTINCT sub_id) AS unique_subscribers,
    ROUND(SUM(billed_amount) / NULLIF(COUNT(DISTINCT sub_id), 0), 2) AS arpu
FROM gold.mart_subscriber_health
GROUP BY plan_name ORDER BY arpu DESC;
```

- **Query logic:** Correct. `SUM(billed_amount) / COUNT(DISTINCT sub_id)` is the correct ARPU formula. `NULLIF(..., 0)` prevents division-by-zero.
- **Business alignment:** Matches "How does ARPU compare across plans?" — explains whether revenue movement is driven by plan mix or subscriber count.
- **Result verification:** Unlimited Max (227.51) > Family (166.94) > Premium (130.10) > Plus (93.11) > Standard (65.07) > Starter (37.54) — matches expected.
- **Metric definition:** Scope defines ARPU as `billed revenue ÷ active subscribers for the same bill_date month`. This query aggregates across both months by plan, which is the correct interpretation for a plan-level comparison.

---

## Dataset Limitation Compliance

| Check | Status |
|-------|--------|
| No YoY comparisons anywhere | ✅ All queries use MoM only (Dec→Jan) |
| Time comparisons limited to 2 months | ✅ Q4 and Q5 correctly filter to Jan only |
| No claims about longer time series | ✅ No query attempts multi-month trends |

---

## Overall Verdict: **PASS-WITH-NOTES**

### What's strong
- **Excellent architecture:** Queries are built against a well-designed gold mart with clear grain (1 row per bill_id). This is a sophisticated and production-appropriate pattern.
- **Consistent style:** All 12 queries use the same column naming, aggregation patterns, and sorting conventions. Code is clean and readable.
- **Correct MoM implementation:** Q4 and Q5 correctly implement the MoM calculation with self-joins, NULLIF guards, and proper month filtering.
- **Metric definitions match scope:** Revenue, collection rate, active subscribers, unpaid/overdue share, and ARPU all use the correct formulas from `01-scope.md`.
- **Complete question coverage:** All 12 sub-questions from `02-questions.md` are addressed — the learner's decomposition is more comprehensive than the expected model (12 vs 8 queries).

### Issues requiring correction
1. **Q9 — Churn count by region:** Counts billing records instead of distinct churned subscribers. Fix: use `COUNT(DISTINCT sub_id)` or query `silver.churn` directly.
2. **Q11 — Churn reasons by region:** Same grain mismatch. Fix: use `COUNT(DISTINCT sub_id)` or query `silver.churn` directly.

### Root cause of Q9/Q11 failure
The `has_churned` flag is a **subscriber-level** attribute joined into the **billing-level** grain. Every billing record for a churned subscriber carries `has_churned = TRUE`. Counting rows (not distinct subscribers) inflates the metric by the number of billing records per churned subscriber. The correct approach is either:
- Querying the `churn` table directly (which has 427 rows, one per churned subscriber), or
- Using `COUNT(DISTINCT sub_id)` in the gold mart to collapse back to subscriber grain.

### No other corrections needed
Q1–Q8, Q10, Q12 are all correct in logic, metric definition, and business alignment.
