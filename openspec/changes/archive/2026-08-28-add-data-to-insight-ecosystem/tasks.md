# Add Data-to-Insight AI Ecosystem — Implementation Tasks

> These tasks implement Phase 2. The canonical spec (`openspec/specs/data-to-insight/spec.md`) is created from the delta spec at archive time and is intentionally NOT listed here.

## Phase 1: Canonical Blueprint

### Step 1.1: Author the canonical blueprint

Create `agent-blueprints/03-data-to-insight.md` documenting the full 7-stage recipe and contracts:

- **Intention / Goals** — why the ecosystem exists, measurable success criteria (reproducible case artifacts, gold-mart-only queries, strong-insight rubric passes).
- **Stage 0 — Context**: read the dataset README (business context, ERD/join hints, data quirks) + `case.md` main question + limitation notes.
- **Stage 1 — Scope** (`01-scope.md`): ~3 Northstar metrics + ~3 dimensions as a **floor** (not a hard cap); add more only if the business question genuinely requires them; every added metric/dimension maps to a sub-question.
- **Stage 2 — Questions** (`02-questions.md`): decompose the main question into sub-questions mapped to 4 buckets (Overall Trends, Growth Rates, Performance Measurement, KPI Reporting); one metric × one dimension per sub-question.
- **Stage 3 — Bronze→Silver** (`_silver.sql`): apply the 6 DQ dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness); profile the dataset, EVALUATE ALL 6, APPLY ONLY the effective subset; document skipped dimensions as N/A with reason.
- **Stage 4 — Silver→Gold** (gold mart): DECLARE THE GRAIN ("one row per what?") and the UNIQUE KEY, build the denormalized mart, then VERIFY `COUNT(*) = COUNT(DISTINCT <grain_key>)` before querying.
- **Stage 5 — Query** (`03-queries.sql` → `03-results.md`): query the GOLD MART ONLY (never raw/bronze/silver); one query per sub-question; GROUP BY over mart grain; execute against PostgreSQL; capture verified results.
- **Stage 6 — Insight** (`04-insight.md`): running log → 5 components (Trend, Fluctuation, Anomaly, Root cause, Recommendation) → insight paragraph → recommendations → self-check against the weak-vs-strong rubric in `learning/04-data-to-insight/data-to-insight.md`.
- **Subagent delegation rules** — `sql-builder` owns stages 3–5; `insight-writer` owns stage 6; orchestrator owns 0–2 + sequencing + checkpoints.
- **Checkpoint gates** — pause for human approval after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight.

**Verification**: The blueprint contains all seven stages (0→6), the six checkpoints, the 6 DQ dimensions, the grain + unique-key declaration requirement, the gold-mart-only rule, and the delegation split — matching the recipe in the proposal/design.

## Phase 2: Orchestrator Skill

### Step 2.1: Author the orchestrator skill

Create `.opencode/skills/data-to-insight/SKILL.md` with YAML frontmatter (`name: data-to-insight`, a `description` covering what it automates and its trigger surface) and a thin body pointing to `agent-blueprints/03-data-to-insight.md`, listing the six checkpoint gates, and declaring its subagent delegation (delegate SQL to `@sql-builder`, insight to `@insight-writer`, QA to `@query-inspector`).

**Verification**: The SKILL.md frontmatter has `name` + `description`; the body points to the blueprint and names all three subagents; it matches the `.opencode/skills/learning-progress/SKILL.md` thin-pointer convention.

## Phase 3: Subagents

### Step 3.1: Author the sql-builder subagent

Create `.opencode/agents/sql-builder.md` with YAML frontmatter (`description`, `mode: subagent`), purpose, inputs (case context, silver/gold schema), outputs (`_silver.sql`, gold mart DDL, `03-queries.sql`, `03-results.md`), behavior (author + execute PostgreSQL for stages 3–5, declare grain + unique key, verify uniqueness, gold-mart-only queries), and boundaries (never writes narrative insight; never creates change proposals; does not modify datasets).

**Verification**: Frontmatter has `mode: subagent`; the file describes stages 3–5, the 6 DQ dimensions, grain/unique-key declaration + verification, and gold-mart-only querying — matching `.opencode/agents/query-inspector.md` structure.

### Step 3.2: Author the insight-writer subagent

Create `.opencode/agents/insight-writer.md` with YAML frontmatter (`description`, `mode: subagent`), purpose, inputs (verified results + running log), outputs (`04-insight.md`), behavior (5-component synthesis, insight paragraph, recommendations, weak-vs-strong self-check), and boundaries (never authors or executes SQL; never creates change proposals).

**Verification**: Frontmatter has `mode: subagent`; the file describes stage 6 only and references the weak-vs-strong rubric in `learning/04-data-to-insight/data-to-insight.md`.

## Phase 4: Registry + Docs

### Step 4.1: Register the new agents in the routing registry

Edit `AGENTS.md`:
- Add `data-to-insight` to the Planning/domain surface as an execution capability (orchestrator skill, checkpointed autonomy).
- Add `sql-builder` and `insight-writer` to the Domain agents table (execution subagents invoked by `data-to-insight`; they SHALL NOT create OpenSpec change proposals).
- Note the `query-inspector` reuse as a QA gate.

**Verification**: `AGENTS.md` Domain agents table lists `sql-builder` and `insight-writer` with their purposes; the `data-to-insight` skill is referenced; no domain agent is described as creating change proposals.

### Step 4.2: Update the root README

Edit `README.md`: add the `data-to-insight` capability to the directory map (`.opencode/skills/data-to-insight/`, `.opencode/agents/sql-builder.md`, `.opencode/agents/insight-writer.md`, `agent-blueprints/03-data-to-insight.md`) and to the capability/skill surface description.

**Verification**: `README.md` directory map and capability list reference all four new paths; no broken references.

### Step 4.3: Append the changes-log entry

Append `change #19: add data-to-insight AI ecosystem (automated 7-stage data-to-insight pipeline; data-to-insight skill + sql-builder + insight-writer + blueprint 03)` to `changes-log.txt` following the established style: skill + subagents created, blueprint created, registry/README updated, `query-inspector` reused as QA gate, PostgreSQL medallion target (`ecommerce_pg.sql` / `telecom_pg.sql`), first execution targets Case 02/03 `work/`.

**Verification**: Entry appended; style matches previous entries; only `AGENTS.md`, `README.md`, and `changes-log.txt` are modified.

## Phase 5: Validation (first executions)

### Step 5.1: Execute Case 02 (MarketHub)

Invoke the `data-to-insight` skill against `learning/02-sql-learning/sql-analyst-lab/02-markethub/`, loading `ecommerce_pg.sql` into PostgreSQL, walking stages 0→6 with human approval at each checkpoint, writing artifacts to `02-markethub/work/`.

**Verification**: `work/` contains `01-scope.md`, `02-questions.md`, `_silver.sql`, gold mart artifacts, `03-queries.sql`, `03-results.md`, `04-insight.md`; `03-results.md` matches `expected/03-results.md`; gold-mart uniqueness `COUNT(*) = COUNT(DISTINCT grain_key)` holds.

### Step 5.2: Execute Case 03 (NovaTel)

Invoke the `data-to-insight` skill against `learning/02-sql-learning/sql-analyst-lab/03-novatel/`, loading `telecom_pg.sql`, walking stages 0→6 with checkpoints, writing artifacts to `03-novatel/work/`, honoring the MoM-only limitation (no YoY fabricated).

**Verification**: `work/` contains all seven artifacts; no YoY sub-query exists (limitation honored); `03-results.md` matches `expected/03-results.md`; insights pass the weak-vs-strong self-check.

## Summary of Changes

| Category          | Before | After |
| ----------------- | ------ | ----- |
| Orchestrator skill | (none) | `.opencode/skills/data-to-insight/SKILL.md` — CREATED |
| Subagent — SQL     | (none) | `.opencode/agents/sql-builder.md` — CREATED |
| Subagent — insight | (none) | `.opencode/agents/insight-writer.md` — CREATED |
| Canonical blueprint | (none) | `agent-blueprints/03-data-to-insight.md` — CREATED |
| Routing registry | no data-to-insight agents | `AGENTS.md` — MODIFIED (3 entries) |
| Root README | no data-to-insight capability | `README.md` — MODIFIED (directory map + capability surface) |
| Changes log | #18 last | `changes-log.txt` — MODIFIED (change #19) |
| Delta spec | (none) | `openspec/changes/add-data-to-insight-ecosystem/specs/data-to-insight/spec.md` — CREATED (ADDED) |
| Canonical spec | (none) | `openspec/specs/data-to-insight/spec.md` — CREATED at archive time from delta (not in tasks) |
| Case artifacts (Phase 2) | `work/` empty | `02-markethub/work/*` + `03-novatel/work/*` — CREATED by first executions |
