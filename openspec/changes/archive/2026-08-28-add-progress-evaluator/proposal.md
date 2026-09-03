# Add Progress Evaluator

## Problem Statement

The `data-to-insight` pipeline (7 stages: 0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold → 5 Query → 6 Insight) has **no independent verification layer**. Every checkpoint is human-approval only: the orchestrator pauses for the human, and the human is the sole quality gate. Nothing in the ecosystem independently checks whether a stage's artifact is *correct and complete* before the next stage runs.

The MarketHub (Case 02) run exposed two real failures that this gap allowed through:

1. **Stage 5 incompleteness** — `03-results.md` was missing the Q9(0) result block: only 12 of 13 statements were captured. No gate compared the number of result blocks against the number of statements/sub-questions.
2. **Stage 6 factual error + self-grading conflict** — `04-insight.md` shipped a factual error (Summit Brands labeled "14th largest" when Q2 shows it is 12th of 14), yet the writer's own self-check reported **PASS** despite the error. The `insight-writer` self-check grades its own output, so a wrong insight can pass its own rubric.

The root cause is a structural one: **the author of an artifact is also its grader.** Scope/questions are authored and accepted by the orchestrator with no second opinion; SQL and results are authored by `sql-builder`; insight is authored *and* self-checked by `insight-writer`. A grader must not grade its own fix.

## Proposed Solution

Add a new read-only verification subagent — **`progress-evaluator`** — that acts as a **BLOCKING GATE at every checkpoint**, in the same family as `query-inspector`:

- **Read-only**: it INSPECTS artifacts and reports verdicts; it NEVER authors or edits SQL, insight, scope, questions, or results. A grader must not grade its own fix.
- **Verdict model**: `PASS` (all mandatory green), `PASS-WITH-NOTES` (mandatory green + advisory notes only), `FAIL` (≥1 mandatory red → block + route back). Checks are split **MANDATORY** (blocking) vs **ADVISORY** (non-blocking).
- **Per-stage mandatory PASS criteria** (stages 1–6), covering semantic/business alignment (Scope, Questions), data-quality coverage (Silver, Gold mart), and correctness/completeness/traceability (Results, Insight).
- **Re-run loop** (enforced by the *orchestrator*, not the evaluator): on `FAIL`, block the checkpoint, surface the defect to the human, route to the owning agent to fix-and-re-run, then re-inspect. Retry budget **3 fixes per checkpoint**; on exhaustion while still FAILING the pipeline **fails closed** (halts entirely, escalates to the human, never silently advances). Human override is allowed only via an explicit, documented decision.
- **Owner routing**: Stages 1–2 → orchestrator; Stages 3–5 → `sql-builder`; Stage 6 → `insight-writer`.
- **Reports** to `docs/04-progress-evaluator/` (dated variant if one exists — same convention as `query-inspector`).

This closes the verification gap without changing who authors each stage — the orchestrator still authors Scope/Questions, `sql-builder` still authors SQL, `insight-writer` still authors insight. The evaluator only *grades*.

## Scope

### In scope

- Creating the `progress-evaluator` subagent definition at `.opencode/agents/progress-evaluator.md` (YAML frontmatter with `description` and `mode: subagent`).
- Authoring the `progress-evaluator` capability spec delta (this change) following the `service-capability-template` structure (Input Contract, Output Contract, Failure Behavior, Quality Acceptance Criteria, Cross-Capability Dependency); the canonical spec is created at archive time.
- Adding an "Evaluation Gate Contract" to the `data-to-insight` spec and extending the Checkpoint Autonomy Contract, Orchestration Contract, and Cross-Capability Dependency to require the evaluator at every checkpoint with block/rerun/fail-closed behavior.
- Inserting the evaluator step into `agent-blueprints/03-data-to-insight.md` (stages 1–6 + checkpoints) and its owner-routing table.
- Updating `.opencode/skills/data-to-insight/SKILL.md` to mention the new delegation + gate behavior.
- Registering `progress-evaluator` in `AGENTS.md` as a domain agent (execution agent that never creates OpenSpec change proposals).

### Out of scope

- Any modification of `query-inspector`, `learning-progress`, or the `sql-builder` / `insight-writer` **authoring** roles beyond adding the gate/re-run wiring.
- Adding a learning track to `learning/00-notes/tracks.md`.
- Making the evaluator a planning agent — it is an execution capability and never creates OpenSpec change proposals.
- Any modification of datasets, the `sql-analyst-lab` module, or the `expected/` folders.
- Phase 2 implementation (actual creation of the agent/blueprint/skill/registry edits) — deferred until this proposal is approved.
- Creating ADRs or modifying OpenSpec methodology files.
- Making any git commits.

## Capabilities

### New Capabilities

- `progress-evaluator`

### Modified Capabilities

- `data-to-insight`

## Value Proposition

After this change, every `data-to-insight` checkpoint is independently verified before the human ever sees it: a read-only evaluator grades the Scope, Questions, Silver, Gold mart, Results, and Insight artifacts against explicit MANDATORY criteria, blocks downstream execution on any FAIL, routes the defect to the owning agent, and fails closed rather than silently advancing. The two MarketHub failures become impossible to ship silently — a missing Q9(0) block is a FAIL (completeness), and a "14th largest" rank that contradicts the results is a FAIL even when the writer's own self-check said PASS (categorical accuracy + traceability). The pipeline keeps its checkpointed-autonomy contract, but the human now signs off on artifacts that have already survived an independent, non-authoring grade — closing the "grader grades its own fix" hole that the Case 02 run exposed.
