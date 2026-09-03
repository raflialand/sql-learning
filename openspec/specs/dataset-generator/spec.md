# dataset-generator Specification

## Purpose

Generates synthetic messy datasets for the sql-learning project with intentional quality issues at configurable dirty levels.

## Requirements

### Requirement: Input Validation

The agent SHALL validate all required inputs before executing any generation logic.

#### Scenario: All inputs provided

- GIVEN the user provides dataset topic, table count, column count, row count, and dirty level
- WHEN the agent begins execution
- THEN the agent SHALL proceed to generation without further prompts

#### Scenario: Missing required input

- GIVEN the user is missing one or more required inputs (topic, table count, column count, row count, or dirty level)
- WHEN the agent attempts to begin execution
- THEN the agent SHALL halt before any generation logic executes
- AND the agent SHALL list each missing input by name
- AND the agent SHALL ask the user to provide the missing values

#### Scenario: Invalid input values

- GIVEN the user provides a dirty level that is not `low`, `mid`, or `high`
- WHEN the agent validates inputs
- THEN the agent SHALL reject the input with a clear error message
- AND the agent SHALL ask for a valid dirty level

#### Scenario: Invalid numeric parameters

- GIVEN the user provides table count, column count, or row count less than 1
- WHEN the agent validates inputs
- THEN the agent SHALL reject the input with a clear error message
- AND the agent SHALL ask for valid positive integer values

### Requirement: Dirty Data Generation by Level

The agent SHALL generate synthetic datasets with intentional quality issues corresponding to the requested dirty level.

#### Scenario: Low dirty level

- GIVEN the dirty level is `low`
- WHEN the agent generates the dataset
- THEN the dataset SHALL contain NULL values in 5-10% of cells across applicable columns
- AND the dataset SHALL contain 2-5% exact duplicate rows
- AND the dataset SHALL contain mixed-case text inconsistencies (e.g. "John" vs "john" vs "JOHN")

#### Scenario: Mid dirty level

- GIVEN the dirty level is `mid`
- WHEN the agent generates the dataset
- THEN the dataset SHALL contain all `low`-level issues
- AND the dataset SHALL contain wrong data types embedded in text columns (e.g. "N/A" in numeric fields)
- AND the dataset SHALL contain leading/trailing whitespace in string values
- AND the dataset SHALL contain inconsistent date formats across rows (e.g. MM/DD/YYYY mixed with YYYY-MM-DD)
- AND the dataset SHALL contain extra internal spaces in name fields (e.g. "John  Doe")

#### Scenario: High dirty level

- GIVEN the dirty level is `high`
- WHEN the agent generates the dataset
- THEN the dataset SHALL contain all `mid`-level issues
- AND the dataset SHALL contain typos in string columns via random character substitution
- AND the dataset SHALL contain swapped values across semantically related columns
- AND the dataset SHALL contain out-of-range numeric values (e.g. negative ages, prices above 1M)
- AND the dataset SHALL contain future dates in fields that should reference past dates
- AND the dataset SHALL contain cross-column semantic inconsistencies (e.g. "cancelled" status with non-null delivery date)

### Requirement: Output File Contract

The agent SHALL produce three output files in a dataset-specific folder under `data/`.

#### Scenario: Successful generation

- GIVEN the agent has validated inputs and generated the dataset
- WHEN output files are written
- THEN the agent SHALL determine the next sequential prefix by scanning `data/` for folders matching the pattern `NN-*` (where `NN` is a two-digit zero-padded number), finding the highest prefix, and incrementing by 1
- AND the agent SHALL create a directory `data/<NN>-<dataset-name>/` using the determined prefix (first dataset = `00`, second = `01`, third = `02`, etc.)
- AND the agent SHALL write `[raw-dataset-name].db` (SQLite database) to that directory
- AND the agent SHALL write `[raw-dataset-name].sql` (PostgreSQL-compatible SQL script with CREATE TABLE and INSERT statements) to that directory
- AND the agent SHALL write `README.md` (dataset documentation) to that directory

#### Scenario: Output directory collision

- GIVEN a directory `data/<NN>-<dataset-name>/` already exists after prefix determination
- WHEN the agent attempts to write output files
- THEN the agent SHALL ask the user for a unique dataset name
- AND the agent SHALL NOT overwrite existing files

### Requirement: README Documentation

The agent SHALL generate a README.md that fully documents the produced dataset.

#### Scenario: README content

- GIVEN the agent has produced a dataset
- WHEN the README.md is generated
- THEN the README SHALL contain the dataset topic/domain description
- AND the README SHALL list each table name, column names, and data types
- AND the README SHALL state the row count per table
- AND the README SHALL list which dirty categories were applied at the requested level
- AND the README SHALL include a usage hint (e.g. "Import into PostgreSQL with: `\copy` or load with a script")

### Requirement: Dataset Naming

The agent SHALL name output directories and files using a consistent convention.

#### Scenario: Directory naming

- GIVEN the user provides a dataset topic (e.g. "e-commerce orders")
- WHEN the agent creates the output directory
- THEN the agent SHALL scan `data/` for existing folders matching the pattern `NN-*`, find the highest prefix, and increment by 1
- AND the directory SHALL be named `<NN>-<kebab-case-topic>` where `<NN>` is the next sequential number (e.g. `00-ecommerce-orders` for the first dataset, `01-ecommerce-orders` for the second)

#### Scenario: File naming

- GIVEN the user provides a dataset topic (e.g. "e-commerce orders")
- WHEN the agent creates output files
- THEN the database file SHALL be named `<kebab-case-topic>.db`
- AND the SQL file SHALL be named `<kebab-case-topic>.sql`

### Requirement: Input-Only Execution Gate

The agent SHALL NOT execute any generation logic until all required inputs are fully provided and validated.

#### Scenario: Partial input provided

- GIVEN the user provides only some inputs (e.g. topic and table count but not row count)
- WHEN the agent detects missing inputs
- THEN the agent SHALL list exactly which inputs are missing
- AND the agent SHALL NOT create any files or directories
- AND the agent SHALL wait for the user to provide the missing values

#### Scenario: All inputs confirmed

- GIVEN the user has provided all required inputs
- WHEN the agent validates all inputs successfully
- THEN the agent SHALL proceed to generation without further confirmation prompts

## Boundaries

### In scope

- Generating synthetic messy datasets from user-provided parameters.
- Input validation and error messaging for missing or invalid inputs.
- Sequential prefix determination for output directories.
- Producing SQLite databases, PostgreSQL-compatible SQL scripts, and README documentation.
- Injecting data quality issues at three dirty levels (low, mid, high).

### Out of scope

- Modifying existing datasets or databases in `data/`.
- Executing queries against a database engine.
- Generating datasets for specific case studies in the data-to-insight pipeline.
- Persisting generated datasets across sessions or versioning them.
- Modifying the `learning-progress` skill, other agents, or OpenSpec methodology files.

## Related Code

- `.opencode/agents/dataset-generator.md` — agent definition
