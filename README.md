# sql-learning

A personal, AI-assisted 3-month SQL learning environment — a structured 12-week / 84-day journey from beginner to intermediate/advanced SQL, with built-in progress tracking, practice databases, and agent-driven tooling.

## What This Is

This directory is a living learning workspace where daily SQL sessions are taught through conversation and tracked automatically by an opencode skill (`sql-learning`). It combines:

- A **canonical roadmap** (`learning/03-tools/sql-roadmaps/sql-learning-roadmap-3months.md`) breaking 3 months into 12 weeks × 7 days with topics, exercises, quizzes, and milestones.
- **Automatic progress reporting** — each session saves a structured note (`learning/00-.notes/session-summary-*.md`), and the skill computes completed days/weeks as a percentage of the 84-day plan, with a Mermaid progress chart.
- **Practice databases** (SQLite) used for exercises: library management, e-commerce, and a `sales-records` dataset for the SQL Mastery modules.
- **Deep-dive modules** under `learning/03-tools/sql-mastery/` (currently: window functions) with lessons, exercises, datasets, and solutions.

## Directory Map

```
├── AGENTS.md              # Agent routing and intent classification (planning vs execution)
├── README.md              # This file
├── changes-log.txt        # Change log for directory reorganizations
├── query-log.txt          # Log of SQL queries practiced
│
├── learning/              # All learning material and progress
│   ├── 00-.notes/         # Daily session summaries (progress truth) — excluded from numbering rules
│   ├── 01-de-roadmap/     # 6-month data engineering roadmap
│   ├── 02-ai-based-business-roadmap/  # AI business reporting roadmap
│   └── 03-tools/          # SQL roadmaps + SQL Mastery modules
│       ├── sql-roadmaps/  # 3-month roadmap + per-week deep dives (Weeks 1–7)
│       └── sql-mastery/   # Module-based learning path (window functions, etc.)
│
├── data/                  # Practice SQLite databases & schema files
│   ├── library-db.sql/.db     # Library management system
│   ├── ecommerce.db           # E-commerce database
│   └── sql-learn-db*.sql/.db  # Roadmap practice databases (Week 6 etc.)
│
├── docs/                  # Documentation (dedicated folders per topic)
│   ├── 01-erd-diagram/    # ERD diagrams
│   └── 02-excel-coach/    # Excel coach agent plan
├── agent-blueprints/      # Canonical agent plans (e.g. 01-sql-learning.md)
├── adr/                   # Architecture Decision Records (conventions in adr/AGENTS.md)
│
├── .opencode/             # opencode configuration
│   ├── agents/            # Agent definitions (e.g. openspec-agent)
│   └── skills/            # Skills (e.g. sql-learning)
│
└── openspec/              # OpenSpec methodology for spec-driven, plan-first changes
    ├── specs/             # Canonical capability specifications
    └── changes/           # Active + archived change proposals
```

## How It Works

The `sql-learning` skill (`.opencode/skills/sql-learning/SKILL.md`) executes on two trigger modes:

| Mode | Triggers | Behavior |
|------|----------|----------|
| **REPORT** | "continue learning", "where am I", "progress" | Read-only: shows current position, progress %, Mermaid pie chart, completed/in-progress/pending weeks, last session summary, and next topic |
| **SUMMARIZE** | "summarize", "daily summary", "rangkuman", "ringkasan" | Saves/appends the session to `learning/00-.notes/session-summary-{day}-{month}-{year}.md`, then runs the same progress report |

Progress rules:
- Roadmap = source of truth for the timeline; session notes = source of truth for actual progress.
- Only `session-summary-*.md` files count toward progress.
- Progress = completed days ÷ 84 days (12 weeks × 7 days).

Changes to the project's *capabilities* (agents, specs, directory structure) follow the **OpenSpec** methodology and are formalized by `@openspec-agent`. Day-to-day learning tasks are executed directly.

## Roadmap Overview

| Month | Focus | Weeks |
|-------|-------|-------|
| **Month 1** | SQL Fundamentals | 1 Intro & Basic Queries · 2 WHERE · 3 Sorting & Limiting · 4 Data Manipulation (CRUD) |
| **Month 2** | Intermediate SQL | 5 Table Design & Relationships · 6 JOINs · 7 Aggregation & GROUP BY · 8 Subqueries |
| **Month 3** | Advanced SQL | 9 CASE & Advanced Filtering · 10 Views & Indexes · 11 Advanced JOINs & Set Operations · 12 Performance & Best Practices |

Three capstone projects punctuate the journey: a personal budget tracker (end of Week 4), a mini e-commerce database (end of Week 8), and a complete inventory system (end of Week 12).

## Getting Started

1. **Open the roadmap** — `learning/03-tools/sql-roadmaps/sql-learning-roadmap-3months.md`.
2. **Open a practice database** in VSCode with the SQLite extension (e.g. `data/sql-learn-db-week6.db` or `learning/03-tools/sql-mastery/datasets/sales-records.db`).
3. **Start a session** — say "continue learning" to get your current position and next topic, then learn and practice in conversation.
4. **Save your progress** — say "summarize" (or "rangkuman") to persist the session as a structured note and see the updated progress report.

## Prerequisites

- **SQLite3** — practice database engine (`sqlite3 --version`)
- **VSCode** — with SQLite Viewer / SQLite extensions
- **opencode** — for the `sql-learning` skill and `openspec-agent` planning workflow

## Related Roadmaps

- `learning/01-de-roadmap/data-engineering-roadmap-6months.md` — broader data engineering path
- `learning/02-ai-based-business-roadmap/ai-business-reporting-roadmap.md` — AI-assisted business reporting path
