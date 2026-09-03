# AGENTS.md — sql-learning

This file is the primary instruction surface for agents contributing to this project. It is injected into context on every interaction.

## Project Identity

sql-learning is a multi-track learning environment (SQL Fundamentals, Data Quality Engineer, Data Engineering). Its execution domain is driven by the `learning-progress` skill (`.opencode/skills/learning-progress/`), the canonical agent plan (`agent-blueprints/01-learning-progress.md`), and the track registry (`learning/00-notes/tracks.md`). It also uses the OpenSpec methodology for spec-driven, plan-first changes to project capabilities.

## Intent Classification

Before acting on any user request, classify the intent into one of three categories:

| Intent    | Signals                                                                                                          | Action                                                       |
| --------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **Planning**  | "create a change plan", "propose", "formalize", "spec this out", adding/modifying agents or project capabilities | Delegate to `@openspec-agent`                                  |
| **Execution** | "run @<agent>", "generate docs", "analyze", "build", direct tasks with concrete inputs/outputs                   | Execute directly (or delegate to the named agent)     |
| **Ambiguous** | Unclear whether planning or execution                                                                            | Ask: "Is this planning (OpenSpec) or execution (do it now)?" |

**Critical rule**: Domain/execution agents are NOT OpenSpec agents. They execute their defined tasks directly. They SHALL NOT create OpenSpec change proposals. If planning is needed, let the main agent delegate to `@openspec-agent`.

## Agent Routing

When the intent is planning, the main agent SHALL delegate to `@openspec-agent`. When the intent is execution, the main agent SHALL delegate to the named agent or execute the task directly. When a planning intent targets the learning-progress skill, the main agent SHALL first run SELF-CHECK/ADJUST to elicit ADR requirements from the user (DETECT/ELICIT), then delegate to `@openspec-agent`.

### Planning agents

| Agent          | Purpose                                                 |
| -------------- | ------------------------------------------------------- |
| `openspec-agent` | Formalize plans using the OpenSpec methodology |

### Domain agents

| Agent                | Purpose                                                       |
| -------------------- | ------------------------------------------------------------- |
| `query-inspector`    | Inspects learner-submitted SQL queries for query-logic correctness and business-requirement alignment; writes `query-analysis.md` to `<case>/verification/` (data-to-insight pipeline) or `docs/03-query-inspector/` (standalone QA) |
| `sql-builder`        | Authors and executes PostgreSQL SQL for the data-to-insight pipeline (stages 3–5: silver cleaning, gold mart, sub-question queries); declares grain + unique key and verifies row uniqueness |
| `insight-writer`     | Synthesizes the 5-component insight (Trend, Fluctuation, Anomaly, Root cause, Recommendation) + recommendations + self-check (stage 6), graded against the weak-vs-strong rubric |
| `progress-evaluator` | Read-only verification gate at every data-to-insight checkpoint (stages 1–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts; writes dated reports to `<case>/verification/` |
| `dataset-generator`  | Generates synthetic messy datasets for practice/learning: accepts a topic + scope parameters, validates inputs, produces SQLite + PostgreSQL SQL script + README under `data/` |
| `case-generator`     | Generates realistic business cases with SAD (C4, flowchart, sequence, ERD) from user-provided datasets and READMEs: analyzes data structure, creates business case with main question |

Domain agents are project-specific. Add agent definitions to `.opencode/agents/` and register them in this table. The `learning-progress` execution capability is defined in `.opencode/skills/learning-progress/`, `agent-blueprints/01-learning-progress.md`, and the track registry `learning/00-notes/tracks.md`. The `data-to-insight` execution capability is defined in `.opencode/skills/data-to-insight/`, `agent-blueprints/03-data-to-insight.md`, and delegates SQL work to `@sql-builder`, insight synthesis to `@insight-writer`, and checkpoint verification to `@progress-evaluator` (read-only blocking gate), reusing `@query-inspector` as a QA gate.

## Directory Write Rules

| Context                    | Allowed writes                                                                 |
| -------------------------- | ------------------------------------------------------------------------------ |
| Planning (`@openspec-agent`) | `openspec/changes/<change-id>/` ONLY (Phase 1), then approved dirs (Phase 2)     |
| Execution (domain agents)  | Agent-defined output directories only (e.g. `learning/`, `agent-blueprints/`)          |
| Execution (main agent)     | Any file (respect `.gitignore`)                                                  |

## Directory Map

```
├── AGENTS.md              # This file — intent routing and agent registry
├── .opencode/             # Agent configuration directory
│   ├── agents/            # Agent definitions for all agents
│   └── skills/            # Skill definitions (e.g. learning-progress)
│
├── adr/                   # Architecture Decision Records
│   ├── AGENTS.md          # ADR conventions and template
│   └── learning-progress/  # Skill-scoped ADRs (SELF-CHECK/ADJUST)
│
├── agent-blueprints/      # Canonical agent plans for execution agents
├── learning/              # Learning material and progress notes (track registry: learning/00-notes/tracks.md)
├── script/                # SQL practice scripts (e.g. 01-sql/query-log.txt)
├── data/                  # Data assets
├── docs/                  # Documentation (dedicated folders per topic)
│   ├── 01-erd-diagram/    # ERD diagrams
│   └── 02-excel-coach/    # Excel coach agent plan
│
└── openspec/
    ├── AGENTS.md          # Complete OpenSpec methodology (loaded by openspec-agent only)
    ├── specs/             # Canonical capability specifications
    └── changes/           # Active and archived change proposals
```

## Key Rules

1. **Classify intent first** — Planning or execution? Route accordingly.
2. **Domain agents are NOT OpenSpec agents** — They never create change proposals.
3. **OpenSpec is for project capabilities, not for data or document tasks.**
4. **Read `openspec/specs/` before proposing changes** to existing capabilities.
5. **OpenSpec methodology** — The full lifecycle, format rules, and archive safety are documented in `openspec/AGENTS.md` and are loaded only by `@openspec-agent`.
