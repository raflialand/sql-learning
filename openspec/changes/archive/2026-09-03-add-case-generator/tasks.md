# Add Case Generator Agent — Implementation Tasks

## Phase 1: Agent Definition

### Step 1.1: Create agent definition file

Create `.opencode/agents/case-generator.md` with the following structure:
- Frontmatter with description and mode: subagent
- Purpose section describing the agent's function
- Inputs section listing required user-provided inputs
- Outputs section describing generated files
- Behavior section with step-by-step execution logic
- Boundaries section defining scope

**Verification**: File exists and contains all required sections with proper formatting.

### Step 1.2: Register agent in AGENTS.md

Add `case-generator` to the domain agents table in `AGENTS.md` with purpose: "Analyzes a dataset + README provided by the user, generates a realistic business case with a main business question, and produces a System Analysis Document (SAD) containing architecture diagrams."

**Verification**: Domain agents table has 6 rows including the new agent.

## Phase 2: Capability Spec

### Step 2.1: Create delta spec for case-generator

Create `openspec/changes/add-case-generator/specs/case-generator/spec.md` with ADDED requirements following the canonical spec format. Requirements should cover:
- Input validation
- Sequential folder numbering
- Case file generation
- SAD diagram generation
- Output file contract

**Verification**: Delta spec exists with at least 5 requirements, each with at least one scenario.

## Phase 3: Validation

### Step 3.1: Verify agent follows existing patterns

Compare the new agent definition with `dataset-generator.md` to ensure:
- Same frontmatter format (description, mode: subagent)
- Similar section structure (Purpose, Inputs, Outputs, Behavior, Boundaries)
- Input validation pattern
- Sequential prefix determination logic
- Output file naming conventions

**Verification**: Agent definition matches established patterns with appropriate content for case generation.

### Step 3.2: Verify output directory structure

Confirm that the output path `learning/04-data-to-insight/generated-case/` exists and the agent will create subdirectories with the pattern `<NN>-<dataset-name>-<case-name>/`.

**Verification**: Directory structure is correctly specified in agent definition.

## Summary of Changes

| Category   | Before            | After             |
| ---------- | ----------------- | ----------------- |
| Agent definitions | 5 agents in `.opencode/agents/` | 6 agents in `.opencode/agents/` |
| Domain agents table | 5 rows | 6 rows |
| OpenSpec specs | 10 capabilities | 11 capabilities |
| Output directories | `learning/04-data-to-insight/` contains only `data-to-insight.md` | Will contain `generated-case/` subdirectory at runtime |