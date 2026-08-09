# sql-learning

A personal, AI-assisted multi-track learning environment — an 84-day SQL Fundamentals journey (12 weeks), a Data Quality Engineer module (13 units, MySQL), a Data Engineering track (26 weeks), and a SQL Skill Push challenge module (60 verified problems across beginner/intermediate/advanced), with built-in progress tracking, practice databases, and agent-driven tooling.

## What This Is

This directory is a living learning workspace where daily SQL sessions are taught through conversation and tracked automatically by an opencode skill (`learning-progress`). It combines:

- A **canonical roadmap** (`learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md`) breaking 3 months into 12 weeks × 7 days with topics, exercises, quizzes, and milestones.
- **Automatic progress reporting** — the `learning-progress` skill tracks every registered learning track (SQL Fundamentals, SQL Skill Push, Data Quality Engineer, Data Engineering) via `learning/00-notes/tracks.md`; each session saves a structured note in that track's notes dir (`session-summary-*.md`), and the skill computes completed units as a percentage of the track's registry total, with a Mermaid progress chart.
- **Practice databases** (SQLite) used for exercises: library management, e-commerce, a `sales-records` dataset for the SQL Mastery modules, plus three profiled datasets (coffee shop, e-commerce, telecom) in `learning/02-sql-learning/sql-skill-push/datasets/` shipped as MySQL + SQLite.
- **Deep-dive modules** under `learning/02-sql-learning/`: `sql-mastery/` (currently: window functions) with lessons, exercises, datasets, and solutions, and `sql-skill-push/` — a challenge-based practice module (60 verified problems with expected results) across three difficulty levels.
- **An execution agent** (`query-inspector`) that reviews learner-submitted SQL from `script/01-sql/` for query-logic correctness and business-requirement alignment, writing analysis reports to `docs/03-query-inspector/`.
- **Four registered learning tracks** in `learning/00-notes/tracks.md`: SQL Fundamentals (84 units), SQL Skill Push (60 challenges), Data Quality Engineer (13 units, MySQL-based against a purpose-built "dirty" dataset), and Data Engineering (26 weeks).

## Directory Map

```
├── AGENTS.md              # Agent routing and intent classification (planning vs execution)
├── README.md              # This file
├── changes-log.txt        # Change log for all project changes
│
├── script/                # SQL practice scripts
│   └── 01-sql/            # SQL query logs (e.g. query-log.txt)
│
├── learning/              # All learning material and progress
│   ├── 00-notes/           # Learning notes — excluded from numbering rules; tracks.md is the track registry
│   │   ├── tracks.md       # Track registry (single source of truth)
│   │   ├── 00-personal-discuss/  # Personal discussion notes (00 = special, not time-based)
│   │   ├── 01-de-progress/ # Data Engineering session summaries
│   │   ├── 02-sql-progress/# SQL session summaries (progress truth)
│   │   ├── 03-dq-progress/ # Data Quality session summaries
│   │   └── 04-sql-push/    # SQL Skill Push session summaries
│   ├── 01-de-learning/     # 6-month data engineering roadmap
│   ├── 02-sql-learning/    # SQL roadmaps + SQL Mastery + Skill Push modules
│   │   ├── sql-roadmaps/   # 3-month roadmap + per-week deep dives (Weeks 1–7)
│   │   ├── sql-mastery/    # Module-based learning path (window functions, etc.)
│   │   └── sql-skill-push/ # Challenge module: 60 verified problems + datasets + solutions
│   └── 03-dq-learning/     # MySQL-based Data Quality Engineer module
│
├── data/                  # Practice SQLite databases & schema files
│   ├── library-db.sql/.db     # Library management system
│   ├── ecommerce.db           # E-commerce database
│   └── sql-learn.db / sql-learn-db-week6.*  # Roadmap practice databases (Week 6 etc.)
│
├── docs/                  # Documentation (dedicated folders per topic)
│   ├── 01-erd-diagram/    # ERD diagrams
│   ├── 02-excel-coach/    # Excel coach agent plan
│   └── 03-query-inspector/    # Query analysis reports (query-inspector agent output)
├── agent-blueprints/      # Canonical agent plans
│   ├── 01-learning-progress.md # Multi-track learning progress plan
│   ├── 02-query-inspector.txt # Query inspector agent plan
│   └── demo-prompt/           # Sample prompts & hands-on training (CSE asset manager)
├── adr/                   # Architecture Decision Records (conventions in adr/AGENTS.md)
│   └── learning-progress/  # Skill-scoped ADRs (SELF-CHECK/ADJUST)
│
├── .opencode/             # opencode configuration
│   ├── agents/            # Agent definitions (openspec-agent, query-inspector)
│   └── skills/            # Skills
│       └── learning-progress/  # SKILL.md + manifest.json baseline (SELF-CHECK/ADJUST)
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

## Prerequisites

- **SQLite3** — practice database engine (`sqlite3 --version`)
- **VSCode** — with SQLite Viewer / SQLite extensions
- **opencode** — for the `learning-progress` skill and `openspec-agent` planning workflow

## Related Roadmaps

- `learning/01-de-learning/data-engineering-roadmap-6months.md` — broader data engineering path
- `learning/03-dq-learning/README.md` — Data Quality Engineer module (MySQL-based, standalone)
- `learning/02-sql-learning/sql-skill-push/README.md` — SQL Skill Push challenge module (60 verified problems)
