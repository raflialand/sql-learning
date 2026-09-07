# Spec Deltas for data-to-insight

## ADDED Requirements

### Requirement: Stakeholder Brief Contract

The system SHALL produce `00-stakeholder-brief.md` in Stage 0 after reading context (README + case.md) and surfacing limitations but BEFORE defining scope in Stage 1, SHALL structure the brief with 5 mandatory sections (Business context summary, Stakeholder priorities, Assumptions, Questions I'd ask the stakeholder, Success criteria) plus a forced "If I were the stakeholder..." perspective flip, and SHALL make the brief available as the输入 for Stage 1 scope decisions.

#### Scenario: Brief written before scope

- GIVEN the pipeline has read the dataset README and `case.md` and surfaced limitations
- WHEN Stage 0 completes
- THEN `00-stakeholder-brief.md` SHALL be written to the case's `work/` folder
- AND Stage 1 SHALL NOT begin until Checkpoint 0 (brief verification + human approval) passes

#### Scenario: Brief has all mandatory sections

- GIVEN `00-stakeholder-brief.md` is written
- WHEN the brief is inspected
- THEN it SHALL contain all 5 mandatory sections: Business context summary, Stakeholder priorities, Assumptions, Questions I'd ask the stakeholder, Success criteria
- AND it SHALL contain the forced "If I were the stakeholder..." perspective flip section

#### Scenario: Brief is non-trivial

- GIVEN `00-stakeholder-brief.md` is written
- WHEN the `progress-evaluator` inspects it at Checkpoint 0
- THEN each mandatory section SHALL contain substantive content (≥2 sentences, no placeholder text)
- AND stakeholder priorities SHALL be ranked or ordered (not a flat unstructured list)

#### Scenario: Optional case-specific questions

- GIVEN the dataset has quirks or limitation notes that deserve stakeholder attention
- WHEN the orchestrator writes the brief
- THEN the brief MAY include a "Case-specific questions" section calling out those quirks
- AND the absence of this section SHALL NOT cause a checkpoint failure

#### Scenario: Brief to scope traceability

- GIVEN `00-stakeholder-brief.md` has been approved at Checkpoint 0
- WHEN Stage 1 writes `01-scope.md`
- THEN every metric and dimension in scope SHALL be traceable to a priority, assumption, or success criterion in the brief
- AND a metric or dimension without such traceability SHALL be flagged at Checkpoint 1

## MODIFIED Requirements

### Requirement: Orchestration Contract

The system SHALL execute the pipeline stages in order (0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold → 5 Query → 6 Insight), SHALL write each stage's artifact to the case's `work/` folder (including `00-stakeholder-brief.md` for Stage 0), SHALL delegate SQL work to the `sql-builder` subagent and insight synthesis to the `insight-writer` subagent, and SHALL delegate checkpoint verification to the `progress-evaluator` subagent.

#### Scenario: Ordered execution

- GIVEN the pipeline is invoked
- WHEN the orchestrator runs
- THEN each stage SHALL complete before the next stage begins
- AND no stage SHALL be skipped
- AND every artifact SHALL be written to the resolved case's `work/` folder

#### Scenario: Stage 0 writes the stakeholder brief

- GIVEN the pipeline begins Stage 0
- WHEN Stage 0 executes
- THEN the orchestrator SHALL read the dataset README and `case.md`
- AND SHALL surface any dataset limitation
- AND SHALL write `00-stakeholder-brief.md` to the case's `work/` folder

#### Scenario: Delegation to subagents

- GIVEN the pipeline reaches a SQL stage (3, 4, or 5)
- WHEN that stage executes
- THEN the SQL work SHALL be delegated to the `sql-builder` subagent
- AND when stage 6 executes, the insight work SHALL be delegated to the `insight-writer` subagent

#### Scenario: Delegation of checkpoint verification

- GIVEN a checkpoint stage has completed
- WHEN the orchestrator reaches the checkpoint
- THEN the verification SHALL be delegated to the `progress-evaluator` subagent
- AND the orchestrator SHALL route any FAIL defect to the owning agent (orchestrator for stages 0–2, `sql-builder` for stages 3–5, `insight-writer` for stage 6)

#### Scenario: Existing artifacts are not silently overwritten

- GIVEN the case's `work/` folder already contains artifacts
- WHEN a stage is about to write
- THEN the orchestrator SHALL NOT silently overwrite existing files
- AND SHALL surface the existing artifacts for human reconciliation at the relevant checkpoint

> **Replaces**: The previous Orchestration Contract requirement. The original read: "The system SHALL execute the pipeline stages in order (0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold → 5 Query → 6 Insight), SHALL write each stage's artifact to the case's `work/` folder, SHALL delegate SQL work to the `sql-builder` subagent and insight synthesis to the `insight-writer` subagent, and SHALL delegate checkpoint verification to the `progress-evaluator` subagent." The original scenarios were: "Ordered execution" (same as above minus brief), "Delegation to subagents" (same), "Delegation of checkpoint verification" (routed to orchestrator for stages 1–2, not 0–2), and "Existing artifacts are not silently overwritten" (same).

### Requirement: Scope Stage Contract

The system SHALL produce `01-scope.md` fixing approximately three Northstar metrics and approximately three dimensions as a floor, SHALL treat the floor as a minimum rather than a hard cap, SHALL require every metric and dimension beyond the floor to map to a specific sub-question, and SHALL require every metric and dimension to be traceable to the stakeholder brief's priorities, assumptions, or success criteria.

#### Scenario: Scope fixed before touching data

- GIVEN the pipeline has completed the Context stage and Checkpoint 0 (stakeholder brief approved)
- WHEN the Scope stage runs
- THEN `01-scope.md` SHALL fix approximately three metrics and approximately three dimensions
- AND SHALL record exact metric definitions for any metric with multiple plausible interpretations

#### Scenario: Adding beyond the floor requires justification

- GIVEN the business question requires an additional metric or dimension beyond the ~3/~3 floor
- WHEN the Scope stage adds it
- THEN the addition SHALL map to a specific sub-question
- AND SHALL NOT be added without that mapping

#### Scenario: Every metric/dimension traces to the brief

- GIVEN `00-stakeholder-brief.md` has been approved
- WHEN `01-scope.md` is written
- THEN every metric and dimension SHALL be traceable to a priority, assumption, or success criterion in the brief
- AND a metric or dimension without such traceability SHALL be flagged at the Scope checkpoint

> **Replaces**: The previous Scope Stage Contract requirement. The original read: "The system SHALL produce `01-scope.md` fixing approximately three Northstar metrics and approximately three dimensions as a floor, SHALL treat the floor as a minimum rather than a hard cap, and SHALL require every metric and dimension beyond the floor to map to a specific sub-question." The original scenarios were: "Scope fixed before touching data" (same minus brief reference) and "Adding beyond the floor requires justification" (same).

### Requirement: Checkpoint Autonomy Contract

The system SHALL pause for human approval at seven checkpoints — after Stakeholder Brief, Scope, Questions, Silver, Gold mart, Queries+results, and final Insight — SHALL run the `progress-evaluator` gate on the stage's artifact before pausing at each checkpoint, and SHALL NOT execute any downstream stage before the evaluator returns a non-FAIL verdict and the human approves the checkpoint.

#### Scenario: Evaluator gate precedes human approval

- GIVEN a checkpoint stage has completed
- WHEN the orchestrator is about to proceed
- THEN the orchestrator SHALL invoke `progress-evaluator` on the stage's artifact
- AND SHALL pause for human approval only after the evaluator returns a non-FAIL verdict
- AND SHALL NOT execute the next stage without both the evaluator's non-FAIL verdict and human approval

#### Scenario: Evaluation FAIL blocks the checkpoint

- GIVEN the evaluator returns a FAIL verdict at a checkpoint
- WHEN the orchestrator processes the verdict
- THEN the orchestrator SHALL block the checkpoint
- AND SHALL route the defect to the owning agent for fix-and-re-run
- AND SHALL NOT execute any downstream stage

#### Scenario: Approval withheld

- GIVEN the human withholds approval at a checkpoint
- WHEN the rejection is communicated
- THEN the pipeline SHALL NOT advance
- AND the current artifact SHALL remain available for revision before re-submission

> **Replaces**: The previous Checkpoint Autonomy Contract requirement. The original read: "The system SHALL pause for human approval at six checkpoints — after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight — SHALL run the `progress-evaluator` gate on the stage's artifact before pausing at each checkpoint, and SHALL NOT execute any downstream stage before the evaluator returns a non-FAIL verdict and the human approves the checkpoint." The original scenarios were: "Evaluator gate precedes human approval" (same), "Evaluation FAIL blocks the checkpoint" (same), and "Approval withheld" (same).

### Requirement: Evaluation Gate Contract

The system SHALL run the `progress-evaluator` subagent as a read-only verification gate at every checkpoint (after Stakeholder Brief, Scope, Questions, Silver, Gold mart, Queries+results, and final Insight), SHALL block the checkpoint on a FAIL verdict, SHALL route the defect to the owning agent for fix-and-re-run, and SHALL re-inspect the corrected artifact until PASS or a retry budget of three fixes per checkpoint is exhausted, failing closed on exhaustion and escalating to the human rather than silently advancing.

#### Scenario: Evaluator gate runs before human approval

- GIVEN a checkpoint stage has completed
- WHEN the orchestrator reaches the checkpoint
- THEN the `progress-evaluator` SHALL inspect the stage artifact
- AND the orchestrator SHALL pause for human approval only after the evaluator returns a non-FAIL verdict

#### Scenario: FAIL blocks downstream execution

- GIVEN the evaluator returns FAIL at a checkpoint
- WHEN the orchestrator processes the verdict
- THEN the orchestrator SHALL block the checkpoint
- AND no downstream stage SHALL execute
- AND the defect SHALL be routed to the owning agent

#### Scenario: Fail-closed on budget exhaustion

- GIVEN the retry budget of three fixes is exhausted while the verdict is still FAIL
- WHEN the checkpoint is evaluated
- THEN the pipeline SHALL halt entirely and escalate to the human
- AND SHALL NEVER silently advance

> **Replaces**: The previous Evaluation Gate Contract requirement. The original read: "The system SHALL run the `progress-evaluator` subagent as a read-only verification gate at every checkpoint (after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight), SHALL block the checkpoint on a FAIL verdict, SHALL route the defect to the owning agent for fix-and-re-run, and SHALL re-inspect the corrected artifact until PASS or a retry budget of three fixes per checkpoint is exhausted, failing closed on exhaustion and escalating to the human rather than silently advancing." The original scenarios were: "Evaluator gate runs before human approval" (same), "FAIL blocks downstream execution" (same), and "Fail-closed on budget exhaustion" (same).

### Requirement: Quality Acceptance Criteria

The system SHALL validate each case's outputs against the `expected/` model answers (scope, questions, queries, results, and insight), SHALL ensure the gold mart uniqueness check holds, SHALL ensure exactly one query per sub-question, SHALL ensure the final insight passes the weak-vs-strong rubric self-check, and SHALL ensure the stakeholder brief passes Checkpoint 0 verification (all mandatory sections present, non-trivial content).

#### Scenario: Results match expected ground truth

- GIVEN a case has an `expected/03-results.md` model answer
- WHEN the pipeline's `03-results.md` is produced
- THEN the captured results SHALL match the expected results
- AND a mismatch SHALL be surfaced for reconciliation

#### Scenario: Insight passes the rubric

- GIVEN `04-insight.md` is produced
- WHEN the quality check runs
- THEN the insight SHALL satisfy the weak-vs-strong rubric (trend + fluctuation + anomaly + root cause + recommendation)
- AND a weak insight SHALL fail the quality check

#### Scenario: Stakeholder brief passes Checkpoint 0

- GIVEN `00-stakeholder-brief.md` is produced
- WHEN Checkpoint 0 runs
- THEN the brief SHALL contain all 5 mandatory sections with substantive content
- AND the forced perspective section SHALL be present
- AND a stub or placeholder brief SHALL fail the quality check

> **Replaces**: The previous Quality Acceptance Criteria requirement. The original read: "The system SHALL validate each case's outputs against the `expected/` model answers (scope, questions, queries, results, and insight), SHALL ensure the gold mart uniqueness check holds, SHALL ensure exactly one query per sub-question, and SHALL ensure the final insight passes the weak-vs-strong rubric self-check." The original scenarios were: "Results match expected ground truth" (same) and "Insight passes the rubric" (same).

### Requirement: Boundaries (In scope)

The system SHALL treat the following as in scope: the 7-stage pipeline recipe (0 Context → 6 Insight) and its per-stage artifact contracts (including `00-stakeholder-brief.md`), the `data-to-insight` orchestrator skill, the `sql-builder` and `insight-writer` subagents, and the canonical blueprint, checkpointed-autonomy gates and human-approval behavior (7 checkpoints), the six data-quality dimensions, the gold grain + unique-key verification, and the gold-mart-only query rule, the 5-component insight synthesis and weak-vs-strong self-check, reuse of the `query-inspector` agent as a QA gate, registration of the new agents in the routing registry, and the stakeholder brief as a mandatory Stage 0 artifact with scope traceability.

> **Replaces**: The previous Boundaries (In scope) text. The original listed: "The 7-stage pipeline recipe (0 Context → 6 Insight) and its per-stage artifact contracts." and "Checkpointed-autonomy gates and human-approval behavior." — both without mention of the stakeholder brief or 7 checkpoints.
