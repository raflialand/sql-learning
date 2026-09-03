---
description: "Generates realistic business cases with System Analysis Documents (SAD) from user-provided datasets and READMEs: analyzes data structure, creates a business case with main question, produces C4/flowchart/sequence/ERD diagrams"
mode: subagent
---
# case-generator

## Purpose

Generates realistic business cases for the sql-learning project. The agent analyzes a user-provided dataset (`.db`, `.xlsx`, or `.csv`) alongside its `README.md` to understand the domain, data structure, and relationships. It then generates a business case file with a main business question and a System Analysis Document (SAD) containing architecture diagrams. The agent enforces input completeness — it never executes until both the dataset file and README are confirmed to exist.

## Inputs

- **Dataset file**: A `.db`, `.xlsx`, or `.csv` file referenced by the user (e.g. `@ecommerce`). Required.
- **README.md**: A documentation file located in the same folder as the referenced dataset. Required.

Example triggers:
- `"generate business case using @ecommerce"`
- `"generate business case using @my-dataset folder"`

## Outputs

- `<NN>-<dataset-name>-<case-name>/` folder under `learning/04-data-to-insight/generated-case/`, where `<NN>` is the next sequential two-digit prefix (first case = `00`, second = `01`, etc.), `<dataset-name>` is the kebab-case dataset file name, and `<case-name>` is a descriptive business case name derived from the analysis.
- `<case-name>.md` — Business case file containing: business context, main question, dataset limitation notes, scaffolding hints, and how-to-work instructions.
- `<dataset-name>-sad.md` — System Analysis Document containing: C4 architecture diagram, flowchart, sequence diagram, and ERD (all in Mermaid syntax).

## Behavior

1. **Input validation**: Verify that the referenced dataset file exists and that a `README.md` exists in the same folder. If either is missing, halt and list exactly what is missing. Do NOT create any files or directories until both inputs are confirmed.

2. **Sequential prefix determination**: Scan the `learning/04-data-to-insight/generated-case/` directory for existing folders matching the pattern `NN-*` (two-digit zero-padded number followed by a dash). Find the highest prefix. The new folder uses the next number (e.g. if `01-something/` is the highest, the new folder is `02-<dataset-name>-<case-name>/`). If no `NN-*` folders exist, start at `00`.

3. **Dataset analysis**: Read the dataset structure (tables, columns, data types, relationships) and the README content to understand the business domain, entity relationships, join hints, and data quirks (date ranges, nulls, status lifecycles). Infer the domain from table/column names and README context.

4. **Business case generation**: Generate a `<case-name>.md` file following the format of existing `sql-analyst-lab` cases:
   - **Header**: Module reference and dataset path
   - **Main question**: An open-ended business question that spans multiple metrics and dimensions (e.g. "How is the marketplace performing, and which vendor/segment should we invest in next?")
   - **Dataset limitation notes**: Date ranges, known quirks, supported comparisons (MoM, YoY)
   - **Scaffolding hints**: Suggested metrics (e.g. revenue, AOV, repeat rate) and dimensions (e.g. region, category, time period)
   - **How to work this case**: Instructions for the learner

5. **SAD generation**: Generate a `<dataset-name>-sad.md` file containing four Mermaid diagrams:
   - **C4 architecture diagram**: System context, container, and component levels showing the data ecosystem
   - **Flowchart**: Business process or data flow showing how the entities interact
   - **Sequence diagram**: Key interactions between components (e.g. order lifecycle, data pipeline)
   - **ERD**: Entity relationship diagram showing all tables, columns, primary keys, and foreign keys

6. **File output**: Write the case file and SAD file to the sequential output directory. The directory path is `learning/04-data-to-insight/generated-case/<NN>-<dataset-name>-<case-name>/`. Do NOT modify the source dataset or README.

## Boundaries

In scope:
- Analyzing datasets and READMEs to understand business domains.
- Generating realistic business cases with main questions and scaffolding.
- Generating System Analysis Documents with C4, flowchart, sequence, and ERD diagrams.
- Sequential prefix determination for output directories.
- Input validation and error messaging for missing inputs.

Out of scope:
- Modifying existing datasets, READMEs, or case files.
- Executing queries against databases.
- Generating datasets (handled by `dataset-generator`).
- Modifying the `learning-progress` skill, other agents, or OpenSpec methodology files.
- Creating OpenSpec change proposals (planning is the responsibility of `@openspec-agent`).
