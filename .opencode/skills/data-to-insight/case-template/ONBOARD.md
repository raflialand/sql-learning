# Onboarding a new dataset into the data-to-insight pipeline

Use this template when a new case/dataset should be run through the `data-to-insight` ecosystem.

## What a new dataset needs

1. **A PostgreSQL dataset** (`<name>_pg.sql`) — DDL + INSERT that creates the raw tables. If only MySQL `.sql` or SQLite `.db` exists, produce the `_pg.sql` variant first (see `sql-skill-push/datasets/*/README.md` for the existing pattern).
2. **A dataset README** with:
   - Business context (one short paragraph).
   - A Mermaid `erDiagram` + relationship summary + join hints.
   - Data notes / quirks (row counts, NULLs, statuses, known anomalies) — these drive which DQ dimensions apply.
3. **A case folder** with `case.md` (main question + limitation notes), a `work/` dir, and (optionally) `expected/` model answers as validation ground truth.

## Steps

1. **Load the dataset into Postgres** (bronze schema) using `script/01-sql/data-to-insight/00-bootstrap.sql`:
   ```
   psql -U postgres -d datainsight -v ON_ERROR_STOP=1 -c "SET search_path TO bronze;" \
     -f "<dataset>_pg.sql"
   ```
2. **Scaffold the case** from this template:
   - Copy `case.md.template` → `<case>/case.md` and fill in the main question, dataset pointer, and limitation notes.
   - Ensure `work/` exists.
3. **Run the pipeline**: invoke the `data-to-insight` skill scoped to the case. It walks the 7 stages and pauses for approval at each of the 6 checkpoints.
4. **Validate** against `expected/` (if present) — results, scope, and insight must match the model answers.

## What the pipeline produces (per case `work/`)

| Stage | Artifact |
|---|---|
| 1 Scope | `01-scope.md` |
| 2 Questions | `02-questions.md` |
| 3 Silver | `_silver.sql` |
| 4 Gold | gold mart (grain + unique key declared, uniqueness verified) |
| 5 Query | `03-queries.sql`, `03-results.md` |
| 6 Insight | `04-insight.md` |
