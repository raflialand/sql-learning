# Spec Deltas for data-to-insight

## ADDED Requirements

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
