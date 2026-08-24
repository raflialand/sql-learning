# Spec Deltas for medallion-lab

## ADDED Requirements

### Requirement: Pipeline Input Contract

The system SHALL read the MarketHub source dataset from `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce.db` read-only by relative path, SHALL run with Python standard library only (`sqlite3` + `ATTACH DATABASE`, no third-party dependencies), and SHALL require a resolvable output directory for the three layer databases.

#### Scenario: Valid source dataset and output directory

- GIVEN `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce.db` exists and an output directory is resolvable
- WHEN the pipeline starts
- THEN the pipeline SHALL attach the source database read-only
- AND SHALL proceed to build the bronze layer

#### Scenario: Source dataset missing

- GIVEN the source dataset path does not exist
- WHEN the pipeline is invoked
- THEN the pipeline SHALL halt before creating any layer database
- AND a failure reason SHALL identify the missing source path by name

#### Scenario: Standard-library-only constraint

- GIVEN the pipeline is invoked on an environment with Python but no third-party packages
- WHEN the orchestrator imports its modules
- THEN the pipeline SHALL import only Python standard library modules
- AND SHALL NOT fail due to missing third-party dependencies

### Requirement: Bronze Layer Contract

The system SHALL create `data/medallion/bronze.db` containing 8 raw tables named `bronze_<name>` for the MarketHub tables (categories, vendors, products, customers, orders, order_items, payments, shipments), each built by CTAS from the source with audit columns `_ingest_ts` and `_source_table`, and SHALL preserve the exact source row counts as the immutability proof.

#### Scenario: Bronze layer built from source

- GIVEN the source dataset is attached
- WHEN the bronze layer is built
- THEN `data/medallion/bronze.db` SHALL exist
- AND it SHALL contain exactly 8 `bronze_<name>` tables
- AND each table SHALL include `_ingest_ts` and `_source_table` audit columns

#### Scenario: Bronze row counts equal source row counts

- GIVEN the bronze layer has been built
- WHEN the bronze tables are counted
- THEN `bronze_categories` SHALL have 16 rows, `bronze_vendors` 14, `bronze_products` 120, `bronze_customers` 500, `bronze_orders` 2,800, `bronze_order_items` 7,102, `bronze_payments` 2,283, and `bronze_shipments` 1,864
- AND any mismatch SHALL fail the pipeline with the measured and expected counts reported

#### Scenario: Bronze tables are raw copies

- GIVEN the bronze layer has been built
- WHEN a bronze table is compared to its source table
- THEN every source column and value SHALL be present unchanged
- AND the audit columns SHALL be the only added columns

### Requirement: Silver Layer Contract

The system SHALL create `data/medallion/silver.db` containing 8 cleaned tables named `silver_<name>` with one row per source row, SHALL apply the approved data-quality work (normalized status enums, `DECIMAL(10,2)` money, `is_valid_order`, `has_payment`, payment completeness vs order total, `in_transit`, `is_active`, `is_discontinued_but_sold`, `parent_cat_name`, customer trim/dedup/full_name, vendor country standardization, `line_revenue`), and SHALL record per-row data-quality issues in a `_quality_issues` comma-delimited column.

#### Scenario: Silver layer preserves grain

- GIVEN the bronze layer exists
- WHEN the silver layer is built
- THEN each `silver_<name>` table SHALL contain the same row count as its `bronze_<name>` source
- AND each silver row SHALL correspond to exactly one source row

#### Scenario: Data-quality flags reflect known quirks

- GIVEN the silver layer has been built
- WHEN the quality flags are counted
- THEN `is_valid_order = 0` SHALL count 456 (Cancelled orders)
- AND `has_payment = 0` SHALL count 517 (orders with no payment row)
- AND `in_transit = 1` SHALL count 95 (shipments with NULL `delivery_date`)
- AND `is_discontinued_but_sold = 1` SHALL count 9 (inactive products still present in order_items)

#### Scenario: Quality issues are observable per row

- GIVEN a silver table has quality issues
- WHEN a row is inspected
- THEN the `_quality_issues` column SHALL be NULL when no issue exists
- AND SHALL contain comma-delimited issue tags when one or more issues exist

### Requirement: Gold Layer Contract

The system SHALL create `data/medallion/gold.db` containing the DE-roadmap star schema: `dim_customer`, `dim_product`, and a generated `dim_date` (not sourced from any source table) plus `fact_order_items` at line grain (7,102 rows) and `fact_orders` at order grain (2,800 rows, one per source order), and SHALL materialize `mart_vendor_performance` and `mart_daily_revenue` from the facts.

#### Scenario: Gold layer built from silver

- GIVEN the silver layer exists
- WHEN the gold layer is built
- THEN `data/medallion/gold.db` SHALL contain `dim_customer`, `dim_product`, `dim_date`, `fact_order_items`, `fact_orders`, `mart_vendor_performance`, and `mart_daily_revenue`
- AND `dim_date` SHALL cover the full range of source order dates
- AND `dim_date` SHALL be generated, not copied from a source table

#### Scenario: Fact grains are exact

- GIVEN the gold layer has been built
- WHEN the fact tables are counted
- THEN `fact_order_items` SHALL contain 7,102 rows (one per silver order_items row)
- AND `fact_orders` SHALL contain 2,800 rows (one per silver order)
- AND any mismatch SHALL fail the pipeline with measured and expected counts reported

#### Scenario: Dimensions are unique and complete

- GIVEN the gold layer has been built
- WHEN dimension tables are inspected
- THEN `dim_product` SHALL contain all 120 products
- AND `dim_customer` SHALL contain the distinct customers from silver with a unique dimension key
- AND each fact row SHALL join to exactly one row in each referenced dimension

### Requirement: Orchestrator Execution Contract

The system SHALL run the pipeline stages in order (bronze → silver → gold) through `script/02-python/medallion_pipeline.py`, SHALL connect the layer databases with `ATTACH DATABASE` chains, SHALL print a stage summary table for each layer (table → before/after row counts and flags), and SHALL execute the gold stage twice asserting identical row counts to prove idempotency.

#### Scenario: Ordered end-to-end execution

- GIVEN the pipeline is invoked without a specific stage
- WHEN the orchestrator runs
- THEN the bronze stage SHALL complete before the silver stage
- AND the silver stage SHALL complete before the gold stage
- AND the pipeline SHALL print a stage summary for every layer

#### Scenario: Cross-layer ATTACH connectivity

- GIVEN the pipeline is building a downstream layer
- WHEN the layer scripts execute
- THEN each script SHALL reference upstream tables through attached schema aliases
- AND the pipeline SHALL fail with a clear SQL error if an attached alias is missing

#### Scenario: Gold idempotency proof

- GIVEN the gold stage has completed once
- WHEN the gold stage executes a second time
- THEN every gold table row count from the second run SHALL equal the first run
- AND a count mismatch SHALL fail the pipeline

### Requirement: Verification and Quality Acceptance Criteria

The system SHALL assert measurable quality thresholds during every pipeline run: per-layer row-count equality (bronze = source, silver = bronze, gold = the approved row grains), a no-data-loss check that the gold `fact_orders` `total_amount` sum for Completed+Shipped orders equals the source `orders` sum for the same statuses, and an end-to-end run with zero assertion failures and exit code 0.

#### Scenario: All assertions pass on a clean run

- GIVEN a clean `data/medallion/` state
- WHEN the full pipeline runs
- THEN every row-count assertion SHALL pass
- AND the Completed+Shipped `total_amount` sums SHALL match between gold and source
- AND the process SHALL exit with code 0

#### Scenario: Assertion failure blocks success

- GIVEN a row-count or sum assertion fails during a run
- WHEN the pipeline detects the failure
- THEN the pipeline SHALL report the measured value and the expected threshold
- AND SHALL exit with a non-zero code

#### Scenario: No row loss in facts

- GIVEN the gold layer has been built
- WHEN the pipeline validates completeness
- THEN `fact_orders` SHALL contain 2,800 rows matching the source orders count
- AND the Completed+Shipped `total_amount` sum SHALL be preserved exactly from the source

### Requirement: Failure Behavior

The system SHALL halt before any side effects when the required input is missing, SHALL surface a clear failure reason for any validation or execution failure, and SHALL leave previously written layer databases consistent when a partial failure occurs.

#### Scenario: Halt before side effects on missing input

- GIVEN the source dataset or output directory is missing or invalid
- WHEN the pipeline is invoked
- THEN the pipeline SHALL halt before creating or modifying any layer database
- AND SHALL report the missing input by name

#### Scenario: Partial execution failure leaves layers consistent

- GIVEN a failure occurs during the silver or gold stage after the bronze stage completed
- WHEN the failure is detected
- THEN the pipeline SHALL report which stage completed and which stage failed
- AND SHALL NOT report a successful overall run

#### Scenario: SQL execution error surfaced

- GIVEN a layer SQL script contains an error
- WHEN the orchestrator executes the script
- THEN the pipeline SHALL surface the SQL error with the script path
- AND SHALL stop the run without proceeding to downstream stages

### Requirement: Mapping and Lineage Documentation Contract

The system SHALL provide `learning/05-dwh-architecture/medallion-case.md` documenting the dataset profile, the layer mapping, a Mermaid lineage graph, the data-quality decisions behind each silver flag, the layer trade-offs, and the mapping to the Data Engineering roadmap (Week 3 star schema and Week 4 raw → staging → analytics pipeline), hosted in the dedicated non-track DWH module `learning/05-dwh-architecture/` (module home: `README.md`).

#### Scenario: Mapping doc exists with required sections

- GIVEN the capability is complete
- WHEN `learning/05-dwh-architecture/medallion-case.md` is inspected
- THEN the doc SHALL contain a dataset profile, a layer mapping, a Mermaid lineage graph, data-quality decision notes, trade-offs, and a DE-roadmap mapping section

#### Scenario: Doc cross-links roadmap and dataset

- GIVEN the mapping doc is written
- WHEN the doc references are checked
- THEN the doc SHALL reference `learning/01-de-learning/data-engineering-roadmap-6months.md`
- AND SHALL reference the MarketHub dataset README

#### Scenario: Lineage reflects the actual pipeline

- GIVEN the mapping doc has been authored
- WHEN the lineage graph is compared to the implementation
- THEN the lineage SHALL show source → bronze → silver → gold → marts
- AND SHALL name the actual tables created by each stage

### Requirement: Cross-Capability Dependency

The system SHALL reuse the sql-skill-push MarketHub dataset read-only without modifying the `learning/02-sql-learning/sql-skill-push/` subtree, SHALL map the case onto the existing `de` learning-progress track without registering a new track, and SHALL document the optional `query-inspector` review of the medallion SQL scripts as a usage note without modifying either capability's contracts.

#### Scenario: Dataset reuse is read-only

- GIVEN the pipeline runs against the shared dataset
- WHEN the repository status under `learning/02-sql-learning/sql-skill-push/` is checked
- THEN no changes SHALL appear for that subtree
- AND the source `.db` SHALL be attached read-only

#### Scenario: No new track registration

- GIVEN the capability is added
- WHEN `learning/00-notes/tracks.md` is inspected
- THEN no new track row SHALL be added
- AND the case SHALL be documented as mapping onto the existing `de` track (Weeks 3–4)

#### Scenario: Optional query-inspector review is a usage note only

- GIVEN the medallion SQL scripts live under `script/01-sql/medallion/`
- WHEN the mapping doc describes review options
- THEN the optional `@query-inspector` review SHALL be described as a usage note (learner references `script/01-sql/medallion/*.sql`)
- AND the `query-inspector` agent and spec SHALL NOT be modified

## Boundaries

### In scope

- The three per-layer SQL scripts and the stdlib Python orchestrator.
- Generated layer databases under `data/medallion/`.
- Row-count, no-data-loss, and idempotency assertions.
- The mapping and lineage doc in `learning/05-dwh-architecture/` (module README + `medallion-case.md`).
- Documentation updates and change log entry.
- The `medallion-lab` capability spec delta.

### Out of scope

- Any modification of `learning/02-sql-learning/sql-skill-push/` files or datasets.
- Registering a new learning track or modifying `learning/00-notes/tracks.md`.
- Changes to the `learning-progress` skill, blueprint, manifest, or spec.
- Changes to the `query-inspector` agent or spec.
- Changes to the `sql-analyst-lab` module or spec.
- ADRs, OpenSpec methodology files, and archived changes.

## Related Code

- `script/02-python/medallion_pipeline.py` — orchestrator implementation (to be created)
- `script/01-sql/medallion/01-bronze.sql`, `02-silver.sql`, `03-gold.sql` — layer SQL scripts (to be created)
- `data/medallion/` — generated layer databases (to be created by the end-to-end run)
- `learning/05-dwh-architecture/README.md` — DWH module home (to be created)
- `learning/05-dwh-architecture/medallion-case.md` — mapping + lineage doc (to be created)
- `learning/01-de-learning/data-engineering-roadmap-6months.md` — DE roadmap (Week 3 star schema, Week 4 3-layer pipeline)
- `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/README.md` — MarketHub dataset profile (reused, read-only)
- `learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce.db` — source dataset (reused, read-only)
- `openspec/specs/service-capability-template/spec.md` — contract template used for this capability
- `openspec/specs/spec-format/spec.md` — format contract this spec follows
