# progress-evaluator Specification

## Purpose

Govern the `progress-evaluator` capability: a read-only verification subagent that acts as a blocking gate at every checkpoint of the `data-to-insight` pipeline, inspecting stage artifacts and emitting PASS / PASS-WITH-NOTES / FAIL verdicts against per-stage MANDATORY checks.

## Requirements

### Requirement: Capability Input Contract

The progress-evaluator capability SHALL accept, before verification begins, the resolved case's `case.md` main question and dataset README, the stage artifact under inspection (`01-scope.md`, `02-questions.md`, `_silver.sql`, the gold mart definition, `03-results.md`, or `04-insight.md`), and — for the Scope and Questions stages — the produced scope pool for semantic cross-checking.

#### Scenario: Valid inspection inputs

- GIVEN the resolved case's `case.md`, dataset README, and the stage artifact under inspection all exist
- WHEN the progress-evaluator is invoked at a checkpoint
- THEN the capability SHALL begin inspection without requiring additional inputs
- AND SHALL NOT require write access to any artifact

#### Scenario: Missing artifact under inspection

- GIVEN the stage artifact under inspection does not exist or is empty
- WHEN the progress-evaluator is invoked
- THEN the capability SHALL halt before emitting any verdict
- AND a failure reason SHALL identify the missing artifact by name

### Requirement: Read-Only Verification Constraint

The progress-evaluator capability SHALL inspect artifacts and report verdicts only, and SHALL NOT author, edit, or re-produce any SQL, insight, scope, questions, or results artifact.

#### Scenario: Evaluator never fixes what it grades

- GIVEN the evaluator identifies a defect in a stage artifact
- WHEN the defect is recorded
- THEN the evaluator SHALL report the defect and its owning agent
- AND SHALL NOT correct the artifact itself
- AND a grader SHALL NOT grade its own fix

### Requirement: Verdict Model Contract

The progress-evaluator capability SHALL emit exactly one verdict per checkpoint from PASS, PASS-WITH-NOTES, and FAIL, SHALL split every check into MANDATORY (blocking) or ADVISORY (non-blocking), and SHALL derive the verdict from the MANDATORY checks only.

#### Scenario: All mandatory checks green

- GIVEN every MANDATORY check passes
- WHEN the verdict is computed
- THEN the verdict SHALL be PASS
- AND any advisory notes SHALL be logged as PASS-WITH-NOTES when present

#### Scenario: Mandatory check fails

- GIVEN at least one MANDATORY check fails
- WHEN the verdict is computed
- THEN the verdict SHALL be FAIL
- AND the failing check SHALL be reported with the measured evidence and the expected condition

#### Scenario: Advisory-only findings

- GIVEN all MANDATORY checks pass but one or more ADVISORY notes are present
- WHEN the verdict is computed
- THEN the verdict SHALL be PASS-WITH-NOTES
- AND the checkpoint SHALL advance with the advisory notes logged

### Requirement: Scope Evaluation Contract

The progress-evaluator capability SHALL grade `01-scope.md` on five MANDATORY checks: every metric and dimension is traceable to the `case.md` main question and justified against it; the ≥3 metrics AND ≥3 dimensions floor is met; metrics are measurable numbers and dimensions are slices with no metric-as-dimension confusion; ambiguous metrics have explicit definitions; and no comparison the dataset limitation forbids is introduced.

#### Scenario: Scope passes semantic alignment

- GIVEN `01-scope.md` traces every metric/dimension to the main question, meets the ≥3/≥3 floor, defines ambiguous metrics, and avoids forbidden comparisons
- WHEN the Scope checkpoint is graded
- THEN the verdict SHALL be PASS
- AND the report SHALL record each of the five checks as green

#### Scenario: Scope introduces a forbidden comparison

- GIVEN `01-scope.md` introduces a comparison the dataset limitation forbids (e.g. NovaTel YoY)
- WHEN the Scope checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the forbidden comparison SHALL be named in the report

#### Scenario: Scope floor not met

- GIVEN `01-scope.md` fixes fewer than three metrics or fewer than three dimensions
- WHEN the Scope checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL state the missing metric or dimension count

### Requirement: Questions Evaluation Contract

The progress-evaluator capability SHALL grade `02-questions.md` on six MANDATORY checks: every sub-question maps to exactly one of the four buckets (Overall Trends, Growth Rates, Performance Measurement, KPI Reporting); each sub-question is one metric × one dimension, both drawn from the Stage 1 scope pool; coverage holds both ways (no orphan scoped metric/dimension and no out-of-scope metric); the bucket lens is correct (Trends=level, Growth=% change, Performance=head-to-head snapshot, KPI="why"); no duplicate sub-question shares the same metric×dimension×lens; and every sub-question demonstrably serves the main question.

#### Scenario: Questions pass coverage both ways

- GIVEN `02-questions.md` uses every scoped metric/dimension, introduces no out-of-scope metric, maps each sub-question to one bucket with the correct lens, and contains no duplicates
- WHEN the Questions checkpoint is graded
- THEN the verdict SHALL be PASS
- AND the report SHALL confirm full two-way coverage

#### Scenario: Out-of-scope metric used by a sub-question

- GIVEN a sub-question uses a metric not drawn from the Stage 1 scope pool
- WHEN the Questions checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the out-of-scope metric SHALL be named in the report

#### Scenario: Duplicate sub-question detected

- GIVEN two sub-questions share the same metric × dimension × lens
- WHEN the Questions checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the duplicate pair SHALL be named in the report

### Requirement: Silver Evaluation Contract

The progress-evaluator capability SHALL grade `_silver.sql` on six MANDATORY checks: all six DQ dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) are evaluated, each applied or N/A-with-reason; no dimension is N/A without a documented reason; the applied subset covers every known dataset quirk from the dataset README; row counts are preserved (conform + flag, never drop); the SQL runs without error; and the profiled dataset surfaces no metric, dimension, or data-quirk that materially affects a sub-question's answer but is absent from `01-scope.md` (i.e. no unflagged scope gap).

#### Scenario: Silver passes DQ coverage and scope reconciliation

- GIVEN `_silver.sql` evaluates all six dimensions, documents every N/A, covers every README quirk, preserves row counts, runs without error, and surfaces no unflagged scope gap against `01-scope.md`
- WHEN the Silver checkpoint is graded
- THEN the verdict SHALL be PASS
- AND the report SHALL record each of the six checks as green

#### Scenario: N/A without reason

- GIVEN `_silver.sql` marks a DQ dimension N/A without a documented reason
- WHEN the Silver checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the undocumented N/A dimension SHALL be named in the report

#### Scenario: Row counts dropped

- GIVEN `_silver.sql` drops rows rather than conforming and flagging
- WHEN the Silver checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL identify the drop and the expected conform-and-flag behavior

#### Scenario: Unflagged scope gap

- GIVEN the profiled dataset surfaces a metric, dimension, or data-quirk that materially affects a sub-question's answer but is absent from `01-scope.md`, and the gap was not surfaced for amendment
- WHEN the Silver checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL name the gap and the affected sub-question

### Requirement: Gold Mart Evaluation Contract

The progress-evaluator capability SHALL grade the gold mart on five MANDATORY checks: the grain is declared ("one row per …"); the unique key is declared; `COUNT(*) = COUNT(DISTINCT grain_key)` holds as independently re-verified; no fan-out is present (mart row count equals source line count); and the mart covers every sub-question's required columns including drill-downs (e.g. product).

#### Scenario: Gold mart passes uniqueness and coverage

- GIVEN the mart declares grain and unique key, the uniqueness equality holds on independent re-verification, no fan-out is present, and all required columns including drill-downs are covered
- WHEN the Gold mart checkpoint is graded
- THEN the verdict SHALL be PASS
- AND the report SHALL record each of the five checks as green

#### Scenario: Uniqueness equality fails

- GIVEN `COUNT(*)` does not equal `COUNT(DISTINCT grain_key)` on re-verification
- WHEN the Gold mart checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL report both counts

#### Scenario: Fan-out detected

- GIVEN the mart row count exceeds the source line count
- WHEN the Gold mart checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL identify the fan-out

### Requirement: Results Evaluation Contract

The progress-evaluator capability SHALL grade `03-results.md` on four MANDATORY checks: completeness (every statement/sub-question has a result block, all N statements captured); reconciliation (Σ vendor GMV ≈ Q1 total, Q6 Jan-26 values consistent with Q2, AOV = GMV ÷ orders within rounding tolerance); no unexpected NULLs (legitimate NULLs such as first-month MoM are allowed); and metric definitions honored (e.g. GMV = SUM(line_revenue) WHERE is_fulfilled = 1).

#### Scenario: Results pass completeness and reconciliation

- GIVEN `03-results.md` contains a result block for every statement, reconciles across queries, shows no unexpected NULLs, and honors metric definitions
- WHEN the Results checkpoint is graded
- THEN the verdict SHALL be PASS
- AND the report SHALL record each of the four checks as green

#### Scenario: Missing result block

- GIVEN `03-results.md` is missing a result block for a statement (e.g. Q9(0))
- WHEN the Results checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL name the missing statement and count captured versus total

#### Scenario: Reconciliation mismatch

- GIVEN a reconciliation check fails (e.g. AOV does not equal GMV ÷ orders within tolerance)
- WHEN the Results checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL state the measured value and expected value

### Requirement: Insight Evaluation Contract

The progress-evaluator capability SHALL grade `04-insight.md` on five MANDATORY checks: the five components are present in canonical order (Trend → Fluctuation → Anomaly → Root cause → Recommendation); every number/claim traces to a `03-results.md` cell; categorical accuracy holds (ranks "Nth of M" and ratios such as "3× the lowest" re-derived correctly); no weak-insight filler (each component has magnitude + context); and seasonality is not overclaimed (a single YoY point is hedged).

#### Scenario: Insight passes traceability and accuracy

- GIVEN `04-insight.md` presents the five components in order, traces every claim to a results cell, re-derives ranks/ratios correctly, and hedges seasonality
- WHEN the Insight checkpoint is graded
- THEN the verdict SHALL be PASS
- AND the report SHALL record each of the five checks as green

#### Scenario: Factual error despite a passing self-check

- GIVEN `04-insight.md` claims a rank (e.g. "14th largest") that contradicts the results (e.g. 12th of 14) even though the writer's own self-check reported PASS
- WHEN the Insight checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL cite the contradicting `03-results.md` cell

#### Scenario: Weak-insight filler present

- GIVEN an insight component lacks magnitude or context (e.g. "X is higher than Y; it is working")
- WHEN the Insight checkpoint is graded
- THEN the verdict SHALL be FAIL
- AND the report SHALL name the weak component

### Requirement: Output Artifact Contract

The progress-evaluator capability SHALL write a verification report to `docs/04-progress-evaluator/` documenting the verdict, every MANDATORY and ADVISORY check result, the evidence traced to the artifact under inspection, and the owning-agent routing on FAIL.

#### Scenario: Verification report written

- GIVEN an inspection has completed
- WHEN the output artifact is produced
- THEN the capability SHALL write the report to `docs/04-progress-evaluator/`
- AND the report SHALL include the verdict, per-check results, evidence, and routing

#### Scenario: Existing report preserved

- GIVEN a report already exists in `docs/04-progress-evaluator/`
- WHEN a new inspection is written
- THEN the capability SHALL NOT silently overwrite the existing report
- AND the new report SHALL be written under a dated filename that preserves the previous report

### Requirement: Re-Run Loop Contract

The system SHALL, on a FAIL verdict, block the checkpoint, surface the defect to the human, route it to the owning agent for fix-and-re-run, re-inspect the corrected artifact, and repeat until PASS or a retry budget of three fixes per checkpoint is exhausted; the system SHALL fail closed on budget exhaustion while still FAILING, halting the pipeline entirely and escalating to the human, and SHALL permit human override only via an explicit, documented decision recorded in the report.

#### Scenario: FAIL blocks and routes to the owner

- GIVEN the evaluator returns FAIL at a checkpoint
- WHEN the orchestrator processes the verdict
- THEN the checkpoint SHALL be blocked
- AND no downstream stage SHALL run
- AND the defect SHALL be surfaced to the human and routed to the owning agent

#### Scenario: Corrected artifact re-inspected

- GIVEN the owning agent fixes and re-produces the artifact after a FAIL
- WHEN the orchestrator re-runs the gate
- THEN the evaluator SHALL inspect the corrected artifact and write a new dated report
- AND the loop SHALL repeat until PASS or the retry budget is exhausted

#### Scenario: Fail-closed on budget exhaustion

- GIVEN the retry budget of three fixes is exhausted while the verdict is still FAIL
- WHEN the checkpoint is evaluated
- THEN the pipeline SHALL halt entirely and escalate to the human
- AND SHALL NEVER silently advance past a FAILING checkpoint

#### Scenario: Human override is explicit and documented

- GIVEN a human wishes to override a FAIL or a budget-exhaustion halt
- WHEN the override is exercised
- THEN the override SHALL be recorded in the report as an explicit decision
- AND SHALL NOT occur silently

### Requirement: Owner Routing Contract

The system SHALL route FAIL defects to the owning agent by stage: stages 1–2 (Scope, Questions) to the orchestrator, stages 3–5 (Silver, Gold mart, Results) to `sql-builder`, and stage 6 (Insight) to `insight-writer`.

#### Scenario: Routing per stage

- GIVEN a FAIL at a checkpoint
- WHEN the defect is routed
- THEN a stage 1 or 2 defect SHALL route to the orchestrator
- AND a stage 3, 4, or 5 defect SHALL route to `sql-builder`
- AND a stage 6 defect SHALL route to `insight-writer`

#### Scenario: Evaluator never routes to itself

- GIVEN a FAIL at any checkpoint
- WHEN the defect is routed
- THEN the defect SHALL NOT route to `progress-evaluator`
- AND the evaluator SHALL only re-inspect the corrected artifact

### Requirement: Failure Behavior

The progress-evaluator capability SHALL halt before emitting a verdict when the artifact under inspection is missing or unreadable, and SHALL NOT fabricate a verdict or findings when it cannot inspect the artifact.

#### Scenario: Halt on missing artifact

- GIVEN the artifact under inspection is missing or unreadable
- WHEN the evaluator is invoked
- THEN the evaluator SHALL halt before emitting a verdict
- AND a failure reason SHALL identify the missing artifact

#### Scenario: No fabricated verdict

- GIVEN the evaluator cannot complete a check for lack of evidence
- WHEN the report is produced
- THEN the evaluator SHALL mark the check as unverified rather than fabricating a pass or fail
- AND SHALL NOT emit a PASS on an uninspectable artifact

### Requirement: Quality Acceptance Criteria

The progress-evaluator capability SHALL produce reports that are complete (every check per stage is recorded), traceable (every finding cites the artifact location), and correct (no false PASS and no false FAIL).

#### Scenario: Complete and traceable report

- GIVEN a verification report is produced
- WHEN the report is validated
- THEN every MANDATORY and ADVISORY check for the stage SHALL be recorded with a result
- AND every FAIL finding SHALL cite the specific artifact location and evidence

#### Scenario: No false PASS

- GIVEN a stage artifact contains a defect (e.g. a missing result block or a factual rank error)
- WHEN the stage is graded
- THEN the evaluator SHALL NOT emit PASS
- AND the defect SHALL appear as a FAIL finding with evidence

### Requirement: Cross-Capability Dependency

The progress-evaluator capability SHALL reuse the `data-to-insight` stage artifacts read-only, SHALL NOT modify the authoring roles of `sql-builder`, `insight-writer`, or the orchestrator beyond the gate/re-run wiring, SHALL NOT modify `query-inspector`, `learning-progress`, or the track registry, and SHALL be registered in the project's agent routing registry as an execution agent that does not create OpenSpec change proposals.

#### Scenario: Read-only reuse of stage artifacts

- GIVEN the evaluator inspects a `data-to-insight` stage artifact
- WHEN the repository status is checked
- THEN the stage artifacts under `work/` SHALL remain unmodified by the evaluator
- AND the evaluator SHALL write only to `docs/04-progress-evaluator/`

#### Scenario: Existing agent contracts preserved

- GIVEN the evaluator is added
- WHEN the dependency surface is inspected
- THEN `sql-builder`, `insight-writer`, `query-inspector`, and `learning-progress` SHALL remain unchanged except for the gate/re-run wiring
- AND no new row SHALL be added to `learning/00-notes/tracks.md`

#### Scenario: Registry entry required

- GIVEN the `progress-evaluator` agent is added
- WHEN the capability is documented
- THEN the agent SHALL be registered in the Domain agents table of `AGENTS.md`
- AND SHALL be declared as an execution agent that does not create OpenSpec change proposals

## Boundaries

### In scope

- The read-only verification of `data-to-insight` stage artifacts at checkpoints (stages 1–6).
- The PASS / PASS-WITH-NOTES / FAIL verdict model and the MANDATORY vs ADVISORY check split.
- The per-stage MANDATORY PASS criteria for Scope, Questions, Silver, Gold mart, Results, and Insight.
- The block / re-run / fail-closed loop and the per-stage owner routing on FAIL.
- The verification report written to `docs/04-progress-evaluator/`.

### Out of scope

- Authoring, editing, or re-producing any stage artifact (SQL, scope, questions, results, or insight).
- Executing SQL or modifying the PostgreSQL dataset.
- Modifying `sql-builder`, `insight-writer`, `query-inspector`, or `learning-progress` beyond the gate/re-run wiring.
- Registering a learning track or modifying the track registry.
- Creating OpenSpec change proposals (planning belongs to `@openspec-agent`).

## Related Code

- `.opencode/agents/progress-evaluator.md` — the progress-evaluator agent definition
- `.opencode/agents/query-inspector.md` — sibling verification agent (unchanged; output-location convention source)
- `.opencode/skills/data-to-insight/SKILL.md` — orchestrator skill that invokes the evaluator at checkpoints
- `.opencode/agents/sql-builder.md` — owning agent for stages 3–5 (defect routing)
- `.opencode/agents/insight-writer.md` — owning agent for stage 6 (defect routing)
- `agent-blueprints/03-data-to-insight.md` — canonical pipeline blueprint (checkpoint gates)
- `AGENTS.md` — agent routing registry (updated with the new agent)
- `docs/04-progress-evaluator/` — verification report output location
- `openspec/specs/data-to-insight/spec.md` — upstream capability whose artifacts are verified
- `openspec/specs/service-capability-template/spec.md` — contract template used for this capability
- `openspec/specs/spec-format/spec.md` — format contract this spec follows
