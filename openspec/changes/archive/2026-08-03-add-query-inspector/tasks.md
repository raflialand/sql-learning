# Add Query Inspector — Implementation Tasks

## Phase 1: Agent Definition

### Step 1.1: Create `.opencode/agents/query-inspector.md`

Create the agent definition file with YAML frontmatter and the sections used by existing agents:

- **Old**: n/a (new file)
- **New**: `.opencode/agents/query-inspector.md` with frontmatter (`description`, `mode: subagent`) and the `## Purpose`, `## Inputs`, `## Outputs`, `## Behavior`, `## Boundaries` sections.

The Behavior section SHALL encode:

- Read the learner-referenced `.sql` or `.txt` file under `script/01-sql/`.
- Analyze query-logic correctness (syntax, semantics, query logic).
- Analyze business-requirement alignment (does the query answer what the exercise asks).
- Highlight mismatches classified as query-logic or business-alignment issues.
- Provide a corrected/recommended query for each mismatch.
- Write `docs/03-query-inspector/query-analysis.md`; if the report already exists, write a dated variant instead of overwriting.
- Halt with a clear failure reason on invalid input (missing file, wrong location, wrong type, no query statements).

**Verification**: File exists at `.opencode/agents/query-inspector.md`; frontmatter has `description` and `mode: subagent`; all five content sections are populated.

## Phase 2: Registration and Output Directory

### Step 2.1: Register `query-inspector` in `AGENTS.md` Domain agents table

Add a row to the Domain agents table under `## Agent Routing`:

- **Old**:
  ```
  | Agent                | Purpose                                                       |
  | -------------------- | ------------------------------------------------------------- |
  ```
- **New**:
  ```
  | Agent                | Purpose                                                       |
  | -------------------- | ------------------------------------------------------------- |
  | `query-inspector`    | Inspects learner-submitted SQL queries for query-logic correctness and business-requirement alignment; writes `query-analysis.md` to `docs/03-query-inspector/` |
  ```

**Verification**: `AGENTS.md` contains a row for `query-inspector` in the Domain agents table.

### Step 2.2: Create the output directory

Create `docs/03-query-inspector/` and seed it with `.gitkeep`.

**Verification**: The directory exists at `docs/03-query-inspector/` and contains `.gitkeep`.

## Phase 3: Validation

### Step 3.1: Smoke-test the agent end to end

Invoke `@query-inspector` with a sample `.sql` or `.txt` file that exists in `script/01-sql/` (or a temporary test file created for the check, then removed).

**Verification**: `docs/03-query-inspector/query-analysis.md` is created and contains the analyzed query, per-axis findings, highlighted mismatches (if any), and corrected/recommended queries.

### Step 3.2: Confirm spec conformance

Compare the agent's implemented Behavior with the ADDED requirements in `openspec/changes/add-query-inspector/specs/query-inspector/spec.md`.

**Verification**: Every ADDED requirement in the delta spec is satisfied by the agent definition; no behavior in the definition contradicts the spec.

## Summary of Changes

| Category           | Before                                      | After                                                              |
| ------------------ | ------------------------------------------- | ------------------------------------------------------------------ |
| Agent definition   | No `query-inspector` agent in `.opencode/agents/` | `.opencode/agents/query-inspector.md` created                 |
| Agent registry     | Domain agents table empty in `AGENTS.md`     | `query-inspector` registered in the Domain agents table             |
| Output directory   | No `docs/03-query-inspector/`                | `docs/03-query-inspector/` created with `.gitkeep`                  |
| Capability spec    | No `query-inspector` capability              | Delta spec in `openspec/changes/add-query-inspector/specs/query-inspector/spec.md` (canonical spec created at archive) |
