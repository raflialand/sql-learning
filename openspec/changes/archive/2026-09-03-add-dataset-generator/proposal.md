# Add Dataset Generator Agent

## Problem Statement

The sql-learning project currently lacks a mechanism to generate synthetic messy datasets for practice and learning purposes. Learners need realistic data with intentional quality issues (NULLs, duplicates, wrong formats, typos) to practice SQL data-cleaning and analysis skills. Without a dedicated generator, dataset creation is manual, inconsistent, and not reusable across learning tracks.

## Proposed Solution

Create a new domain agent called `dataset-generator` that produces synthetic messy datasets on demand. The agent accepts a topic, table/column/row count, and dirty level from the user, validates inputs before execution, generates a SQLite database and a PostgreSQL-compatible SQL script, and produces a README documenting the dataset. The agent is defined in `.opencode/agents/dataset-generator.md` and registered in the main `AGENTS.md` agent routing table.

## Scope

### In scope

- Agent definition file (`.opencode/agents/dataset-generator.md`) with Purpose, Inputs, Outputs, Behavior, and Boundaries sections
- Registration in the "Domain agents" table in `AGENTS.md`
- Output directory structure under `data/` with sequential prefix (`<NN>-<dataset-name>/` where `<NN>` increments from the highest existing `NN-*` folder) containing `.db`, `.sql` (PostgreSQL script), and `README.md`
- Dirty-data generation logic for three levels: `low`, `mid`, `high`
- Input validation flow requiring all required inputs before execution
- README generation describing the dataset contents and structure

### Out of scope

- Modifying existing domain agents (`query-inspector`, `sql-builder`, `insight-writer`, `progress-evaluator`)
- Modifying existing skills or OpenSpec methodology files
- Generating datasets for specific case studies in the data-to-insight pipeline
- PostgreSQL-native output format is supported via the `.sql` script (no CSV export)
- Persisting generated datasets across sessions or versioning them

## Capabilities

### New Capabilities

- `dataset-generator` — the behavioral spec governing the agent's input validation, generation logic, and output contract

### Modified Capabilities

- None — this is a net-new capability

## Value Proposition

Learners gain instant access to realistic, messy practice datasets tailored to their chosen topic and difficulty level. The agent enforces input completeness before execution, preventing partial or malformed runs. The dirty-level system allows progressive difficulty from introductory (`low`) to advanced (`high`) data quality challenges, aligning with the project's multi-track learning philosophy.
