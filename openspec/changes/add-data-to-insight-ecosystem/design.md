# Add Data-to-Insight AI Ecosystem — Design

## Overview

The change adds a new **service/operation capability** — `data-to-insight` — an AI ecosystem that automates the 7-stage data-to-insight SQL analysis pipeline. Three implementation components work together under one canonical blueprint:

1. **Orchestrator skill** `.opencode/skills/data-to-insight/SKILL.md` — owns stage sequencing, artifact writing to the case `work/` folder, and the checkpointed-autonomy gates (human approval before proceeding past each gate).
2. **`sql-builder` subagent** `.opencode/agents/sql-builder.md` — owns stages 3 (bronze→silver), 4 (silver→gold mart), and 5 (query + results). It declares the mart grain + unique key, verifies row uniqueness, authors and executes PostgreSQL, and captures verified results.
3. **`insight-writer` subagent** `.opencode/agents/insight-writer.md` — owns stage 6 (insight synthesis): running log → 5 components → insight paragraph → recommendations → weak-vs-strong self-check.

The **existing `query-inspector` agent** is reused as a QA gate on generated queries. The canonical blueprint `agent-blueprints/03-data-to-insight.md` is the single source of truth all three components follow.

Because this is a service/operation capability (an orchestrated pipeline with checkpoints), the delta spec's ADDED requirements are structured around the `service-capability-template` contracts (Input Contract, Output Contract, stage contracts, Failure Behavior, Quality Acceptance Criteria, Cross-Capability Dependency).

## Design Decisions

### Decision 1: New capability `data-to-insight`, not an extension of `sql-analyst-lab`

**Choice**: Create a new capability folder `data-to-insight` with its own spec. Do not extend `sql-analyst-lab`.
**Rationale**: `sql-analyst-lab` is the *module* spec (case folder anatomy, expected model answers, read-only dataset reuse, track registration). `data-to-insight` is the *automation executor* spec (agent surface, stage contracts, checkpointed autonomy, SQL execution). Different contracts — mixing them would blur the module-vs-executor boundary and force a MODIFIED delta on a spec whose scope is intentionally content-shaped.

### Decision 2: Three components (orchestrator + 2 subagents) under one capability, not three capabilities

**Choice**: One spec governs the skill and both subagents as a single `data-to-insight` capability. No separate specs for `sql-builder` or `insight-writer`.
**Rationale**: The three components form one behavioral surface: the orchestrator cannot complete the pipeline without the two subagents, and the subagents have no independent trigger surface of their own (they are invoked by the orchestrator). This mirrors `learning-progress` (one skill + one blueprint = one spec) and `medallion-lab` (orchestrator + SQL scripts = one spec). Splitting would fragment one pipeline contract into three thin specs with no standalone value.

### Decision 3: CHECKPOINTED autonomy, not full autonomy

**Choice**: The orchestrator pauses for human approval at six checkpoints — after Scope (stage 1), Questions (stage 2), Silver (stage 3), Gold mart (stage 4), Queries+results (stage 5), and final Insight (stage 6). No downstream stage executes before the current gate is approved.
**Rationale**: Data-to-insight conclusions are judgment calls (which metric is the Northstar, which root cause to chase). Full autonomy would let a subagent fabricate an unsupported comparison (e.g. a telecom YoY that the dataset cannot support — Case 03's explicit limitation). Checkpoints keep the learner in control at exactly the points where the recipe says "fix the definition before touching data". This is the user-approved architecture, kept as-is.

### Decision 4: PostgreSQL true medallion (bronze/silver/gold schemas)

**Choice**: Target engine is PostgreSQL 18, with the three layers materialized as `bronze.`, `silver.`, and `gold.` schemas. The datasets to load are the existing PostgreSQL variants `ecommerce_pg.sql` (MarketHub) and `telecom_pg.sql` (NovaTel).
**Rationale**: The manual Case 01 run used SQLite (`.db`) and the existing `sql-analyst-lab` verification helper `run_query.py`. This capability deliberately upgrades to PostgreSQL schemas to model a real medallion architecture — the same discipline the `medallion-lab` capability teaches, now applied to the analyst pipeline. The `_pg.sql` variants already exist in `sql-skill-push/datasets/`, so no new dataset artifacts are authored; only loading is performed.

### Decision 5: The 7-stage recipe is the canonical blueprint (stages 0→6)

**Choice**: Encode the exact 7-stage recipe the learner practiced manually as the blueprint: 0 Context, 1 Scope, 2 Questions, 3 Bronze→Silver, 4 Silver→Gold, 5 Query, 6 Insight.
**Rationale**: The recipe is the durable intellectual asset — it reproduces the manual workflow verbatim. The blueprint is the single source of truth; the skill file is a thin pointer to it (mirroring the `learning-progress` skill/blueprint split), and the subagents implement disjoint slices of it (stages 3–5 for `sql-builder`, stage 6 for `insight-writer`).

### Decision 6: `sql-builder` owns stages 3–5; `insight-writer` owns stage 6; orchestrator owns 0–2 + sequencing

**Choice**: Role separation by stage. `sql-builder` authors and executes SQL only (silver, gold mart, queries). `insight-writer` synthesizes narrative only (insight + recommendations + rubric self-check). The orchestrator performs context/scoping/decomposition and delegates SQL and insight work.
**Rationale**: SQL authoring and insight narrative are different disciplines with different failure modes. Keeping them in separate subagents makes each contract testable in isolation (SQL correctness vs rubric quality) and prevents a single agent from silently blurring "what the query proves" into "what the narrative claims".

### Decision 7: Reuse `query-inspector` as a QA gate — dependency, not modification

**Choice**: The orchestrator invokes the existing `query-inspector` agent on generated queries as a QA gate before results are locked in. `query-inspector`'s contract (reads `.sql`/`.txt` under `script/01-sql/`, writes `docs/03-query-inspector/query-analysis.md`) is honored as-is; the ecosystem SHALL NOT modify the agent or its spec.
**Rationale**: `query-inspector` already performs query-logic correctness + business-alignment review — exactly the QA check the pipeline needs. Reusing it avoids duplicating that logic in `sql-builder` and gives the pipeline a second opinion on generated queries. The mechanics (materializing generated query text where `query-inspector` can read it) are an implementation detail handled by the orchestrator without changing the dependency's contract.

### Decision 8: Blueprint numbered `03` — `02` is occupied by a historical planning prompt

**Choice**: The canonical blueprint is `agent-blueprints/03-data-to-insight.md`, not `02-data-to-insight.md`.
**Rationale**: `agent-blueprints/01-learning-progress.md` is the canonical learning-progress plan; `agent-blueprints/02-query-inspector.txt` is a historical planning prompt (a `.txt` capture of the original query-inspector request), not a canonical `.md` blueprint. Numbering the new canonical blueprint `03` avoids the `02` slot being shared with a non-canonical artifact and keeps the canonical `.md` blueprint sequence unambiguous.

### Decision 9: Case work folders as output; `expected/` as ground truth (read-only)

**Choice**: Artifacts are written to the case's `work/` folder (`02-markethub/work/`, `03-novatel/work/`). The `expected/` folders (already containing `01-scope.md`, `02-questions.md`, `03-queries.sql`, `03-results.md`, `04-insight.md`) are read as validation ground truth and never modified.
**Rationale**: `work/` is the lab's designated learner-draft space; `expected/` is the model answer the lab already treats as check-only. The ecosystem writes only to `work/`, validating its own outputs against `expected/` — preserving the lab's "check yourself against the model answer" philosophy while automating the drafting.

## Target Structure

```
.opencode/skills/data-to-insight/SKILL.md        ← CREATED: orchestrator skill (YAML frontmatter name+description, trigger, pointer to blueprint, checkpoint gates)
.opencode/agents/sql-builder.md                  ← CREATED: SQL-authoring subagent (frontmatter mode: subagent; stages 3–5)
.opencode/agents/insight-writer.md               ← CREATED: insight-synthesis subagent (frontmatter mode: subagent; stage 6)
agent-blueprints/03-data-to-insight.md           ← CREATED: canonical blueprint (7-stage recipe, contracts, delegation rules)
AGENTS.md                                        ← MODIFIED: register data-to-insight / sql-builder / insight-writer in the routing registry
README.md                                        ← MODIFIED: directory map + capability surface entries
openspec/changes/add-data-to-insight-ecosystem/specs/data-to-insight/spec.md  ← CREATED: delta spec (ADDED requirements)
openspec/specs/data-to-insight/spec.md           ← CREATED at archive time from delta (not in tasks.md)
learning/02-sql-learning/sql-analyst-lab/02-markethub/work/*   ← CREATED (Phase 2, first execution target)
learning/02-sql-learning/sql-analyst-lab/03-novatel/work/*     ← CREATED (Phase 2, first execution target)
```

## Edge Cases

- **Case 03 limitation — no YoY possible (billing spans only 2025-12-01 and 2026-01-01)**: the orchestrator's Context stage (0) reads `case.md`'s limitation note and SHALL propagate it; the Question stage SHALL NOT author any YoY sub-question, and `sql-builder` SHALL NOT fabricate a YoY comparison. Handling: the limitation is treated as a hard constraint surfaced to the user, not a suggestion.
- **A metric with multiple plausible definitions (e.g. repeat purchase rate in Case 02)**: the Scope stage SHALL fix the exact definition before querying (matching Case 02's `01-scope.md` which fixes "≥2 Completed/Shipped orders" as the repeat threshold), and every downstream query SHALL implement that same definition. Handling: the blueprint mandates "definitions fixed here" in `01-scope.md`, and the QA gate + `expected/` cross-check catch drift.
- **Six DQ dimensions vs. only an effective subset applies**: the Silver stage SHALL evaluate all six (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) and SHALL apply only the subset that addresses the current dataset's real quirks, documenting each skipped dimension as N/A with a reason. Handling: prevents both "applied nothing" and "applied everything blindly"; the `expected/` answers anchor the subset.
- **Gold mart uniqueness might fail**: the Gold stage SHALL declare the grain and unique key, then verify `COUNT(*) = COUNT(DISTINCT <grain_key>)` before any query runs. Handling: a failed uniqueness check halts the stage with the grain/key that violated it, instead of silently producing duplicate-grained marts.
- **Querying raw/bronze/silver by accident**: the Query stage SHALL query the gold mart ONLY. Handling: the orchestrator does not expose non-gold schemas to the query step, and the QA gate flags any query touching `bronze.`/`silver.`/raw tables.
- **`query-inspector` input location mismatch**: `query-inspector` reads `.sql` files under `script/01-sql/`, but generated queries live in `work/`. Handling: the orchestrator materializes the generated `03-queries.sql` where `query-inspector` can read it (a usage-note-style copy, matching the `sql-analyst-lab` README's documented "copy `work/` queries into `script/01-sql/`" flow) without modifying `query-inspector`.
- **`work/` already contains prior artifacts (e.g. the learner's Case 01 `work/` has drafts)**: the ecosystem SHALL NOT silently overwrite existing `work/` files. Handling: writing to a case `work/` folder is checkpoint-gated, and existing artifacts are surfaced for the human to reconcile at the relevant gate.
- **Dataset immutability**: every dataset reference is read-only by relative path; the PostgreSQL load reads the `_pg.sql` variants without writing back to `learning/02-sql-learning/sql-skill-push/`.

## Affected Specs

| Spec                              | Change Type                    |
| --------------------------------- | ------------------------------ |
| `specs/data-to-insight/spec.md`   | ADDED (new capability)         |
| `specs/sql-analyst-lab/spec.md`   | no delta (dependency, consumed read-only) |
| `specs/query-inspector/spec.md`   | no delta (reused as QA gate)   |
| `specs/learning-progress/spec.md` | no delta (no track registration) |
| `specs/medallion-lab/spec.md`     | no delta (different capability) |
