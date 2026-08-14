# Add SQL Analyst Lab

**Status: DONE** — tasks executed (22 queries verified, 0 failures), docs updated, archived 14-Aug-2026.

## Problem Statement

The SQL learning path currently ends at `sql-skill-push` — 60 isolated, exact-match challenges across three levels (beginner/intermediate/advanced). Every problem has one correct expected result and a single closed-ended business question. Nothing in the path teaches **open-ended analytical work**: taking an ambiguous business question ("How is sales performance?"), narrowing scope before touching data, decomposing it into sub-questions, writing multiple SQL queries to answer each sub-question, and surfacing strong, decision-ready insights. The notes module `learning/04-data-to-insight/data-to-insight.md` already documents the 4-step analytical framework (Northstar metrics/dimensions → break questions into 4 buckets → one query per sub-question → strong insights + recommendations, plus the Running Log pro-tip), but there is no hands-on module that turns that framework into practice.

## Proposed Solution

Add a new sibling module `learning/02-sql-learning/sql-analyst-lab/` — "Data-to-Insight Case Studies" — the next level beyond `sql-skill-push`. The module reuses the three existing business-profiled SQLite datasets (read-only, by relative path — never copied or regenerated):

- `01-brew-and-co/` — Case 01 on `datasets/01-beginner/retail.db` (Brew & Co., highest scaffolding)
- `02-markethub/` — Case 02 on `datasets/02-intermediate/ecommerce.db` (MarketHub, medium scaffolding)
- `03-novatel/` — Case 03 on `datasets/03-advanced/telecom.db` (NovaTel, minimal scaffolding)

Each case is ONE open-ended main question and follows the 4-step framework: `case.md` (brief + dataset limitation notes) → `expected/01-scope.md` (~3 Northstar metrics + ~3 dimensions chosen before touching data; ambiguous metric definitions fixed) → `expected/02-questions.md` (sub-questions mapped to the 4 buckets: Overall Trends, Growth Rates, Performance Measurement, KPI Reporting) → `expected/03-queries.sql` (one SQL query per sub-question, metric × dimension) → `expected/03-results.md` (captured by executing the model queries) → `expected/04-insight.md` (strong insights + recommendations, weak-vs-strong standard) → `work/` (learner scratch space). Verification uses the existing `_tools/run_query.py` (SQL exact-match) plus a text rubric for insights; an optional `@query-inspector` review is documented as a usage note.

Also: register a new `analyst` learning-progress track (3 Case units) with notes dir `learning/00-notes/05-analyst-lab/`, update `README.md` and `changes-log.txt`, and add the `sql-analyst-lab` capability spec.

## Scope

### In scope

- Creating the module tree `learning/02-sql-learning/sql-analyst-lab/` (README + 3 cases, each with `case.md`, `expected/` = 01-scope.md, 02-questions.md, 03-queries.sql, 03-results.md, 04-insight.md, and `work/`).
- Authoring ~22 model SQL queries across the 3 cases (6 / 8 / 8), executing every one against the reused SQLite datasets, and capturing verified results into each `03-results.md` (real execution output, never guessed row counts).
- Registering the `analyst` track row in `learning/00-notes/tracks.md` and creating `learning/00-notes/05-analyst-lab/` with a README (session template + progress snapshot table with 3 Case rows).
- Updating `README.md` (intro, What This Is, directory map, Getting Started, Related Roadmaps).
- Appending a `change #16` entry to `changes-log.txt`.
- Creating the `sql-analyst-lab` capability spec delta (this change) and canonical spec (at archive time).

### Out of scope

- Any modification under `learning/02-sql-learning/sql-skill-push/` (datasets, tools, challenges, solutions) — the subtree must remain byte-identical.
- Copying, regenerating, or modifying the datasets.
- Changes to the `learning-progress` skill, blueprint, manifest, or spec (track registration is registry-data-only).
- Changes to the `query-inspector` agent, spec, or contract (optional review is only documented as a usage note).
- Creating ADRs or modifying OpenSpec methodology files (`openspec/AGENTS.md`, `openspec/specs/spec-format/`, `openspec/specs/archive-safety/`).
- Modifying archived changes under `openspec/changes/archive/`.
- Making any git commits.

## Capabilities

### New Capabilities

- `sql-analyst-lab`

### Modified Capabilities

- None

## Value Proposition

After this change, the SQL path has a real "analysis capstone" layer: learners move from reproducing exact results to making scoped, question-driven analytical decisions on the same familiar datasets. The module teaches the industry-standard discipline of limiting scope (~3 metrics × ~3 dimensions) before exploring data, decomposing ambiguous questions into the 4 buckets, executing one query per sub-question, and writing strong insights with recommendations — including the honest limitation discipline (e.g. NovaTel has no YoY because billing spans only two months). The new `analyst` track makes the module trackable by `learning-progress` like every other module, and the verified expected results give learners an exact feedback loop without requiring the existing datasets or tooling to change.
