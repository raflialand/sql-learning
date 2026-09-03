# Directory Reorganization Plan — sql-learning

**Date:** 2026-08-31  
**Status:** Pure plan (executable anytime)  
**Location:** `learning/00-notes/00-personal-discuss/directory-reorganization-plan.md`

---

## Executive Summary

This plan reorganizes the `sql-learning` directory to eliminate structural drift, centralize datasets under one canonical naming scheme, and make the rules durable + machine-enforced so future files/folders conform automatically.

---

## Target Structure

### `data/` (centralized, renamed)
```
data/
├── 00-data-creation/      library.sql · sqllearn.sql · sqllearn-week6.sql
├── 01-practice/           library.db · sqllearn.db · sqllearn-week6.db · <ecommerce.db resolved>
├── datasets/
│   ├── brewco/            brewco.sql · brewco_pg.sql · brewco.db
│   │                      brewco_silver.sql · brewco_gold.db · brewco_gold.csv · README.md
│   ├── markethub/         markethub.sql · markethub_eda.sql · markethub_pg.sql
│   │                      markethub.db · README.md
│   ├── novatel/           novatel.sql · novatel_pg.sql · novatel.db · README.md
│   └── salesrecords/      salesrecords.sql · salesrecords.db
└── medallion/             markethub_bronze.db · markethub_silver.db · markethub_gold.db
```

### `learning/00-notes/` (SQL consolidated)
```
00-notes/
├── tracks.md
├── 00-personal-discuss/
├── 01-de-progress/
├── 02-sql-progress/
│   ├── roadmap/           (was flat 02-sql-progress)
│   ├── skill-push/        (was 04-sql-push)
│   └── analyst-lab/       (was 05-analyst-lab)
└── 03-dq-progress/
```

### `learning/02-sql-learning/sql-roadmaps/` (flattened)
All 7 weeks at root alongside `sql-learning-roadmap-3months.md`.

### New files
- `NAMING.md` (repo root) — canonical naming rules
- `learning/README.md` — landing index (track → module → notes → dataset)
- `docs/04-progress-evaluator/` — create; standardize `verification.md` / `verification-<YYYY-MM-DD>.md`
- `agent-blueprints/02-query-inspector.txt` → `.md`
- `openspec/specs/naming-conventions/spec.md` — new capability spec

---

## Naming Rules (canonical, enforced)

| Rule | Format | Applies to |
|---|---|---|
| Ordered folders | `NN-name` (age-order, zero-padded, sticky number) | `learning/`, `docs/`, `script/`, `data/`, `agent-blueprints/` |
| Special folders/files | `00-name` (non-time-based) | `00-notes`, `00-personal-discuss`, `00-data-creation`, `00-query-log` |
| Dataset families | `{business}{_dialect}{_layer}.{ext}` | all DBs/DDL |
| Session notes | `session-summary-{dd}-{month}-{yyyy}.md` (lowercase month) | progress notes |
| Dated reports | `<name>.md` → `<name>-<YYYY-MM-DD>.md` (never overwrite) | agent outputs |
| Pipeline artifacts | `01-scope.md`…`04-insight.md`; `_silver.sql`/`_gold.sql` (underscore = working) | case `work/` |
| Agent/skill/blueprint files | kebab-case, all `.md` | `.opencode/`, `agent-blueprints/` |
| Invariants | lowercase, no spaces, unique base name per scope; `_` = temporary, `NN-` = ordered, `00-` = special | everywhere |

Suffix vocabulary: `_pg` = PostgreSQL (none = MySQL), `_bronze`/`_silver`/`_gold` = medallion layers (none = raw), `.db`/`.sql`/`.csv` = format.

---

## Execution Steps

### 1. Create `NAMING.md` + wire references
- Create `NAMING.md` at repo root
- Add pointer in `AGENTS.md` (Key Rules + Directory Write Rules)
- Add `naming-conventions` spec in `openspec/specs/`

### 2. Landing index
- Create `learning/README.md` with track → module → notes → dataset table

### 3. Consolidate SQL notes
- Create `02-sql-progress/{roadmap,skill-push,analyst-lab}/`
- Move session summaries into respective subdirs
- Update `tracks.md` notes-dir paths
- Update the 3 notes-dir READMEs

### 4. Flatten roadmap weeks
- Move weeks 1–4 from `month-1-sql-learning/` to `sql-roadmaps/` root
- Remove empty `month-1-sql-learning/`

### 5. Centralize datasets → `data/datasets/`
- Create `data/datasets/{brewco,markethub,novatel,salesrecords}/`
- Move & rename:
  - `sql-skill-push/datasets/01-beginner/retail.*` → `brewco/brewco.*`
  - `sql-skill-push/datasets/02-intermediate/ecommerce.*` → `markethub/markethub.*`
  - `sql-skill-push/datasets/03-advanced/telecom.*` → `novatel/novatel.*`
  - `sql-mastery/datasets/sales-records.*` → `salesrecords/salesrecords.*` (de-dup)
- Rename `data/*.db` to match DDL (resolve orphan `ecommerce.db` via Python `sqlite3`)
- Move medallion outputs to `markethub_{bronze,silver,gold}.db`

### 6. Code edits
| File | Change |
|---|---|
| `script/02-python/medallion_pipeline.py` | `SOURCE_DB` → `data/datasets/markethub/markethub.db`; OUT_DIR DBs → `markethub_{bronze,silver,gold}.db` |
| `sql-skill-push/_tools/generate_datasets.py` | `DATA_DIR` → `data/datasets/`; folder names → `brewco/markethub/novatel`; base names → `brewco/markethub/novatel` |
| `script/01-sql/data-to-insight/00-bootstrap.sql` | Loader paths → `data/datasets/markethub/markethub_pg.sql`, `data/datasets/novatel/novatel_pg.sql` |

### 7. Spec deltas (MODIFIED requirements)
- `medallion-lab`: source path, `markethub_{bronze,silver,gold}.db`, "read-only from data/datasets/"
- `sql-analyst-lab`: dataset paths → `data/datasets/`, helper path, notes dir → `02-sql-progress/analyst-lab/`
- `data-to-insight`: `markethub_pg.sql`/`novatel_pg.sql`, "read-only from data/datasets/"
- NEW: `naming-conventions` spec

### 8. Reference sweep
- `tracks.md` (data only — no skill/blueprint/spec change)
- `sql-skill-push/` README + challenges + solutions + datasets READMEs
- `sql-analyst-lab/` README + case.md + expected/03-results.md
- `sql-mastery/` README + window-functions files
- `learning/05-dwh-architecture/` medallion-case.md + README.md
- `data/01-data-test/retail-eda-test.sql` → `brewco_eda.sql`
- `.opencode/skills/data-to-insight/` SKILL + README + case-template/ONBOARD.md
- `.opencode/agents/` — add `NAMING.md` pointer
- `agent-blueprints/03-data-to-insight.md`
- `agent-blueprints/02-query-inspector.txt` → `.md`
- `README.md` + `AGENTS.md` directory maps + naming pointer
- Dedupe `changes-log.txt` #20/#21

### 9. Fix dangling refs + de-noise
- Ensure `docs/04-progress-evaluator/` exists
- Editor-exclude `.opencode/node_modules`
- Archive `agent-blueprints/demo-prompt/`

### 10. Verification
- `run_query.py` all 60 skill-push solutions + 22 analyst-lab queries → identical results
- `medallion_pipeline.py` re-run → exit 0
- `generate_datasets.py` re-run → identical `.sql`+`.db`
- `@openspec-agent` validates all paths against `NAMING.md`

### 11. Docs
- Update `README.md`, `AGENTS.md` maps
- Add `changes-log.txt` entry

---

## OpenSpec Flow

1. Delegate to `@openspec-agent` with this brief
2. It writes `openspec/changes/<id>/` (proposal.md, design.md, tasks.md, spec deltas)
3. **Pauses for approval** before any move/edit outside `openspec/changes/<id>/`
4. On approval → executes all steps, verifies, archives, logs in `changes-log.txt`

---

## Decisions Locked

| Decision | Outcome |
|---|---|
| Dataset base names | **Branded**: `brewco` / `markethub` / `novatel` / `salesrecords` |
| Medallion layer representation | **Suffix + per-dataset folder**: `markethub_bronze.db` in `data/medallion/` |
| `data/ecommerce.db` (orphan) | Runtime resolution via Python `sqlite3`; de-dup if byte-identical |
| `_tools/` location | **Kept in `sql-skill-push/`**, repoints to `data/datasets/` |
| `sql-learn*.db` hyphens | **Preserved** (kebab-case allowed for non-dataset files) |
| `00-data-creation/` folder | **Preserved as-is** (no rename to `00-creation/`) |
| `data/01-data-test/retail-eda-test.sql` | Renamed to `brewco_eda.sql` (matches `_eda` pattern) |

---

## Notes

- **No manifest re-hash needed** — `learning-progress` is registry-driven (`tracks.md` is data, not definition)
- **Use `git mv`** for all moves/renames to preserve history
- **Verification is mandatory** after any structural change