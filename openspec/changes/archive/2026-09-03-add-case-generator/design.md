# Add Case Generator Agent — Design

## Overview

The `case-generator` agent will be an execution agent that analyzes a user-provided dataset and its accompanying README to generate a realistic business case. The agent will read the dataset structure (tables, columns, relationships) and README content to understand the domain, then create a business case with a main question and a System Analysis Document (SAD) containing Mermaid architecture diagrams. The agent will follow the same output structure and file format as existing `sql-analyst-lab` cases.

## Design Decisions

### Decision 1: Agent Type and Registration

**Choice**: Register as a domain agent in `.opencode/agents/case-generator.md` and add to the domain agents table in `AGENTS.md`.

**Rationale**: The agent is an execution capability that performs a specific task (generating cases) rather than a planning capability. Following the pattern of `dataset-generator`, it should be a domain agent with its own definition file.

### Decision 2: Input Validation Strategy

**Choice**: Validate that both the dataset file (`.db`, `.xlsx`, or `.csv`) and a `README.md` exist in the same folder before proceeding.

**Rationale**: The agent requires both the dataset and its documentation to understand the data structure and generate a meaningful business case. This matches the pattern of existing agents that validate inputs before execution.

### Decision 3: Output Location and Naming

**Choice**: Write outputs to `learning/04-data-to-insight/generated-case/<NN>-<dataset-name>-<case-name>/` with sequential numbering.

**Rationale**: This keeps generated cases separate from the curated `sql-analyst-lab` cases while still being accessible to the `data-to-insight` pipeline. The sequential numbering follows the pattern used by `dataset-generator` for output directories.

### Decision 4: Case File Format

**Choice**: Follow the exact format of existing `sql-analyst-lab` cases (case.md structure) with business context, main question, dataset limitation notes, scaffolding hints, and how-to-work instructions.

**Rationale**: Consistency with existing cases ensures the generated cases can be used directly with the `data-to-insight` pipeline without modification. The format is proven and familiar to users.

### Decision 5: SAD Diagram Types

**Choice**: Generate four Mermaid diagram types: C4 architecture (system context, container, component levels), flowchart (business process/data flow), sequence diagram (key interactions), and ERD (entity relationships).

**Rationale**: These diagrams provide a comprehensive system analysis view that helps users understand the dataset's context and structure. Mermaid syntax is already used in the project for ERDs and other diagrams.

## Target Structure

```
.opencode/agents/case-generator.md          ← CREATED: agent definition
AGENTS.md                                   ← MODIFIED: add to domain agents table
learning/04-data-to-insight/generated-case/ ← CREATED: output directory (populated at runtime)
openspec/specs/case-generator/spec.md       ← CREATED: capability spec (during archive)
```

## Edge Cases

- **Case 1**: Dataset file exists but README.md is missing
  - Handling: Agent halts and lists missing README.md as required input
- **Case 2**: Multiple dataset files in the same folder
  - Handling: Agent uses the file referenced by the user; if ambiguous, asks for clarification
- **Case 3**: Generated case name already exists in the output directory
  - Handling: Agent increments the sequential prefix and uses the next available number
- **Case 4**: Dataset has no clear business domain
  - Handling: Agent generates a generic business case based on table/column names and relationships
- **Case 5**: README contains minimal or no documentation
  - Handling: Agent uses dataset structure (table/column names) to infer domain and generate case

## Affected Specs

| Spec                          | Change Type |
| ----------------------------- | ----------- |
| `specs/case-generator/spec.md` | ADDED       |