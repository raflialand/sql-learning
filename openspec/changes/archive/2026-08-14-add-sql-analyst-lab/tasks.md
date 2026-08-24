# Add SQL Analyst Lab — Implementation Tasks

## Phase 1: Skeleton + Track

### Step 1.1: Create the module README

Create `learning/02-sql-learning/sql-analyst-lab/README.md`: module purpose (next level after sql-skill-push), the 4-step framework summary cross-linked to `learning/04-data-to-insight/data-to-insight.md` (include the Running Log pro-tip), dataset reuse map (case → which .db), how-to-use (read dataset README + ERD → read case.md → work in work/ → verify), verification model (SQL exact-match via `_tools/run_query.py` + text rubric + optional `@query-inspector` usage note: learner copies work/ queries to `script/01-sql/` and runs `@query-inspector`), and the track registration note (`analyst`, 3 Case units).

**Verification**: File exists; references `learning/04-data-to-insight/data-to-insight.md`, all three dataset `.db` paths by relative path, and `learning/00-notes/05-analyst-lab/`.

### Step 1.2: Create the analyst notes directory

Create `learning/00-notes/05-analyst-lab/README.md` following the `learning/00-notes/04-sql-push/README.md` convention: how-to-use, `session-summary-<DD-MMM-YYYY>.md` template, progress snapshot table with 3 Case rows.

**Verification**: File exists with the session template and a 3-row snapshot table (Case 01/02/03, unit label Case).

### Step 1.3: Register the analyst track

Edit `learning/00-notes/tracks.md`:
- **Old**: `| de | Data Engineering | learning/01-de-learning/data-engineering-roadmap-6months.md | learning/00-notes/01-de-progress/ | 26 | Week |`
- **New**: same line plus `\n| analyst | Data-to-Insight Case Studies | learning/02-sql-learning/sql-analyst-lab/README.md | learning/00-notes/05-analyst-lab/ | 3 | Case |`

**Verification**: `tracks.md` has exactly 5 rows; the analyst row matches the approved format.

## Phase 2: Case 01 — Brew & Co. (retail.db)

### Step 2.1: Create the case folder and brief

Create `learning/02-sql-learning/sql-analyst-lab/01-brew-and-co/case.md` (main question "How is sales performance, and where should we focus next month?"; dataset pointer to `datasets/01-beginner/README.md` — business context + Mermaid ERD, not duplicated).

**Verification**: File exists and points to the dataset README.

### Step 2.2: Author scope + questions

Create `expected/01-scope.md` (suggested metrics revenue/order count/AOV; dimensions store/category/month) and `expected/02-questions.md` (map the 4 buckets to concrete sub-questions, including the underperforming-product KPI "why").

**Verification**: 01-scope.md lists ~3 metrics + ~3 dimensions; 02-questions.md covers all 4 buckets.

### Step 2.3: Author and execute the ~6 model queries

Author `expected/03-queries.sql` for SQLite (use `strftime` for month grouping), run through `python learning/02-sql-learning/sql-skill-push/_tools/run_query.py ../../sql-skill-push/datasets/01-beginner/retail.db expected/03-queries.sql` — one query per sub-question.

**Verification**: All queries execute without SQL errors; output row counts are recorded from real execution.

### Step 2.4: Capture verified results + insight

Write `expected/03-results.md` from the real execution output (sample rows + "(N rows)" / "(N rows total; M shown)" convention) and `expected/04-insight.md` using the weak-vs-strong standard + a short Running Log excerpt. Create `work/.gitkeep`.

**Verification**: 03-results.md matches the executed output exactly; 04-insight.md contains at least one strong insight and a Running Log excerpt.

## Phase 3: Case 02 — MarketHub (ecommerce.db)

### Step 3.1: Create the case folder and brief

Create `learning/02-sql-learning/sql-analyst-lab/02-markethub/case.md` (main question "How is the marketplace performing, and which vendor/segment should we invest in next?"; dataset pointer to `datasets/02-intermediate/README.md`).

**Verification**: File exists and points to the dataset README.

### Step 3.2: Author scope + questions

Create `expected/01-scope.md` (metrics/dimensions still suggested: GMV, AOV, repeat purchase rate × country, category, month, payment method; **fix the repeat-purchase-rate definition here**) and `expected/02-questions.md` (bucket mapping left partially open).

**Verification**: 01-scope.md fixes the repeat-purchase-rate definition; 02-questions.md covers all 4 buckets with some mapping left to the learner.

### Step 3.3: Author and execute the ~8 model queries

Author `expected/03-queries.sql` for SQLite, run against `../../sql-skill-push/datasets/02-intermediate/ecommerce.db`. Include MoM AND YoY (compare Jan-2025 vs Jan-2026 — supported here) and a payment-failure KPI "why" query (payments table status).

**Verification**: All queries execute without SQL errors; output row counts are recorded from real execution.

### Step 3.4: Capture verified results + insight

Write `expected/03-results.md` from real execution output and `expected/04-insight.md` (strong insights + recommendations). Create `work/.gitkeep`.

**Verification**: 03-results.md matches executed output; repeat-purchase-rate query output is consistent with the fixed definition.

## Phase 4: Case 03 — NovaTel (telecom.db)

### Step 4.1: Create the case folder and brief

Create `learning/02-sql-learning/sql-analyst-lab/03-novatel/case.md` (main question "Is the subscriber base healthy, and where is revenue leaking?"; dataset pointer to `datasets/03-advanced/README.md`; **state the NO-YoY limitation explicitly** — billing spans only 2025-12-01 and 2026-01-01).

**Verification**: case.md states the no-YoY limitation.

### Step 4.2: Author scope + questions

Create `expected/01-scope.md` (learner derives metrics: revenue, active subscribers, avg data usage; dimensions: plan, state, month, usage tier) and `expected/02-questions.md`.

**Verification**: 01-scope.md derives metrics/dimensions; 02-questions.md covers all 4 buckets.

### Step 4.3: Author and execute the ~8 model queries

Author `expected/03-queries.sql` for SQLite, run against `../../sql-skill-push/datasets/03-advanced/telecom.db`. Include: revenue-by-plan (Overall Trends), MoM revenue/ARPU Dec→Jan (Growth Rates — **NO YoY anywhere**), ARPU by plan (Performance Measurement), churn-by-plan/region "why" using churn + tickets tables, and at least one dimension dug deeper (KPI Reporting).

**Verification**: All queries execute without SQL errors; output row counts recorded; no query references a YoY comparison.

### Step 4.4: Capture verified results + insight

Write `expected/03-results.md` from real execution output and `expected/04-insight.md` (strong insights + recommendations). Create `work/.gitkeep`.

**Verification**: 03-results.md matches executed output; 04-insight.md stays within the MoM-only limitation.

## Phase 5: Full Verification + Docs

### Step 5.1: Re-run every expected query file

Re-run all 3 `expected/03-queries.sql` files against their `.db` files and assert outputs match their `03-results.md`.

**Verification**: 3 files × 0 failures; outputs identical.

### Step 5.2: Assert sql-skill-push untouched

Run `git status --short` scoped to `learning/02-sql-learning/sql-skill-push/`.

**Verification**: No changes under `learning/02-sql-learning/sql-skill-push/` (byte-identical reuse).

### Step 5.3: Update the root README

Edit `README.md`:
- intro line adds the module;
- "What This Is" extends the deep-dive modules bullet (`sql-analyst-lab/` 3 case studies) and the track list bullet (now "Five registered learning tracks" incl. Data-to-Insight Case Studies 3 cases);
- directory map adds `sql-analyst-lab/` under `learning/02-sql-learning/` and `05-analyst-lab/` under `learning/00-notes/`;
- Getting Started adds an analyst-lab step;
- Related Roadmaps adds `learning/02-sql-learning/sql-analyst-lab/README.md`.

**Verification**: README.md contains the new module in all five locations.

### Step 5.4: Append the changes-log entry

Append `change #16: add Data-to-Insight Case Studies module + register analyst track (14-Aug-2026)` to `changes-log.txt` following the established style (module tree + 3 cases, dataset reuse without copies, 05-analyst-lab notes dir, tracks.md analyst row, verification summary: 3 cases / ~22 queries executed / 0 failures / sql-skill-push untouched, docs updates).

**Verification**: Entry appended; style matches previous entries.

## Summary of Changes

| Category   | Before            | After             |
| ---------- | ----------------- | ----------------- |
| Module     | (none)            | `learning/02-sql-learning/sql-analyst-lab/` — CREATED (README + 3 cases with case.md, expected/, work/) |
| Case 01    | (none)            | `01-brew-and-co/` — CREATED (~6 verified queries on retail.db) |
| Case 02    | (none)            | `02-markethub/` — CREATED (~8 verified queries incl. MoM + YoY on ecommerce.db) |
| Case 03    | (none)            | `03-novatel/` — CREATED (~8 verified queries, MoM only, on telecom.db) |
| Track registry | 4 rows         | `learning/00-notes/tracks.md` — MODIFIED (analyst row, 3 Case units) |
| Notes dir  | (none)            | `learning/00-notes/05-analyst-lab/` — CREATED (README + session template) |
| README     | 4 tracks, no lab  | `README.md` — MODIFIED (module, 5 tracks, map, getting started, roadmaps) |
| Changes log | #15 last          | `changes-log.txt` — MODIFIED (change #16) |
| Delta spec | (none)            | `openspec/changes/2026-08-14-add-sql-analyst-lab/specs/sql-analyst-lab/spec.md` — CREATED (ADDED) |
| Canonical spec | (none)         | `openspec/specs/sql-analyst-lab/spec.md` — CREATED at archive time from delta (not in tasks) |
