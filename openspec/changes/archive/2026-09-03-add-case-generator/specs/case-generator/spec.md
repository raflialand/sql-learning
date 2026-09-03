# Spec Deltas for case-generator

## ADDED Requirements

### Requirement: Input Validation

The agent SHALL validate that both a dataset file and a README.md exist before proceeding with case generation.

#### Scenario: All inputs provided

- GIVEN the user provides a reference to a dataset file (`.db`, `.xlsx`, or `.csv`)
- AND a `README.md` exists in the same folder as the dataset file
- WHEN the agent begins execution
- THEN the agent SHALL proceed to analysis without further prompts

#### Scenario: Missing dataset file

- GIVEN the user references a dataset file that does not exist
- WHEN the agent attempts to begin execution
- THEN the agent SHALL halt before any generation logic executes
- AND the agent SHALL list the missing dataset file path
- AND the agent SHALL ask the user to provide a valid dataset reference

#### Scenario: Missing README

- GIVEN the user provides a valid dataset file reference
- AND no `README.md` exists in the same folder as the dataset
- WHEN the agent attempts to begin execution
- THEN the agent SHALL halt before any generation logic executes
- AND the agent SHALL indicate that a README.md is required in the dataset folder
- AND the agent SHALL ask the user to provide or create the README

### Requirement: Sequential Folder Numbering

The agent SHALL generate output folders with sequential two-digit prefixes under `learning/04-data-to-insight/generated-case/`.

#### Scenario: First generated case

- GIVEN no existing folders in `learning/04-data-to-insight/generated-case/` match the pattern `NN-*`
- WHEN the agent creates the output directory
- THEN the agent SHALL name the folder `00-<dataset-name>-<case-name>/`

#### Scenario: Subsequent generated cases

- GIVEN existing folders in `learning/04-data-to-insight/generated-case/` include `00-something/` and `01-other/`
- WHEN the agent creates a new output directory
- THEN the agent SHALL scan for the highest existing prefix (`01`) and increment by 1
- AND the agent SHALL name the folder `02-<dataset-name>-<case-name>/`

### Requirement: Case File Generation

The agent SHALL generate a `<case-name>.md` file following the format of existing `sql-analyst-lab` cases.

#### Scenario: Case file content

- GIVEN the agent has analyzed the dataset and README
- WHEN the agent writes the case file
- THEN the case file SHALL contain a business context and domain description derived from the dataset
- AND the case file SHALL contain a main business question (open-ended, like existing cases)
- AND the case file SHALL contain dataset limitation notes (date ranges, known quirks)
- AND the case file SHALL contain scaffolding hints (metrics, dimensions suggested)
- AND the case file SHALL contain how-to-work-this-case instructions

### Requirement: SAD Diagram Generation

The agent SHALL generate a `<dataset-name>-sad.md` file containing Mermaid architecture diagrams.

#### Scenario: SAD content

- GIVEN the agent has analyzed the dataset structure and relationships
- WHEN the agent writes the SAD file
- THEN the SAD SHALL contain a C4 architecture diagram (Mermaid) showing system context, container, and component levels
- AND the SAD SHALL contain a flowchart (Mermaid) showing the business process or data flow
- AND the SAD SHALL contain a sequence diagram (Mermaid) showing key interactions
- AND the SAD SHALL contain an ERD (Mermaid) showing entity relationships of the dataset tables

### Requirement: Output File Contract

The agent SHALL produce exactly two files in the output directory.

#### Scenario: Successful generation

- GIVEN the agent has validated inputs and generated content
- WHEN output files are written
- THEN the agent SHALL create `learning/04-data-to-insight/generated-case/<NN>-<dataset-name>-<case-name>/`
- AND the agent SHALL write `<case-name>.md` to that directory
- AND the agent SHALL write `<dataset-name>-sad.md` to that directory
- AND the agent SHALL NOT modify the source dataset or README

### Requirement: Dataset Analysis

The agent SHALL analyze the dataset structure and README content to generate appropriate business context.

#### Scenario: Dataset with clear business domain

- GIVEN the dataset README describes a specific business domain (e.g., e-commerce, healthcare)
- WHEN the agent generates the business case
- THEN the case SHALL reflect the described domain with realistic business questions
- AND the SAD diagrams SHALL accurately represent the system architecture

#### Scenario: Dataset with minimal documentation

- GIVEN the dataset README contains minimal or no business context
- WHEN the agent generates the business case
- THEN the agent SHALL infer domain from table/column names and relationships
- AND the case SHALL contain a generic but plausible business context