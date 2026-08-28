# Add Data-to-Insight AI Ecosystem

## Problem Statement

The learner has manually completed Case 01 (Brew & Co.) of `learning/02-sql-learning/sql-analyst-lab/`. That manual run is the proof that the lab's 7-stage "data-to-insight" pipeline works: read context → scope Northstar metrics/dimensions → decompose the main question into sub-questions → clean bronze→silver with the 6 data-quality dimensions → build a gold mart → query the mart → synthesize strong insights with recommendations. Every one of those stages was executed by hand.

Nothing in the repository automates that pipeline. Cases 02 (MarketHub, 8-table ecommerce) and 03 (NovaTel, 7-table telecom) still require the learner to repeat the same manual discipline from scratch, and every future dataset would too. The `sql-analyst-lab` capability formalizes the *module* (case folders, expected model answers, read-only dataset reuse), but it has no executable agent surface that *performs* the analysis. The gap is not more content — it is a repeatable AI capability that walks the canonical recipe and produces the case artifacts.

## Proposed Solution

Add a new capability — `data-to-insight` — an AI ecosystem that automates the data-to-insight SQL analysis pipeline for the SQL Analyst Lab (and any future dataset), reproducing the learner's manual 7-stage recipe under a **checkpointed-autonomy** contract (human approval at each gate). The capability ships:

- **Orchestrator skill `data-to-insight`** — walks stages 0→6, writes artifacts into the case's `work/` folder, and pauses for human approval at six checkpoints (after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight).
- **`sql-builder` subagent** — the technical heart: authors the silver cleaning SQL (6 DQ dimensions), the gold mart (with explicit grain + unique-key declaration and row-uniqueness verification), and the per-sub-question queries; executes them against PostgreSQL; captures verified results.
- **`insight-writer` subagent** — synthesizes the 5-component insight (Trend, Fluctuation, Anomaly, Root cause, Recommendation) + recommendations + self-check against the weak-vs-strong insight rubric.
- **Reuse of the existing `query-inspector` agent** — as a QA gate on generated queries, without modifying its contract.
- **Canonical blueprint** `agent-blueprints/03-data-to-insight.md` — the single plan that all three components follow.

The pipeline targets PostgreSQL (true medallion: `bronze.`/`silver.`/`gold.` schemas), loading the existing PostgreSQL dataset variants `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce_pg.sql` and `.../03-advanced/telecom_pg.sql`. Case 02/03 artifacts are written to `learning/02-sql-learning/sql-analyst-lab/02-markethub/work/` and `03-novatel/work/`, validated against the `expected/` model answers already present in each case.

### Why this is a capability change, not a data/document task

`AGENTS.md` states: "OpenSpec is for project capabilities, not for data or document tasks." This is a **capability** change for the same reasons `add-sql-analyst-lab` and `add-medallion-lab` were:

1. **It is a repeatable executor, not a one-off output.** The orchestrator skill + two subagents + blueprint are a durable agent surface that can be re-invoked for Case 02, Case 03, and any future dataset to deterministically reproduce the 7-stage pipeline. The *capability that produces the case artifacts* is the durable asset, not any single `work/` file.
2. **It has a behavioral contract that needs a spec.** Input contract (case folder + dataset README + PostgreSQL), output contract (`01-scope.md`, `02-questions.md`, `_silver.sql`, gold mart, `03-queries.sql`/`03-results.md`, `04-insight.md`), the 6 DQ dimensions, the gold grain + unique-key verification, the gold-mart-only query rule, the 5-component insight rubric, checkpointed autonomy gates, failure behavior, and quality acceptance criteria validated against `expected/`. These are exactly the SHALL / GIVEN-WHEN-THEN guarantees OpenSpec exists to formalize.
3. **It extends the project's capability surface.** It adds a new skill (`.opencode/skills/data-to-insight/`), two new subagents (`.opencode/agents/sql-builder.md`, `.opencode/agents/insight-writer.md`), a new canonical blueprint (`agent-blueprints/03-data-to-insight.md`), and new agent-routing registry entries in `AGENTS.md` — mirroring how `learning-progress` and `query-inspector` were formalized as capabilities.
4. **Contrast with a true data/document task.** Producing the *analysis itself* (running one case once, or writing one report) is execution-domain work. This change adds the *automated analyst* that produces those artifacts on demand — the automation machinery is the capability, and it follows the project's established convention that domain/execution agents never create their own change proposals (planning stays with `openspec-agent`).

## Scope

### In scope

- Creating the `data-to-insight` orchestrator skill at `.opencode/skills/data-to-insight/SKILL.md` (YAML frontmatter `name` + `description`, pointer to the canonical blueprint, trigger/checkpoint behavior).
- Creating the `sql-builder` subagent at `.opencode/agents/sql-builder.md` and the `insight-writer` subagent at `.opencode/agents/insight-writer.md` (YAML frontmatter with `description` and `mode: subagent`).
- Creating the canonical blueprint `agent-blueprints/03-data-to-insight.md` documenting the full 7-stage recipe (stages 0→6), the input/output contract, and the subagent delegation rules.
- Registering `data-to-insight`, `sql-builder`, and `insight-writer` in the `AGENTS.md` routing registry (Planning/domain-agent tables) and updating the root `README.md` directory map.
- Authoring the `data-to-insight` capability spec delta (this change); the canonical spec is created at archive time.
- Documenting the two target cases (Case 02 MarketHub, Case 03 NovaTel) as the capability's first executions, with the PostgreSQL datasets `ecommerce_pg.sql` and `telecom_pg.sql` as the load sources and `expected/` folders as validation ground truth.

### Out of scope

- **Phase 2 implementation** — actual creation of the skill/agent/blueprint files and execution of Case 02/03 is deferred until this proposal is approved. This change only produces the Phase 1 proposal artifacts.
- Any modification of `learning/02-sql-learning/sql-skill-push/` — datasets, `.sql`/`.db` files, tools, challenges, and READMEs remain byte-identical (read-only reuse by relative path).
- Changes to the `sql-analyst-lab` module or spec — the ecosystem *consumes* the case folders (`case.md`, `expected/`, `work/`) without modifying the module's contract.
- Changes to the `query-inspector` agent or spec — reuse as a QA gate is a declared dependency, not a modification.
- Changes to the `learning-progress` skill, blueprint, manifest, or spec — no new track is registered; progress tracking is out of scope for this capability.
- Creating ADRs or modifying OpenSpec methodology files (`openspec/AGENTS.md`, `openspec/specs/spec-format/`, `openspec/specs/service-capability-template/`, `openspec/specs/archive-safety/`).
- Modifying archived changes under `openspec/changes/archive/`.
- Making any git commits.

## Capabilities

### New Capabilities

- `data-to-insight`

### Modified Capabilities

- None

## Value Proposition

After this change, the learner (or any future dataset owner) can point the `data-to-insight` skill at a case and have the full analyst workflow executed reproducibly — with human sign-off at every gate so no stage runs unchecked. The same discipline the learner practiced manually in Case 01 becomes a reusable, inspectable automation: scope stays at a ~3-metric / ~3-dimension floor instead of "all metrics by all dimensions", sub-questions stay mapped to the four buckets, silver cleaning evaluates all six DQ dimensions before applying only the effective subset, the gold mart declares its grain and proves row uniqueness before any query runs, queries touch the gold mart only, and insights are graded against the weak-vs-strong rubric before delivery. It closes the loop the `sql-analyst-lab` module opened — turning the lab's framework from a manual exercise into a project capability the learner can re-run, extend, and reuse for Case 02, Case 03, and any dataset that arrives next.
