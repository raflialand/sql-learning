# Add Query Inspector

## Problem Statement

Learners in the sql-learning environment practice by writing SQL queries in `script/01-sql/`, but there is no dedicated, repeatable feedback mechanism that verifies whether a submitted query is logically correct AND answers what the exercise actually asks. Query review today is ad-hoc: when a learner asks for feedback, the main agent inspects the query without a consistent contract, so analysis depth, mismatch highlighting, and corrective recommendations vary between sessions. The learner needs a dedicated agent whose sole job is to inspect queries, flag query-logic and business-alignment mismatches, and recommend corrected queries.

## Proposed Solution

Add a new domain agent `query-inspector` that:

- Accepts a learner-referenced `.sql` or `.txt` file located in `script/01-sql/`.
- Analyzes the query on two axes: (1) query-logic correctness (SQL syntax, semantics, query logic) and (2) business-requirement alignment (does it answer what the exercise asks).
- Highlights every part that does not match the expected logic, classified by type.
- Provides corrected/recommended queries for each identified mismatch.
- Writes a `query-analysis.md` report to `docs/03-query-inspector/`.

The capability is formalized as a new OpenSpec service capability (`query-inspector`) with an input contract, output contract, failure behavior, quality acceptance criteria, and dependency declaration.

## Scope

### In scope

- Creating the agent definition at `.opencode/agents/query-inspector.md`.
- Registering `query-inspector` in the Domain agents table of `AGENTS.md`.
- Creating the output directory `docs/03-query-inspector/` for analysis reports.
- Adding the `query-inspector` capability spec (delta spec in this change; canonical spec created at archive time).

### Out of scope

- Modifying the `sql-learning` skill (`.opencode/skills/sql-learning/`) or the agent blueprint (`agent-blueprints/01-sql-learning.md`).
- Modifying OpenSpec methodology files (`openspec/AGENTS.md`, `openspec/specs/spec-format/`, `openspec/specs/archive-safety/`).
- Executing queries against a database engine or mutating learner files in `script/01-sql/`.
- Fixing the learner's queries in place — the agent only recommends corrections in its report.

## Capabilities

### New Capabilities

- `query-inspector`

### Modified Capabilities

- None

## Value Proposition

Learners get consistent, structured, two-axis feedback on every submitted query: whether it is logically correct and whether it answers the business requirement. Mismatches are highlighted precisely and paired with corrected queries, turning each practice session into a targeted learning opportunity. Because the capability is registered and spec'd like any other project capability, future improvements (new analysis criteria, output formats) follow the OpenSpec lifecycle.
