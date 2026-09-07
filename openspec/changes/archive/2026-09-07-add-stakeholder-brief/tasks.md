# Add Stakeholder Brief — Implementation Tasks

## Phase 1: Delta Spec

### Step 1.1: Create the delta spec for data-to-insight

Create `openspec/changes/add-stakeholder-brief/specs/data-to-insight/spec.md` with ADDED and MODIFIED requirements as specified in the delta spec artifact.

**Verification**: File exists with 1 ADDED requirement (Stakeholder Brief Contract) and 6 MODIFIED requirements (Orchestration, Scope Stage, Checkpoint Autonomy, Evaluation Gate, Quality Acceptance, Boundaries).

---

## Phase 2: Blueprint Updates

### Step 2.1: Update Stage 0 description in the blueprint

Edit `agent-blueprints/03-data-to-insight.md` — Stage 0 section.

- **Old**:
```
### Stage 0 — Context

1. Read the dataset README: business context, ERD/join hints, data quirks.
2. Read `case.md`: the main question + dataset limitation notes.
3. Surface any limitation (e.g. NovaTel billing spans only 2025-12-01 and 2026-01-01 → MoM only, NO YoY) to the user and carry it as a hard constraint for all downstream stages.
```
- **New**:
```
### Stage 0 — Context + Stakeholder Brief

1. Read the dataset README: business context, ERD/join hints, data quirks.
2. Read `case.md`: the main question + dataset limitation notes.
3. Surface any limitation (e.g. NovaTel billing spans only 2025-12-01 and 2026-01-01 → MoM only, NO YoY) to the user and carry it as a hard constraint for all downstream stages.
4. Write `00-stakeholder-brief.md` to the case's `work/` folder — a structured brief with 5 mandatory sections (Business context summary, Stakeholder priorities, Assumptions, Questions I'd ask the stakeholder, Success criteria) + optional case-specific questions + forced "If I were the stakeholder..." perspective flip.
5. Checkpoint 0: `progress-evaluator` verifies the brief exists and is non-trivial; learner approves before Stage 1 begins.
```

**Verification**: Stage 0 section in the blueprint describes 5 steps including brief writing and Checkpoint 0.

### Step 2.2: Update the artifact table in the blueprint

Edit `agent-blueprints/03-data-to-insight.md` — Artifacts table.

- **Old**:
```
| Stage | Artifact | Owner |
|---|---|---|
| 1 Scope | `01-scope.md` | orchestrator |
| 2 Questions | `02-questions.md` | orchestrator |
| 3 Bronze→Silver | `_silver.sql` (+ any silver DDL) | `sql-builder` |
| 4 Silver→Gold | gold mart DDL/definition | `sql-builder` |
| 5 Query | `03-queries.sql`, `03-results.md` | `sql-builder` |
| 6 Insight | `04-insight.md` | `insight-writer` |
| Verification | `<case>/verification/` — evaluator reports + query-analysis | `progress-evaluator`, `query-inspector` |
```
- **New**:
```
| Stage | Artifact | Owner |
|---|---|---|
| 0 Context + Stakeholder Brief | `00-stakeholder-brief.md` | orchestrator |
| 1 Scope | `01-scope.md` | orchestrator |
| 2 Questions | `02-questions.md` | orchestrator |
| 3 Bronze→Silver | `_silver.sql` (+ any silver DDL) | `sql-builder` |
| 4 Silver→Gold | gold mart DDL/definition | `sql-builder` |
| 5 Query | `03-queries.sql`, `03-results.md` | `sql-builder` |
| 6 Insight | `04-insight.md` | `insight-writer` |
| Verification | `<case>/verification/` — evaluator reports + query-analysis | `progress-evaluator`, `query-inspector` |
```

**Verification**: Artifact table includes row for Stage 0 with `00-stakeholder-brief.md`.

### Step 2.3: Update the checkpoint list in the blueprint

Edit `agent-blueprints/03-data-to-insight.md` — Checkpoint gates section.

- **Old**:
```
### Checkpoint gates (verification + human approval)

At each of the six checkpoints, the `progress-evaluator` subagent runs as a read-only verification gate BEFORE the human-approval pause. A FAIL verdict blocks the checkpoint and routes the defect to the owning agent for fix-and-re-run; only a non-FAIL verdict (PASS or PASS-WITH-NOTES) lets the human approval proceed. Evaluator reports are written to `<case>/verification/`.

1. After Scope (`01-scope.md`)
2. After Questions (`02-questions.md`)
3. After Silver (`_silver.sql`)
4. After Gold mart
5. After Queries + results (`03-results.md`)
6. After final Insight (`04-insight.md`)
```
- **New**:
```
### Checkpoint gates (verification + human approval)

At each of the seven checkpoints, the `progress-evaluator` subagent runs as a read-only verification gate BEFORE the human-approval pause. A FAIL verdict blocks the checkpoint and routes the defect to the owning agent for fix-and-re-run; only a non-FAIL verdict (PASS or PASS-WITH-NOTES) lets the human approval proceed. Evaluator reports are written to `<case>/verification/`.

0. After Stakeholder Brief (`00-stakeholder-brief.md`)
1. After Scope (`01-scope.md`)
2. After Questions (`02-questions.md`)
3. After Silver (`_silver.sql`)
4. After Gold mart
5. After Queries + results (`03-results.md`)
6. After final Insight (`04-insight.md`)
```

**Verification**: Checkpoint list has 7 entries, starting with Checkpoint 0 (Stakeholder Brief).

### Step 2.4: Update the owner routing table in the blueprint

Edit `agent-blueprints/03-data-to-insight.md` — Owner routing on FAIL section.

- **Old**:
```
| Stages | Owning agent (receives the defect) |
|---|---|
| 1–2 (Scope, Questions) | orchestrator |
| 3–5 (Silver, Gold mart, Results) | `sql-builder` |
| 6 (Insight) | `insight-writer` |
```
- **New**:
```
| Stages | Owning agent (receives the defect) |
|---|---|
| 0–2 (Stakeholder Brief, Scope, Questions) | orchestrator |
| 3–5 (Silver, Gold mart, Results) | `sql-builder` |
| 6 (Insight) | `insight-writer` |
```

**Verification**: Owner routing table shows stages 0–2 routing to orchestrator.

### Step 2.5: Update the implementation mapping table in the blueprint

Edit `agent-blueprints/03-data-to-insight.md` — Implementation Mapping table.

- **Old**:
```
| `.opencode/agents/progress-evaluator.md` | Read-only checkpoint verification gate (stages 1–6) |
```
- **New**:
```
| `.opencode/agents/progress-evaluator.md` | Read-only checkpoint verification gate (stages 0–6) |
```

**Verification**: Implementation mapping references stages 0–6 for progress-evaluator.

### Step 2.6: Update the pipeline flow description in the blueprint

Edit `agent-blueprints/03-data-to-insight.md` — Section 6 title.

- **Old**:
```
## 6. Workflow — the 7-stage recipe
```
- **New**:
```
## 6. Workflow — the 7-stage recipe (8 artifacts, 7 checkpoints)
```

**Verification**: Section 6 title reflects 7 checkpoints.

---

## Phase 3: Progress Evaluator Agent Update

### Step 3.1: Update the progress-evaluator description

Edit `.opencode/agents/progress-evaluator.md` — frontmatter description.

- **Old**:
```
description: Read-only verification gate at every data-to-insight checkpoint (stages 1–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts against per-stage MANDATORY checks; writes dated reports to <case>/verification/.
```
- **New**:
```
description: Read-only verification gate at every data-to-insight checkpoint (stages 0–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts against per-stage MANDATORY checks; writes dated reports to <case>/verification/.
```

**Verification**: Frontmatter description references stages 0–6.

### Step 3.2: Add Stage 0 MANDATORY checks to the progress-evaluator

Edit `.opencode/agents/progress-evaluator.md` — Per-stage MANDATORY checks section. Add a new bullet for Stage 0 before the existing Scope bullet.

- **Old**:
```
## Per-stage MANDATORY checks

- **Scope (`01-scope.md`):**
```
- **New**:
```
## Per-stage MANDATORY checks

- **Stakeholder Brief (`00-stakeholder-brief.md`):** (1) file exists in `work/`; (2) all 5 mandatory sections present (Business context summary, Stakeholder priorities, Assumptions, Questions I'd ask the stakeholder, Success criteria); (3) forced perspective section ("If I were the stakeholder...") present; (4) brief is non-trivial (no placeholder text, each section has ≥2 sentences of substantive content); (5) stakeholder priorities are ranked or ordered (not a flat list).
- **Scope (`01-scope.md`):**
```

**Verification**: Per-stage MANDATORY checks section begins with Stakeholder Brief checks.

### Step 3.3: Update the progress-evaluator Inputs section

Edit `.opencode/agents/progress-evaluator.md` — Inputs section.

- **Old**:
```
- The stage artifact under inspection: `01-scope.md`, `02-questions.md`, `_silver.sql`, the gold mart definition, `03-results.md`, or `04-insight.md`.
```
- **New**:
```
- The stage artifact under inspection: `00-stakeholder-brief.md`, `01-scope.md`, `02-questions.md`, `_silver.sql`, the gold mart definition, `03-results.md`, or `04-insight.md`.
```

**Verification**: Inputs section lists `00-stakeholder-brief.md` as a possible stage artifact.

---

## Phase 4: Skill File Updates

### Step 4.1: Update SKILL.md frontmatter

Edit `.opencode/skills/data-to-insight/SKILL.md` — frontmatter description.

- **Old**:
```
description: Automates the 7-stage data-to-insight SQL analysis pipeline (0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold mart → 5 Query mart → 6 Insight) for a SQL Analyst Lab case or any dataset, against a PostgreSQL medallion (bronze/silver/gold schemas). Writes artifacts (01-scope.md, 02-questions.md, _silver.sql, gold mart, 03-queries.sql/03-results.md, 04-insight.md) into the case's work/ folder and pauses for human approval at six checkpoints. Delegates SQL work (stages 3–5) to @sql-builder, insight synthesis (stage 6) to @insight-writer, checkpoint verification (stages 1–6) to @progress-evaluator (blocking gate), and reuses @query-inspector as a QA gate. Executes on explicit invocation scoped to a case (e.g. "run data-to-insight on Case 02").
```
- **New**:
```
description: Automates the 7-stage data-to-insight SQL analysis pipeline (0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold mart → 5 Query mart → 6 Insight) for a SQL Analyst Lab case or any dataset, against a PostgreSQL medallion (bronze/silver/gold schemas). Writes artifacts (00-stakeholder-brief.md, 01-scope.md, 02-questions.md, _silver.sql, gold mart, 03-queries.sql/03-results.md, 04-insight.md) into the case's work/ folder and pauses for human approval at seven checkpoints. Delegates SQL work (stages 3–5) to @sql-builder, insight synthesis (stage 6) to @insight-writer, checkpoint verification (stages 0–6) to @progress-evaluator (blocking gate), and reuses @query-inspector as a QA gate. Executes on explicit invocation scoped to a case (e.g. "run data-to-insight on Case 02").
```

**Verification**: SKILL.md frontmatter lists `00-stakeholder-brief.md` in artifacts, seven checkpoints, and stages 0–6 for evaluator.

### Step 4.2: Update SKILL.md quick reference — delegation line

Edit `.opencode/skills/data-to-insight/SKILL.md` — Quick Reference, delegation bullet.

- **Old**:
```
- **Delegation:** Stages 3–5 (SQL: silver, gold mart, queries + results) → `@sql-builder`. Stage 6 (insight) → `@insight-writer`. Generated queries → `@query-inspector` as a QA gate (output to `<case>/verification/`). Checkpoint verification (stages 1–6) → `@progress-evaluator` as a read-only blocking gate (output to `<case>/verification/`; FAIL blocks the checkpoint and routes the defect to the owning agent for fix-and-re-run). The orchestrator passes the case path to all delegated agents so they write verification files to `<case>/verification/`.
```
- **New**:
```
- **Delegation:** Stages 3–5 (SQL: silver, gold mart, queries + results) → `@sql-builder`. Stage 6 (insight) → `@insight-writer`. Generated queries → `@query-inspector` as a QA gate (output to `<case>/verification/`). Checkpoint verification (stages 0–6) → `@progress-evaluator` as a read-only blocking gate (output to `<case>/verification/`; FAIL blocks the checkpoint and routes the defect to the owning agent for fix-and-re-run). The orchestrator passes the case path to all delegated agents so they write verification files to `<case>/verification/`.
```

**Verification**: Delegation bullet references stages 0–6 for progress-evaluator.

### Step 4.3: Update SKILL.md quick reference — checkpoints line

Edit `.opencode/skills/data-to-insight/SKILL.md` — Quick Reference, checkpoints bullet.

- **Old**:
```
- **Checkpoints:** Pause for human approval after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight. Never run a downstream stage before the current gate is approved.
```
- **New**:
```
- **Checkpoints:** Pause for human approval after Stakeholder Brief, Scope, Questions, Silver, Gold mart, Queries+results, and final Insight (7 checkpoints total). Never run a downstream stage before the current gate is approved.
```

**Verification**: Checkpoints bullet lists 7 checkpoints including Stakeholder Brief.

### Step 4.4: Update SKILL.md quick reference — key rules line

Edit `.opencode/skills/data-to-insight/SKILL.md` — Quick Reference, key rules bullet.

- **Old**:
```
- **Key rules:** ~3 metrics + ~3 dimensions is a floor, not a cap; decompose into 4 buckets (Overall Trends / Growth Rates / Performance Measurement / KPI Reporting), one metric × one dimension per sub-question; silver evaluates all 6 DQ dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) but applies only the effective subset; silver profiling surfaces any profile-only scope gap (metric/dimension/quirk materially affecting a sub-question but absent from `01-scope.md`); such a finding routes to the orchestrator for a scope amendment — never to `sql-builder`; gold declares grain + unique key and verifies `COUNT(*) = COUNT(DISTINCT <grain_key>)`; queries read the gold mart only; insight must pass the weak-vs-strong rubric.
```
- **New**:
```
- **Key rules:** Stage 0 writes `00-stakeholder-brief.md` before scope — every metric/dimension in scope must trace back to the brief; ~3 metrics + ~3 dimensions is a floor, not a cap; decompose into 4 buckets (Overall Trends / Growth Rates / Performance Measurement / KPI Reporting), one metric × one dimension per sub-question; silver evaluates all 6 DQ dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) but applies only the effective subset; silver profiling surfaces any profile-only scope gap (metric/dimension/quirk materially affecting a sub-question but absent from `01-scope.md`); such a finding routes to the orchestrator for a scope amendment — never to `sql-builder`; gold declares grain + unique key and verifies `COUNT(*) = COUNT(DISTINCT <grain_key>)`; queries read the gold mart only; insight must pass the weak-vs-strong rubric.
```

**Verification**: Key rules bullet mentions stakeholder brief traceability.

---

## Phase 5: README Updates

### Step 5.1: Update the stage table in README.md

Edit `.opencode/skills/data-to-insight/README.md` — "The 7 stages" table.

- **Old**:
```
| Stage | Artifact | Owner |
|---|---|---|
| 0 Context | — | orchestrator |
| 1 Scope | `01-scope.md` | orchestrator |
| 2 Questions | `02-questions.md` | orchestrator |
| 3 Bronze→Silver | `_silver.sql` | `@sql-builder` |
| 4 Silver→Gold | gold mart | `@sql-builder` |
| 5 Query | `03-queries.sql`, `03-results.md` | `@sql-builder` |
| 6 Insight | `04-insight.md` | `@insight-writer` |
```
- **New**:
```
| Stage | Artifact | Owner |
|---|---|---|
| 0 Context + Stakeholder Brief | `00-stakeholder-brief.md` | orchestrator |
| 1 Scope | `01-scope.md` | orchestrator |
| 2 Questions | `02-questions.md` | orchestrator |
| 3 Bronze→Silver | `_silver.sql` | `@sql-builder` |
| 4 Silver→Gold | gold mart | `@sql-builder` |
| 5 Query | `03-queries.sql`, `03-results.md` | `@sql-builder` |
| 6 Insight | `04-insight.md` | `@insight-writer` |
```

**Verification**: Stage table row for Stage 0 shows `00-stakeholder-brief.md` artifact.

### Step 5.2: Update the checkpoint description in README.md

Edit `.opencode/skills/data-to-insight/README.md` — Checkpoints section.

- **Old**:
```
## Checkpoints (human approval gates)

The pipeline pauses for your approval after: Scope, Questions, Silver, Gold mart, Queries+results, and final Insight. No downstream stage runs before you approve the current one.
```
- **New**:
```
## Checkpoints (human approval gates)

The pipeline pauses for your approval after: Stakeholder Brief, Scope, Questions, Silver, Gold mart, Queries+results, and final Insight (7 checkpoints total). No downstream stage runs before you approve the current one.
```

**Verification**: Checkpoint description lists 7 checkpoints including Stakeholder Brief.

---

## Phase 6: Registry and Template Updates

### Step 6.1: Update the AGENTS.md agent routing registry

Edit `AGENTS.md` — progress-evaluator row in the Domain agents table.

- **Old**:
```
| `progress-evaluator` | Read-only verification gate at every data-to-insight checkpoint (stages 1–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts; writes dated reports to `<case>/verification/` |
```
- **New**:
```
| `progress-evaluator` | Read-only verification gate at every data-to-insight checkpoint (stages 0–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts; writes dated reports to `<case>/verification/` |
```

**Verification**: AGENTS.md progress-evaluator description references stages 0–6.

### Step 6.2: Update the progress-evaluator spec Boundaries section

Edit `openspec/specs/progress-evaluator/spec.md` — Boundaries, In scope line.

- **Old**:
```
- The read-only verification of `data-to-insight` stage artifacts at checkpoints (stages 1–6).
```
- **New**:
```
- The read-only verification of `data-to-insight` stage artifacts at checkpoints (stages 0–6).
```

**Verification**: progress-evaluator spec Boundaries references stages 0–6.

### Step 6.3: Update the case template with stakeholder context hint

Edit `case-template/case.md.template` — add a new section after "Dataset limitation note".

- **Old**:
```markdown
## Dataset limitation note

<Any constraint on valid comparisons, e.g. "billing spans only 2 months → MoM only, NO YoY". Delete if none.>
```
- **New**:
```markdown
## Dataset limitation note

<Any constraint on valid comparisons, e.g. "billing spans only 2 months → MoM only, NO YoY". Delete if none.>

## Stakeholder context (for the brief)

<Who is the stakeholder? What decision are they trying to make? What does "good" look like for them? This helps the analyst write a better stakeholder brief in Stage 0.>
```

**Verification**: case.md.template has a "Stakeholder context" section after the limitation note.

### Step 6.4: Update ONBOARD.md artifact table and checkpoint count

Edit `case-template/ONBOARD.md` — artifact table.

- **Old**:
```markdown
| Stage | Artifact |
|---|---|
| 1 Scope | `01-scope.md` |
| 2 Questions | `02-questions.md` |
| 3 Silver | `_silver.sql` |
| 4 Gold | gold mart (grain + unique key declared, uniqueness verified) |
| 5 Query | `03-queries.sql`, `03-results.md` |
| 6 Insight | `04-insight.md` |
```
- **New**:
```markdown
| Stage | Artifact |
|---|---|
| 0 Brief | `00-stakeholder-brief.md` |
| 1 Scope | `01-scope.md` |
| 2 Questions | `02-questions.md` |
| 3 Silver | `_silver.sql` |
| 4 Gold | gold mart (grain + unique key declared, uniqueness verified) |
| 5 Query | `03-queries.sql`, `03-results.md` |
| 6 Insight | `04-insight.md` |
```

**Verification**: ONBOARD.md artifact table includes `00-stakeholder-brief.md` row.

Edit `case-template/ONBOARD.md` — checkpoint count line.

- **Old**:
```
3. **Run the pipeline**: invoke the `data-to-insight` skill scoped to the case. It walks the 7 stages and pauses for approval at each of the 6 checkpoints.
```
- **New**:
```
3. **Run the pipeline**: invoke the `data-to-insight` skill scoped to the case. It walks the 7 stages and pauses for approval at each of the 7 checkpoints.
```

**Verification**: ONBOARD.md says 7 checkpoints.

---

## Summary of Changes

| Category | Before | After |
| --- | --- | --- |
| `openspec/specs/data-to-insight/spec.md` | 12 requirements, 6 checkpoints | 13 requirements (1 ADDED + 6 MODIFIED), 7 checkpoints |
| `agent-blueprints/03-data-to-insight.md` | Stage 0: 3 steps, no brief artifact, 6 checkpoints | Stage 0: 5 steps, `00-stakeholder-brief.md` artifact, 7 checkpoints |
| `.opencode/agents/progress-evaluator.md` | Stages 1–6, no Stage 0 checks | Stages 0–6, Stage 0 MANDATORY checks added |
| `.opencode/skills/data-to-insight/SKILL.md` | 6 checkpoints in frontmatter + quick ref | 7 checkpoints, brief artifact, stages 0–6 evaluator |
| `.opencode/skills/data-to-insight/README.md` | 6 checkpoints, no brief in stage table | 7 checkpoints, brief in stage table |
| `AGENTS.md` | progress-evaluator: "stages 1–6" | progress-evaluator: "stages 0–6" |
| `openspec/specs/progress-evaluator/spec.md` | Boundaries: "stages 1–6" | Boundaries: "stages 0–6" |
| `case-template/case.md.template` | No stakeholder context section | Added "Stakeholder context (for the brief)" section |
| `case-template/ONBOARD.md` | 6 checkpoints, no brief in artifact table | 7 checkpoints, brief in artifact table |
| Delta spec | — | `specs/data-to-insight/spec.md` created with ADDED + MODIFIED |
