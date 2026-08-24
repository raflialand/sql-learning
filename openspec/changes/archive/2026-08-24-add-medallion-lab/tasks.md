# Add Medallion Lab — Implementation Tasks

## Phase 1: Bronze Layer

### Step 1.1: Author the bronze SQL script

Create `script/01-sql/medallion/01-bronze.sql` — 8 CTAS raw copies from the attached source (`bronze_categories`, `bronze_vendors`, `bronze_products`, `bronze_customers`, `bronze_orders`, `bronze_order_items`, `bronze_payments`, `bronze_shipments`), each with `_ingest_ts` (TEXT ingestion timestamp) and `_source_table` (TEXT source table name) audit columns. The script runs against an attached `bronze` schema alias.

**Verification**: The script contains exactly 8 `CREATE TABLE bronze.bronze_* AS SELECT ...` statements plus 2 audit columns per table; source table names match the MarketHub 8-table set.

### Step 1.2: Scaffold the orchestrator

Create `script/02-python/medallion_pipeline.py` — stdlib-only (`sqlite3`, `os`, `sys`, `datetime`): path resolution relative to repo root, `ATTACH DATABASE` for the source and `data/medallion/bronze.db`, and a `run_bronze()` stage that executes `01-bronze.sql` and prints a stage summary (table → source row count vs bronze row count).

**Verification**: `python script/02-python/medallion_pipeline.py --stage bronze` runs without SQL errors.

### Step 1.3: Assert bronze immutability

Implement the bronze row-count assertion: each `bronze_<name>` row count equals the source table row count (categories 16, vendors 14, products 120, customers 500, orders 2,800, order_items 7,102, payments 2,283, shipments 1,864). Assertion failure prints measured vs expected and exits non-zero.

**Verification**: End-to-end bronze run prints a summary table with 8 rows, all counts matching the source; a deliberately broken count fails the run.

## Phase 2: Silver Layer

### Step 2.1: Author the silver SQL script

Create `script/01-sql/medallion/02-silver.sql` — 8 cleaned tables (`silver_<name>`) at the same grain as the source (1 row per source row) with: normalized status enums; `DECIMAL(10,2)` money columns; `is_valid_order` (excludes Cancelled); `has_payment` (517 no-payment case); payment-completeness vs order total; `in_transit` (95 NULL `delivery_date`); `is_active` and `is_discontinued_but_sold` (9 inactive-but-sold products); `parent_cat_name` via the categories self-join; customer trim/dedup/`full_name`; vendor country standardization; `line_revenue = quantity * unit_price` in order_items; and a `_quality_issues` comma-delimited column per row. The script runs against the attached `bronze` and `silver` schema aliases.

**Verification**: The script contains 8 table builds; each table's grain matches its bronze source; the DQ columns/derivations above are all present.

### Step 2.2: Add the silver stage to the orchestrator

Add `run_silver()` to `script/02-python/medallion_pipeline.py`: ATTACH `bronze.db` and `silver.db`, execute `02-silver.sql`, and print the stage summary (bronze row count vs silver row count per table).

**Verification**: `python script/02-python/medallion_pipeline.py --stage silver` runs after bronze; summary shows silver counts equal to bronze counts for all 8 tables.

### Step 2.3: Assert silver grain and flags

Implement assertions: silver table row counts equal bronze table row counts (one row per source row); DQ flag spot-checks pass — `is_valid_order = 0` count is 456 (Cancelled), `has_payment = 0` count is 517, `in_transit = 1` count is 95, `is_discontinued_but_sold = 1` count is 9; every row's `_quality_issues` is NULL or comma-delimited text.

**Verification**: All spot-check counts match the dataset README quirks; a wrong expected count fails the run.

## Phase 3: Gold Layer

### Step 3.1: Author the gold SQL script

Create `script/01-sql/medallion/03-gold.sql` — star schema from the attached `silver` schema: `dim_customer` (deduplicated, unique key), `dim_product` (all 120 products), `dim_date` (generated over the source order-date range — not a source table, with day/week/month/year/quarter attributes), `fact_order_items` (line grain, one row per silver order_items row, 7,102), `fact_orders` (order grain, one row per silver order, 2,800, with `is_valid_order`), `mart_vendor_performance` (per-vendor revenue/order metrics), `mart_daily_revenue` (per-day revenue from valid revenue orders). Each gold table is dropped and rebuilt on run (idempotent materialization).

**Verification**: Script contains the 7 table builds; dims/facts/marts match the DE-roadmap star schema shape; `dim_date` covers the full order-date range.

### Step 3.2: Add the gold stage with idempotency run

Add `run_gold()` to the orchestrator: ATTACH `silver.db` and `gold.db`, execute `03-gold.sql`, then execute `03-gold.sql` a **second time** and assert the second run's table row counts are identical to the first (idempotency proof). Print the gold stage summary.

**Verification**: Gold stage runs twice; second-run row counts match first-run for all 7 gold tables.

### Step 3.3: Assert gold row counts

Implement assertions: `fact_order_items` = 7,102; `fact_orders` = 2,800; `dim_product` = 120; `dim_customer` = 500 distinct customers; `mart_vendor_performance` = 14 rows; `dim_date` covers min/max source order dates.

**Verification**: All gold assertions pass; a wrong count fails the run.

## Phase 4: Verification + Hardening

### Step 4.1: Add the no-data-loss assertion

Implement: `SUM(total_amount)` over `gold.fact_orders WHERE order_status IN ('Completed','Shipped')` equals `SUM(total_amount)` over the source `orders` for the same statuses — proving no monetary data loss for revenue orders. Also assert `COUNT(*)` in `fact_orders` = 2,800 = source orders count (no row loss).

**Verification**: Both assertions pass on the end-to-end run; temporarily altering a source amount (in a scratch copy only) makes the check fail.

### Step 4.2: Full end-to-end run

Run the complete pipeline from a clean `data/medallion/` state: `python script/02-python/medallion_pipeline.py`. All stages execute, all summaries print, all assertions pass, exit code 0.

**Verification**: Clean-state run completes with zero assertion failures; `data/medallion/{bronze,silver,gold}.db` all exist and open in `sqlite3`.

### Step 4.3: Assert source immutability

Run `git status --short` scoped to `learning/02-sql-learning/sql-skill-push/`.

**Verification**: No changes under `learning/02-sql-learning/sql-skill-push/` — dataset reuse is byte-identical read-only.

## Phase 5: Documentation + Docs Updates

### Step 5.1: Write the DWH module home and the mapping/lineage doc

Create the new non-track module `learning/05-dwh-architecture/`:
- `learning/05-dwh-architecture/README.md` — module home: what this module is (DWH architecture study cases), what it covers, and pointers to `medallion-case.md` and the DE roadmap.
- `learning/05-dwh-architecture/medallion-case.md` — mapping doc: dataset profile (MarketHub, 8 tables, row counts, quirks from the dataset README), layer mapping (bronze/silver/gold → tables + purpose), Mermaid lineage graph (source → bronze → silver → gold → marts), DQ decision notes (each flag and the quirk it addresses), trade-offs (three-DB ATTACH vs single DB, stdlib vs dbt, one-row-per-source-row grain), and a DE-roadmap mapping section (Week 3 star schema + Week 4 3-layer pipeline + Week 5–8 staging→intermediate→marts analogies) cross-linking `learning/01-de-learning/data-engineering-roadmap-6months.md` and the dataset README.

**Verification**: Both files exist under `learning/05-dwh-architecture/`; `README.md` lists the module contents (including `medallion-case.md`); `medallion-case.md` contains the Mermaid lineage, the layer mapping, DQ notes for all documented quirks, and explicit DE-roadmap Week 3–4 references.

### Step 5.2: Update the root README

Edit `README.md`:
- intro line mentions the Medallion lab (Python stdlib pipeline: bronze/silver/gold on the MarketHub dataset);
- "What This Is" adds a medallion-lab bullet under deep-dive modules / a pipeline capability bullet;
- directory map adds `learning/05-dwh-architecture/` under `learning/` (`learning/04-data-to-insight/` stays as-is), `script/01-sql/medallion/` under `script/01-sql/`, a `script/02-python/` entry, and `data/medallion/` under `data/`;
- Getting Started adds a "Build the Medallion pipeline" step (`python script/02-python/medallion_pipeline.py`);
- Related Roadmaps adds `learning/05-dwh-architecture/README.md`.

**Verification**: README.md contains the medallion lab in all five locations; no broken path references.

### Step 5.3: Append the changes-log entry

Append `change #18: add Medallion architecture study case + medallion-lab capability (24-Aug-2026)` to `changes-log.txt` following the established style: script files created (`script/01-sql/medallion/*.sql`, `script/02-python/medallion_pipeline.py`), new DWH module (`learning/05-dwh-architecture/README.md` + `medallion-case.md`), generated outputs (`data/medallion/*.db`), verification summary (bronze counts == source, silver grain == bronze, gold star schema 7 tables, no-data-loss check, gold run twice idempotent, end-to-end 0 failures, sql-skill-push untouched), docs updates (README.md, this log).

**Verification**: Entry appended; style matches previous entries; README + changes-log are the only doc files modified.

## Summary of Changes

| Category       | Before            | After             |
| -------------- | ----------------- | ----------------- |
| SQL scripts    | (none)            | `script/01-sql/medallion/01-bronze.sql`, `02-silver.sql`, `03-gold.sql` — CREATED |
| Orchestrator   | (none)            | `script/02-python/medallion_pipeline.py` — CREATED (ATTACH chains, stage summaries, idempotency run, assertions) |
| Generated data | (none)            | `data/medallion/{bronze,silver,gold}.db` — CREATED by end-to-end run |
| DWH module     | (none)            | `learning/05-dwh-architecture/README.md` + `medallion-case.md` — CREATED (module home + mapping/lineage/trade-offs) |
| README         | no medallion lab  | `README.md` — MODIFIED (intro, What This Is, directory map, Getting Started, Related Roadmaps) |
| Changes log    | #17 last          | `changes-log.txt` — MODIFIED (change #18) |
| Delta spec     | (none)            | `openspec/changes/add-medallion-lab/specs/medallion-lab/spec.md` — CREATED (ADDED) |
| Canonical spec | (none)            | `openspec/specs/medallion-lab/spec.md` — CREATED at archive time from delta (not in tasks) |
