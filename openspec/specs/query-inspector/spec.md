# query-inspector Specification

## Purpose

Govern the query-inspector capability: analyzing learner-submitted SQL queries for query-logic correctness and business-requirement alignment, highlighting mismatches, recommending corrected queries, and writing analysis reports.

## Requirements

### Requirement: Query Input Contract
The query-inspector capability SHALL accept a learner-referenced `.sql` or `.txt` file located under `script/01-sql/` as the required input before analysis begins.

#### Scenario: Valid query file input
- GIVEN a learner references a `.sql` or `.txt` file that exists under `script/01-sql/`
- WHEN the query-inspector is invoked
- THEN the capability SHALL analyze the referenced file's contents
- AND SHALL NOT require additional inputs to begin analysis

#### Scenario: Missing query file
- GIVEN a referenced `.sql` or `.txt` file does not exist under `script/01-sql/`
- WHEN the query-inspector is invoked
- THEN the capability SHALL halt before producing any output
- AND a failure reason SHALL identify the missing file path

#### Scenario: Disallowed input location or type
- GIVEN a file reference points outside `script/01-sql/` or is neither a `.sql` nor a `.txt` file
- WHEN the query-inspector is invoked
- THEN the capability SHALL reject the input
- AND a failure reason SHALL state the allowed location and file type

### Requirement: Query-Logic Correctness Analysis
The query-inspector capability SHALL analyze the submitted query for SQL correctness, covering syntax, semantics, and query logic.

#### Scenario: Correct query logic
- GIVEN a submitted query is syntactically valid and semantically correct
- WHEN query-logic correctness is analyzed
- THEN the capability SHALL confirm the query logic is correct
- AND SHALL NOT flag the query for logic errors

#### Scenario: Syntax error detected
- GIVEN a submitted query contains a SQL syntax error
- WHEN query-logic correctness is analyzed
- THEN the capability SHALL identify the syntax error
- AND SHALL pinpoint the clause or expression containing the error

#### Scenario: Semantic or logic flaw detected
- GIVEN a submitted query is syntactically valid but contains a semantic or logic flaw such as a wrong join, missing filter, incorrect aggregation, or wrong column usage
- WHEN query-logic correctness is analyzed
- THEN the capability SHALL identify the flawed part
- AND SHALL explain why the logic does not produce the intended result

### Requirement: Business-Requirement Alignment Analysis
The query-inspector capability SHALL analyze whether the submitted query answers the business or exercise requirement it is meant to satisfy.

#### Scenario: Query aligned with the business requirement
- GIVEN a submitted query addresses the stated business requirement
- WHEN business-requirement alignment is analyzed
- THEN the capability SHALL confirm the query answers the requirement
- AND SHALL NOT flag alignment issues

#### Scenario: Query correct but misaligned
- GIVEN a submitted query is logically correct but does not answer what the business requirement actually asks
- WHEN business-requirement alignment is analyzed
- THEN the capability SHALL identify the misalignment
- AND SHALL state which part of the requirement is not addressed

#### Scenario: Ambiguous business requirement
- GIVEN the business requirement is not clearly stated in the analysis context
- WHEN business-requirement alignment is analyzed
- THEN the capability SHALL state its assumed interpretation of the requirement
- AND SHALL flag the assumption explicitly in the analysis

### Requirement: Mismatch Identification and Highlighting
The query-inspector capability SHALL identify and clearly highlight every part of the query that does not match expected query logic or the business requirement.

#### Scenario: Mismatches present
- GIVEN the analysis identifies one or more mismatches
- WHEN the analysis report is produced
- THEN each mismatch SHALL reference the specific query part
- AND each mismatch SHALL be classified as a query-logic or business-alignment issue

#### Scenario: No mismatches present
- GIVEN the analysis identifies no mismatches
- WHEN the analysis report is produced
- THEN the capability SHALL state that no mismatches were found
- AND SHALL provide positive confirmation that the query satisfies both criteria

### Requirement: Solution Recommendation
The query-inspector capability SHALL provide a corrected or recommended query for every identified mismatch.

#### Scenario: Correction recommended for each mismatch
- GIVEN one or more mismatches are identified
- WHEN solution recommendations are produced
- THEN the capability SHALL provide a corrected or recommended query for each mismatch
- AND SHALL explain each change relative to the submitted query

#### Scenario: No correction needed
- GIVEN no mismatches are identified
- WHEN solution recommendations are produced
- THEN the capability SHALL state that no correction is needed
- AND SHALL NOT fabricate unnecessary changes

### Requirement: Output Artifact Contract
The query-inspector capability SHALL write a `query-analysis.md` report to `docs/03-query-inspector/` documenting the full analysis.

#### Scenario: Analysis report written
- GIVEN an analysis has been completed
- WHEN the output artifact is produced
- THEN the capability SHALL write `query-analysis.md` to `docs/03-query-inspector/`
- AND the report SHALL include the analyzed query, findings, mismatches, and recommended queries

#### Scenario: Report written for an error-free query
- GIVEN a query with no mismatches is analyzed
- WHEN the output artifact is produced
- THEN the capability SHALL still write `query-analysis.md`
- AND the report SHALL document the positive confirmation

#### Scenario: Existing report preserved
- GIVEN a `query-analysis.md` report already exists in `docs/03-query-inspector/`
- WHEN a new analysis is written
- THEN the capability SHALL NOT silently overwrite the existing report
- AND the new report SHALL be written under a dated filename that preserves the previous report

### Requirement: Failure Behavior
The query-inspector capability SHALL halt before writing any output when required input is missing or invalid and SHALL surface a clear failure reason.

#### Scenario: Halt before side effects
- GIVEN the required query file input is missing or invalid
- WHEN the capability is invoked
- THEN the capability SHALL halt before writing any output
- AND SHALL report the failure reason to the caller

#### Scenario: File contains no query statements
- GIVEN a referenced file exists but contains no query statements, such as an empty or comment-only file
- WHEN the capability is invoked
- THEN the capability SHALL report that no query statements were found
- AND SHALL NOT produce an analysis with fabricated findings

### Requirement: Quality Acceptance Criteria
The query-inspector capability SHALL produce analyses that satisfy measurable criteria for correctness, completeness, and consistency.

#### Scenario: Complete analysis
- GIVEN an analysis report is produced
- WHEN the output is validated
- THEN the report SHALL cover both query-logic correctness and business-requirement alignment
- AND each identified mismatch SHALL include a recommended query

#### Scenario: Accurate findings
- GIVEN the analysis flags an issue
- WHEN the flagged issue is validated
- THEN the flag SHALL be traceable to a specific query part
- AND the capability SHALL NOT report a mismatch that does not exist

### Requirement: Cross-Capability Dependency
The query-inspector capability SHALL operate within the SQL track of the learning-progress execution domain and SHALL be registered in the project's agent routing registry.

#### Scenario: Dependency on the learning-progress domain
- GIVEN the query-inspector capability serves the SQL track managed by the learning-progress capability
- WHEN the capability is documented
- THEN the spec SHALL reference the learning-progress skill and agent blueprint in `## Related Code`
- AND the capability SHALL NOT modify the learning-progress skill or agent blueprint

#### Scenario: Registry entry required
- GIVEN the query-inspector agent is added to the project
- WHEN the capability is documented
- THEN the agent SHALL be registered in the Domain agents table of `AGENTS.md`
- AND the agent definition SHALL be referenced in `## Related Code`

## Boundaries

### In scope
- Reading learner-submitted query files (`.sql` or `.txt`) from `script/01-sql/`.
- Analyzing query-logic correctness (syntax, semantics, query logic) and business-requirement alignment.
- Highlighting mismatches classified per axis and recommending corrected queries.
- Writing analysis reports to `docs/03-query-inspector/`.

### Out of scope
- Executing queries against a database engine.
- Modifying learner files in `script/01-sql/`.
- Modifying the `learning-progress` skill (`.opencode/skills/learning-progress/`) or the agent blueprint (`agent-blueprints/01-learning-progress.md`).
- Creating OpenSpec change proposals (planning is the responsibility of `openspec-agent`).

## Related Code

- `.opencode/agents/query-inspector.md` — the query-inspector agent definition
- `AGENTS.md` — Domain agents table (agent routing registry)
- `.opencode/skills/learning-progress/` — the learning-progress execution domain skill
- `agent-blueprints/01-learning-progress.md` — the canonical agent plan
- `script/01-sql/` — learner query files (input location)
- `docs/03-query-inspector/` — analysis report output location
- `openspec/specs/service-capability-template/spec.md` — contract template used for this capability
- `openspec/specs/spec-format/spec.md` — format contract this spec follows
