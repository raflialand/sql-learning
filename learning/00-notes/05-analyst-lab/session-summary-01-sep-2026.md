# Summary: SQL Analyst Lab Session

**Date:** 1 September 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 03 (NovaTel) — Stage 0 (Context) + Stage 1 (Scope) + Stage 2 (Questions) COMPLETE. Both checkpoints PASSED by @progress-evaluator. Waiting for user approval before Stage 3 (Bronze→Silver).

---

## Completed

- **Case 03 (NovaTel Telecom) started** — resolved from the track registry as the next case after Case 02.
- **Stage 0 — Context** — read `case.md` + `datasets/03-advanced/README.md`. Captured business context (4,500 subscribers, 6 plans, 7 tables), the main question ("Is the subscriber base healthy, and where is revenue leaking?"), and the critical limitation (billing spans only 2 months — MoM only, NO YoY). Wrote `work/00-context.md`.
- **Stage 1 — Scope** — derived 3 Northstar metrics (Revenue billed, Payment collection rate, Active subscriber base) and 3 dimensions (Plan, Region, Month). Added secondary metrics (Unpaid/Overdue share, Churn count, ARPU) and KPI "why" dimensions (Usage tier, Ticket category). Wrote `work/01-scope.md`.
- **@progress-evaluator checkpoint — Stage 1: PASS** — all 5 MANDATORY checks passed (traceability, floor met, no metric-as-dimension confusion, explicit definitions, no forbidden comparison). Advisory notes: churn count is total not monthly, usage tier boundaries not concretized, ticket category positioning minor confusion risk. Report: `docs/04-progress-evaluator/verification-2026-09-01-scope.md`.
- **Stage 2 — Questions** — decomposed the main question into 12 sub-questions across 4 buckets: Overall Trends (Q1–Q3), Growth Rates (Q4–Q5), Performance Measurement (Q6–Q9), KPI Reporting (Q10–Q12). Each = one metric × one dimension from the scope pool. No YoY. No duplicates. Wrote `work/02-questions.md`.
- **@progress-evaluator checkpoint — Stage 2: PASS** — all 6 MANDATORY checks passed (bucket mapping, metric×dimension from scope, two-way coverage, lens correct, no duplicates, serves main question). Advisory: Usage tier and Ticket category (KPI "why" dimensions) were not consumed — acceptable per "floor, not cap" rule. Report: `docs/04-progress-evaluator/verification-2026-09-01-questions.md`.

## Key Takeaways (conceptual this session)

1. **Scope is a floor, not a cap.** Starting with 3 metrics × 3 dimensions is the minimum. Derived metrics and KPI "why" dimensions are valid additions when the business question demands deeper digging — they don't replace the core scope, they supplement it.
2. **The MoM-only constraint is a hard boundary.** NovaTel's billing spans exactly 2 months (Dec 2025, Jan 2026). Any time-series analysis must be MoM. YoY claims are forbidden and would be caught at the evaluator gate.
3. **Revenue leak = Unpaid + Overdue.** In this dataset, `billing.status IN ('Unpaid','Overdue')` is the direct signal. 1,408 of 7,996 bills (~17.6%) are not paid — that's the leakage the main question is asking about.
4. **Bucket lens discipline matters.** The 4 buckets aren't just labels — they enforce different analytical lenses: Trends = absolute level, Growth = % change, Performance = head-to-head, KPI = "why". Mixing lenses within a bucket would break the decomposition logic.
5. **Coverage check is critical before moving downstream.** Every metric and dimension in the scope must appear in at least one sub-question (no orphans), and no out-of-scope element should appear. This prevents wasted SQL work or hallucinated analysis.

## Artifacts Produced

| File | Description |
|------|-------------|
| `work/00-context.md` | Stage 0 context: business, dataset, limitations |
| `work/01-scope.md` | Stage 1 scope: metrics, dimensions, definitions, constraints |
| `work/02-questions.md` | Stage 2 questions: 12 sub-questions across 4 buckets |
| `docs/04-progress-evaluator/verification-2026-09-01-scope.md` | Evaluator report: Stage 1 PASS |
| `docs/04-progress-evaluator/verification-2026-09-01-questions.md` | Evaluator report: Stage 2 PASS |

## Mistakes / Notes

- None this session — clean execution of context + scope.

## Next Steps

1. **Await user approval** on Stage 2 questions before proceeding.
2. **Stage 3 — Bronze→Silver** (`_silver.sql`): delegated to `@sql-builder`. Profile the dataset, evaluate all 6 DQ dimensions, apply the effective subset, document skipped dimensions as N/A with reason. Checkpoint 3 — @progress-evaluator verification, then pause for approval.
3. **Stage 4 — Silver→Gold** (mart): delegated to `@sql-builder`. Declare grain + unique key, build denormalized mart, verify COUNT(*) = COUNT(DISTINCT grain_key). Checkpoint 4.
4. **Stage 5 — Query** (`03-queries.sql` → `03-results.md`): delegated to `@sql-builder`. One query per sub-question, gold mart only. Checkpoint 5.
5. **Stage 6 — Insight** (`04-insight.md`): delegated to `@insight-writer`. 5-component insight + recommendations + self-check. Checkpoint 6.

---

*Session saved. Waiting for approval to continue to Stage 3 (Bronze→Silver).*
