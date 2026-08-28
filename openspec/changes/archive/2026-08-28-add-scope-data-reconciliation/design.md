# Add Scope Data Reconciliation — Design

## Overview

The change adds a reconciliation step at Stage 3 (Silver) — the first moment the dataset is actually profiled — and a matching MANDATORY check in the `progress-evaluator` Silver gate. When Silver profiling surfaces a metric/dimension/data-quirk that is not in `01-scope.md` and materially affects a sub-question, the finding is routed to the orchestrator (who owns `01-scope.md` and `02-questions.md`) for a scope amendment, re-verified before questions/queries lock. The evaluator independently FAILs the Silver checkpoint if such a gap exists but was never surfaced.

## Design Decisions

### Decision 1: New ADDED "Scope Reconciliation Contract" rather than folding into the Silver contract

**Choice**: A separate requirement in `data-to-insight`.
**Rationale**: The reconciliation carries a distinct routing nuance (route to the orchestrator, not `sql-builder`) and a distinct lifecycle (amend + re-verify before lock). Keeping it separate leaves the Silver Data Quality Contract focused purely on the six DQ dimensions and makes the safety-net semantics explicit.

### Decision 2: Route the finding to the orchestrator, not `sql-builder`

**Choice**: Scope-amendment findings route to the orchestrator.
**Rationale**: `sql-builder` owns the SQL authoring for stages 3–5 but not the scope authority. `01-scope.md` and `02-questions.md` are orchestrator-owned. Routing the amendment there preserves the existing owner-routing semantics (which already route stages 1–2 to the orchestrator) rather than granting `sql-builder` scope-authoring power.

### Decision 3: The new evaluator check is MANDATORY and blocking

**Choice**: A sixth MANDATORY check, "scope coverage vs. profiled data".
**Rationale**: An unflagged scope gap that changes an answer is a correctness defect, not a stylistic note. Making it MANDATORY keeps the gate fail-closed: the pipeline cannot advance on a scope the data contradicts.

### Decision 4: Scope amendment is a documented safety net, not a failure

**Choice**: Frame the amendment as a legitimate outcome of the "scope before data" rule.
**Rationale**: Preserves the rule's intent (prevent "analyze everything by everything") while adding the missing re-validation. Without this framing, agents might suppress legitimate amendments to avoid a FAIL.

## Target Structure

```
openspec/changes/add-scope-data-reconciliation/proposal.md                       ← CREATED: problem/solution/scope
openspec/changes/add-scope-data-reconciliation/design.md                         ← CREATED: this file
openspec/changes/add-scope-data-reconciliation/tasks.md                          ← CREATED: ordered implementation steps
openspec/changes/add-scope-data-reconciliation/specs/data-to-insight/spec.md     ← CREATED: ADDED Scope Reconciliation Contract
openspec/changes/add-scope-data-reconciliation/specs/progress-evaluator/spec.md  ← CREATED: MODIFIED Silver Evaluation Contract (5→6 checks)
```

Implementation edits to `.opencode/skills/data-to-insight/SKILL.md` and `.opencode/agents/progress-evaluator.md` happen in Phase 2 after approval and are described in `tasks.md`, not here.

## Edge Cases

- **A profile-only column that does not materially affect any sub-question** (e.g. a cosmetic comment column):
  - Handling: NOT a scope gap; no amendment and no FAIL. The check is scoped to "materially affects a sub-question's answer".
- **A gap is surfaced and an amendment is already in flight when the evaluator runs**:
  - Handling: The check targets an "unflagged" gap. The orchestrator SHALL complete and re-verify the amendment BEFORE the Silver checkpoint is graded, so the evaluator sees the amended scope and the check passes.
- **Multiple material gaps at once**:
  - Handling: Surface all gaps in a single amendment pass; the evaluator names each gap and affected sub-question in the FAIL report.
- **A quirk that is both a DQ issue and a scope dimension**:
  - Handling: Covered by two independent MANDATORY checks (README-quirk coverage and scope coverage). Both must pass; there is no double-counting conflict.

## Affected Specs

| Spec                          | Change Type                |
| ----------------------------- | -------------------------- |
| `specs/data-to-insight/spec.md` | ADDED (Scope Reconciliation Contract) |
| `specs/progress-evaluator/spec.md` | MODIFIED (Silver Evaluation Contract) |
