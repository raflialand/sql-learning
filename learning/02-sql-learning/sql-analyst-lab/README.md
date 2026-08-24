# SQL Analyst Lab — Data-to-Insight Case Studies

The **next level beyond `sql-skill-push`**. Skill Push taught you to reproduce exact results for 60 closed-ended challenges. This lab teaches the opposite discipline: taking **one ambiguous business question**, narrowing scope before touching data, decomposing it into sub-questions, writing multiple SQL queries to answer each one, and surfacing **strong insights with recommendations**.

## The 4-Step Framework

Every case follows the framework in [`learning/04-data-to-insight/data-to-insight.md`](../../../04-data-to-insight/data-to-insight.md) (video: "Think Like a Senior Data Analyst", Christine Jiang):

1. **Identify Northstar metrics + dimensions** — pick ~3 metrics (numbers that measure performance) and ~3 dimensions (qualitative ways to slice) *before* touching the data.
2. **Break the ambiguous question into smaller questions** — classify sub-questions into the four buckets:
   - **Overall Trends** — seasonality, patterns, segmentation, summary stats.
   - **Growth Rates** — MoM / YoY changes as a metric itself.
   - **Performance Measurement** — comparing segments.
   - **KPI Reporting** — not just the static number, but *why* it's at that level (dig one dimension deeper).
3. **Investigate the "why" with SQL** — one query per sub-question: a **metric sliced by a dimension**.
4. **Surface insights and recommendations** — strong insight = trend + fluctuation + anomaly + root cause + recommendation. Weak insight = "X is higher than Y. It's working."

**Pro-tip — the Running Log:** as you explore, continuously write down the big question, the derived sub-questions, immediate findings, and root causes. Your final summary builds itself as you work.

## Cases & datasets

The lab **reuses** the three verified datasets from `sql-skill-push` **read-only** — nothing is copied or regenerated. Read the dataset README (business context + Mermaid ERD) before starting each case.

| Case | Folder | Dataset | Business | Scaffolding |
| --- | --- | --- | --- | --- |
| Case 01 | `01-brew-and-co/` | `../sql-skill-push/datasets/01-beginner/retail.db` | Brew & Co. coffee shop (3 stores) | Highest — metrics/dimensions/buckets suggested |
| Case 02 | `02-markethub/` | `../sql-skill-push/datasets/02-intermediate/ecommerce.db` | MarketHub marketplace (8 tables) | Medium — metrics/dimensions suggested, bucket mapping partially open |
| Case 03 | `03-novatel/` | `../sql-skill-push/datasets/03-advanced/telecom.db` | NovaTel telecom carrier (7 tables) | Minimal — you derive metrics/dimensions |

## How to use

1. **Read the dataset README + ERD** — e.g. `../sql-skill-push/datasets/01-beginner/README.md`. Understand the business, tables, join hints, and data quirks. The case brief points there instead of duplicating context.
2. **Read `case.md`** — one open-ended main question, the dataset pointer, and any dataset limitation notes.
3. **Work in `work/`** — draft your scope, sub-questions, queries, and insights. The `expected/` folder holds a model answer: `01-scope.md` (fixed metrics/dimensions), `02-questions.md` (bucket mapping), `03-queries.sql` (model queries), `03-results.md` (verified output), `04-insight.md` (strong insight example). Use `expected/` to check yourself — but write your own first.
4. **Verify** — run your queries and compare against `03-results.md`.

## Verification model

- **SQL exact-match:** execute the model queries (or your own) with the shared helper:
  ```bash
  python ../sql-skill-push/_tools/run_query.py ../sql-skill-push/datasets/01-beginner/retail.db 01-brew-and-co/expected/03-queries.sql
  ```
  The helper prints markdown-preview rows + total count in the same `(N rows)` / `(N rows total; M shown)` convention used by Skill Push challenges.
- **Text rubric:** insights are graded against the weak-vs-strong standard (trend + fluctuation + anomaly + root cause + recommendation), not by exact text.
- **Optional `@query-inspector` review:** copy your `work/` queries into `script/01-sql/` and run `@query-inspector` to get a second opinion on query-logic correctness and business-requirement alignment. This is an optional usage note — the lab does not require it.

## Track registration

This module is a registered learning track. `learning/00-notes/tracks.md` row:

| id | name | roadmap | notes dir | total units | unit label |
| --- | --- | --- | --- | --- | --- |
| analyst | Data-to-Insight Case Studies | learning/02-sql-learning/sql-analyst-lab/README.md | learning/00-notes/05-analyst-lab/ | 3 | Case |

Session notes go in `learning/00-notes/05-analyst-lab/` (see its README for the session-summary template and progress snapshot table). Track your progress with the `learning-progress` skill: `progress analyst`, `summarize analyst`.
