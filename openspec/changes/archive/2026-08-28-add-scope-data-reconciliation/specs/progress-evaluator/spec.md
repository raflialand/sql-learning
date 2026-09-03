# Spec Deltas for progress-evaluator

## MODIFIED Requirements

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

> **Replaces**: The previous requirement text being modified. Include the full original `### Requirement:` header and all scenario text for exact matching during archive merge.
>
> ### Requirement: Silver Evaluation Contract
>
> The progress-evaluator capability SHALL grade `_silver.sql` on five MANDATORY checks: all six DQ dimensions (Completeness, Uniqueness, Validity, Accuracy, Consistency, Timeliness) are evaluated, each applied or N/A-with-reason; no dimension is N/A without a documented reason; the applied subset covers every known dataset quirk from the dataset README; row counts are preserved (conform + flag, never drop); and the SQL runs without error.
>
> #### Scenario: Silver passes DQ coverage
>
> - GIVEN `_silver.sql` evaluates all six dimensions, documents every N/A, covers every README quirk, preserves row counts, and runs without error
> - WHEN the Silver checkpoint is graded
> - THEN the verdict SHALL be PASS
> - AND the report SHALL record each of the five checks as green
>
> #### Scenario: N/A without reason
>
> - GIVEN `_silver.sql` marks a DQ dimension N/A without a documented reason
> - WHEN the Silver checkpoint is graded
> - THEN the verdict SHALL be FAIL
> - AND the undocumented N/A dimension SHALL be named in the report
>
> #### Scenario: Row counts dropped
>
> - GIVEN `_silver.sql` drops rows rather than conforming and flagging
> - WHEN the Silver checkpoint is graded
> - THEN the verdict SHALL be FAIL
> - AND the report SHALL identify the drop and the expected conform-and-flag behavior
