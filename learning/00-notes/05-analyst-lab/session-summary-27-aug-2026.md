# Summary: SQL Analyst Lab Session

**Date:** 27 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 (MarketHub) — via the new `data-to-insight` AI ecosystem. Stage 0 (Context) + Stage 1 (Scope) done & approved; Stage 2 (Questions) decomposed (8 sub-questions), pending write to `02-questions.md`.

---

## Completed

- **Built the `data-to-insight` AI ecosystem** (project capability, change #19) to automate the 7-stage pipeline for Cases 02/03 and any future dataset:
  - Orchestrator skill `.opencode/skills/data-to-insight/SKILL.md` + runbook + `case-template/`.
  - Subagents `.opencode/agents/sql-builder.md` (stages 3–5) + `.opencode/agents/insight-writer.md` (stage 6).
  - Blueprint `agent-blueprints/03-data-to-insight.md` + canonical spec `openspec/specs/data-to-insight/spec.md`.
  - `script/01-sql/data-to-insight/00-bootstrap.sql` + `01-silver-dq-patterns.sql` (6 DQ dimensions).
  - Reuses `query-inspector` as a QA gate; OpenSpec archive deferred until pilot validates.
- **Loaded raw datasets into PostgreSQL** — separate DBs per case: `datainsight_markethub` (bronze: 8 tables, counts 16/14/120/500/2800/7102/2283/1864) and `datainsight_novatel`. Row counts verified.
- **Case 02 — Stage 0 (Context)** absorbed: 8-table marketplace, main question "how is the marketplace performing, and which vendor/segment should we invest in next?", quirks (517 no-payment orders, Failed/Refunded, 95 in-transit, 9 discontinued-but-sold), limitation = MoM **and** YoY both supported.
- **Case 02 — Stage 1 (Scope) written + approved** → `work/01-scope.md`:
  - **Metrics (4):** GMV (Gross Merchandise Value), Order count, AOV, Repeat purchase rate.
  - **Dimensions (4):** Vendor · Country · Category · Month (payment method deferred to KPI drill-down).
  - **Definitions fixed:** fulfilled = `status IN ('Completed','Shipped')`; repeat purchase rate = (≥2 fulfilled ÷ ≥1 fulfilled) **× 100 → %**.
- **Case 02 — Stage 2 (Questions) decomposed** (draft approved, not yet written): 8 sub-questions across the 4 buckets — Q1 GMV×Month, Q2 GMV×Vendor, Q3 GMV×Category, Q4 GMV×Country (Overall Trends); Q5 GMV growth %×Month MoM+YoY (Growth); Q6 AOV×Vendor, Q7 repeat-rate×Vendor (Performance); Q8 bottom-vendor why→product/category/payment drill (KPI).

## Key Takeaways (conceptual this session)

1. **GMV = Gross Merchandise Value** — marketplace top-line ("total money spent buying things"), gross not net (no fees/refunds deducted); the marketplace equivalent of "revenue" but vendors own the inventory.
2. **Repeat purchase rate = the "invest next" signal** — GMV/order/AOV describe *level* (today's sales); repeat rate describes *loyalty* (do buyers return). The invest-next question needs the loyalty metric, not another sales-level metric.
3. **Product is a drill-down, not a dimension** — category/vendor/country are decision-level; product is the leaf (120 rows). Product belongs in the KPI "why" (one layer deeper), same as Case 01's Q6. Avoids "analyze everything by everything".
4. **Pipeline contract (execution mode settled):** I author SQL (`01-scope`, `02-questions`, `_silver`, mart, `03-queries`); the user runs SQL in pgAdmin/psql and pastes output; I capture results and continue. 6 checkpoints (Scope / Questions / Silver / Gold / Queries / Insight). I do NOT read `expected/` until after drafting each artifact.

## Mistakes / Notes

- psql hangs on interactive password prompt (scram-sha-256) → user runs DB commands themselves; password stays out of the conversation.
- GMV metric name first written as bare abbreviation → corrected to "GMV (Gross Merchandise Value)"; repeat-rate definition made explicit "× 100 → percent" after a units question.

## Next Steps

1. **Stage 2 — write `work/02-questions.md`** (8 sub-questions approved) → checkpoint.
2. **Stage 3 — Silver** (`sql-builder`): 6 DQ dimensions, apply effective subset for MarketHub → `_silver.sql` → checkpoint.
3. **Stage 4 — Gold mart**: declare grain + unique key, verify `COUNT(*) = COUNT(DISTINCT grain_key)` → checkpoint.
4. **Stage 5 — Queries + results** (`03-queries.sql`; user runs against `datainsight_markethub`) → `03-results.md` → checkpoint.
5. **Stage 6 — Insight** (`insight-writer`): 5 components + self-check → checkpoint.
6. Then Case 03 (NovaTel), then archive the OpenSpec change once both pilots validate.
