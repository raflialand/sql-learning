# Add Medallion Lab

## Problem Statement

The Data Engineering track (`learning/01-de-learning/data-engineering-roadmap-6months.md`) teaches star schema design in Week 3 ("Star Schema fundamentals", "E-commerce DW design project: create dim_customers, dim_products, fact_orders"), a **raw → staging → analytics 3-layer pipeline** in the Week 4 project ("Build pipeline: raw → staging → analytics", "Create analytics tables: daily_revenue, customer_ltv, product_performance"), and later the dbt **staging → intermediate → marts** layering in Weeks 5–8. All of this is described in the roadmap, but nothing in the repository turns those concepts into a **concrete, reproducible layered pipeline**.

The learner already owns the verified MarketHub dataset `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce.db` (8 tables; categories 16, vendors 14, products 120, customers 500, orders 2,800, order_items 7,102, payments 2,283, shipments 1,864) with rich, realistic data quirks (456 Cancelled / 1,388 Completed / 476 Shipped / 480 Pending orders; 517 orders with no payment; 95 shipments with `delivery_date IS NULL`; 9 inactive-but-sold products). The `sql-analyst-lab` module analyzes that same dataset with **read-only queries**, but never materializes transformation layers. There is no Medallion architecture (bronze/silver/gold) study case that builds layered, cleaned, analysis-ready databases from a source dataset — which is exactly the DE skill gap the learner wants to close hands-on.

## Proposed Solution

Add a new **repeatable pipeline capability** — `medallion-lab` — a hands-on Medallion architecture study case that builds three layered SQLite databases (`bronze.db`, `silver.db`, `gold.db`) from the read-only MarketHub source, using **Python stdlib only** (`sqlite3` + `ATTACH DATABASE`, zero new dependencies). The capability ships:

- `script/02-python/medallion_pipeline.py` — orchestrator: ATTACH chains, executes the per-layer SQL scripts in order, prints stage summary tables (table → before/after row counts + flags), runs the gold stage twice to prove idempotency, and enforces row-count + no-data-loss assertions.
- `script/01-sql/medallion/01-bronze.sql` — raw CTAS copies of all 8 tables with audit columns (`_ingest_ts`, `_source_table`); bronze row counts SHALL equal source row counts (immutability proof).
- `script/01-sql/medallion/02-silver.sql` — 8 cleaned tables, one row per source row, with DQ flags (`is_valid_order` excludes Cancelled; `has_payment` marks the 517 no-payment orders; payment-completeness vs order total; `in_transit` marks the 95 NULL-delivery shipments; `is_active` / `is_discontinued_but_sold` for the 9 inactive-but-sold products; `parent_cat_name` via categories self-join; customer trim/dedup/full_name; vendor country standardization; `line_revenue = quantity*unit_price`; `_quality_issues` comma-delimited per row).
- `script/01-sql/medallion/03-gold.sql` — DE-roadmap star schema: `dim_customer`, `dim_product`, `dim_date` (generated, not source), `fact_order_items` (line grain, 7,102), `fact_orders` (order grain, 2,800), plus `mart_vendor_performance` and `mart_daily_revenue`.
- `learning/05-dwh-architecture/medallion-case.md` — mapping doc + Mermaid lineage + layer trade-offs, cross-linked to the DE roadmap (Weeks 3–4) and the dataset README, hosted in the new dedicated non-track DWH module `learning/05-dwh-architecture/` (module home: `learning/05-dwh-architecture/README.md`).
- `data/medallion/{bronze,silver,gold}.db` — generated outputs from the end-to-end run.

### Why this is a capability change, not a data/document task

`AGENTS.md` states: "OpenSpec is for project capabilities, not for data or document tasks." The classification question is whether this medallion case adds a durable, repeatable project capability or is a one-off data/document task. The evidence points to **capability**:

1. **It is a repeatable pipeline, not a one-off output.** The orchestrator + per-layer SQL scripts can be re-run end-to-end at any time against the read-only source to reproduce the three layered databases deterministically (with assertions and idempotency checks as part of the contract). A one-off data/document task produces a static artifact once; this change adds the *capability that produces the artifacts* — the pipeline itself is the durable asset.
2. **It has a behavioral contract that needs a spec.** Input contract (read-only source, stdlib-only), output contract (three layers with defined tables/row grains/flags), failure behavior (halt before side effects on missing input, clear failure reasons), quality acceptance criteria (row-count equality, no-data-loss sum check, idempotency), and cross-capability dependencies (reuses the sql-skill-push dataset read-only; maps onto the `de` learning track). These are exactly the SHALL/GIVEN-WHEN-THEN guarantees OpenSpec exists to formalize.
3. **It extends the project's capability surface.** It adds a new script directory (`script/01-sql/medallion/`), a new Python tool (`script/02-python/medallion_pipeline.py`), a new generated-output directory (`data/medallion/`), and a new mapping doc that future cases can reference — mirroring how `add-sql-analyst-lab` was formalized as a capability.
4. **Contrast with a true data/document task.** Writing a single static report, summarizing notes, or generating one analysis file would be execution-domain work (the main agent / `learning-progress` / `query-inspector` domain). Here the deliverable is a *repeatable transformation capability mapped to the DE roadmap*, which the learner will re-run and extend as part of the DE track.

Conclusion: this is a project-capability change and belongs in OpenSpec.

## Scope

### In scope

- Creating the capability skeleton: `script/01-sql/medallion/` (three per-layer SQL scripts) and `script/02-python/medallion_pipeline.py` (orchestrator).
- Authoring and verifying `01-bronze.sql` (8 `bronze_<name>` CTAS tables + audit columns, source row counts preserved), `02-silver.sql` (8 cleaned tables, 1 row per source row, DQ flags, `_quality_issues`), and `03-gold.sql` (star schema: dim_customer / dim_product / dim_date + fact_order_items @ 7,102 + fact_orders @ 2,800 + mart_vendor_performance + mart_daily_revenue).
- Implementing the orchestrator: ATTACH chains across source → bronze → silver → gold, stage summary table printing, gold run twice for idempotency, and the verification assertions (per-layer row counts; gold `fact_orders` `total_amount` sum for Completed+Shipped equals the source `orders` sum — no data loss; end-to-end run with zero assertion failures).
- Running the pipeline end-to-end and generating `data/medallion/{bronze,silver,gold}.db`.
- Creating the `learning/05-dwh-architecture/` non-track module: `README.md` (module home — what the module is, what it covers, pointers to the case doc and the DE roadmap) and `medallion-case.md` (dataset profile, layer mapping, Mermaid lineage, DQ decision notes, trade-offs, DE-roadmap mapping).
- Updating `README.md` (intro, What This Is, directory map, Getting Started, Related Roadmaps) and appending a `change #18` entry to `changes-log.txt`.
- Creating the `medallion-lab` capability spec delta (this change); the canonical spec is created at archive time.

### Out of scope

- Any modification of `learning/02-sql-learning/sql-skill-push/` — the dataset, tools, challenges, and READMEs SHALL remain byte-identical (read-only reuse by relative path, exactly like `sql-analyst-lab`).
- Copying or regenerating the source dataset; the source `.db` is never written.
- Registering a new learning track or modifying `learning/00-notes/tracks.md` — `learning/05-dwh-architecture/` is a non-track module (like `learning/04-data-to-insight/`), the case maps onto the existing `de` track (Weeks 3–4), and no registry row or notes dir is added.
- Changes to the `learning-progress` skill, blueprint, manifest, or spec.
- Changes to the `query-inspector` agent, spec, or contract (optional review of the medallion SQL scripts is documented as a usage note only).
- Creating ADRs or modifying OpenSpec methodology files (`openspec/AGENTS.md`, `openspec/specs/spec-format/`, `openspec/specs/archive-safety/`).
- Modifying archived changes under `openspec/changes/archive/`.
- Making any git commits.

## Capabilities

### New Capabilities

- `medallion-lab`

### Modified Capabilities

- None

## Value Proposition

After this change, the learner can point at the verified MarketHub dataset and **build a complete Medallion pipeline in ~three files**, the same layered discipline the DE roadmap describes for Weeks 3–4 (star schema design) and Weeks 5–8 (staging → intermediate → marts). The case turns abstract DE concepts into concrete, verifiable artifacts: bronze proves immutability by exact row counts, silver documents every data-quality decision against the dataset's known quirks (no-payment orders, NULL deliveries, discontinued-but-sold products), and gold produces the exact star schema shape the roadmap teaches (dims + line-grain and order-grain facts + analytics marts), with an idempotency check that models real pipeline expectations. It is zero-cost (Python stdlib only), fully reproducible, reuses the existing verified dataset without touching it, and gives the learner a portfolio-grade end-to-end pipeline plus a mapping doc that explains the lineage and trade-offs. It also exercises the `de` track's Week 4 project deliverables (star schema, SQL scripts for all tables, lineage documentation) in the repo itself.
