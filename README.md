# sql-learning

A personal, AI-assisted multi-track learning environment — an 84-day SQL Fundamentals journey (12 weeks), a Data Quality Engineer module (13 units, MySQL), a Data Engineering track (26 weeks), a SQL Skill Push challenge module (60 verified problems across beginner/intermediate/advanced), a SQL Analyst Lab case-studies module (3 open-ended data-to-insight cases), a data-to-insight notes module (turning messy data into actionable insights), and a Data Warehouse Architecture module (Medallion pipeline case: bronze → silver → gold on the MarketHub dataset), with built-in progress tracking, practice databases, and agent-driven tooling.

## What This Is

This directory is a living learning workspace where daily SQL sessions are taught through conversation and tracked automatically by an opencode skill (`learning-progress`). It combines:

- A **canonical roadmap** (`learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md`) breaking 3 months into 12 weeks × 7 days with topics, exercises, quizzes, and milestones.
- **Automatic progress reporting** — the `learning-progress` skill tracks every registered learning track (SQL Fundamentals, SQL Skill Push, Data Quality Engineer, Data Engineering, Data-to-Insight Case Studies) via `learning/00-notes/tracks.md`; each session saves a structured note in that track's notes dir (`session-summary-*.md`), and the skill computes completed units as a percentage of the track's registry total, with a Mermaid progress chart.
- **Practice databases** (SQLite) used for exercises: library management, e-commerce, a `sales-records` dataset for the SQL Mastery modules, plus three profiled datasets (coffee shop, e-commerce, telecom) in `learning/02-sql-learning/sql-skill-push/datasets/` shipped as MySQL + SQLite.
- **Deep-dive modules** under `learning/02-sql-learning/`: `sql-mastery/` (currently: window functions) with lessons, exercises, datasets, and solutions, `sql-skill-push/` — a challenge-based practice module (60 verified problems with expected results) across three difficulty levels, and `sql-analyst-lab/` — an open-ended case-studies module (3 data-to-insight cases: Brew & Co., MarketHub, NovaTel) that applies the 4-step analytical framework to the shared datasets.
- **An execution agent** (`query-inspector`) that reviews learner-submitted SQL from `script/01-sql/` for query-logic correctness and business-requirement alignment, writing analysis reports to `docs/03-query-inspector/`.
- **A notes module** (`learning/04-data-to-insight/`) capturing video analysis reports — currently "Think Like a Senior Data Analyst: Data to Insight in 15 Minutes" (Christine Jiang) with a 4-step analytical framework for turning messy data into actionable insights.
- **A DWH architecture module** (`learning/05-dwh-architecture/`) hosting the **Medallion study case** — a stdlib Python pipeline (`script/02-python/medallion_pipeline.py`) that builds `bronze.db → silver.db → gold.db` (star schema + marts) from the verified MarketHub dataset, with idempotency and no-data-loss assertions. See [`medallion-case.md`](learning/05-dwh-architecture/medallion-case.md).
- **A data-to-insight AI ecosystem** (`.opencode/skills/data-to-insight/`) — an orchestrator skill that automates the 7-stage data-to-insight pipeline (context → scope → questions → bronze→silver → gold mart → query → insight) against a PostgreSQL medallion (`bronze.`/`silver.`/`gold.` schemas), delegating SQL work to `sql-builder` and insight synthesis to `insight-writer` (with `query-inspector` as a QA gate), under checkpointed human approval at each gate. Canonical plan: `agent-blueprints/03-data-to-insight.md`.
- **Five registered learning tracks** in `learning/00-notes/tracks.md`: SQL Fundamentals (84 units), SQL Skill Push (60 challenges), Data Quality Engineer (13 units, MySQL-based against a purpose-built "dirty" dataset), Data Engineering (26 weeks), and Data-to-Insight Case Studies (3 cases).

## Directory Map

```
├── AGENTS.md              # Agent routing and intent classification (planning vs execution)
├── README.md              # This file
├── changes-log.txt        # Change log for all project changes
│
├── script/                # SQL practice scripts
│   ├── 01-sql/            # SQL query logs (e.g. query-log.txt)
│   │   ├── medallion/     # Medallion layer SQL: 01-bronze.sql / 02-silver.sql / 03-gold.sql
│   │   └── data-to-insight/ # PostgreSQL medallion bootstrap (00-bootstrap.sql)
│   └── 02-python/         # Python scripts (e.g. medallion_pipeline.py orchestrator)
│
├── learning/              # All learning material and progress
│   ├── 00-notes/           # Learning notes — excluded from numbering rules; tracks.md is the track registry
│   │   ├── tracks.md       # Track registry (single source of truth)
│   │   ├── 00-personal-discuss/  # Personal discussion notes (00 = special, not time-based)
│   │   ├── 01-de-progress/ # Data Engineering session summaries
│   │   ├── 02-sql-progress/# SQL session summaries (progress truth)
│   │   ├── 03-dq-progress/ # Data Quality session summaries
│   │   ├── 04-sql-push/    # SQL Skill Push session summaries
│   │   └── 05-analyst-lab/ # SQL Analyst Lab session summaries
│   ├── 01-de-learning/     # 6-month data engineering roadmap
│   ├── 02-sql-learning/    # SQL roadmaps + SQL Mastery + Skill Push + Analyst Lab modules
│   │   ├── sql-roadmaps/   # 3-month roadmap + per-week deep dives (Weeks 1–7)
│   │   ├── sql-mastery/    # Module-based learning path (window functions, etc.)
│   │   ├── sql-skill-push/ # Challenge module: 60 verified problems + datasets + solutions
│   │   └── sql-analyst-lab/# Case-studies module: 3 open-ended data-to-insight cases
│   ├── 03-dq-learning/     # MySQL-based Data Quality Engineer module
│   ├── 04-data-to-insight/  # Notes module: data → actionable insights
│   └── 05-dwh-architecture/ # DWH architecture module: Medallion pipeline case
│
├── data/                  # Practice SQLite databases & schema files
│   ├── library-db.sql/.db     # Library management system
│   ├── ecommerce.db           # E-commerce database
│   ├── sql-learn.db / sql-learn-db-week6.*  # Roadmap practice databases (Week 6 etc.)
│   └── medallion/             # Generated Medallion layers: bronze.db / silver.db / gold.db
│
├── docs/                  # Documentation (dedicated folders per topic)
│   ├── 01-erd-diagram/    # ERD diagrams
│   ├── 02-excel-coach/    # Excel coach agent plan
│   └── 03-query-inspector/    # Query analysis reports (query-inspector agent output)
├── agent-blueprints/      # Canonical agent plans
│   ├── 01-learning-progress.md # Multi-track learning progress plan
│   ├── 02-query-inspector.txt # Query inspector agent plan
│   ├── 03-data-to-insight.md # Data-to-insight pipeline plan (7-stage recipe)
│   └── demo-prompt/           # Sample prompts & hands-on training (CSE asset manager)
├── adr/                   # Architecture Decision Records (conventions in adr/AGENTS.md)
│   └── learning-progress/  # Skill-scoped ADRs (SELF-CHECK/ADJUST)
│
├── .opencode/             # opencode configuration
│   ├── agents/            # Agent definitions (openspec-agent, query-inspector, sql-builder, insight-writer)
│   └── skills/            # Skills
│       ├── learning-progress/  # SKILL.md + manifest.json baseline (SELF-CHECK/ADJUST)
│       └── data-to-insight/    # SKILL.md + README (runbook) + case-template/ — 7-stage pipeline orchestrator
│
└── openspec/              # OpenSpec methodology for spec-driven, plan-first changes
    ├── specs/             # Canonical capability specifications
    └── changes/           # Active + archived change proposals
```

## How It Works

The `learning-progress` skill (`.opencode/skills/learning-progress/SKILL.md`) executes on three trigger modes, optionally scoped to a track keyword (`progress <track>`, `summarize <track>`); bare triggers default to the most recently active track:

| Mode | Triggers | Behavior |
|------|----------|----------|
| **REPORT** | "continue learning", "where am I", "progress", "progress <track>" | Read-only: shows current position, progress %, Mermaid pie chart, completed/in-progress/pending units, last session summary, and next topic |
| **SUMMARIZE** | "summarize", "daily summary", "rangkuman", "ringkasan", "summarize <track>" | Saves/appends the session to the resolved track's notes dir (`session-summary-{day}-{month}-{year}.md`), then runs the same progress report |
| **SELF-CHECK/ADJUST** | "adjust the skill", "self-check", detected manifest diff | Detects changes to the skill's own definition (diff of SKILL.md / blueprint / spec vs `manifest.json`), elicits ADR requirements before an adjustment executes, and writes `adr/learning-progress/ADR-{NNN}-{slug}.md` after execution |

Beyond progress tracking, a `query-inspector` domain agent reviews learner-submitted SQL files under `script/01-sql/`, checks them for query-logic correctness and business-requirement alignment, and writes the full analysis to `docs/03-query-inspector/query-analysis.md` (dated variants when the file exists). It is an execution agent — it never creates OpenSpec change proposals.

Progress rules:
- Roadmap = source of truth for the timeline; session notes = source of truth for actual progress.
- Only `session-summary-*.md` files count toward progress.
- Progress = completed units ÷ the track's total units from `learning/00-notes/tracks.md`.

Changes to the project's *capabilities* (agents, specs, directory structure) follow the **OpenSpec** methodology and are formalized by `@openspec-agent`. Day-to-day learning tasks are executed directly.

## Roadmap Overview

| Month | Focus | Weeks |
|-------|-------|-------|
| **Month 1** | SQL Fundamentals | 1 Intro & Basic Queries · 2 WHERE · 3 Sorting & Limiting · 4 Data Manipulation (CRUD) |
| **Month 2** | Intermediate SQL | 5 Table Design & Relationships · 6 JOINs · 7 Aggregation & GROUP BY · 8 Subqueries |
| **Month 3** | Advanced SQL | 9 CASE & Advanced Filtering · 10 Views & Indexes · 11 Advanced JOINs & Set Operations · 12 Performance & Best Practices |

Three capstone projects punctuate the journey: a personal budget tracker (end of Week 4), a mini e-commerce database (end of Week 8), and a complete inventory system (end of Week 12).

## Getting Started

1. **Open the roadmap** — `learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md`.
2. **Open a practice database** in VSCode with the SQLite extension (e.g. `data/sql-learn-db-week6.db` or `learning/02-sql-learning/sql-mastery/datasets/sales-records.db`).
3. **Start a session** — say "continue learning" to get your current position and next topic, then learn and practice in conversation.
4. **Save your progress** — say "summarize" (or "rangkuman") to persist the session as a structured note and see the updated progress report.
5. **Get query feedback** — put your SQL in `script/01-sql/` and run `@query-inspector` to have it checked for correctness and business alignment.
6. **Push your SQL skills** — solve the verified challenges in `learning/02-sql-learning/sql-skill-push/` (60 problems across beginner/intermediate/advanced, each with an expected result).
7. **Think like an analyst** — work the open-ended case studies in `learning/02-sql-learning/sql-analyst-lab/` (3 cases that apply the 4-step data-to-insight framework: scope metrics/dimensions → break the question into sub-questions → query → strong insights).
8. **Build the Medallion pipeline** — run `python script/02-python/medallion_pipeline.py` to build bronze → silver → gold on the MarketHub dataset, then read the mapping and lineage in `learning/05-dwh-architecture/medallion-case.md`.

## Prerequisites

- **SQLite3** — practice database engine (`sqlite3 --version`)
- **VSCode** — with SQLite Viewer / SQLite extensions
- **opencode** — for the `learning-progress` skill and `openspec-agent` planning workflow

## Related Roadmaps

- `learning/01-de-learning/data-engineering-roadmap-6months.md` — broader data engineering path
- `learning/03-dq-learning/README.md` — Data Quality Engineer module (MySQL-based, standalone)
- `learning/02-sql-learning/sql-skill-push/README.md` — SQL Skill Push challenge module (60 verified problems)
- `learning/02-sql-learning/sql-analyst-lab/README.md` — SQL Analyst Lab case-studies module (3 open-ended data-to-insight cases)
- `learning/05-dwh-architecture/README.md` — Data Warehouse Architecture module (Medallion pipeline case)
