# Add Scope Data Reconciliation — Implementation Tasks

## Phase 1: Spec Deltas

### Step 1.1: Add the Scope Reconciliation Contract to data-to-insight

Author `openspec/changes/add-scope-data-reconciliation/specs/data-to-insight/spec.md` with an `## ADDED Requirements` section containing the `Scope Reconciliation Contract` requirement and its four scenarios.

**Verification**: The delta contains one ADDED requirement with at least one `#### Scenario:` block using GIVEN/WHEN/THEN/AND bullet form; no MODIFIED or REMOVED sections are present.

### Step 1.2: Extend the Silver Evaluation Contract in progress-evaluator

Author `openspec/changes/add-scope-data-reconciliation/specs/progress-evaluator/spec.md` with a `## MODIFIED Requirements` section. Update the `Silver Evaluation Contract` from five to six MANDATORY checks, add the "scope coverage vs. profiled data" check, and include a `> **Replaces**:` block with the exact current five-check text.

**Verification**: The `Replaces` block is byte-exact against the current `Silver Evaluation Contract` in `openspec/specs/progress-evaluator/spec.md`; the updated requirement names six checks and carries a new FAIL scenario for an unflagged scope gap.

## Phase 2: Implementation (after approval)

### Step 2.1: Add the reconciliation rule to the orchestrator skill

In `.opencode/skills/data-to-insight/SKILL.md`, add a Key rule and an Invariant stating that Stage 3 Silver profiling SHALL surface profile-only scope gaps and route them to the orchestrator (not `sql-builder`) for amendment before questions/queries lock.

- **Old**: `- **Key rules:** ~3 metrics + ~3 dimensions is a floor, not a cap; decompose into 4 buckets (Overall Trends / Growth Rates / Performance Measurement / KPI Reporting), one metric × one dimension per sub-question; silver evaluates all 6 DQ dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) but applies only the effective subset; gold declares grain + unique key and verifies \`COUNT(*) = COUNT(DISTINCT <grain_key>)\`; queries read the gold mart only; insight must pass the weak-vs-strong rubric.`
- **New**: append to the Key rules list: `silver profiling surfaces any profile-only scope gap (metric/dimension/quirk materially affecting a sub-question but absent from \`01-scope.md\`); such a finding routes to the orchestrator for a scope amendment — never to \`sql-builder\`.` Also add an Invariant line: `- Surface profile-only scope gaps at Silver and route them to the orchestrator for amendment — never to \`sql-builder\`.`

**Verification**: `grep` for the reconciliation rule in `SKILL.md`; the rule names the orchestrator as the routing target and `sql-builder` as excluded.

### Step 2.2: Add the sixth Silver check to the progress-evaluator agent

In `.opencode/agents/progress-evaluator.md`, extend the `Silver (_silver.sql)` line of the `Per-stage MANDATORY checks` section from five to six checks.

- **Old**: `- **Silver (\`_silver.sql\`):** (1) all six DQ dimensions evaluated, each applied or N/A-with-reason; (2) no N/A without a reason; (3) applied subset covers every dataset quirk; (4) row counts preserved (conform + flag, never drop); (5) SQL runs without error.`
- **New**: `- **Silver (\`_silver.sql\`):** (1) all six DQ dimensions evaluated, each applied or N/A-with-reason; (2) no N/A without a reason; (3) applied subset covers every dataset quirk; (4) row counts preserved (conform + flag, never drop); (5) SQL runs without error; (6) scope coverage vs. profiled data — no metric/dimension/quirk materially affecting a sub-question is present but absent from \`01-scope.md\` (no unflagged scope gap).`

**Verification**: The Silver bullet lists six checks; the sixth names the scope-coverage check and the no-unflagged-gap condition.

## Phase 3: Validation

### Step 3.1: Validate the proposal artifacts

Confirm every file exists and is populated; the delta specs conform to `openspec/AGENTS.md` delta rules; the `Replaces` block matches the canonical spec exactly.

**Verification**: `openspec/changes/AGENTS.md` validation checklist all green; no empty sections; no placeholder markers remain.

## Summary of Changes

| Category | Before | After |
| --- | --- | --- |
| `data-to-insight` spec | No scope-reconciliation requirement | ADDED `Scope Reconciliation Contract` |
| `progress-evaluator` spec | Silver = five MANDATORY checks | Silver = six MANDATORY checks (scope coverage added) |
| `.opencode/skills/data-to-insight/SKILL.md` | No reconciliation rule | Key rule + invariant added (Phase 2) |
| `.opencode/agents/progress-evaluator.md` | Silver = five checks | Silver = six checks (Phase 2) |
