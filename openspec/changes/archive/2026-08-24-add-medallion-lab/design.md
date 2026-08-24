# Add Medallion Lab — Design

## Overview

The change adds a new **service/operation capability** — `medallion-lab` — a repeatable Medallion architecture pipeline that materializes three layered SQLite databases (`data/medallion/bronze.db`, `silver.db`, `gold.db`) from the read-only MarketHub source `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce.db`. A Python orchestrator (`script/02-python/medallion_pipeline.py`, stdlib-only: `sqlite3` + `ATTACH DATABASE`) executes three per-layer SQL scripts under `script/01-sql/medallion/` in order, printing stage summary tables, running the gold stage twice to prove idempotency, and enforcing row-count and no-data-loss assertions. The capability is documented end-to-end in `learning/05-dwh-architecture/medallion-case.md` (mapping + Mermaid lineage + trade-offs), hosted in the new dedicated non-track DWH module `learning/05-dwh-architecture/` (module home: `README.md`), and maps onto the DE roadmap's Week 3 (star schema) and Week 4 (raw → staging → analytics pipeline) content.

Because this is a service/operation capability (an ETL pipeline), the delta spec's ADDED requirements are structured around the `service-capability-template` contracts (Input Contract, Output Contracts, Orchestrator/Execution, Failure Behavior, Quality Acceptance Criteria, Cross-Capability Dependency). At archive time the canonical spec is created from these ADDED requirements following that template.

## Design Decisions

### Decision 1: New capability `medallion-lab`, not an extension of `sql-analyst-lab`

**Choice**: Create a new capability folder `medallion-lab` with its own spec. Do not extend `sql-analyst-lab`.
**Rationale**: The two capabilities have different contracts. `sql-analyst-lab` is a read-only analytical query module (4-step framework, one SQL query per sub-question, `run_query.py`, insights rubric). `medallion-lab` is a materializing ETL pipeline (Python orchestrator, CTAS, ATTACH, layered DB files, star schema, marts, assertions). Mixing them would blur both contracts and force a MODIFIED delta on a spec whose scope is intentionally read-only analysis.

### Decision 2: Three separate `.db` files connected via ATTACH (user-approved)

**Choice**: Layer storage = `data/medallion/bronze.db`, `data/medallion/silver.db`, `data/medallion/gold.db`; the orchestrator connects them with `ATTACH DATABASE` so cross-layer SQL scripts can reference `bronze.`/`silver.`/`gold.` schema aliases.
**Rationale**: Mirrors real Medallion implementations where layers are physically separated, forces explicit cross-DB joins (a real DE skill), and makes the bronze→silver→gold boundary visible in the file tree. It is also the user-approved decision — kept as-is.

### Decision 3: Python stdlib only, no new dependencies

**Choice**: The orchestrator uses only `sqlite3` (and `os`/`sys`) — no third-party packages, no `run_query.py` dependency.
**Rationale**: Keeps the case zero-cost and runnable anywhere Python 3 ships, consistent with the project's $0 tools discipline. The existing `_tools/run_query.py` is a verification helper for exact-match query output; this pipeline needs script execution + assertions + ATTACH, which stdlib `sqlite3` provides directly.

### Decision 4: Bronze = CTAS raw copies with audit columns (immutability proof)

**Choice**: `01-bronze.sql` creates 8 `bronze_<name>` tables via `CREATE TABLE ... AS SELECT` from the source, adding `_ingest_ts` (TEXT ingestion timestamp) and `_source_table` (TEXT source table name). The orchestrator asserts each bronze table's row count equals the source table's row count (16/14/120/500/2800/7102/2283/1864).
**Rationale**: Raw-layer immutability is the core Medallion guarantee; the row-count assertion is the measurable proof. Audit columns trace provenance, a DQ-lineage habit the DE roadmap rewards.

### Decision 5: Silver = one row per source row + explicit DQ flags

**Choice**: `02-silver.sql` produces 8 `silver_<name>` tables with the same grain as the source, applying the approved DQ work: normalized status enums; `DECIMAL(10,2)` money; `is_valid_order` (Cancelled excluded); `has_payment` (517 no-payment orders); payment-completeness vs order total; `in_transit` (95 NULL `delivery_date`); `is_active`/`is_discontinued_but_sold` (9 inactive-but-sold products); `parent_cat_name` (categories self-join); customer trim/dedup/`full_name`; vendor country standardization; `line_revenue = quantity*unit_price` in order_items; and a `_quality_issues` comma-delimited column per row.
**Rationale**: "One row per source row" keeps silver auditable against bronze (row-count equality), while the flags and `_quality_issues` column make every DQ decision visible and queryable — the DQ discipline from the `dq` track applied in a pipeline setting.

### Decision 6: Gold = DE-roadmap star schema + two marts, idempotent

**Choice**: `03-gold.sql` creates `dim_customer` (from deduplicated silver customers), `dim_product`, `dim_date` (generated over the source order-date range — not a source table), `fact_order_items` (line grain, 7,102 rows), `fact_orders` (order grain, 2,800 rows, one per source order), `mart_vendor_performance`, and `mart_daily_revenue`. The orchestrator drops and rebuilds gold tables on each run and runs the gold stage **twice**, asserting the second run yields identical row counts.
**Rationale**: This is the exact shape the DE roadmap teaches in Week 3 (dims + fact_orders) and Week 4 (daily_revenue + product/vendor performance analytics tables). Running gold twice proves idempotency — a realistic pipeline expectation.

### Decision 7: No track registration — maps onto the existing `de` track

**Choice**: Do not add a row to `learning/00-notes/tracks.md` and do not create a new notes dir. The medallion case is an exercise inside the DE roadmap's Weeks 3–4 project, which the `de` track (26 Week units) already covers.
**Rationale**: Adding a unit would change the `de` registry total and break progress math; adding a new track for a single case would be overkill and diverges from the sql-analyst-lab precedent only because that module was a *new module* with 3 cases. The mapping doc cross-links to the DE roadmap instead.

### Decision 8: Dedicated non-track DWH module `learning/05-dwh-architecture/`

**Choice**: Create a new non-track learning module `learning/05-dwh-architecture/` containing `README.md` (module home — what the module is, what it covers, pointers to the case doc and the DE roadmap) and `medallion-case.md` (dataset profile, layer mapping, Mermaid lineage, DQ decisions, trade-offs, DE-roadmap mapping).
**Rationale**: Medallion / star-schema / lineage content is DWH architecture content, not the data-to-insight analyst-framework content that owns `04-data-to-insight/`; a dedicated numbered module (`05`) matches the `01-de-learning` / `03-dq-learning` / `04-data-to-insight` convention. It is deliberately NOT a registered track, per the `04` precedent and because the case maps onto the existing `de` track (Weeks 3–4). The module also gives future DWH topics (SCD, Kimball/Inmon, lakehouse) a home. The doc cross-links to `data-engineering-roadmap-6months.md` and the dataset README.

## Target Structure

```
script/02-python/medallion_pipeline.py              ← CREATED: stdlib orchestrator (ATTACH chains, per-layer script execution, stage summaries, gold idempotency run, assertions)
script/01-sql/medallion/01-bronze.sql               ← CREATED: 8 CTAS raw copies + _ingest_ts/_source_table audit cols
script/01-sql/medallion/02-silver.sql               ← CREATED: 8 cleaned tables, 1 row/source row, DQ flags, _quality_issues
script/01-sql/medallion/03-gold.sql                 ← CREATED: dim_customer/dim_product/dim_date + fact_order_items (7,102) + fact_orders (2,800) + mart_vendor_performance + mart_daily_revenue
learning/05-dwh-architecture/README.md                ← CREATED: module home (what the module is, what it covers, pointers to the case doc and the DE roadmap)
learning/05-dwh-architecture/medallion-case.md        ← CREATED: mapping doc (dataset profile, layer mapping, Mermaid lineage, DQ notes, trade-offs, DE-roadmap mapping)
data/medallion/bronze.db                            ← CREATED (generated by end-to-end run)
data/medallion/silver.db                            ← CREATED (generated by end-to-end run)
data/medallion/gold.db                              ← CREATED (generated by end-to-end run)
README.md                                           ← MODIFIED: intro, What This Is, directory map (learning/05-dwh-architecture + script/01-sql/medallion + script/02-python + data/medallion), Getting Started, Related Roadmaps
changes-log.txt                                     ← MODIFIED: append change #18
openspec/changes/add-medallion-lab/specs/medallion-lab/spec.md  ← CREATED: delta spec (ADDED requirements)
openspec/specs/medallion-lab/spec.md                ← CREATED at archive time from delta (not in tasks.md)
```

## Edge Cases

- **517 orders have no payment row**: silver marks them `has_payment = 0` and records the gap in `_quality_issues`; gold facts and marts treat them as valid-but-unpaid (they are not Cancelled) and the mapping doc explains the business interpretation.
- **95 shipments with `delivery_date IS NULL`**: silver sets `in_transit = 1` instead of fabricating a delivery date; marts that measure fulfillment (not in this change's two marts, but future ones) can filter on the flag.
- **9 inactive-but-sold products**: silver sets `is_active` from the source and derives `is_discontinued_but_sold` where `is_active = 0` AND the product appears in `order_items`; dim_product keeps all 120 products so historical facts still join.
- **Cancelled orders and the no-data-loss assertion**: `fact_orders` keeps all 2,800 rows (1 per source order, no row loss) with `is_valid_order = 0` for the 456 Cancelled rows; revenue marts filter to Completed+Shipped. The no-data-loss assertion compares the Completed+Shipped `total_amount` sum in gold vs source — proving monetary amounts for revenue orders survived, while Cancelled rows are explicitly excluded from revenue.
- **Gold run twice (idempotency)**: gold tables are dropped and rebuilt on each gold run; the orchestrator runs the gold stage twice and asserts identical row counts — a mismatch means a non-idempotent transform and fails the run.
- **Customer dedup vs one-row-per-source-row**: silver preserves one row per source row; if duplicate `cust_id` rows exist, they are flagged in `_quality_issues` and `dim_customer` is built from deduplicated customers so the dimension key is unique.
- **Source dataset immutability**: every path reference to `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce.db` is read-only; verification asserts `git status --short` shows no changes under `learning/02-sql-learning/sql-skill-push/`.
- **Relative path portability**: the orchestrator resolves the source path relative to the repo root so it runs from any working directory.

## Affected Specs

| Spec                                | Change Type              |
| ----------------------------------- | ------------------------ |
| `specs/medallion-lab/spec.md`       | ADDED (new capability)   |
| `specs/sql-analyst-lab/spec.md`     | no delta (different capability, read-only) |
| `specs/learning-progress/spec.md`   | no delta (no track registration) |
| `specs/query-inspector/spec.md`     | no delta (usage note only) |
