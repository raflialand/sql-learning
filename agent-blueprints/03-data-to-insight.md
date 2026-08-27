# Agent Blueprint: Data-to-Insight Skill

The canonical plan for the `data-to-insight` agent ecosystem (orchestrator skill + `sql-builder` + `insight-writer` subagents). Implemented by `.opencode/skills/data-to-insight/SKILL.md`, `.opencode/agents/sql-builder.md`, and `.opencode/agents/insight-writer.md`.

---

## 1. Intention

Why this ecosystem exists:

- The learner manually completed Case 01 (Brew & Co.) of `learning/02-sql-learning/sql-analyst-lab/`, proving a 7-stage "data-to-insight" pipeline: read context → scope Northstar metrics/dimensions → decompose the main question into sub-questions → clean bronze→silver with the 6 data-quality dimensions → build a gold mart → query the mart → synthesize strong insights with recommendations.
- Cases 02 (MarketHub) and 03 (NovaTel) — and any future dataset — would otherwise require repeating that same manual discipline from scratch.
- The ecosystem encodes that recipe as a repeatable, checkpointed automation: an orchestrator walks the stages, delegates SQL work and insight writing to specialized subagents, and pauses for human approval at every gate.

---

## 2. Goals

Measurable success criteria:

- **G1 — Reproducible artifacts.** Each stage writes its artifact (`01-scope.md`, `02-questions.md`, `_silver.sql`, gold mart, `03-queries.sql`/`03-results.md`, `04-insight.md`) into the resolved case's `work/` folder.
- **G2 — Gold-mart-only queries.** Every query reads the gold mart only — never raw, bronze, or silver tables.
- **G3 — Proven mart grain.** The gold mart declares its grain and unique key, and `COUNT(*) = COUNT(DISTINCT <grain_key>)` holds before any query runs.
- **G4 — Strong insights.** The final `04-insight.md` passes the weak-vs-strong rubric (Trend → Fluctuation → Anomaly → Root cause → Recommendation) defined in `learning/04-data-to-insight/data-to-insight.md`.
- **G5 — Checkpointed control.** No downstream stage executes before the current checkpoint is approved by the human.
- **G6 — Robustness.** Handles a missing case folder/README/dataset, a dataset limitation note (e.g. NovaTel MoM-only), and prior artifacts already in `work/` — never silently overwrites or fabricates.

---

## 3. Requirements

### Prerequisites

- A resolvable case folder containing `case.md` (main question + limitation notes) and a `work/` directory.
- A dataset README describing business context, ERD/join hints, and data quirks.
- A PostgreSQL instance with the case's dataset loaded into `bronze.`/`silver.`/`gold.` schemas (source datasets: `ecommerce_pg.sql`, `telecom_pg.sql`).
- `learning/04-data-to-insight/data-to-insight.md` — the weak-vs-strong insight rubric and Running Log source.

### Invariants (must never be violated)

- NEVER query raw/bronze/silver at the query stage — queries read the gold mart only.
- NEVER skip a stage or execute a downstream stage before the current checkpoint is approved.
- NEVER declare a YoY (or any) comparison that the dataset's limitation note forbids.
- NEVER silently overwrite existing `work/` artifacts — surface them for human reconciliation at the relevant checkpoint.
- NEVER fabricate numbers, results, or a root cause that is not traceable to a query result.
- Scope is a floor, not a ceiling: start from ~3 metrics + ~3 dimensions and add more only when a specific sub-question demands it.
- Silver evaluates all six DQ dimensions but applies only the effective subset, documenting every skipped dimension as N/A with a reason.
- Gold declares grain + unique key and verifies `COUNT(*) = COUNT(DISTINCT <grain_key>)` before querying.
- Datasets (`learning/02-sql-learning/sql-skill-push/`) and case `expected/` folders are read-only.

### Non-goals

- Not a progress tracker — `learning-progress` owns session notes and progress reporting.
- Not a change-proposal author — the ecosystem is an execution capability; planning stays with `@openspec-agent`.
- Does not modify datasets, the `sql-analyst-lab` module, or the `query-inspector` agent.

---

## 4. Input

### Triggers

The orchestrator is invoked against a specific case, e.g. "run data-to-insight on Case 02" / "run the analyst pipeline on MarketHub" / a direct skill invocation scoped to a case folder.

### Case resolution

- An explicit case reference (`01-brew-and-co`, `02-markethub`, `03-novatel`, or a path) → that case.
- Otherwise, ask which `sql-analyst-lab` case (or dataset) to analyze.

### Data sources (in priority order)

1. Dataset README — business context, ERD/join hints, data quirks (the "read before solving" notes).
2. `case.md` — the main question + dataset limitation notes.
3. The loaded PostgreSQL dataset (`bronze.`/`silver.`/`gold.` schemas).
4. `expected/` model answers — read-only ground truth for self-validation.

---

## 5. Output

### Artifacts (written to the case's `work/` folder)

| Stage | Artifact | Owner |
|---|---|---|
| 1 Scope | `01-scope.md` | orchestrator |
| 2 Questions | `02-questions.md` | orchestrator |
| 3 Bronze→Silver | `_silver.sql` (+ any silver DDL) | `sql-builder` |
| 4 Silver→Gold | gold mart DDL/definition | `sql-builder` |
| 5 Query | `03-queries.sql`, `03-results.md` | `sql-builder` |
| 6 Insight | `04-insight.md` | `insight-writer` |

### Checkpoint gates (pause for human approval)

1. After Scope (`01-scope.md`)
2. After Questions (`02-questions.md`)
3. After Silver (`_silver.sql`)
4. After Gold mart
5. After Queries + results (`03-results.md`)
6. After final Insight (`04-insight.md`)

---

## 6. Workflow — the 7-stage recipe

### Stage 0 — Context

1. Read the dataset README: business context, ERD/join hints, data quirks.
2. Read `case.md`: the main question + dataset limitation notes.
3. Surface any limitation (e.g. NovaTel billing spans only 2025-12-01 and 2026-01-01 → MoM only, NO YoY) to the user and carry it as a hard constraint for all downstream stages.

### Stage 1 — Scope (`01-scope.md`)

1. Fix approximately three Northstar metrics + approximately three dimensions as a **floor** (not a hard cap).
2. Add a metric/dimension beyond the floor only if the business question genuinely requires it, and only if it maps to a specific sub-question.
3. Record exact definitions for any metric with multiple plausible interpretations (a "Definitions fixed here" section).

### Stage 2 — Questions (`02-questions.md`)

1. Decompose the main question into sub-questions mapped to exactly four buckets: Overall Trends, Growth Rates, Performance Measurement, KPI Reporting.
2. Each sub-question = one metric × one dimension.
3. Do NOT author any sub-question that requests a forbidden comparison (per the limitation note).

### Stage 3 — Bronze→Silver (`_silver.sql`) — delegated to `sql-builder`

1. Profile the dataset.
2. Evaluate all six DQ dimensions — Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness.
3. Apply only the subset effective for the current case; document each skipped dimension as N/A with a reason.

### Stage 4 — Silver→Gold (mart) — delegated to `sql-builder`

1. DECLARE the grain ("one row per what?").
2. DECLARE the unique key (what makes a row distinct).
3. Build the denormalized mart from the silver layer.
4. VERIFY `COUNT(*) = COUNT(DISTINCT <grain_key>)` before any query runs.

### Stage 5 — Query (`03-queries.sql` → `03-results.md`) — delegated to `sql-builder`

1. One query per sub-question, `GROUP BY` over the mart grain.
2. Query the gold mart only.
3. Execute against PostgreSQL and capture verified results into `03-results.md`.
4. Reuse `query-inspector` as a QA gate before results are locked in.

### Stage 6 — Insight (`04-insight.md`) — delegated to `insight-writer`

1. Running log → 5 components (Trend, Fluctuation, Anomaly, Root cause, Recommendation) → insight paragraph → recommendations → self-check.
2. Grade against the weak-vs-strong rubric; strengthen any weak insight before delivery.

---

## 7. Implementation Mapping

| File | Role |
|---|---|
| `agent-blueprints/03-data-to-insight.md` | This canonical plan |
| `.opencode/skills/data-to-insight/SKILL.md` | Thin skill file: frontmatter + triggers + pointer to this plan + delegation rules |
| `.opencode/agents/sql-builder.md` | SQL subagent (stages 3–5) |
| `.opencode/agents/insight-writer.md` | Insight subagent (stage 6) |
| `.opencode/agents/query-inspector.md` | Reused QA gate (unchanged) |
| `learning/04-data-to-insight/data-to-insight.md` | Pedagogy source (4-step framework + Running Log + weak-vs-strong rubric) |
