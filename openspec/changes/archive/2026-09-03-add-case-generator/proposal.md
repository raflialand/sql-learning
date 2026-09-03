# Add Case Generator Agent

## Problem Statement

The sql-learning project has a `data-to-insight` pipeline that requires cases (folder structures with `case.md`, `work/`, `expected/`, `verification/`) to run. Currently, there is no agent that creates these case structures. The `dataset-generator` agent only produces raw datasets (SQLite + PostgreSQL SQL + README) under `data/`, explicitly excluding case study generation from its scope (line 56 of its agent definition). This gap means users cannot automatically generate realistic business cases from existing datasets, limiting the pipeline's utility for practice and learning.

## Proposed Solution

Create a new `case-generator` agent that analyzes a user-provided dataset (alongside its README), generates a realistic business case with a main business question, and produces a System Analysis Document (SAD) containing architecture diagrams. The agent will read the dataset and README to understand the data, then generate a business case following the same format as existing `sql-analyst-lab` cases. The output will be written to `learning/04-data-to-insight/generated-case/<NN>-<dataset-name>-<case-name>/`.

## Scope

### In scope

- Creating a new `case-generator` agent definition in `.opencode/agents/case-generator.md`
- Registering the agent in the domain agents table in `AGENTS.md`
- Implementing input validation for dataset file and README existence
- Generating sequential folder numbering under `learning/04-data-to-insight/generated-case/`
- Producing two output files: `<case-name>.md` and `<dataset-name>-sad.md`
- Following existing case file format from `sql-analyst-lab` cases
- Generating Mermaid diagrams (C4, flowchart, sequence, ERD) in the SAD
- Ensuring the agent never modifies source datasets or READMEs

### Out of scope

- Modifying existing datasets or case files
- Executing queries against databases
- Creating OpenSpec change proposals (planning responsibility of `@openspec-agent`)
- Modifying the `learning-progress` skill, other agents, or OpenSpec methodology files
- Generating datasets (handled by `dataset-generator`)

## Capabilities

### New Capabilities

- `case-generator` — Analyzes datasets and READMEs to generate business cases with System Analysis Documents

### Modified Capabilities

- None

## Value Proposition

This change bridges the gap between dataset generation and the `data-to-insight` pipeline by enabling automatic creation of realistic business cases from existing datasets. Users can now generate practice cases from any dataset, expanding the learning opportunities without manual case authoring. The agent follows established patterns and integrates seamlessly with the existing pipeline.