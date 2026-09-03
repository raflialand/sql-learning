# Spec Deltas for data-to-insight

## ADDED Requirements

### Requirement: Evaluation Gate Contract

The system SHALL run the `progress-evaluator` subagent as a read-only verification gate at every checkpoint (after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight), SHALL block the checkpoint on a FAIL verdict, SHALL route the defect to the owning agent for fix-and-re-run, and SHALL re-inspect the corrected artifact until PASS or a retry budget of three fixes per checkpoint is exhausted, failing closed on exhaustion and escalating to the human rather than silently advancing.

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

## MODIFIED Requirements

### Requirement: Checkpoint Autonomy Contract

The system SHALL pause for human approval at six checkpoints — after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight — SHALL run the `progress-evaluator` gate on the stage's artifact before pausing at each checkpoint, and SHALL NOT execute any downstream stage before the evaluator returns a non-FAIL verdict and the human approves the checkpoint.

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

> **Replaces**: The previous requirement text being modified. Include the full original `### Requirement:` header and all scenario text for exact matching during archive merge.
>
> ### Requirement: Checkpoint Autonomy Contract
>
> The system SHALL pause for human approval at six checkpoints — after Scope, Questions, Silver, Gold mart, Queries+results, and final Insight — and SHALL NOT execute any downstream stage before the current checkpoint is approved.
>
> #### Scenario: Checkpoint approval required
>
> - GIVEN a checkpoint stage has completed
> - WHEN the orchestrator is about to proceed
> - THEN the orchestrator SHALL pause for human approval
> - AND SHALL NOT execute the next stage without it
>
> #### Scenario: Approval withheld
>
> - GIVEN the human withholds approval at a checkpoint
> - WHEN the rejection is communicated
> - THEN the pipeline SHALL not advance
> - AND the current artifact SHALL remain available for revision before re-submission

### Requirement: Orchestration Contract

The system SHALL execute the pipeline stages in order (0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold → 5 Query → 6 Insight), SHALL write each stage's artifact to the case's `work/` folder, SHALL delegate SQL work to the `sql-builder` subagent and insight synthesis to the `insight-writer` subagent, and SHALL delegate checkpoint verification to the `progress-evaluator` subagent.

#### Scenario: Ordered execution

- GIVEN the pipeline is invoked
- WHEN the orchestrator runs
- THEN each stage SHALL complete before the next stage begins
- AND no stage SHALL be skipped
- AND every artifact SHALL be written to the resolved case's `work/` folder

#### Scenario: Delegation to subagents

- GIVEN the pipeline reaches a SQL stage (3, 4, or 5)
- WHEN that stage executes
- THEN the SQL work SHALL be delegated to the `sql-builder` subagent
- AND when stage 6 executes, the insight work SHALL be delegated to the `insight-writer` subagent

#### Scenario: Delegation of checkpoint verification

- GIVEN a checkpoint stage has completed
- WHEN the orchestrator reaches the checkpoint
- THEN the verification SHALL be delegated to the `progress-evaluator` subagent
- AND the orchestrator SHALL route any FAIL defect to the owning agent (orchestrator for stages 1–2, `sql-builder` for stages 3–5, `insight-writer` for stage 6)

#### Scenario: Existing artifacts are not silently overwritten

- GIVEN the case's `work/` folder already contains artifacts
- WHEN a stage is about to write
- THEN the orchestrator SHALL NOT silently overwrite existing files
- AND SHALL surface the existing artifacts for human reconciliation at the relevant checkpoint

> **Replaces**: The previous requirement text being modified. Include the full original `### Requirement:` header and all scenario text for exact matching during archive merge.
>
> ### Requirement: Orchestration Contract
>
> The system SHALL execute the pipeline stages in order (0 Context → 1 Scope → 2 Questions → 3 Bronze→Silver → 4 Silver→Gold → 5 Query → 6 Insight), SHALL write each stage's artifact to the case's `work/` folder, and SHALL delegate SQL work to the `sql-builder` subagent and insight synthesis to the `insight-writer` subagent.
>
> #### Scenario: Ordered execution
>
> - GIVEN the pipeline is invoked
> - WHEN the orchestrator runs
> - THEN each stage SHALL complete before the next stage begins
> - AND no stage SHALL be skipped
> - AND every artifact SHALL be written to the resolved case's `work/` folder
>
> #### Scenario: Delegation to subagents
>
> - GIVEN the pipeline reaches a SQL stage (3, 4, or 5)
> - WHEN that stage executes
> - THEN the SQL work SHALL be delegated to the `sql-builder` subagent
> - AND when stage 6 executes, the insight work SHALL be delegated to the `insight-writer` subagent
>
> #### Scenario: Existing artifacts are not silently overwritten
>
> - GIVEN the case's `work/` folder already contains artifacts
> - WHEN a stage is about to write
> - THEN the orchestrator SHALL NOT silently overwrite existing files
> - AND SHALL surface the existing artifacts for human reconciliation at the relevant checkpoint

### Requirement: Cross-Capability Dependency

The system SHALL reuse the `sql-analyst-lab` case folders and the `sql-skill-push` datasets read-only without modifying either, SHALL reuse the existing `query-inspector` agent as a QA gate without modifying its contract, SHALL reuse the new `progress-evaluator` agent as a read-only verification gate without modifying the authoring roles of `sql-builder`, `insight-writer`, or the orchestrator, SHALL NOT register a new learning track or modify the `learning-progress` skill, blueprint, manifest, or spec, and SHALL register the new agents in the project's agent routing registry.

#### Scenario: Case folders and datasets reused read-only

- GIVEN the pipeline runs against a `sql-analyst-lab` case and its `sql-skill-push` dataset
- WHEN the repository status is checked
- THEN no changes SHALL appear under `learning/02-sql-learning/sql-skill-push/`
- AND the `expected/` folders SHALL remain unmodified

#### Scenario: No modification of existing capabilities

- GIVEN the capability is added
- WHEN the dependency surface is inspected
- THEN the `sql-analyst-lab`, `query-inspector`, and `learning-progress` specs SHALL remain unchanged
- AND no new row SHALL be added to `learning/00-notes/tracks.md`

#### Scenario: Evaluator is read-only and non-authoring

- GIVEN the `progress-evaluator` gate inspects a stage artifact
- WHEN the dependency surface is inspected
- THEN `progress-evaluator` SHALL NOT modify the artifact under inspection or the owning agent's authoring role
- AND a FAIL verdict SHALL be routed to the owning agent, never fixed by the evaluator itself

#### Scenario: Registry entry required

- GIVEN the new skill and subagents are added
- WHEN the capability is documented
- THEN `data-to-insight`, `sql-builder`, `insight-writer`, and `progress-evaluator` SHALL be registered in `AGENTS.md`
- AND the subagents SHALL be declared as execution agents that do not create OpenSpec change proposals

> **Replaces**: The previous requirement text being modified. Include the full original `### Requirement:` header and all scenario text for exact matching during archive merge.
>
> ### Requirement: Cross-Capability Dependency
>
> The system SHALL reuse the `sql-analyst-lab` case folders and the `sql-skill-push` datasets read-only without modifying either, SHALL reuse the existing `query-inspector` agent as a QA gate without modifying its contract, SHALL NOT register a new learning track or modify the `learning-progress` skill, blueprint, manifest, or spec, and SHALL register the new agents in the project's agent routing registry.
>
> #### Scenario: Case folders and datasets reused read-only
>
> - GIVEN the pipeline runs against a `sql-analyst-lab` case and its `sql-skill-push` dataset
> - WHEN the repository status is checked
> - THEN no changes SHALL appear under `learning/02-sql-learning/sql-skill-push/`
> - AND the `expected/` folders SHALL remain unmodified
>
> #### Scenario: No modification of existing capabilities
>
> - GIVEN the capability is added
> - WHEN the dependency surface is inspected
> - THEN the `sql-analyst-lab`, `query-inspector`, and `learning-progress` specs SHALL remain unchanged
> - AND no new row SHALL be added to `learning/00-notes/tracks.md`
>
> #### Scenario: Registry entry required
>
> - GIVEN the new skill and subagents are added
> - WHEN the capability is documented
> - THEN `data-to-insight`, `sql-builder`, and `insight-writer` SHALL be registered in `AGENTS.md`
> - AND the subagents SHALL be declared as execution agents that do not create OpenSpec change proposals
