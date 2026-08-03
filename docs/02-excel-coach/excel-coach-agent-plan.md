# Excel Coach Agent — OpenSpec Implementation Plan

**Status:** Plan only — not yet executed

---

## Goal

Adapt the OpenSpec methodology from `data-openspec-training` into the SQL-DUMMY project to create a domain agent (`excel-coach`) that guides the 30-day Excel for Data Analyst intensive — using **opencode** as the sole AI tool.

---

## Phase 1: Directory Structure

Create folders:

```
learning/excel-30day-intensive/learning-materials/     ← roadmap lives here
openspec/specs/excel-coach/                             ← agent spec
openspec/specs/spec-format/                             ← format guardrail
openspec/specs/service-capability-template/             ← pattern reference
openspec/specs/archive-safety/                          ← archive protocol
openspec/changes/archive/                               ← completed changes
adr/                                                    ← architecture decisions
```

---

## Phase 2: Copy OpenSpec Template Files

Copy from `D:\#MY DATA\AI & DATA\.LESSONS\SDD-OPENSPEC-UPDATED\data-openspec-training\` into SQL-DUMMY root:

| Source | Destination | Purpose |
|--------|-------------|---------|
| `openspec/AGENTS.md` | `openspec/AGENTS.md` | Methodology authority (canonical/delta format rules, lifecycle, archive safety) |
| `openspec/changes/AGENTS.md` | `openspec/changes/AGENTS.md` | Change proposal templates |
| `openspec/specs/spec-format/spec.md` | `openspec/specs/spec-format/spec.md` | Format guardrail |
| `openspec/specs/service-capability-template/spec.md` | `openspec/specs/service-capability-template/spec.md` | Service spec template |
| `openspec/specs/archive-safety/spec.md` | `openspec/specs/archive-safety/spec.md` | Archive merge safety |
| `adr/AGENTS.md` | `adr/AGENTS.md` | ADR conventions |
| `.opencode/agents/openspec-agent.md` | `.opencode/agents/openspec-agent.md` | Planning subagent |

**What changes from the original:** Only `openspec/AGENTS.md` lines referencing archive-safety spec path will be adjusted to match the new project. All other files are domain-agnostic and stay as-is.

---

## Phase 3: Write `openspec/specs/excel-coach/spec.md`

Following canonical OpenSpec format:

```markdown
# excel-coach Specification

## Purpose

Guides a learner through the 30-day Excel for Data Analyst intensive using opencode as the AI tool — generating prompts, validating outputs, and tracking progress day by day.

## Requirements

### Requirement: Generate opencode Prompts Per Day
The system SHALL generate structured opencode prompts for each day's topic (formulas, PQ, DAX, charts, VBA, Python).

#### Scenario: Day 1 — Basic formulas
- GIVEN the user is on Day 1
- WHEN the agent is asked for the task
- THEN the agent SHALL output an opencode prompt instructing opencode to write SUM/AVERAGE/IF formulas for a sales CSV
- AND the agent SHALL provide a 3-item validation checklist

#### Scenario: Day 5 — Power Query cleaning
- GIVEN the user is on Day 5
- WHEN the agent is asked for the task
- THEN the agent SHALL output an opencode prompt instructing opencode to generate M code for cleaning a dirty CSV export
- AND the agent SHALL list validation steps (row count, date format check, dedup verification)

#### Scenario: Day 11 — DAX measures
- GIVEN the user is on Day 11
- WHEN the agent is asked for the task
- THEN the agent SHALL output an opencode prompt for DAX measures (CALCULATE, SAMEPERIODLASTYEAR)
- AND the agent SHALL provide a manual cross-check validation step

#### Scenario: Day 20 — VBA macros
- GIVEN the user is on Day 20
- WHEN the agent is asked for the task
- THEN the agent SHALL output an opencode prompt for a VBA export-to-PDF macro
- AND the agent SHALL list error-handling edge cases to test

#### Scenario: Day 22 — Python in Excel
- GIVEN the user is on Day 22
- WHEN the agent is asked for the task
- THEN the agent SHALL output an opencode prompt for a pandas groupby in a PY() cell
- AND the agent SHALL provide a comparison check against native Excel pivot

### Requirement: Validate AI Output
The system SHALL provide a per-day validation checklist the user can run against opencode's output.

#### Scenario: Formula validation
- GIVEN opencode returns a formula
- WHEN the user asks for validation
- THEN the agent SHALL list 3-5 checks (edge cases, error handling, business logic correctness)

#### Scenario: Chart validation
- GIVEN opencode recommends a chart type
- WHEN the user asks for validation
- THEN the agent SHALL provide 2 alternative chart types to compare
- AND the agent SHALL note why opencode's recommendation may or may not be optimal

### Requirement: Track Progress
The system SHALL track which days are completed and suggest the next.

#### Scenario: Completion tracking
- GIVEN the user reports Day N is done
- WHEN the agent updates status
- THEN the agent SHALL mark Day N complete
- AND the agent SHALL preview Day N+1's topic and goal

### Requirement: Use opencode Exclusively
The system SHALL use opencode as the single AI tool — no Copilot, no ChatGPT references.

#### Scenario: Prompt generation for any day
- GIVEN any day's task requires AI assistance
- WHEN the agent generates a prompt
- THEN the prompt SHALL be formatted for opencode
- AND the agent SHALL NOT reference Copilot or ChatGPT

## Boundaries

### In scope
- Reading and referencing `learning/excel-30day-intensive/learning-materials/excel-30day-roadmap.md`
- Generating opencode prompts for all 30 days
- Providing validation checklists per day
- Tracking day-by-day progress

### Out of scope
- Modifying Excel files directly
- Connecting to external databases or APIs
- Writing OpenSpec methodology changes
- Providing domain-specific business advice beyond the curriculum

## Related Code
- `learning/excel-30day-intensive/learning-materials/excel-30day-roadmap.md` — The curriculum
- `.opencode/agents/excel-coach.md` — Agent definition
- `openspec/specs/excel-coach/spec.md` — This file
```

---

## Phase 4: Write `.opencode/agents/excel-coach.md`

```yaml
---
description: Guides 30-day Excel learning with opencode prompts
mode: subagent
---

# excel-coach

## Purpose

Guide the user through the 30-day Excel for Data Analyst intensive using opencode as the AI tool. Generate day-specific prompts, validate outputs, track progress.

## Inputs

- `learning/excel-30day-intensive/learning-materials/excel-30day-roadmap.md`
- `openspec/specs/excel-coach/spec.md`
- User's current day and status

## Outputs

- Daily opencode prompt for the day's skill
- Validation checklist (3-5 checks per day)
- Progress update (completed days / next day preview)

## Behavior

### Day Flow
1. Read `learning/excel-30day-intensive/learning-materials/excel-30day-roadmap.md` to determine current day's topic
2. Generate an opencode prompt targeting that day's skill
3. Provide a validation checklist (3-5 checks)
4. After user confirms completion, mark day done and preview next day

### opencode Prompt Pattern
Every prompt follows this structure:
```
Prompt opencode to:
[Specific task description referencing the practice data file]

Requirements:
- [Concrete output expectations]
- [Edge cases to handle]

Explain each step so I understand the logic.
```

### Validation Pattern
After user runs the prompt:
```
Checklist for Day N:
□ [Check 1 — e.g., "All dates in DD/MM/YYYY format"]
□ [Check 2 — e.g., "No duplicate Order IDs remain"]
□ [Check 3 — e.g., "Business logic: High/Medium/Low tiers cover all rows"]
```

### Week-Level Behavior
| Phase | Days | Agent Focus |
|-------|------|-------------|
| Foundations + Power Query | 1-7 | Formula accuracy, PQ step audit, data integrity |
| Pivots + Business Metrics | 8-14 | DAX measure validation, metric interpretation |
| Dashboard + Visualization | 15-21 | Chart choice rationale, interactivity testing |
| Python + AI + Capstone | 22-30 | Python output verification, automation error handling |

## Boundaries

- Does NOT write or modify Excel files
- Does NOT connect to APIs or external databases
- All guidance is text-based prompts — user executes in Excel
- Does NOT modify OpenSpec methodology files

## Related

- `learning/excel-30day-intensive/learning-materials/excel-30day-roadmap.md`
- `openspec/specs/excel-coach/spec.md`
```

---

## Phase 5: Write `AGENTS.md` (Project Root)

```markdown
# AGENTS.md — SQL-DUMMY Project

## Intent Classification

| Intent | Signal | Action |
|--------|--------|--------|
| Planning | "spec this out", "propose a change", "formalize" | Delegate to `@openspec-agent` |
| Execution | "run @excel-coach", "guide me through Day X", "help with Day 5" | Execute directly or delegate to named agent |
| Ambiguous | Unclear whether planning or execution | Ask: "Is this planning (OpenSpec) or execution (do it now)?" |

**Critical rule:** Domain agents (`excel-coach`) are NOT OpenSpec agents. They execute their defined tasks directly. They SHALL NOT create OpenSpec change proposals. If planning is needed, delegate to `@openspec-agent`.

## Agent Routing

### Planning agents

| Agent | Purpose |
|-------|---------|
| `openspec-agent` | Formalize plans using the OpenSpec methodology |

### Domain agents

| Agent | Purpose |
|-------|---------|
| `excel-coach` | Guides 30-day Excel learning with opencode prompts |

## Directory Write Rules

| Context | Allowed writes |
|---------|---------------|
| Planning (`@openspec-agent`) | `openspec/changes/<change-id>/` ONLY (Phase 1), then approved dirs (Phase 2) |
| Execution (`excel-coach`) | None — guidance only, no file writes |
| Execution (main agent) | Any file (respect `.gitignore`) |

## Directory Map

```
├── AGENTS.md              # This file — intent routing and agent registry
├── README.md              # Project overview
├── .gitignore
│
├── .opencode/
│   ├── agents/
│   │   ├── openspec-agent.md    # Planning subagent
│   │   └── excel-coach.md       # Domain agent for Excel learning
│   ├── skills/                  # Existing skills
│   └── package.json
│
├── adr/                   # Architecture Decision Records
│   └── AGENTS.md
│
├── openspec/
│   ├── AGENTS.md          # Methodology authority
│   ├── specs/             # Canonical capability specifications
│   └── changes/           # Active and archived change proposals
│
├── docs/                  # Project documentation
│   └── 02-excel-coach/
│       └── excel-coach-agent-plan.md   # This file
│
└── learning/
    ├── excel-30day-intensive/
    │   └── learning-materials/
    │       └── excel-30day-roadmap.md    # The curriculum
    └── ...                              # Existing learning folders
```

## Key Rules

1. **Classify intent first** — Planning or execution? Route accordingly.
2. **Domain agents are NOT OpenSpec agents** — They never create change proposals.
3. **OpenSpec is for project capabilities, not for data or document tasks.**
4. **Read `openspec/specs/` before proposing changes** to existing capabilities.
```

---

## Phase 6: Save Roadmap with opencode-only Edits

Place `excel-30day-roadmap.md` in `learning/excel-30day-intensive/learning-materials/`.

Replace all references to Copilot/ChatGPT across the file:

| Section | Find | Replace With |
|---------|------|-------------|
| AI Agent Tasks (Days 1-6) | "Prompt Copilot/ChatGPT:" | "Prompt opencode:" |
| AI Agent Tasks (Days 8-28) | *"Copilot:" / "ChatGPT:" inside quoted prompts* | *"opencode:"* |
| Toolstack — AI Agents | "Microsoft Copilot, ChatGPT, opencode, OpenAI API (via VBA)" | "opencode" |
| Toolstack — AI Agents description | "Excel-native AI for..." | Single description: "Generate formulas, PQ M code, DAX, VBA, Python, charts — all via opencode" |
| AI Integration Summary table | Copilot / ChatGPT entries | opencode in every row |
| Tool Proficiency By Day 30 | "Copilot" listed | Removed |
| Interview Script | "Copilot wrote my initial formulas, ChatGPT helped design the layout" | "opencode helped me generate and validate every stage — formulas, layout, automation" |
| Progress Tracker | Mentions of Copilot/ChatGPT | opencode |
| Final Portfolio — README tools | Copilot, ChatGPT | opencode only |

No structural changes. Only AI tool name replacements.

---

## Phase 7: Create OpenSpec Change Proposal

After all files are in place, invoke `@openspec-agent` with:

> *"Create a change proposal: add-excel-coach-agent. New capability: excel-coach domain agent for guiding 30-day Excel learning."*

This generates:

```
openspec/changes/add-excel-coach-agent/
├── proposal.md   — Problem, solution, scope, value
├── design.md     — Architecture, design decisions, file changes
├── tasks.md      — Ordered steps (Phases 1-7 above)
└── specs/
    └── excel-coach/spec.md  — DELTA: ADDED Requirements
```

After user approval, the agent executes the tasks in order, then archives the completed change.

---

## Summary of All Files to Create

| # | File | Action | Source |
|---|------|--------|--------|
| 1 | `learning/excel-30day-intensive/learning-materials/excel-30day-roadmap.md` | **CREATE** (with opencode-only edits) | Written content |
| 2 | `AGENTS.md` | **CREATE** | Adapted from template |
| 3 | `openspec/AGENTS.md` | **COPY** (minor path adjustment) | `data-openspec-training/openspec/AGENTS.md` |
| 4 | `openspec/changes/AGENTS.md` | **COPY** | `data-openspec-training/openspec/changes/AGENTS.md` |
| 5 | `openspec/specs/spec-format/spec.md` | **COPY** | `data-openspec-training/openspec/specs/spec-format/spec.md` |
| 6 | `openspec/specs/service-capability-template/spec.md` | **COPY** | `data-openspec-training/openspec/specs/service-capability-template/spec.md` |
| 7 | `openspec/specs/archive-safety/spec.md` | **COPY** | `data-openspec-training/openspec/specs/archive-safety/spec.md` |
| 8 | `openspec/specs/excel-coach/spec.md` | **CREATE** | Written content (Phase 3) |
| 9 | `openspec/changes/archive/.gitkeep` | **CREATE** | Empty |
| 10 | `adr/AGENTS.md` | **COPY** | `data-openspec-training/adr/AGENTS.md` |
| 11 | `.opencode/agents/openspec-agent.md` | **COPY** | `data-openspec-training/.opencode/agents/openspec-agent.md` |
| 12 | `.opencode/agents/excel-coach.md` | **CREATE** | Written content (Phase 4) |

**Total: 12 files** (4 copies, 4 creates, 1 adapted copy, 1 gitkeep, 2 empty dir markers)

---

## Execution Order

```
Phase 1: Create directory structure
Phase 2: Copy template files (items 3-7, 10-11)
Phase 3: Write excel-coach spec (item 8)
Phase 4: Write excel-coach agent (item 12)
Phase 5: Write AGENTS.md root (item 2)
Phase 6: Save roadmap with opencode edits (item 1)
Phase 7: Invoke @openspec-agent for change proposal
```
