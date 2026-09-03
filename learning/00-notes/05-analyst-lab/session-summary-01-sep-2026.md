# Summary: SQL Analyst Lab Session

**Date:** 1 September 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 03 (NovaTel) — Stages 0–4 COMPLETE (Context, Scope, Questions, Silver, Gold mart). All 4 checkpoints PASSED/PASS-WITH-NOTES by @progress-evaluator. Waiting for user approval before Stage 5 (Query + results).

---

## Completed

- **Case 03 (NovaTel Telecom) started** — resolved from the track registry as the next case after Case 02.
- **Stage 0 — Context** — read `case.md` + `datasets/03-advanced/README.md`. Captured business context (4,500 subscribers, 6 plans, 7 tables), the main question ("Is the subscriber base healthy, and where is revenue leaking?"), and the critical limitation (billing spans only 2 months — MoM only, NO YoY). Wrote `work/00-context.md`.
- **Stage 1 — Scope** — derived 3 Northstar metrics (Revenue billed, Payment collection rate, Active subscriber base) and 3 dimensions (Plan, Region, Month). Added secondary metrics (Unpaid/Overdue share, Churn count, ARPU) and KPI "why" dimensions (Usage tier, Ticket category). Wrote `work/01-scope.md`.
- **@progress-evaluator checkpoint — Stage 1: PASS** — all 5 MANDATORY checks passed (traceability, floor met, no metric-as-dimension confusion, explicit definitions, no forbidden comparison). Advisory notes: churn count is total not monthly, usage tier boundaries not concretized, ticket category positioning minor confusion risk. Report: `docs/04-progress-evaluator/verification-2026-09-01-scope.md`.
- **Stage 2 — Questions** — decomposed the main question into 12 sub-questions across 4 buckets: Overall Trends (Q1–Q3), Growth Rates (Q4–Q5), Performance Measurement (Q6–Q9), KPI Reporting (Q10–Q12). Each = one metric × one dimension from the scope pool. No YoY. No duplicates. Wrote `work/02-questions.md`.
- **@progress-evaluator checkpoint — Stage 2: PASS** — all 6 MANDATORY checks passed (bucket mapping, metric×dimension from scope, two-way coverage, lens correct, no duplicates, serves main question). Advisory: Usage tier and Ticket category (KPI "why" dimensions) were not consumed — acceptable per "floor, not cap" rule. Report: `docs/04-progress-evaluator/verification-2026-09-01-questions.md`.
- **Stage 3 — Bronze→Silver** — delegated to `@sql-builder`. Profiled the dataset, evaluated all 6 DQ dimensions: 5 applied (Completeness, Uniqueness, Validity, Accuracy, Consistency) + 1 N/A (Timeliness — structural 2-month limitation). Key findings: (1) 1,408/7,996 bills (17.6%) Unpaid/Overdue, (2) 2,580/7,418 usage logs (34.8%) exceed plan allowance, (3) 1,149/3,800 tickets (30.2%) unresolved, (4) 38 churned subs with unpaid bills. Silver enrichments: `_leakage_flag`, `_data_flag`, `_data_utilization_pct`, `_resolution_flag`, `_days_to_resolve`. All 27,735 bronze rows preserved (conform + flag, never drop). Wrote `work/_silver.sql` (238 lines).
- **@progress-evaluator checkpoint — Stage 3: PASS** — all 6 MANDATORY checks passed (all 6 DQ dimensions evaluated, no N/A without reason, applied subset covers all dataset quirks, row counts preserved, SQL valid, scope coverage complete). Report: `docs/04-progress-evaluator/verification-2026-09-01-silver.md`.
- **Stage 4 — Silver→Gold mart** — delegated to `@sql-builder`. Built denormalized mart `gold.mart_subscriber_health` with grain = one row per `bill_id` (unique key: `bill_id`). Joined 6 tables: billing (primary fact), subscribers, plans, usage_logs (aggregated), tickets (aggregated), churn. All joins many-to-one or one-to-one — no fan-out. Mart row count = 7,996 = `silver.billing`. Silver enrichments preserved (`_leakage_flag`, `_data_flag`, `_data_utilization_pct`, `_resolution_flag`, `_days_to_resolve`, `has_churned`). Verification query written but commented out (needs execution). Wrote `work/_gold.sql` (192 lines).
- **@progress-evaluator checkpoint — Stage 4: PASS-WITH-NOTES** — all 5 MANDATORY checks passed at design level. Note: verification query needs uncommenting and execution. Design is correct. Report: `docs/04-progress-evaluator/verification-2026-09-01-gold.md`.

## Key Takeaways (conceptual this session)

1. **Scope is a floor, not a cap.** Starting with 3 metrics × 3 dimensions is the minimum. Derived metrics and KPI "why" dimensions are valid additions when the business question demands deeper digging — they don't replace the core scope, they supplement it.
2. **The MoM-only constraint is a hard boundary.** NovaTel's billing spans exactly 2 months (Dec 2025, Jan 2026). Any time-series analysis must be MoM. YoY claims are forbidden and would be caught at the evaluator gate.
3. **Revenue leak = Unpaid + Overdue.** In this dataset, `billing.status IN ('Unpaid','Overdue')` is the direct signal. 1,408 of 7,996 bills (~17.6%) are not paid — that's the leakage the main question is asking about.
4. **Bucket lens discipline matters.** The 4 buckets aren't just labels — they enforce different analytical lenses: Trends = absolute level, Growth = % change, Performance = head-to-head, KPI = "why". Mixing lenses within a bucket would break the decomposition logic.
5. **Coverage check is critical before moving downstream.** Every metric and dimension in the scope must appear in at least one sub-question (no orphans), and no out-of-scope element should appear. This prevents wasted SQL work or hallucinated analysis.
6. **Conform + flag, never drop.** Silver cleaning preserves all rows and adds diagnostic flags (`_leakage_flag`, `_data_flag`, `_resolution_flag`). This keeps the full dataset intact for downstream analysis while making quality issues filterable.
7. **DQ dimensions are a lens, not a checklist.** Not all 6 dimensions apply to every dataset. Timeliness was N/A here because the 2-month span is a structural limitation, not a quality defect. Applying it blindly would waste effort.
8. **Grain choice is the most consequential design decision in the gold mart.** Choosing billing grain (one row per `bill_id`) preserves per-bill payment status — essential for collection rate queries. A coarser grain (subscriber) would lose the month dimension; a finer grain (line items) doesn't exist in this dataset.
9. **Aggregate before joining to prevent fan-out.** Pre-aggregating usage_logs and tickets by (sub_id, month) before joining to billing grain keeps the row count stable. Joining raw ticket rows would multiply billing rows.

## Artifacts Produced

| File | Description |
|------|-------------|
| `work/00-context.md` | Stage 0 context: business, dataset, limitations |
| `work/01-scope.md` | Stage 1 scope: metrics, dimensions, definitions, constraints |
| `work/02-questions.md` | Stage 2 questions: 12 sub-questions across 4 buckets |
| `work/_silver.sql` | Stage 3 silver cleaning SQL (238 lines, DDL + verification) |
| `work/_gold.sql` | Stage 4 gold mart DDL (192 lines, grain = bill_id) |
| `docs/04-progress-evaluator/verification-2026-09-01-scope.md` | Evaluator report: Stage 1 PASS |
| `docs/04-progress-evaluator/verification-2026-09-01-questions.md` | Evaluator report: Stage 2 PASS |
| `docs/04-progress-evaluator/verification-2026-09-01-silver.md` | Evaluator report: Stage 3 PASS |
| `docs/04-progress-evaluator/verification-2026-09-01-gold.md` | Evaluator report: Stage 4 PASS-WITH-NOTES |

## Mistakes / Notes

- None this session — clean execution of context + scope.

## Next Steps

1. **Await user approval** on Stage 4 gold mart before proceeding.
2. **Stage 5 — Query + results** (`03-queries.sql` → `03-results.md`): delegated to `@sql-builder`. One query per sub-question, gold mart only. Reuse `@query-inspector` as QA gate. Checkpoint 5 — @progress-evaluator verification, then pause for approval.
3. **Stage 6 — Insight** (`04-insight.md`): delegated to `@insight-writer`. 5-component insight + recommendations + self-check. Checkpoint 6.

---

*Session saved. Waiting for approval to continue to Stage 5 (Query + results).*
