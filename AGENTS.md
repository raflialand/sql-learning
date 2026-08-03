# AGENTS.md — sql-learning

This file is the primary instruction surface for agents contributing to this project. It is injected into context on every interaction.

## Project Identity

sql-learning is a 3-month, 12-week SQL learning environment. Its execution domain is driven by the `sql-learning` skill (`.opencode/skills/sql-learning/`) and the canonical agent plan (`agent-blueprints/01-sql-learning.md`). It also uses the OpenSpec methodology for spec-driven, plan-first changes to project capabilities.

## Intent Classification

Before acting on any user request, classify the intent into one of three categories:

| Intent    | Signals                                                                                                          | Action                                                       |
| --------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **Planning**  | "create a change plan", "propose", "formalize", "spec this out", adding/modifying agents or project capabilities | Delegate to `@openspec-agent`                                  |
| **Execution** | "run @<agent>", "generate docs", "analyze", "build", direct tasks with concrete inputs/outputs                   | Execute directly (or delegate to the named agent)     |
| **Ambiguous** | Unclear whether planning or execution                                                                            | Ask: "Is this planning (OpenSpec) or execution (do it now)?" |

**Critical rule**: Domain/execution agents are NOT OpenSpec agents. They execute their defined tasks directly. They SHALL NOT create OpenSpec change proposals. If planning is needed, let the main agent delegate to `@openspec-agent`.

## Agent Routing

When the intent is planning, the main agent SHALL delegate to `@openspec-agent`. When the intent is execution, the main agent SHALL delegate to the named agent or execute the task directly.

### Planning agents

| Agent          | Purpose                                                 |
| -------------- | ------------------------------------------------------- |
| `openspec-agent` | Formalize plans using the OpenSpec methodology |

### Domain agents

| Agent                | Purpose                                                       |
| -------------------- | ------------------------------------------------------------- |

Domain agents are project-specific. Add agent definitions to `.opencode/agents/` and register them in this table. The `sql-learning` execution capability is defined in `.opencode/skills/sql-learning/` and `agent-blueprints/01-sql-learning.md`.

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
│   └── skills/            # Skill definitions (e.g. sql-learning)
│
├── adr/                   # Architecture Decision Records
│   └── AGENTS.md          # ADR conventions and template
│
├── agent-blueprints/      # Canonical agent plans for execution agents
├── learning/              # Learning material and progress notes
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
