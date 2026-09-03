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

---

# Summary: SQL Analyst Lab Session (continued — Stage 3 verified + Stage 4 Gold mart built & verified)

**Date:** 27 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 — Stage 3 (Silver) VERIFIED in PostgreSQL; Stage 4 (Gold mart) authored, gap-fixed, and VERIFIED. Stage 5 (queries) planned but not started.

---

## Completed

- **Stage 3 (Silver) executed & verified** — user ran `_silver.sql`: all row counts (16/14/120/500/2800/7102/2283/1864), flag counts, accuracy (0 total_amount mismatches), enum domains, and PK uniqueness matched. No errors.
- **Stage 4 (Gold mart) authored** (`@sql-builder`) → `work/_gold.sql` → `gold.mart_markethub`:
  - **Grain:** one row per order-item LINE · **unique key:** `item_id` · **rows:** 7,102 (no fan-out).
  - **Scope:** all 2,800 orders kept; `is_fulfilled` carries the GMV scope (Completed + Shipped).
  - **22 columns** after the fix (see below).
- **Coverage gap found & fixed** — before running, traced every sub-question (Q1–Q9) to mart columns and found Q9's *product* drill missing: `category` was rolled to top-level only, and `product_id`/`product_name` were absent. Fixed by adding `oi.product_id` + `p.prod_name AS product_name` (no new joins; grain/row count unchanged). Result: **one mart answers all 9 sub-questions** — no second mart needed.
- **Stage 4 (Gold) executed & verified** — user ran `_gold.sql`: uniqueness `total = distinct_item = 7102` · fan-out `distinct_orders = 2800` · GMV consistency `difference = 0.00` · row count `mart_rows = silver_order_items_rows = 7102`. All clean.

## Key Takeaways (conceptual this session)

1. **Verify mart coverage against every sub-question before authoring queries.** Mapping Q1–Q9 to columns surfaced a real gap (Q9's product drill) that a pure "does it run" check would have missed. The mart must carry every dimension a sub-question groups by — including leaf-level drill-downs (product), not just the scope dimensions (category top-level).
2. **Fan-out = a join multiplying rows.** A 1:many join duplicates each left row once per match, silently double-counting `SUM`/`COUNT`. Grain discipline: verification #1/#4 (`COUNT(*) = COUNT(DISTINCT item_id)`; mart_rows = source rows) detect fan-out; #2 (`COUNT(DISTINCT order_id)`) detects the opposite — dropped rows.
3. **`total_amount` is order-level, repeated on every line.** At line grain it must NEVER be aggregated after a join — GMV at any slice = `SUM(line_revenue)`, and the order-level GMV is checked by de-duplicating orders first.
4. **Payments is provably 1:0..1** (2,283 rows = 2,800 − 517 no-payment orders), shipments 1:1 for fulfilled orders — so the line mart joins don't fan out. That's why a single line-grain mart safely answers Q1–Q9 including Q9's payment/shipment drill.

## Mistakes / Notes

- Authored the gold mart **without** `product_id`/`product_name`, so Q9's "product/category mix" drill had no leaf-level column. Root cause: rolled `category` to top-level and forgot product is the Q9 leaf drill (not a scope dimension). Fix: added both columns from the already-joined base/products tables.

## Next Steps

1. **Stage 5 — Queries** (`@sql-builder`): author `03-queries.sql` (one query per sub-question, gold-mart-only). Plan locked: Q1–Q4 level splits, Q5–Q6 MoM+YoY via `LAG`, Q7 AOV ÷ `COUNT(DISTINCT order_id)`, Q8 repeat rate per vendor, Q9 bottom-vendor drill.
2. **QA gate** — `@query-inspector` reviews the 9 queries before execution.
3. **Run + capture** — user runs `03-queries.sql`, I write `03-results.md` → checkpoint 5.
4. **Stage 6 — Insight** (`@insight-writer`) → checkpoint.
5. Then Case 03 (NovaTel), then archive the OpenSpec change once both pilots validate.

---

# Summary: SQL Analyst Lab Session (continued — Stage 5 queries authored & QA'd)

**Date:** 27 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 — Stage 5 (Queries) AUTHORED + QA'd (PASS-WITH-NOTES). Pending: user runs `03-queries.sql` in psql and pastes output → `03-results.md`.

---

## Completed

- **`work/03-queries.sql` authored** (`@sql-builder`) — 13 runnable statements covering Q1–Q9 (Q9 split into anchor 0 + drills a/b/c/d), `gold.mart_markethub`-only.
  - Q1–Q4 level splits (month/vendor/category/country) · Q5 monthly MoM+YoY (`LAG` 1/12) · Q6 vendor×month MoM+YoY · Q7 AOV·vendor · Q8 repeat-rate·vendor · Q9 bottom-vendor drill (category/product/shipment/payment).
  - Grain discipline: every GMV = `SUM(line_revenue)` + `is_fulfilled = 1`; orders/buyers = `COUNT(DISTINCT ...)`; `total_amount` never aggregated.
- **QA gate** (`@query-inspector`) → `docs/03-query-inspector/query-analysis-2026-08-27.md` — **PASS-WITH-NOTES**, no correctness failures.
- **Acted on the one meaningful note — hardened Q6.** Built a dense `vendor × month` grid (`CROSS JOIN`) so `LAG` walks true calendar months; a vendor with a gap month shows `gmv = 0` and MoM/YoY compares to the real prior period (no silent gap-span). Added `NULLIF` denominator guards. Also fixed a "12 → 13 statements" doc nit.

## Key Takeaways (conceptual this session)

1. **A growth `LAG` over a `GROUP BY` result compares consecutive *selling* periods, not calendar periods.** If a vendor skips a month, MoM silently compares to 2 months back. Fix = dense dimension grid (`vendors × months`) + `LEFT JOIN` the aggregate + `COALESCE(gmv, 0)` + `NULLIF` on the denominator. This matters most for momentum (Q6) — the "invest next" signal.
2. **QA gate catches subtle grain issues, not just syntax.** The inspector confirmed all 13 statements correct against the locked metric definitions, and only flagged advisory hardening — a clean second opinion before execution.

## Mistakes / Notes

- None this session (authoring + QA; no queries run yet).

## Next Steps

1. **Run `03-queries.sql`** (user runs psql against `datainsight_markethub`, statement-by-statement) and paste all 13 outputs.
2. **Capture** — I write `03-results.md` from the pasted output → checkpoint 5.
3. **Stage 6 — Insight** (`@insight-writer`): 5 components + self-check → checkpoint.
4. Then Case 03 (NovaTel), then archive the OpenSpec change once both pilots validate.
