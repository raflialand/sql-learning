# Add Progress Evaluator — Design

## Overview

The change adds a **read-only verification subagent** — `progress-evaluator` — as an independent BLOCKING GATE on the `data-to-insight` pipeline's six checkpoints. It sits in the same subagent family as `query-inspector`, but with a different contract: `query-inspector` reviews *queries* for logic + business alignment; `progress-evaluator` grades *every stage artifact* (scope, questions, silver, gold mart, results, insight) against per-stage MANDATORY criteria and emits a PASS / PASS-WITH-NOTES / FAIL verdict that gates the checkpoint.

The evaluator is **read-only** by construction: it inspects and reports; it never authors. The re-run loop (block → route → fix → re-inspect) is enforced by the **orchestrator**, not by the evaluator, so the grader can never fix what it grades and can never silently advance the pipeline.

Because the evaluator is a service/operation capability (inspection with a verdict model, failure behavior, quality acceptance, and cross-capability dependencies), its delta spec follows the `service-capability-template` structure. The `data-to-insight` spec gains a new "Evaluation Gate Contract" and extended checkpoint/orchestration/dependency requirements.

## Design Decisions

### Decision 1: Read-only verification, not a fixer

**Choice**: The evaluator INSPECTS artifacts and reports verdicts only; it NEVER authors or edits SQL, insight, scope, questions, or results. On FAIL, the orchestrator routes the defect to the owning agent (orchestrator / `sql-builder` / `insight-writer`), never back to the evaluator.

**Rationale**: The Case 02 root cause was a self-grading conflict — `insight-writer` graded its own output PASS despite a factual error. A grader that fixes its own findings reintroduces the same hole. Read-only keeps the grade independent: the evaluator can only report, so a "14th largest" error becomes a FAIL the *writer* must fix, then the evaluator re-inspects.

### Decision 2: BLOCKING gate at every checkpoint (not advisory)

**Choice**: The evaluator runs at all six checkpoints (after Scope, Questions, Silver, Gold mart, Queries+results, final Insight), and a FAIL blocks the checkpoint. The gate runs *before* the human-approval pause.

**Rationale**: The existing Checkpoint Autonomy Contract already pauses for the human at six gates. Layering the evaluator *before* the human means the human signs off on an artifact that has already passed an independent grade. Advisory-only verification (report but don't block) would not have prevented the Case 02 failures from shipping.

### Decision 3: New capability `progress-evaluator`, not a fold into `data-to-insight`

**Choice**: A separate `progress-evaluator` capability spec, mirroring how `query-inspector` is its own spec rather than a section of `data-to-insight`.

**Rationale**: The evaluator has its own input contract (case context + the artifact under inspection), output contract (`docs/04-progress-evaluator/` reports), verdict model, and per-stage criteria — a full behavioral surface. Keeping it a sibling spec lets its contract evolve independently and keeps `data-to-insight`'s spec focused on the pipeline recipe, referencing the evaluator via a thin gate contract + dependency.

### Decision 4: MANDATORY vs ADVISORY check split with a 3-verdict model

**Choice**: Every check is classified MANDATORY (blocking) or ADVISORY (non-blocking). The verdict is PASS (all mandatory green), PASS-WITH-NOTES (mandatory green + advisory notes), or FAIL (≥1 mandatory red). The verdict is derived from MANDATORY checks only.

**Rationale**: This prevents the gate from becoming a brittle all-or-nothing bar while guaranteeing that real correctness/completeness defects always block. Advisory findings (e.g. a formatting suggestion) are logged without halting the run, preserving the learner's forward momentum.

### Decision 5: Re-run loop + fail-closed are enforced by the orchestrator

**Choice**: The block → route → fix → re-inspect loop, the 3-fix retry budget, the fail-closed halt on exhaustion, and the explicit human override all live in the orchestrator (`data-to-insight`), not in the evaluator. The evaluator only inspects and returns a verdict (writing a new dated report on each re-inspection).

**Rationale**: The evaluator must stay stateless and non-authoring. The orchestrator already owns sequencing and checkpoints, so it owns the loop. Fail-closed (never silently advance) is the hard safety guarantee that makes the gate a real gate.

### Decision 6: Owner routing table is fixed by stage

**Choice**: FAIL defects route by stage: Stages 1–2 (Scope, Questions) → orchestrator; Stages 3–5 (Silver, Gold mart, Results) → `sql-builder`; Stage 6 (Insight) → `insight-writer`.

**Rationale**: The stage that authored the artifact is the one with the context to fix it. Routing is fixed (not inferred) so a FAIL never stalls for want of an owner, and it preserves the existing authoring-role boundaries (orchestrator authors Scope/Questions; `sql-builder` authors SQL; `insight-writer` authors insight).

### Decision 7: Reports to `docs/04-progress-evaluator/` with the `query-inspector` dated-variant convention

**Choice**: Reports write to `docs/04-progress-evaluator/`; if a report already exists, write a dated variant instead of overwriting.

**Rationale**: `docs/03-query-inspector/` is the existing convention for verification agents' outputs. `04-progress-evaluator/` is the next free slot, and the dated-variant rule preserves re-run history (each fix-and-re-run yields a new dated report, matching "repeat until PASS" traceability).

## Target Structure

```
.opencode/agents/progress-evaluator.md                              ← CREATED: read-only verification subagent (frontmatter mode: subagent; verdict model + per-stage checks + report location)
agent-blueprints/03-data-to-insight.md                              ← MODIFIED: insert evaluator step into stages 1–6 + checkpoints; add owner-routing table
.opencode/skills/data-to-insight/SKILL.md                           ← MODIFIED: mention delegation to @progress-evaluator + blocking-gate behavior
AGENTS.md                                                           ← MODIFIED: register progress-evaluator in the Domain agents table
openspec/changes/add-progress-evaluator/specs/progress-evaluator/spec.md   ← CREATED: delta spec (ADDED requirements)
openspec/changes/add-progress-evaluator/specs/data-to-insight/spec.md      ← CREATED: delta spec (ADDED + MODIFIED requirements)
openspec/specs/progress-evaluator/spec.md                           ← CREATED at archive time from delta (not in tasks.md)
openspec/specs/data-to-insight/spec.md                              ← MODIFIED at archive time from delta (not in tasks.md)
```

## Edge Cases

- **Missing artifact under inspection**: the evaluator halts before emitting a verdict and reports the missing artifact by name — it never fabricates a PASS/FAIL. Handling: the `Failure Behavior` requirement; an uninspectable artifact is a hard stop, not a silent advance.
- **Legitimate NULLs (e.g. first-month MoM)**: the Results check forbids *unexpected* NULLs but must not false-FAIL a legitimate NULL. Handling: the check is scoped to "unexpected NULLs", with legitimate NULLs explicitly allowed.
- **Factual error that passes the writer's own self-check**: the Insight check re-derives ranks ("Nth of M") and ratios against `03-results.md` independently, so a "14th largest" claim that contradicts Q2 (12th of 14) is a FAIL even when the self-check reported PASS. Handling: the "categorical accuracy" and "traceability" MANDATORY checks + the "no false PASS" quality criterion.
- **Retry budget exhausted while still FAILING**: the pipeline fails closed — halts entirely, escalates to the human, never silently advances. Handling: the `Re-Run Loop Contract` / `Evaluation Gate Contract` fail-closed scenario.
- **Human override of a FAIL or a halt**: allowed only as an explicit, documented decision recorded in the report. Handling: the `Re-Run Loop Contract` override scenario; never silent.
- **Re-inspection must not overwrite prior reports**: each fix-and-re-run writes a new dated report. Handling: the `Output Artifact Contract` dated-variant rule.
- **Evaluator grading its own fix**: impossible by construction — the evaluator is read-only and routes FAILs to the owning agent. Handling: the `Read-Only Verification Constraint` and `Owner Routing Contract`.

## Affected Specs

| Spec                              | Change Type                          |
| --------------------------------- | ------------------------------------ |
| `specs/progress-evaluator/spec.md` | ADDED (new capability)               |
| `specs/data-to-insight/spec.md`   | ADDED + MODIFIED (Evaluation Gate Contract; extended checkpoint/orchestration/dependency) |
| `specs/query-inspector/spec.md`   | no delta (sibling verification agent, unchanged) |
| `specs/learning-progress/spec.md` | no delta (no track registration)     |
| `specs/sql-analyst-lab/spec.md`   | no delta (consumed read-only)        |
