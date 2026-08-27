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

---

# Summary: SQL Analyst Lab Session (continued — Stage 2 Questions finalized & approved)

**Date:** 27 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 — Stage 2 (Questions) COMPLETE & approved: 9 sub-questions locked in `work/02-questions.md`; Stage 3 (Silver) next.

---

## Completed

- **Wrote `work/02-questions.md`** — main question decomposed into **9 sub-questions** across the 4 buckets (approved):
  - Bucket 1 Overall Trends (4): Q1 GMV·Month · Q2 GMV·Vendor · Q3 GMV·Category · Q4 GMV·Country.
  - Bucket 2 Growth Rates (2): Q5 GMV·Month MoM+YoY · **Q6 GMV·Vendor×Month MoM+YoY (vendor momentum)**.
  - Bucket 3 Performance (2): Q7 AOV·Vendor · Q8 Repeat-rate·Vendor.
  - Bucket 4 KPI Reporting (1): Q9 bottom-vendor drill (category/shipment/payment "why").

## Key Takeaways

1. **Why the 4 buckets** — each is a different lens (level / % change / head-to-head snapshot / the "why") and each donates one ingredient to the final insight: Trend → *worth acting*, Growth → *when*, Performance → *where/who*, KPI → *which lever*. Level alone is a weak insight; a strong answer chains all four.
2. **Momentum is the forward-looking invest signal.** Size (GMV), efficiency (AOV), and loyalty (repeat rate) are all backward-looking ("best today"). Vendor momentum (GMV % × Vendor) is the *trajectory* that answers "invest **next**" — a growing $80k vendor outruns a shrinking $100k vendor. That's why Q6 earned a slot.
3. **Renumbered to clean Q1–Q9** (dropped the `Q5b` working label) — sequential numbering preferred over lettered sub-labels.

## Mistakes / Notes

- None (design/discussion session; no queries run).

## Next Steps

1. **Stage 3 — Silver** (`sql-builder`): 6 DQ dimensions, apply effective subset for MarketHub → `_silver.sql` → checkpoint.
2. **Stage 4 — Gold mart**: declare grain + unique key, verify `COUNT(*) = COUNT(DISTINCT grain_key)` → checkpoint.
3. **Stage 5 — Queries + results** (`03-queries.sql`; user runs against `datainsight_markethub`) → `03-results.md` → checkpoint.
4. **Stage 6 — Insight** (`insight-writer`): 5 components + self-check → checkpoint.
5. Then Case 03 (NovaTel), then archive the OpenSpec change once both pilots validate.

---

# Summary: SQL Analyst Lab Session (continued — Stage 3 Silver authored & checkpoint decisions locked)

**Date:** 27 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 — Stage 3 (Silver) authored: `work/_silver.sql` written by `@sql-builder`; 6-DQ evaluation done (4 applied / 2 N/A); 6 open decisions confirmed. **Pending:** user runs `_silver.sql` + pastes verification output, then Stage 4 (gold mart).

---

## Completed

- **`work/_silver.sql` authored** (`@sql-builder`) — builds 8 `silver.cleaned_*` tables, row counts preserved (16/14/120/500/2800/7102/2283/1864), **conform + flag, never drop**.
- **6-DQ evaluation (4 applied / 2 N/A):**
  - Completeness → applied (`in_transit` flag for 95 NULL `delivery_date`)
  - Validity → applied (lowercase `status`/`method`, clean `is_active`)
  - Accuracy → applied (verify `total_amount` vs line-item sum; flag discontinued-but-sold)
  - Consistency → applied (`has_payment`/`has_shipment` flags; cardinality 2283/1864 < 2800)
  - Uniqueness → N/A (all PKs declared); Timeliness → N/A (static snapshot)
- **6 checkpoint decisions confirmed with the user:**
  1. 517 no-payment orders → keep, flagged (not dropped)
  2. 480 Pending orders → keep, excluded from GMV via `is_fulfilled`
  3. 9 discontinued-but-sold → keep, flagged (Q9 needs them)
  4. lowercase canonical status/method → accepted
  5. payments cardinality → verify 1-per-order before joining
  6. shipments cardinality → verify 1-per-order before joining

## Key Takeaways

1. **"Keep + flag, never drop" is the silver principle** — every quirk (no-payment, Pending, discontinued, in-transit) is a legitimate business state. Filtering happens downstream (GMV scope at the gold mart), not by deleting rows.
2. **Where GMV is sourced from decides correctness.** No-payment orders only "ruin" the decision if you build GMV from `payments.amount` (under-counts) instead of `orders.total_amount` + fulfilled filter (correct). Right source → they're excluded from GMV but visible for Q9's payment-health drill.
3. **`is_active=0` is a current state, not a history.** Discontinued-but-sold products have past `order_items` sales; dropping them would delete real revenue. Timeline: sold-while-active, discontinued-later.
4. **Join cardinality = the silent double-count risk.** If any order has >1 payment/shipment row, `orders JOIN payments` duplicates the order and inflates GMV/counts — verify 1-per-order (or pre-aggregate) before joining.

## Mistakes / Notes

- None (authoring + decision session; SQL authored but not yet executed — user runs it).

## Next Steps

1. **Run `_silver.sql`** (user runs psql; run twice for idempotency) and paste verification output (row counts, PK uniqueness, payments/shipments 1-per-order).
2. **Stage 4 — Gold mart** (`sql-builder`): declare grain + unique key, verify `COUNT(*) = COUNT(DISTINCT grain_key)` → checkpoint.
3. **Stage 5 — Queries + results** (`03-queries.sql`; user runs against `datainsight_markethub`) → `03-results.md` → checkpoint.
4. **Stage 6 — Insight** (`insight-writer`): 5 components + self-check → checkpoint.
5. Then Case 03 (NovaTel), then archive the OpenSpec change once both pilots validate.
