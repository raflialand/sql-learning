# Data Warehouse Architecture — SQL Learning Module

A dedicated, non-track module for studying **data warehouse architecture** — the layered patterns (Medallion, 3-tier, star schema), how data flows from sources to curated marts, and the data-quality discipline applied along the way.

> **Currently inside:** the **Medallion architecture study case** ([`medallion-case.md`](medallion-case.md)) — a hands-on bronze → silver → gold pipeline built on the verified MarketHub dataset with Python stdlib only. More DWH topics (SCD, Kimball vs Inmon, lakehouse) can land here as they are studied.

---

## What's here

| Doc | What it covers |
| --- | --- |
| [`medallion-case.md`](medallion-case.md) | The Medallion study case: dataset profile, layer mapping, Mermaid lineage, DQ decisions, trade-offs, and how it maps to the Data Engineering roadmap |
| `script/01-sql/medallion/` | Per-layer SQL scripts (`01-bronze.sql`, `02-silver.sql`, `03-gold.sql`) |
| `script/02-python/medallion_pipeline.py` | The stdlib orchestrator that runs all three layers end-to-end |
| `data/medallion/` | Generated output: `bronze.db`, `silver.db`, `gold.db` |

## Relationship to other tracks

This module is **not a registered learning track** — it lives outside `learning/00-notes/tracks.md` (like `04-data-to-insight/`). The Medallion case maps onto the existing **Data Engineering** track (`de`), specifically:

- **Week 3** — Star Schema fundamentals, dim_customer / dim_products / fact_orders design
- **Week 4** — raw → staging → analytics 3-layer pipeline, analytics tables
- **Weeks 5–8** — the dbt staging → intermediate → marts layering that the Medallion pattern mirrors

The silver layer is also where the **Data Quality Engineer** track (`dq`) skills show up in a pipeline setting: every cleaning decision becomes an explicit flag.

---

## Run the pipeline

```bash
python script/02-python/medallion_pipeline.py          # bronze → silver → gold, all assertions
python script/02-python/medallion_pipeline.py --stage gold   # rebuild upstream + gold only
```

The pipeline is **idempotent** (gold runs twice, row counts must match), enforces **no-data-loss** (Completed+Shipped revenue sums match source), and **never writes** to the source dataset.
