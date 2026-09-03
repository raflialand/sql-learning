---
name: data-to-insight
description: Automates the 7-stage data-to-insight SQL analysis pipeline (0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold mart → 5 Query mart → 6 Insight) for a SQL Analyst Lab case or any dataset, against a PostgreSQL medallion (bronze/silver/gold schemas). Writes artifacts (01-scope.md, 02-questions.md, _silver.sql, gold mart, 03-queries.sql/03-results.md, 04-insight.md) into the case's work/ folder and pauses for human approval at six checkpoints. Delegates SQL work (stages 3–5) to @sql-builder, insight synthesis (stage 6) to @insight-writer, checkpoint verification (stages 1–6) to @progress-evaluator (blocking gate), and reuses @query-inspector as a QA gate. Executes on explicit invocation scoped to a case (e.g. "run data-to-insight on Case 02").
---

# Data-to-Insight Skill

Canonical agent plan: `agent-blueprints/03-data-to-insight.md`. Read it for the full spec (Intention, Goals, Requirements, Input, Output, Workflow) and follow it exactly.

## Quick Reference

- **Case resolution:** Resolve the target case folder (e.g. `learning/02-sql-learning/sql-analyst-lab/02-markethub/`) from the trigger or ask. Read its `case.md` (main question + limitation notes) and the dataset README first.
- **7 stages, in order:** 0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold mart → 5 Query → 6 Insight. Write each artifact to the case's `work/` folder.
- **Delegation:** Stages 3–5 (SQL: silver, gold mart, queries + results) → `@sql-builder`. Stage 6 (insight) → `@insight-writer`. Generated queries → `@query-inspector` as a QA gate (output to `<case>/verification/`). Checkpoint verification (stages 1–6) → `@progress-evaluator` as a read-only blocking gate (output to `<case>/verification/`; FAIL blocks the checkpoint and routes the defect to the owning agent for fix-and-re-run). The orchestrator passes the case path to all delegated agents so they write verification files to `<case>/verification/`.
- **Checkpoints:** Pause for human approval after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight. Never run a downstream stage before the current gate is approved.
- **Key rules:** ~3 metrics + ~3 dimensions is a floor, not a cap; decompose into 4 buckets (Overall Trends / Growth Rates / Performance Measurement / KPI Reporting), one metric × one dimension per sub-question; silver evaluates all 6 DQ dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) but applies only the effective subset; silver profiling surfaces any profile-only scope gap (metric/dimension/quirk materially affecting a sub-question but absent from `01-scope.md`); such a finding routes to the orchestrator for a scope amendment — never to `sql-builder`; gold declares grain + unique key and verifies `COUNT(*) = COUNT(DISTINCT <grain_key>)`; queries read the gold mart only; insight must pass the weak-vs-strong rubric.

## Invariants

- Never query raw/bronze/silver at the query stage — gold mart only.
- Never skip a stage or run downstream before the current checkpoint is approved.
- Never author a comparison the dataset limitation forbids (e.g. telecom YoY).
- Never silently overwrite existing `work/` artifacts — surface for reconciliation at the gate.
- Never fabricate numbers or a root cause not traceable to a query result.
- Datasets and case `expected/` folders are read-only.
- This is an execution capability — it never creates OpenSpec change proposals; planning belongs to `@openspec-agent`.
- `@progress-evaluator` is read-only — it never authors or edits stage artifacts; it only grades and reports.
- Surface profile-only scope gaps at Silver and route them to the orchestrator for amendment — never to `sql-builder`.
