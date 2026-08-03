# Add Query Inspector — Design

## Overview

The `query-inspector` capability is delivered as an opencode domain agent defined in `.opencode/agents/query-inspector.md` and registered in the Domain agents table of `AGENTS.md`. When a learner references a `.sql` or `.txt` file under `script/01-sql/`, the agent reads it, analyzes it on two axes (query-logic correctness and business-requirement alignment), highlights mismatches, produces corrected/recommended queries, and writes `docs/03-query-inspector/query-analysis.md`. The capability is spec'd as a new OpenSpec service capability following the service-capability-template contract sections (Input Contract, Output Contract, Failure Behavior, Quality Acceptance Criteria, Cross-Capability Dependency).

## Design Decisions

### Decision 1: Agent definition format follows the existing subagent convention

**Choice**: Create `.opencode/agents/query-inspector.md` with YAML frontmatter (`description`, `mode: subagent`) and the Purpose / Inputs / Outputs / Behavior / Boundaries sections, mirroring `.opencode/agents/openspec-agent.md`.
**Rationale**: The project already defines agents this way; consistency keeps `.opencode/agents/` uniform and lets the agent be invoked as `@query-inspector`.

### Decision 2: Register in the Domain agents table of `AGENTS.md`

**Choice**: Add a row for `query-inspector` to the Domain agents table under `## Agent Routing`.
**Rationale**: `AGENTS.md` documents "Add agent definitions to `.opencode/agents/` and register them in this table." The table is currently empty; this is the first domain agent and establishes the routing convention.

### Decision 3: Output directory follows the numbered docs convention

**Choice**: Write reports to `docs/03-query-inspector/query-analysis.md`.
**Rationale**: `docs/` already uses numbered per-topic folders (`01-erd-diagram`, `02-excel-coach`); `03-query-inspector` continues the sequence and keeps analysis artifacts discoverable.

### Decision 4: Input contract restricted to `script/01-sql/` `.sql` and `.txt` files

**Choice**: The agent accepts a learner-referenced `.sql` or `.txt` file that exists under `script/01-sql/`.
**Rationale**: That is where practice queries live, and learners may write queries in plain-text note files as well as `.sql` scripts. Restricting input to these two types keeps the agent focused, avoids touching unrelated files, and makes the failure contract explicit.

### Decision 5: Two-axis analysis as the core behavioral contract

**Choice**: Every analysis MUST cover query-logic correctness and business-requirement alignment, with mismatches classified per axis and each mismatch paired with a corrected/recommended query.
**Rationale**: This directly encodes the requirement: a query can be logically correct yet still fail the business requirement, so both axes must be assessed and reported.

### Decision 6: Spec structured as a service capability

**Choice**: The delta spec's ADDED requirements map to the service-capability-template contract sections (input, output, failure, quality, dependency) plus the two analysis behaviors.
**Rationale**: The archive process states that service/operation capabilities start from the service-capability-template section structure; `query-inspector` is an operation with input/output artifacts.

## Target Structure

```
.opencode/agents/query-inspector.md            ← CREATED: agent definition (frontmatter + Purpose/Inputs/Outputs/Behavior/Boundaries)
AGENTS.md                                      ← MODIFIED: add `query-inspector` row to the Domain agents table
docs/03-query-inspector/                       ← CREATED: output directory for analysis reports, seeded with `.gitkeep`
openspec/changes/add-query-inspector/specs/query-inspector/spec.md  ← CREATED: delta spec for the new capability
```

Note: `openspec/specs/query-inspector/spec.md` is created from this delta during the archive step, not in implementation tasks.

## Edge Cases

- **File does not exist**: The agent halts before writing any output and reports the missing path.
- **Non-`.sql`/`.txt` file or path outside `script/01-sql/`**: The agent rejects the input and states the allowed location and file types.
- **Empty or comment-only file**: The agent reports that no query statements were found and does not fabricate findings.
- **Business requirement ambiguous**: The agent states its assumed interpretation and flags the assumption explicitly in the report.
- **Query correct on both axes**: The agent confirms no mismatches, gives positive confirmation, and still writes the report.
- **`query-analysis.md` already exists**: The agent preserves the previous report by writing a dated variant (e.g. `query-analysis-<YYYY-MM-DD>.md`) instead of silently overwriting.

## Affected Specs

| Spec                            | Change Type           |
| ------------------------------- | --------------------- |
| `specs/query-inspector/spec.md` | ADDED (new capability) |
