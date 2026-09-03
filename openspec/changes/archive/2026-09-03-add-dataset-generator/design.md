# Add Dataset Generator Agent — Design

## Overview

The `dataset-generator` is a standalone domain agent that takes user-provided parameters (topic, table/column/row counts, dirty level), generates synthetic data using Python's `faker` and `random` libraries, intentionally introduces quality issues at the requested dirty level, writes the results to a SQLite database and a PostgreSQL-compatible SQL script, and produces a README documenting the dataset. The agent validates all required inputs before any generation begins.

## Design Decisions

### Decision 1: SQLite as primary output format

**Choice**: SQLite `.db` as the primary database output, with a PostgreSQL-compatible SQL script (`<name>.sql`) for creating the dataset in PostgreSQL.

**Rationale**: SQLite is self-contained, requires no server, and is immediately queryable. The PostgreSQL SQL script provides a portable fallback — learners can run the `.sql` file directly in PostgreSQL to recreate the dataset with full `CREATE TABLE` and `INSERT` statements. The existing project already uses SQLite files in `data/` (e.g. `sql-learn.db`, `ecommerce.db`), so this is consistent with established patterns.

### Decision 2: Three-tier dirty level model

**Choice**: Dirty levels `low`, `mid`, `high` — each tier adds specific categories of data messiness.

**Rationale**: A three-tier model is simple enough to understand and implement, yet granular enough to cover the full range from introductory cleaning tasks (low: NULLs, duplicates) to advanced multi-dimensional quality challenges (high: all of mid plus semantic corruption, cross-column inconsistencies, and temporal anomalies). This aligns with the project's progressive learning philosophy.

### Decision 3: Input validation before execution

**Choice**: The agent SHALL ask for any missing required inputs and SHALL NOT proceed until all are provided.

**Rationale**: Prevents partial or malformed runs that produce incomplete datasets. The agent's behavior spec mandates halting on missing inputs with a clear message identifying what is missing, consistent with the service-capability input contract pattern.

### Decision 4: README as dataset documentation

**Choice**: The agent generates a `README.md` alongside the database and SQL script, documenting schema, row counts, dirty levels applied, and a usage hint.

**Rationale**: Every dataset produced must be self-describing. The README serves as both human documentation and as input context for downstream agents (e.g. `query-inspector`) that may need to understand the dataset's structure and quirks.

### Decision 5: Agent definition in `.opencode/agents/`

**Choice**: The agent is defined as a `.md` file in `.opencode/agents/dataset-generator.md` following the established pattern (frontmatter with `description` and `mode: subagent`, followed by Purpose/Inputs/Outputs/Behavior/Boundaries).

**Rationale**: All existing domain agents follow this exact structure. Consistency reduces cognitive load and makes the agent discoverable by the framework.

## Target Structure

```
.opencode/agents/dataset-generator.md    ← CREATED: agent definition
AGENTS.md                                ← MODIFIED: add dataset-generator to Domain agents table
data/                                    ← READ: existing data directory
data/<NN>-<dataset-name>/                ← CREATED: output directory per dataset (NN = next sequential prefix)
data/<NN>-<dataset-name>/<name>.db       ← CREATED: SQLite database
data/<NN>-<dataset-name>/<name>.sql      ← CREATED: PostgreSQL-compatible SQL script
data/<NN>-<dataset-name>/README.md       ← CREATED: dataset documentation
```

The `<NN>` prefix is determined by scanning `data/` for folders matching `NN-*`, finding the highest two-digit prefix, and incrementing by 1. First dataset = `00`, second = `01`, third = `02`, etc.

## Edge Cases

- **Case 1**: User provides a topic but omits table/column/row count.
  - Handling: Agent asks for the missing parameters and does not proceed until all are provided.
- **Case 2**: User provides invalid parameters (e.g. 0 tables, negative rows, unknown dirty level).
  - Handling: Agent rejects the input with a clear error message and asks for valid values.
- **Case 3**: Generated dataset name collides with an existing folder in `data/`.
  - Handling: The sequential prefix avoids most collisions. If a collision still occurs (e.g. user provides a name matching an existing manually-created folder), the agent asks the user for a unique name and does NOT overwrite existing files.
- **Case 4**: Dirty level `high` generates cross-column inconsistencies that are difficult to detect.
  - Handling: The README documents all applied dirty categories explicitly so learners know what to look for.
- **Case 5**: The generated SQLite database is empty (0 rows requested).
  - Handling: Agent rejects the input — minimum row count is 10.

## Affected Specs

| Spec                                | Change Type |
| ----------------------------------- | ----------- |
| `specs/dataset-generator/spec.md`   | ADDED       |
