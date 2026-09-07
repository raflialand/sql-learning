# Add Stakeholder Brief — Design

## Overview

Stage 0 of the data-to-insight pipeline gains a new step: after reading context (README + case.md) and surfacing limitations, the orchestrator writes `00-stakeholder-brief.md` to the case's `work/` folder. A new Checkpoint 0 pauses for progress-evaluator verification and human approval before Stage 1 begins. Stage 1's scope contract is updated so every metric/dimension traces back to the brief's priorities and assumptions. The total checkpoint count moves from 6 to 7.

## Design Decisions

### Decision 1: Orchestrator writes the brief, no dedicated agent

**Choice**: The orchestrator reads context and produces the brief directly.
**Rationale**: The orchestrator already reads README + case.md in Stage 0. Adding a dedicated stakeholder agent would introduce a new delegation boundary, a new agent definition, and new routing complexity for a task that is fundamentally a synthesis of information the orchestrator already holds. The brief is a thinking exercise, not a domain-specialist task.

### Decision 2: New step within Stage 0, not a new numbered stage

**Choice**: The brief is written as an additional step within Stage 0 (Context), not as Stage 0a or a new Stage 0.
**Rationale**: The brief is context-gathering output, not a separate pipeline phase. Keeping it within Stage 0 preserves the 7-stage mental model (0 Context → 6 Insight) while adding the brief as a mandatory deliverable of the context stage. The pipeline flow becomes: Read → Surface limitations → Write brief → Checkpoint 0 → Stage 1.

### Decision 3: Template floor, adaptive ceiling

**Choice**: 5 mandatory sections always present + optional case-specific questions + forced perspective flip.
**Rationale**: A rigid template risks becoming a checkbox exercise. The 5 mandatory sections ensure minimum structure (context, priorities, assumptions, questions, success criteria). The optional case-specific questions let the orchestrator call out dataset quirks or limitation notes that deserve stakeholder attention. The forced perspective flip ("If I were the stakeholder...") forces empathy and surfaces the one thing the stakeholder actually needs.

### Decision 4: Stage 1 must trace back to the brief

**Choice**: Every metric/dimension in `01-scope.md` must be justifiable from the brief's priorities and assumptions.
**Rationale**: Without this constraint, the brief becomes a write-and-forget artifact. The traceability requirement forces the orchestrator to use the brief as the输入 for scope decisions, creating a defensible chain from stakeholder need → scope → sub-questions → queries → insight.

### Decision 5: Checkpoint 0 is a full evaluator gate

**Choice**: The progress-evaluator verifies the brief exists and is non-trivial before human approval.
**Rationale**: A checkpoint without evaluator verification would be a rubber stamp. The evaluator ensures the brief has all mandatory sections, is non-trivial (not a stub), and contains no placeholder text. This catches incomplete briefs before the human reviews them, saving review time.

## Target Structure

```
openspec/changes/add-stakeholder-brief/
├── proposal.md                                ← CREATED
├── design.md                                  ← CREATED (this file)
├── tasks.md                                   ← CREATED
└── specs/
    └── data-to-insight/
        └── spec.md                            ← CREATED (delta spec)

agent-blueprints/03-data-to-insight.md         ← MODIFIED: Stage 0 description, artifact table, checkpoint list, owner routing
.opencode/agents/progress-evaluator.md         ← MODIFIED: add Stage 0 MANDATORY checks, update description
.opencode/skills/data-to-insight/SKILL.md      ← MODIFIED: quick reference updates
.opencode/skills/data-to-insight/README.md     ← MODIFIED: stage table, checkpoint description
AGENTS.md                                      ← MODIFIED: progress-evaluator description (stages 1–6 → 0–6)
openspec/specs/progress-evaluator/spec.md      ← MODIFIED: Boundaries (stages 1–6 → 0–6)
case-template/case.md.template                 ← MODIFIED: add stakeholder context hint section
case-template/ONBOARD.md                       ← MODIFIED: artifact table, checkpoint count
```

## Edge Cases

- **Case with minimal context (short README, no limitation notes)**: The brief still requires all 5 mandatory sections. The orchestrator synthesizes what it can from available context and flags gaps in the "Questions I'd ask the stakeholder" section. The evaluator checks for non-trivial content, not completeness of external knowledge.
- **Case with explicit stakeholder persona in case.md**: The brief leverages the persona directly. If case.md provides no persona, the orchestrator infers one from the business context and marks assumptions explicitly.
- **Re-run after Checkpoint 0 rejection**: The orchestrator revises the brief in place (overwrites `00-stakeholder-brief.md`) and resubmits for evaluator re-check and human re-approval. No new file is created; the existing brief is updated.
- **Brief reveals scope is fundamentally wrong**: If the brief surfaces that the main question is unanswerable with the available data (e.g. missing a critical dimension), the orchestrator flags this at Checkpoint 0 and the human decides whether to proceed, adjust the question, or abort. This is a feature, not a bug — early detection of unanswerable questions saves downstream work.

## Affected Specs

| Spec | Change Type |
| --- | --- |
| `specs/data-to-insight/spec.md` | MODIFIED (6 requirements updated) + ADDED (1 new requirement) |
