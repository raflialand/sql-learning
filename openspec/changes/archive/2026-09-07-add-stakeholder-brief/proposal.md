# Add Stakeholder Brief

## Problem Statement

Stage 0 of the data-to-insight pipeline currently reads context (README + case.md) and surfaces limitations, then jumps directly into Stage 1 scope definition. There is no deliberate pause to synthesize what the stakeholder actually needs, what assumptions the analyst is making, or what a "good" analysis looks like from the decision-maker's perspective. This means metric/dimension selection in Stage 1 is driven by the raw context rather than by a structured understanding of stakeholder priorities. The result: scopes that are technically correct but misaligned with what the stakeholder would actually act on.

## Proposed Solution

Add a `00-stakeholder-brief.md` artifact to Stage 0. After reading context but BEFORE defining scope, the orchestrator writes a structured brief with 5 mandatory sections (Business context summary, Stakeholder priorities, Assumptions, Questions I'd ask the stakeholder, Success criteria) plus a forced "If I were the stakeholder..." perspective flip and optional case-specific questions. A new Checkpoint 0 pauses for human approval of the brief before Stage 1 begins. Stage 1 scope must then trace every metric/dimension back to the brief's priorities and assumptions.

## Scope

### In scope

- New `00-stakeholder-brief.md` artifact written by the orchestrator in Stage 0
- New Checkpoint 0 (progress-evaluator verifies brief exists and is non-trivial, then human approves)
- Brief template with 5 mandatory sections + forced perspective + optional case-specific questions
- Stage 1 scope contract updated to require traceability back to the brief
- All pipeline specs, blueprints, skill files, and agent definitions updated to reflect 7 checkpoints
- `AGENTS.md` agent routing registry updated (progress-evaluator stages 1–6 → 0–6)
- `openspec/specs/progress-evaluator/spec.md` Boundaries updated (stages 1–6 → 0–6)
- Case templates updated with stakeholder context hints and 7 checkpoints

### Out of scope

- Creating a dedicated stakeholder agent (the orchestrator writes the brief)
- Modifying the `progress-evaluator` spec (no canonical spec exists; only the agent definition is updated)
- Changes to any learning-progress, query-inspector, or sql-analyst-lab specs
- Changes to datasets or case expected/ folders

## Capabilities

### New Capabilities

- None (the brief is a new artifact within an existing capability, not a new capability)

### Modified Capabilities

- `data-to-insight` — the pipeline gains a new artifact, a new checkpoint, and modified scope/evaluation contracts

## Value Proposition

- **Forces deliberate context-gathering** — the analyst cannot skip straight to metrics; they must first articulate what the stakeholder needs and what they're assuming.
- **Surfaces misalignment early** — the "Questions I'd ask the stakeholder" section and forced perspective flip catch gaps before Stage 1 locks in scope.
- **Creates a traceability chain** — every metric/dimension in scope can be justified from the brief, making the analysis defensible and reviewable.
- **Improves checkpoint quality** — Checkpoint 0 gives the human a chance to correct stakeholder understanding before any scoping work is done.
- **Zero new agents** — the orchestrator already reads context; the brief is a natural output of that reading, adding no new delegation complexity.
