# Data-to-Insight Skill — Runbook

Automates the 7-stage data-to-insight SQL analysis pipeline for a SQL Analyst Lab case (or any dataset), against a PostgreSQL medallion (`bronze.`/`silver.`/`gold.` schemas).

- **Canonical plan:** `agent-blueprints/03-data-to-insight.md`
- **Spec:** `openspec/specs/data-to-insight/spec.md`

## Prerequisites

1. PostgreSQL with the case's dataset loaded into the `bronze` schema. See `script/01-sql/data-to-insight/00-bootstrap.sql`.
2. A case folder with `case.md` + a `work/` dir.
3. A dataset README (business context + ERD/join hints + data quirks).

## How to invoke

Scope the skill to a case, e.g.:

- `run data-to-insight on Case 02`
- `run the analyst pipeline on MarketHub`
- `run data-to-insight on <path-to-case>`

## The 7 stages

| Stage | Artifact | Owner |
|---|---|---|
| 0 Context | — | orchestrator |
| 1 Scope | `01-scope.md` | orchestrator |
| 2 Questions | `02-questions.md` | orchestrator |
| 3 Bronze→Silver | `_silver.sql` | `@sql-builder` |
| 4 Silver→Gold | gold mart | `@sql-builder` |
| 5 Query | `03-queries.sql`, `03-results.md` | `@sql-builder` |
| 6 Insight | `04-insight.md` | `@insight-writer` |

## Checkpoints (human approval gates)

The pipeline pauses for your approval after: Scope, Questions, Silver, Gold mart, Queries+results, and final Insight. No downstream stage runs before you approve the current one.

## Key rules enforced

- Scope = ~3 metrics + ~3 dimensions as a **floor**; add more only if the question demands it.
- Decompose into **4 buckets** (Overall Trends / Growth Rates / Performance Measurement / KPI Reporting), one metric × one dimension per sub-question.
- Silver evaluates **all 6 DQ dimensions** (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) but applies only the effective subset.
- Gold declares **grain + unique key** and verifies `COUNT(*) = COUNT(DISTINCT <grain_key>)`.
- Queries read the **gold mart only** (never raw/bronze/silver).
- Insight must pass the **weak-vs-strong rubric** (Trend → Fluctuation → Anomaly → Root cause → Recommendation).

## Onboarding a new dataset

See `case-template/ONBOARD.md` and `case-template/case.md.template`.
