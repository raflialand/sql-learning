# Add Dataset Generator Agent — Implementation Tasks

## Phase 1: Agent Definition

### Step 1.1: Create agent definition file

Create `.opencode/agents/dataset-generator.md` with the following structure:

- Frontmatter: `description` and `mode: subagent`
- **Purpose**: One-paragraph description of the agent's role
- **Inputs**: Dataset topic, table count, column count, row count, dirty level (`low`/`mid`/`high`)
- **Outputs**: `<NN>-<dataset-name>/` folder with `.db`, `.sql` (PostgreSQL-compatible SQL script with CREATE TABLE and INSERT statements), and `README.md` (where `<NN>` is the next sequential two-digit prefix based on scanning `data/` for existing `NN-*` folders)
- **Behavior**: 5-step behavioral spec covering input validation, generation, dirty injection, file output, and README generation
- **Boundaries**: In-scope and out-of-scope lists

**Verification**: File exists at `.opencode/agents/dataset-generator.md` with valid frontmatter and all five sections populated.

### Step 1.2: Define dirty-level behavior in agent spec

Within the agent definition's Behavior section, document:

- **Sequential numbering**: The agent scans `data/` for folders matching `NN-*`, finds the highest two-digit prefix, increments by 1, and uses it for the output directory name (first = `00`, second = `01`, etc.)
- **Dirty categories per level**:

- **Low**: NULL values (5-10% per column), exact duplicate rows (2-5%), mixed-case text inconsistencies
- **Mid**: All low-level issues + wrong data types in text columns (e.g. "N/A" in numeric fields), leading/trailing whitespace, inconsistent date formats (MM/DD/YYYY vs YYYY-MM-DD), extra spaces in names
- **High**: All mid-level issues + typos in string columns (random character substitution), swapped values across columns, out-of-range numeric values, future dates in past-only fields, cross-column semantic inconsistencies (e.g. "cancelled" order with non-null delivery date)

**Verification**: Behavior section lists specific dirty categories for each of the three levels with concrete examples.

## Phase 2: Registration

### Step 2.1: Register agent in AGENTS.md

Add `dataset-generator` to the "Domain agents" table in the root `AGENTS.md` file.

- **Old**:
  ```
  | `progress-evaluator` | Read-only verification gate at every data-to-insight checkpoint (stages 1–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts; writes dated reports to `<case>/verification/` |
  ```
- **New**:
  ```
  | `progress-evaluator` | Read-only verification gate at every data-to-insight checkpoint (stages 1–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts; writes dated reports to `<case>/verification/` |
  | `dataset-generator`  | Generates synthetic messy datasets for practice/learning: accepts a topic + scope parameters, validates inputs, produces SQLite + PostgreSQL SQL script + README under `data/` |
  ```

**Verification**: The "Domain agents" table in `AGENTS.md` contains a row for `dataset-generator` with a one-line purpose description.

### Step 2.2: Update Directory Map in AGENTS.md

Add `dataset-generator` to the domain agents list in the Directory Map comment block.

- **Old**:
  ```
  ```
- **New**: (No change needed — the Directory Map is a tree of directories, not individual agent files. The agent lives in `.opencode/agents/` which is already shown.)

**Verification**: No regression — the Directory Map still accurately reflects the project structure.

## Phase 3: Validation

### Step 3.1: Verify agent definition structure

Read `.opencode/agents/dataset-generator.md` and confirm:
- Frontmatter contains `description` and `mode: subagent`
- All five sections exist: Purpose, Inputs, Outputs, Behavior, Boundaries
- Behavior section covers: input validation, generation, dirty injection, file output, README generation

**Verification**: All structural checks pass.

### Step 3.2: Verify AGENTS.md registration

Read `AGENTS.md` and confirm:
- `dataset-generator` row exists in the "Domain agents" table
- The row follows the existing format (pipe-delimited, agent name in backticks, one-line purpose)

**Verification**: Registration row is present and correctly formatted.

## Summary of Changes

| Category          | Before                          | After                                     |
| ----------------- | ------------------------------- | ----------------------------------------- |
| Agent definition  | `.opencode/agents/dataset-generator.md` does not exist | Created with Purpose/Inputs/Outputs/Behavior/Boundaries |
| AGENTS.md         | Domain agents table has 4 rows  | Domain agents table has 5 rows            |
| Data directory    | No dataset-generator output     | Agent will produce `data/<NN>-<name>/` on execution (NN = sequential prefix) |
