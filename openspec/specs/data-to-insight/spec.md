# data-to-insight Specification

## Purpose

Govern the `data-to-insight` capability: an AI ecosystem that automates the 7-stage data-to-insight SQL analysis pipeline (context → scope → questions → bronze→silver → gold mart → query → insight) for a SQL Analyst Lab case or any dataset, against a PostgreSQL medallion (`bronze.`/`silver.`/`gold.` schemas), under checkpointed human approval.

## Requirements

### Requirement: Pipeline Input Contract

The system SHALL require, before any stage executes, a resolvable case folder containing a `case.md` main question and a `work/` directory, a dataset README describing business context, ERD/join hints, and data quirks, and a PostgreSQL instance with the case's dataset loaded into `bronze.`/`silver.`/`gold.` schemas.

#### Scenario: Valid case and dataset

- GIVEN a case folder with `case.md` and `work/`, a dataset README, and a PostgreSQL instance with the case dataset loaded
- WHEN the pipeline is invoked
- THEN the pipeline SHALL begin with the Context stage (stage 0)
- AND SHALL NOT require additional inputs to start

#### Scenario: Missing case folder or dataset README

- GIVEN the case folder, its `work/` directory, or the dataset README does not exist
- WHEN the pipeline is invoked
- THEN the pipeline SHALL halt before writing any artifact
- AND a failure reason SHALL identify the missing path by name

#### Scenario: Dataset limitation note present

- GIVEN `case.md` states a dataset limitation (e.g. NovaTel billing spans only 2025-12-01 and 2026-01-01)
- WHEN the pipeline runs the Context stage
- THEN the limitation SHALL be surfaced to the user
- AND downstream stages SHALL NOT author any comparison the limitation forbids (e.g. telecom YoY)

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

### Requirement: Scope Stage Contract

The system SHALL produce `01-scope.md` fixing approximately three Northstar metrics and approximately three dimensions as a floor, SHALL treat the floor as a minimum rather than a hard cap, and SHALL require every metric and dimension beyond the floor to map to a specific sub-question.

#### Scenario: Scope fixed before touching data

- GIVEN the pipeline has completed the Context stage
- WHEN the Scope stage runs
- THEN `01-scope.md` SHALL fix approximately three metrics and approximately three dimensions
- AND SHALL record exact metric definitions for any metric with multiple plausible interpretations

#### Scenario: Adding beyond the floor requires justification

- GIVEN the business question requires an additional metric or dimension beyond the ~3/~3 floor
- WHEN the Scope stage adds it
- THEN the addition SHALL map to a specific sub-question
- AND SHALL NOT be added without that mapping

### Requirement: Question Decomposition Contract

The system SHALL produce `02-questions.md` decomposing the main question into sub-questions mapped to exactly four buckets (Overall Trends, Growth Rates, Performance Measurement, KPI Reporting), with each sub-question expressed as one metric sliced by one dimension.

#### Scenario: Sub-questions mapped to the four buckets

- GIVEN the Scope stage has completed
- WHEN the Questions stage runs
- THEN `02-questions.md` SHALL map each sub-question to one of the four buckets
- AND each sub-question SHALL specify exactly one metric and one dimension

#### Scenario: Forbidden comparison is not authored

- GIVEN the dataset limitation forbids a comparison (e.g. NovaTel YoY)
- WHEN sub-questions are authored
- THEN no sub-question SHALL request the forbidden comparison

### Requirement: Silver Data Quality Contract

The system SHALL produce `_silver.sql` that profiles the dataset and evaluates all six data-quality dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness), SHALL apply only the subset effective for the current case, and SHALL document each skipped dimension as N/A with a reason.

#### Scenario: All six dimensions evaluated

- GIVEN the pipeline reaches the Bronze→Silver stage
- WHEN `_silver.sql` is authored
- THEN each of the six DQ dimensions SHALL be evaluated against the dataset profile
- AND the evaluation SHALL be recorded

#### Scenario: Only the effective subset applied

- GIVEN a dimension does not address a real quirk in the current dataset
- WHEN `_silver.sql` is authored
- THEN that dimension SHALL be documented as N/A with a reason
- AND SHALL NOT be applied blindly

#### Scenario: Effective subset addresses real quirks

- GIVEN the dataset has a known quirk (e.g. MarketHub has 517 orders with no payment row)
- WHEN the silver layer is built
- THEN the applied subset SHALL include the dimension that addresses that quirk
- AND SHALL NOT omit an effective dimension

### Requirement: Gold Mart Contract

The system SHALL declare the grain ("one row per what?") and the unique key before building the denormalized gold mart, SHALL build the mart from the silver layer, and SHALL verify row uniqueness (`COUNT(*)` equals `COUNT(DISTINCT <grain_key>)`) before any query runs.

#### Scenario: Grain and unique key declared

- GIVEN the pipeline reaches the Silver→Gold stage
- WHEN the gold mart is authored
- THEN the grain SHALL be declared explicitly
- AND the unique key that makes a row distinct SHALL be declared explicitly

#### Scenario: Uniqueness verified before querying

- GIVEN the gold mart has been built
- WHEN the uniqueness check runs
- THEN `COUNT(*)` SHALL equal `COUNT(DISTINCT <grain_key>)`
- AND a failure SHALL halt the stage before any downstream query executes

### Requirement: Query Execution Contract

The system SHALL author `03-queries.sql` containing exactly one query per sub-question, SHALL query the gold mart ONLY (never raw, bronze, or silver), SHALL group by the mart grain, SHALL execute the queries against PostgreSQL, and SHALL capture verified results to `03-results.md`.

#### Scenario: One query per sub-question over the gold mart

- GIVEN the gold mart has passed the uniqueness check
- WHEN the Query stage runs
- THEN `03-queries.sql` SHALL contain one query per sub-question
- AND every query SHALL reference the gold mart only
- AND every query SHALL GROUP BY over the mart grain

#### Scenario: Non-gold query rejected

- GIVEN a generated query references a raw, bronze, or silver table
- WHEN the QA gate reviews it
- THEN the query SHALL be flagged
- AND the query SHALL NOT be executed as-is

#### Scenario: Verified results captured

- GIVEN `03-queries.sql` has been executed against PostgreSQL
- WHEN results are captured
- THEN `03-results.md` SHALL record the actual execution output
- AND the output SHALL be reproducible on re-execution

### Requirement: Insight Synthesis Contract

The system SHALL produce `04-insight.md` containing a running log, the five insight components (Trend, Fluctuation, Anomaly, Root cause, Recommendation), an insight paragraph, recommendations, and a self-check against the weak-vs-strong insight rubric in `learning/04-data-to-insight/data-to-insight.md`.

#### Scenario: Five components present

- GIVEN verified results are available
- WHEN the Insight stage runs
- THEN `04-insight.md` SHALL include all five components (Trend, Fluctuation, Anomaly, Root cause, Recommendation)
- AND SHALL include an insight paragraph and recommendations

#### Scenario: Self-check against the rubric

- GIVEN the insight has been written
- WHEN the self-check runs
- THEN the insight SHALL be graded against the weak-vs-strong rubric
- AND a weak insight (e.g. "X is higher than Y; it is working") SHALL be strengthened before delivery

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

### Requirement: QA Gate Contract

The system SHALL reuse the existing `query-inspector` agent as a QA gate on generated queries, and SHALL NOT modify the `query-inspector` agent or spec.

#### Scenario: Generated queries reviewed

- GIVEN `03-queries.sql` has been authored
- WHEN the QA gate runs
- THEN the queries SHALL be reviewed by `query-inspector` for query-logic correctness and business-requirement alignment
- AND flagged queries SHALL be corrected before results are locked in

#### Scenario: query-inspector contract preserved

- GIVEN the ecosystem invokes `query-inspector`
- WHEN the invocation is performed
- THEN the `query-inspector` agent and its spec SHALL remain unchanged
- AND the review SHALL follow the `query-inspector` input/output contract as-is

### Requirement: Failure Behavior

The system SHALL halt before writing any artifact when a required input is missing, SHALL surface a clear failure reason for validation or execution failures, and SHALL leave previously written `work/` artifacts consistent when a partial failure occurs.

#### Scenario: Halt before side effects on missing input

- GIVEN a required input (case folder, dataset README, or PostgreSQL dataset) is missing
- WHEN the pipeline is invoked
- THEN the pipeline SHALL halt before writing any `work/` artifact
- AND SHALL report the missing input by name

#### Scenario: Partial failure leaves prior stages consistent

- GIVEN a failure occurs at a later stage after earlier stages wrote artifacts
- WHEN the failure is detected
- THEN the pipeline SHALL report which stages completed and which failed
- AND SHALL NOT report a successful overall run
- AND previously written artifacts SHALL remain unchanged

### Requirement: Quality Acceptance Criteria

The system SHALL validate each case's outputs against the `expected/` model answers (scope, questions, queries, results, and insight), SHALL ensure the gold mart uniqueness check holds, SHALL ensure exactly one query per sub-question, and SHALL ensure the final insight passes the weak-vs-strong rubric self-check.

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

### Requirement: Scope Reconciliation Contract

The system SHALL, when the Silver stage profiles the dataset, surface any metric, dimension, or data-quirk present in the data that (a) is NOT captured in `01-scope.md` AND (b) materially affects a sub-question's answer, SHALL route such a finding to the orchestrator for a scope amendment (the orchestrator owns `01-scope.md` and `02-questions.md`) rather than to `sql-builder`, and SHALL amend and re-verify the scope (and questions where needed) BEFORE questions and queries are locked.

#### Scenario: Profiled data reveals a material scope gap

- GIVEN the Silver stage profiles the dataset and finds a metric, dimension, or data-quirk that is not captured in `01-scope.md` and materially affects a sub-question's answer
- WHEN the finding is surfaced
- THEN the finding SHALL be routed to the orchestrator for a scope amendment
- AND SHALL NOT be routed to `sql-builder`

#### Scenario: Scope amended before questions and queries are locked

- GIVEN a scope amendment is required by a profiled-data finding
- WHEN the amendment is applied
- THEN `01-scope.md` SHALL be amended and, where a sub-question is affected, `02-questions.md` SHALL be amended
- AND the amended scope SHALL be re-verified BEFORE questions and queries are locked

#### Scenario: Scope amendment is a documented safety net

- GIVEN a scope amendment arises from data profiling
- WHEN the amendment is documented
- THEN the amendment SHALL be recorded as a legitimate, documented outcome
- AND SHALL NOT be treated as a failure of the "scope before data" rule

#### Scenario: No material scope gap surfaced

- GIVEN the profiled dataset surfaces no metric, dimension, or data-quirk that materially affects a sub-question but is absent from `01-scope.md`
- WHEN the Silver stage completes
- THEN no scope amendment SHALL be triggered
- AND the scope SHALL remain unchanged

## Boundaries

### In scope

- The 7-stage pipeline recipe (0 Context → 6 Insight) and its per-stage artifact contracts.
- The `data-to-insight` orchestrator skill, the `sql-builder` and `insight-writer` subagents, and the canonical blueprint.
- Checkpointed-autonomy gates and human-approval behavior.
- The six data-quality dimensions, the gold grain + unique-key verification, and the gold-mart-only query rule.
- The 5-component insight synthesis and weak-vs-strong self-check.
- Reuse of the `query-inspector` agent as a QA gate.
- Registration of the new agents in the routing registry.

### Out of scope

- Any modification of `learning/02-sql-learning/sql-skill-push/` files or datasets.
- Changes to the `sql-analyst-lab` module or spec (case folders are consumed read-only).
- Changes to the `query-inspector` agent or spec.
- Changes to the `learning-progress` skill, blueprint, manifest, or spec; registering a new learning track.
- Creating ADRs or modifying OpenSpec methodology files.
- Progress tracking or session summarization (owned by `learning-progress`).

## Related Code

- `.opencode/skills/data-to-insight/SKILL.md` — orchestrator skill
- `.opencode/agents/sql-builder.md` — SQL-authoring subagent (stages 3–5)
- `.opencode/agents/insight-writer.md` — insight-synthesis subagent (stage 6)
- `agent-blueprints/03-data-to-insight.md` — canonical blueprint
- `.opencode/agents/query-inspector.md` — reused QA gate (unchanged)
- `AGENTS.md` — agent routing registry (updated with the new agents)
- `learning/04-data-to-insight/data-to-insight.md` — pedagogy source (4-step framework + Running Log + weak-vs-strong rubric)
- `learning/02-sql-learning/sql-analyst-lab/` — case folders consumed read-only (`case.md`, `expected/`, `work/`)
- `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce_pg.sql` — MarketHub PostgreSQL dataset (read-only)
- `learning/02-sql-learning/sql-skill-push/datasets/03-advanced/telecom_pg.sql` — NovaTel PostgreSQL dataset (read-only)
- `script/01-sql/data-to-insight/00-bootstrap.sql` — PostgreSQL medallion bootstrap (schemas + dataset load)
- `openspec/specs/service-capability-template/spec.md` — contract template used for this capability
- `openspec/specs/spec-format/spec.md` — format contract this spec follows
