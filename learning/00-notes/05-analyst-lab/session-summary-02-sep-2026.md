# Summary: SQL Analyst Lab Session

**Date:** 2 September 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 03 (NovaTel) — Stage 4 (Gold mart) verified. Ready for Stage 5 (Query + results).

---

## Completed

- **Fixed gold mart SQL syntax error** — type mismatch `numeric = text` in JOIN conditions. Changed `bp.billing_month` to `bp.bill_month_str` (text) to match `ua.bill_month_str` and `ta.bill_month_str`.
- **Uncommented verification query** — enabled uniqueness check in `_gold.sql`.
- **Verified gold mart** — `gold.mart_subscriber_health` confirmed: 7,996 total rows, 7,996 unique bills, difference = 0. No fan-out, grain preserved.
- **Case 03 Stage 4 checkpoint passed** — all 5 MANDATORY checks satisfied at design level. PASS-WITH-NOTES verdict (verification query now executed and confirmed).

---

## Key Takeaways

1. **Type consistency is critical in JOINs** — `EXTRACT(MONTH ...)` returns numeric (1-12), `TO_CHAR(..., 'YYYY-MM')` returns text ('2025-12'). Always match types explicitly.
2. **`bill_month_str` is the correct join key** — the text-formatted 'YYYY-MM' column is the consistent key across billing, usage_agg, and ticket_agg CTEs.
3. **Verification queries should be executed, not just written** — the original design had the check commented out; now it's confirmed.

---

## Artifacts Updated

| File | Change |
|------|--------|
| `work/_gold.sql` | Fixed JOIN conditions (lines 175, 178) + uncommented verification query (lines 187-191) |

---

## Current Case 03 Status

| Stage | Status |
|-------|--------|
| Stage 0 — Context | ✅ Complete |
| Stage 1 — Scope | ✅ Complete |
| Stage 2 — Questions | ✅ Complete |
| Stage 3 — Silver | ✅ Complete |
| **Stage 4 — Gold** | **✅ Verified** |
| Stage 5 — Query + results | ⏳ Next |
| Stage 6 — Insight | ❌ Pending |

## Next Steps

1. **Stage 5 — Query + results** — delegate to `@sql-builder`: one query per sub-question against `gold.mart_subscriber_health`, output to `03-queries.sql` → `03-results.md`. Checkpoint 5.
2. **Stage 6 — Insight** — delegate to `@insight-writer`: 5-component insight + recommendations + self-check → `04-insight.md`. Checkpoint 6.
3. **Close Case 03** — mark complete, update progress snapshot.

---

## Session Continuation — Stage 5 Discussion

### Stage 5 Pipeline Understanding

- **Stage 5 queries pull from the gold mart** — `03-queries.sql` reads from `gold.mart_subscriber_health` (created in Stage 4).
- **Pipeline flow:** Stage 3 (Silver) → Stage 4 (Gold) → Stage 5 (Query) → Stage 6 (Insight)
- **Queries are translated from sub-questions** — each of the 12 sub-questions in `work/02-questions.md` becomes one SQL query in `work/03-queries.sql`.
- **Framework execution model:** SQL queries execute against PostgreSQL directly — the `.csv` file is not part of the framework pipeline.

### Key Clarifications

| Question | Answer |
|----------|--------|
| Do queries pull from the mart created in Stage 4? | Yes — `gold.mart_subscriber_health` |
| Are queries translated from sub-questions? | Yes — 12 sub-questions → 12 queries |
| Is the .csv file used by the framework? | No — framework queries PostgreSQL directly |
| What's the .csv for? | Manual backup/reference, not pipeline execution |

### CSV vs SQL Comparison

- **Exported `novatel-mart.csv`** (7,996 rows) and compared with `_gold.sql` definition.
- **Result:** 34 columns match exactly (names, order, data types, NULL handling).
- **Row count:** 7,996 data rows — matches expected count from `silver.billing`.

### Stage 5 Reference Files

| File | Purpose |
|------|---------|
| `02-questions.md` | 12 sub-questions (Q1–Q12) to write queries for |
| `01-scope.md` | Metric definitions (revenue, collection rate, ARPU, etc.) |
| `_gold.sql` | Verified gold mart — query target |
| `case.md` | Dataset limitation: MoM only, NO YoY |

---

## Session Continuation — Stage 5 Execution

**Time:** ~09:45 - 10:00

### Stage 5 Completed

- **sql-builder authored 12 queries** — one per sub-question, all against `gold.mart_subscriber_health`
- **Queries executed** — results captured in `03-results.md`
- **query-inspector QA gate** — verdict: PASS-WITH-NOTES (flagged Q9/Q11 grain mismatch)
- **progress-evaluator first check** — verdict: FAIL (grain mismatch on Q9/Q11)
- **Fix applied** — Q9 and Q11 changed from `COUNT(*)` to `COUNT(DISTINCT sub_id)` to collapse from billing-record grain to subscriber grain
- **Re-executed fixed queries** — corrected results obtained via Python/SQLite
- **progress-evaluator re-check** — verdict: PASS

### Key Learning: Grain Mismatch

The gold mart grain is **one row per bill_id**. The `has_churned` flag is a **subscriber-level** attribute LEFT JOINED in, so it appears on every billing row for a churned subscriber. Counting rows (`COUNT(*)`) inflates the metric by the number of bills per churned subscriber.

**Fix:** Use `COUNT(DISTINCT sub_id)` to collapse back to subscriber grain.

### Stage 5 Key Findings

| Metric | Dec-2025 | Jan-2026 | MoM Change |
|--------|----------|----------|------------|
| Billed Revenue | $203,420 | $175,870 | **-13.54%** |
| Collection Rate | 82.55% | 82.21% | -0.34pp |
| Active Subscribers | 4,287 | 3,709 | -13.48% |

**Churn Hotspots:** West (6.02%), Northeast (5.67%)
**Revenue Leakage:** Premium (19.02% non-payment), Starter (17.96%)

### Artifacts Updated

| File | Change |
|------|--------|
| `work/03-queries.sql` | 12 queries authored, Q9/Q11 fixed |
| `work/03-results.md` | Results captured, Q9/Q11 corrected |
| `work/query-analysis.md` | QA analysis from query-inspector |
| `work/verification-stage5.md` | First evaluation (FAIL) |
| `work/verification-stage5-2026-09-02.md` | Re-evaluation (PASS) |

---

## Current Case 03 Status

| Stage | Status |
|-------|--------|
| Stage 0 — Context | ✅ Complete |
| Stage 1 — Scope | ✅ Complete |
| Stage 2 — Questions | ✅ Complete |
| Stage 3 — Silver | ✅ Complete |
| Stage 4 — Gold | ✅ Verified |
| **Stage 5 — Query + results** | **✅ PASS** |
| Stage 6 — Insight | ⏳ Next |

## Next Steps

1. **Stage 6 — Insight** — delegate to `@insight-writer`: 5-component insight + recommendations + self-check → `04-insight.md`. Checkpoint 6.
2. **Close Case 03** — mark complete, update progress snapshot.

---

*Session saved. Continue later with Stage 6 (Insight).* 