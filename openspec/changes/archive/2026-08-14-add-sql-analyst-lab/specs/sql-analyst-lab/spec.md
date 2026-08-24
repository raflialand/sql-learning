# Spec Deltas for sql-analyst-lab

## ADDED Requirements

### Requirement: Module Structure
The system SHALL provide the `sql-analyst-lab` learning module at `learning/02-sql-learning/sql-analyst-lab/` containing a `README.md` and one folder per case study, each case folder containing a `case.md`, an `expected/` directory with scope, questions, queries, results, and insight artifacts, and a `work/` directory for learner drafts.

#### Scenario: Module exists with expected anatomy
- GIVEN the module has been added
- WHEN the module directory is inspected
- THEN `learning/02-sql-learning/sql-analyst-lab/README.md` SHALL exist
- AND each case folder SHALL contain `case.md`, `expected/01-scope.md`, `expected/02-questions.md`, `expected/03-queries.sql`, `expected/03-results.md`, `expected/04-insight.md`, and `work/`

#### Scenario: Case folders follow the approved naming
- GIVEN the module contains three case studies
- WHEN the case folders are listed
- THEN the folders SHALL be `01-brew-and-co/`, `02-markethub/`, and `03-novatel/`

### Requirement: Analytical Framework Contract
The system SHALL structure every case study around the 4-step framework from `learning/04-data-to-insight/data-to-insight.md`: scope ~3 Northstar metrics and ~3 dimensions before touching data, break the main question into sub-questions across the four buckets (Overall Trends, Growth Rates, Performance Measurement, KPI Reporting), provide one SQL query per sub-question expressed as a metric sliced by a dimension, and surface strong insights with recommendations.

#### Scenario: Framework steps are visible in the expected artifacts
- GIVEN a case study is authored
- WHEN its `expected/` artifacts are reviewed
- THEN `01-scope.md` SHALL fix approximately three metrics and three dimensions
- AND `02-questions.md` SHALL map sub-questions to the four buckets
- AND `03-queries.sql` SHALL contain one query per sub-question
- AND `04-insight.md` SHALL distinguish weak insights from strong insights (trend + fluctuation + anomaly + root cause + recommendation)

#### Scenario: Dataset limitations are honored
- GIVEN a dataset cannot support a comparison (e.g. NovaTel telecom billing spans only 2025-12-01 and 2026-01-01)
- WHEN the case study is authored
- THEN the limitation SHALL be stated in `case.md`
- AND the model queries SHALL NOT fabricate unsupported comparisons such as telecom YoY

#### Scenario: Ambiguous metric definitions are fixed before querying
- GIVEN a metric has multiple plausible definitions (e.g. repeat purchase rate)
- WHEN the scope is written
- THEN `01-scope.md` SHALL fix the exact definition
- AND all queries in `03-queries.sql` SHALL implement that same definition consistently

### Requirement: Dataset Reuse Contract
The system SHALL reuse the existing sql-skill-push datasets read-only by relative path and SHALL NOT copy, regenerate, or modify any dataset file; the system SHALL reuse the existing `_tools/run_query.py` helper for verification.

#### Scenario: Queries run against the shared datasets
- GIVEN a case study's model queries
- WHEN the queries are executed
- THEN the database SHALL be one of `learning/02-sql-learning/sql-skill-push/datasets/01-beginner/retail.db`, `.../02-intermediate/ecommerce.db`, or `.../03-advanced/telecom.db` referenced by relative path
- AND the verification helper SHALL be `learning/02-sql-learning/sql-skill-push/_tools/run_query.py`

#### Scenario: Shared datasets remain unchanged
- GIVEN the module is developed
- WHEN the repository status under `learning/02-sql-learning/sql-skill-push/` is checked
- THEN no changes SHALL appear for that subtree

### Requirement: Expected Results Verification
The system SHALL generate each case's `expected/03-results.md` by executing `expected/03-queries.sql` against the reused dataset, presenting sample rows plus total counts using the `(N rows)` or `(N rows total; M shown)` convention, such that re-execution reproduces the same output.

#### Scenario: Results captured from real execution
- GIVEN the model queries have been authored
- WHEN `03-results.md` is written
- THEN the row counts and sample rows SHALL come from actual execution output
- AND the format SHALL match the sql-skill-push convention `(N rows)` / `(N rows total; M shown)`

#### Scenario: Re-execution reproduces the expected output
- GIVEN the module is complete
- WHEN each `expected/03-queries.sql` is re-run against its dataset
- THEN the output SHALL match the corresponding `03-results.md` with zero failures

### Requirement: Track Registration
The system SHALL register the analyst track in `learning/00-notes/tracks.md` with id `analyst`, name `Data-to-Insight Case Studies`, roadmap `learning/02-sql-learning/sql-analyst-lab/README.md`, notes dir `learning/00-notes/05-analyst-lab/`, total units `3`, and unit label `Case`, and SHALL create the notes directory with a README following the existing per-track notes convention.

#### Scenario: Analyst row appended to the registry
- GIVEN the module is complete
- WHEN `learning/00-notes/tracks.md` is inspected
- THEN a row `| analyst | Data-to-Insight Case Studies | learning/02-sql-learning/sql-analyst-lab/README.md | learning/00-notes/05-analyst-lab/ | 3 | Case |` SHALL exist

#### Scenario: Notes directory follows the convention
- GIVEN the analyst track is registered
- WHEN the notes directory is created
- THEN `learning/00-notes/05-analyst-lab/README.md` SHALL exist
- AND it SHALL include a session-summary template and a progress snapshot table with 3 Case rows

#### Scenario: Registration is registry-data-only
- GIVEN the analyst track is added
- WHEN the learning-progress skill, blueprint, manifest, and spec are inspected
- THEN none of them SHALL be modified by this registration

### Requirement: Cross-Capability Dependency
The system SHALL document the analyst lab's dependency on the `learning-progress` capability for progress tracking and SHALL document the optional `query-inspector` review without modifying either capability's contracts.

#### Scenario: Dependency is declared, not implemented
- GIVEN the module references progress tracking
- WHEN the module README is inspected
- THEN the dependency on `learning-progress` (registry + skill) SHALL be referenced in the module's Related Code / usage notes
- AND the `learning-progress` skill, blueprint, and spec SHALL NOT be modified

#### Scenario: Optional review is a usage note only
- GIVEN the module wants to offer query review
- WHEN the module README is inspected
- THEN the optional `@query-inspector` review SHALL be described as a usage note (learner copies `work/` queries to `script/01-sql/` and runs `@query-inspector`)
- AND the `query-inspector` agent and spec SHALL NOT be modified

## Boundaries

### In scope
- Module skeleton, three case studies, expected artifacts, and verified results.
- Analyst track registration and notes directory.
- Documentation updates and change log entry.
- The `sql-analyst-lab` capability spec delta.

### Out of scope
- Any modification of `learning/02-sql-learning/sql-skill-push/` files or datasets.
- Changes to the `learning-progress` skill, blueprint, manifest, or spec.
- Changes to the `query-inspector` agent or spec.
- ADRs, OpenSpec methodology files, and archived changes.

## Related Code
- `learning/02-sql-learning/sql-analyst-lab/` — module implementation
- `learning/04-data-to-insight/data-to-insight.md` — pedagogy source (4-step framework + Running Log)
- `learning/02-sql-learning/sql-skill-push/_tools/run_query.py` — verification helper (reused, not modified)
- `learning/02-sql-learning/sql-skill-push/datasets/` — reused datasets (read-only)
- `learning/00-notes/tracks.md` — track registry (analyst row)
- `learning/00-notes/05-analyst-lab/` — analyst notes directory
