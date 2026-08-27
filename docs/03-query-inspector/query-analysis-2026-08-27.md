# Query Analysis Report

- **Inspector**: `query-inspector`
- **Source**: `script/01-sql/data-to-insight/03-queries.sql` (Case 02 — MarketHub, Stage 5)
- **Date**: 2026-08-27
- **QA gate for**: `data-to-insight` pipeline · Stage 5 (Query the gold mart)
- **References**: `gold.mart_markethub` (grain = one row per order-item line; `item_id` unique key; 7,102 lines; 2,800 distinct orders), `work/01-scope.md` (metric definitions), `work/02-questions.md` (9 sub-questions), `work/_gold.sql` (mart build), `work/_silver.sql` (conformed source), dataset README `datasets/02-intermediate/README.md`
- **Method**: static review of every statement against the locked metric definitions and sub-question mapping. No DB execution (out of scope for this inspector); data types confirmed against `ecommerce_pg.sql` DDL (`unit_price`/`total_amount` `DECIMAL(10,2)`, `quantity` `INT`).

---

## Verdict at a Glance

| Metric | Value |
| --- | --- |
| Statements reviewed | 13 (Q1–Q8, Q9 split into 0/a/b/c/d) |
| Query-logic mismatches | **0** |
| Business-alignment mismatches | **0** |
| Advisory notes | 3 (no query is wrong; see "Notes" below) |
| Final verdict | **PASS-WITH-NOTES** |

The file correctly implements all 9 sub-questions against the gold mart, using the locked metric definitions exactly: `GMV = SUM(line_revenue) WHERE is_fulfilled = 1`, order counts via `COUNT(DISTINCT order_id)`, AOV via `SUM(line_revenue) / COUNT(DISTINCT order_id)`, and repeat rate via the ≥2-fulfilled-orders ÷ ≥1-fulfilled-order ratio. `total_amount` is never aggregated (correct — order-level value repeated per line). No statement contains a syntax or semantic error that would fail in PostgreSQL.

---

## Stated Business Requirement

Main question: *"How is the marketplace performing, and which vendor/segment should we invest in next?"* — decomposed into 9 sub-questions (Q1–Q9) across 4 buckets.

### Locked metric definitions (must match exactly)

| Metric | Definition |
| --- | --- |
| **GMV** | `SUM(line_revenue)` over `is_fulfilled = 1` (NOT `total_amount`). |
| **Order count** | `COUNT(DISTINCT order_id)` over `is_fulfilled = 1` (NEVER `COUNT(*)` at line grain). |
| **AOV** | GMV ÷ order count (same grouping scope). |
| **Repeat purchase rate** | distinct customers with ≥2 fulfilled orders ÷ distinct customers with ≥1 fulfilled order, × 100. |

### Sub-question mapping

| # | Metric × Dimension | Bucket |
| --- | --- | --- |
| Q1 | GMV · Month | Overall Trends |
| Q2 | GMV · Vendor | Overall Trends |
| Q3 | GMV · Category | Overall Trends |
| Q4 | GMV · Country | Overall Trends |
| Q5 | GMV · Month + MoM% + YoY% (LAG 1 and 12) | Growth Rates |
| Q6 | GMV · Vendor×Month + MoM%/YoY% (`PARTITION BY vendor_id`) | Growth Rates |
| Q7 | AOV · Vendor | Performance |
| Q8 | Repeat rate · Vendor | Performance |
| Q9 | Bottom-vendor drill (category mix, product mix, shipment health, payment health) | KPI Reporting |

---

## Summary Table (Q1–Q9)

| Q | Verdict | One-line assessment |
| - | ------- | ------------------- |
| Q1 | PASS | `SUM(line_revenue)` filtered `is_fulfilled = 1`, one row per month, chronological `ORDER BY month` (YYYY-MM text sorts correctly). |
| Q2 | PASS | Fulfilled GMV per vendor, `GROUP BY vendor_id, vendor_name`, `ORDER BY gmv DESC`. |
| Q3 | PASS | Fulfilled GMV per top-level `category` (already rolled up in the mart). |
| Q4 | PASS | Fulfilled GMV per buyer `country`. |
| Q5 | PASS | `LAG(gmv,1)` + `LAG(gmv,12)` over `ORDER BY month`; % formula `100.0*(gmv-prev)/prev`; NULL propagates (no divide-by-zero). |
| Q6 | PASS (note) | `PARTITION BY vendor_id` correct; `LAG` over *present* rows — see Note 1 on sparse vendor-months. |
| Q7 | PASS | `SUM(line_revenue) / COUNT(DISTINCT order_id)` = numeric / bigint → numeric, no integer truncation. |
| Q8 | PASS | `COUNT(*)` is over the customer-grain CTE (`buyer_orders`), so it equals distinct buyers per vendor — not a grain violation. |
| Q9(0) | PASS | Bottom vendor by fulfilled GMV ascending, `LIMIT 1` — same ranking as Q2. |
| Q9(a) | PASS (note) | Category GMV + share% via `SUM(gmv) OVER ()`; share uses rounded `gmv` — see Note 2. |
| Q9(b) | PASS | Product GMV + units, top 10, fulfilled scope, anchored on the same bottom-vendor CTE. |
| Q9(c) | PASS | Carrier × `in_transit`; `COUNT(*)` correctly labeled `lines`, orders via `COUNT(DISTINCT order_id)`. |
| Q9(d) | PASS | Payment health over ALL orders of the bottom vendor — the one documented `is_fulfilled` exception; intentional and correct. |

---

## Correctness Checklist (the 6 mandated checks)

1. **`is_fulfilled = 1` filter** — Applied in every GMV / order-count / AOV / repeat query: Q1–Q8 and Q9(0)/Q9(a)/Q9(b)/Q9(c) all filter `is_fulfilled = 1` (either in the main query or its CTE). **Q9(d) is the one exception** and is intentional: the `bottom_vendor` CTE still filters `is_fulfilled = 1` to anchor on the same bottom vendor as Q2, while the *payment-health drill itself* deliberately spans ALL orders of that vendor (failed/refunded/no-payment signals live largely outside the fulfilled set, and a NULL `payment_status` — "no payment row" — is a finding, not a defect). ✅ correct.

2. **Grain discipline** — No `COUNT(*)` used where a basket/buyer count is meant:
   - Q8's `COUNT(*) AS total_buyers` is over the `buyer_orders` CTE (one row per vendor-customer), so it correctly counts distinct buyers, not line rows. ✅
   - Q9(c)'s `COUNT(*) AS lines` is the only line-grain `COUNT(*)` and is explicitly intended (count of line rows). ✅
   - `total_amount` is **never aggregated** anywhere (reference column only). ✅

3. **Q5/Q6 window functions** — `LAG(gmv, 1)` (MoM) and `LAG(gmv, 12)` (YoY) offsets are correct; Q6 partitions by `vendor_id`; % formula is `100.0 * (gmv − prev) / prev`; NULL handling is safe (a NULL `prev` makes the whole expression NULL, never a divide-by-zero, since `NULL/0` and `x/NULL` both yield NULL without error). ✅

4. **Q7 AOV division types** — `SUM(line_revenue)` is `numeric` (line_revenue = `quantity(INT) × unit_price(DECIMAL(10,2))`, rounded), and `COUNT(DISTINCT order_id)` is `bigint`; `numeric / bigint` → `numeric`. No integer-division truncation. ✅

5. **Q9 bottom-vendor CTE** — `SELECT vendor_id … GROUP BY vendor_id ORDER BY SUM(line_revenue) ASC LIMIT 1` matches Q9(0) and the Q2 anchor (same ranking, ascending). Grouping by `vendor_id` alone is equivalent to Q9(0)'s `vendor_id, vendor_name` because `vendor_id` is the vendor PK (functional dependency). Each drill's scope is correct: (a) category mix, (b) product mix, (c) shipment health all in fulfilled scope; (d) payment health across all orders by design. ✅

6. **Syntax/semantics** — All referenced columns exist in `gold.mart_markethub` (`month, line_revenue, vendor_id, vendor_name, category, country, order_id, customer_id, product_name, quantity, carrier, in_transit, payment_status, is_fulfilled`). `ORDER BY <alias>` (`gmv`, `aov`, `repeat_rate_pct`, `orders`) is valid in PostgreSQL. `SUM(gmv) OVER ()` window in Q9(a) is valid. No stray terminators, no dialect-specific functions. ✅

---

## Notes (advisory — not correctness failures)

### Note 1 — Q6 (and Q5 in principle): `LAG` compares consecutive *rows*, not consecutive *calendar months*

**Classification**: Query-logic / Business-alignment (advisory, medium severity *if* the condition holds)

`LAG(gmv, 1) OVER (PARTITION BY vendor_id ORDER BY month)` computes "previous row in the result set", not "previous calendar month". The `vendor_month` CTE only emits rows for months in which a vendor actually has fulfilled lines. If any vendor has a month with **zero** fulfilled orders, that month is absent, and the "MoM%" silently spans two (or more) calendar months; the `LAG(gmv, 12)` YoY comparison likewise compares to the row 12 positions back rather than the same month of the prior year.

- **Q5 (marketplace-level)** is very unlikely to trigger this: with 2,800 orders across a 13-month span, a marketplace-wide zero-GMV month is implausible.
- **Q6 (per-vendor)** is the realistic exposure: 14 vendors × 13 months = 182 cells, and a niche vendor can plausibly miss a month.

**Current behavior (illustrative)**:

```
vendor X: 2025-01 -> 1000
          2025-02 -> (no sales, row absent)
          2025-03 -> 900
LAG(gmv,1) for 2025-03 = 1000  => "MoM = -10%"  <-- actually 2 months apart, mislabeled
```

**Recommended fix** (dense vendor × month grid so LAG aligns to calendar months; missing months become NULL and the % formula stays NULL, avoiding any divide-by-zero):

```sql
WITH month_axis AS (
    SELECT DISTINCT month FROM gold.mart_markethub
),
vendor_axis AS (
    SELECT DISTINCT vendor_id, vendor_name FROM gold.mart_markethub
),
grid AS (
    SELECT v.vendor_id, v.vendor_name, m.month
    FROM vendor_axis v
    CROSS JOIN month_axis m
),
vendor_month AS (
    SELECT vendor_id, month, SUM(line_revenue) AS gmv
    FROM gold.mart_markethub
    WHERE is_fulfilled = 1
    GROUP BY vendor_id, month
),
filled AS (
    SELECT g.vendor_id, g.vendor_name, g.month,
           vm.gmv                                   -- NULL for a missed month
    FROM grid g
    LEFT JOIN vendor_month vm
           ON vm.vendor_id = g.vendor_id AND vm.month = g.month
),
with_lags AS (
    SELECT vendor_id, vendor_name, month, gmv,
           LAG(gmv, 1)  OVER (PARTITION BY vendor_id ORDER BY month) AS prev_month_gmv,
           LAG(gmv, 12) OVER (PARTITION BY vendor_id ORDER BY month) AS prev_year_gmv
    FROM filled
)
SELECT vendor_id, vendor_name, month,
       ROUND(gmv, 2) AS gmv,
       ROUND(100.0 * (gmv - prev_month_gmv) / NULLIF(prev_month_gmv, 0), 2) AS mom_pct,
       ROUND(100.0 * (gmv - prev_year_gmv)  / NULLIF(prev_year_gmv,  0), 2) AS yoy_pct
FROM with_lags
ORDER BY vendor_id, month;
```

**Change rationale**: added a `vendor_axis × month_axis` grid and `LEFT JOIN`ed the aggregate so every calendar month is present per vendor; `LAG` then walks true calendar months. `NULLIF(prev, 0)` guards against a (legitimate) zero-denominator edge. If every vendor in fact sells every month, this fix produces output identical to the submitted Q6 — it is a hardening, not a repair of a confirmed defect.

---

### Note 2 — Q9(a): share% is computed on *rounded* GMV

**Classification**: Query-logic (cosmetic / precision)

```sql
ROUND(100.0 * gmv / SUM(gmv) OVER (), 2) AS share_pct
```

`gmv` here is `ROUND(SUM(m.line_revenue), 2)` (already rounded in `category_gmv`), and the window denominator `SUM(gmv) OVER ()` sums those rounded values. Because each category GMV is rounded to 2 decimals before summing, the category shares can sum to `99.99` or `100.01` instead of exactly `100.00`. Functionally harmless for a drill; if exact-share semantics matter, compute the window over the unrounded `SUM(m.line_revenue)` and round only the final `share_pct`.

**Recommended (optional) hardening**:

```sql
-- compute share on the unrounded total, round only at the end
SELECT category,
       ROUND(SUM(m.line_revenue), 2) AS gmv,
       ROUND(100.0 * SUM(m.line_revenue)
                 / SUM(SUM(m.line_revenue)) OVER (), 2) AS share_pct
FROM gold.mart_markethub m
JOIN bottom_vendor bv ON bv.vendor_id = m.vendor_id
WHERE m.is_fulfilled = 1
GROUP BY m.category
ORDER BY gmv DESC;
```

---

### Note 3 — Header comment understates the statement count (trivial)

**Classification**: Documentation (cosmetic, no query impact)

The header (lines 8, 345) and the end-of-file banner say "12 runnable statements (Q1..Q9, Q9 split into 0/a/b/c/d)". The file actually contains **13** runnable statements: Q1–Q8 (8) + Q9 split into 0/a/b/c/d (5). Purely a comment-count nit; no query is affected.

---

## Confirmations of intentional patterns (correct as written)

- **Q8's `COUNT(*)`** is safe *because* it operates on `buyer_orders`, which is already grouped to one row per (vendor, customer). It is not counting line-grain rows. This is the correct way to count distinct buyers per vendor without an extra `COUNT(DISTINCT customer_id)`.
- **Q9(c)'s `COUNT(*)`** intentionally counts *line rows* (labeled `lines`) alongside `COUNT(DISTINCT order_id)` (labeled `orders`) — the two grain-level counts are complementary and correctly named.
- **Q9(d)'s missing `is_fulfilled` filter** is deliberate and well-documented: the bottom-vendor anchor still filters on fulfilled GMV (matching Q2), while payment health must include failed/refunded/no-payment orders, which largely fall outside the fulfilled set. A NULL `payment_status` ("no payment row") is a legitimate finding, not an error.
- **Q5/Q6 YoY via `LAG(…, 12)`** correctly compares e.g. 2026-01 against 2025-01 (the 13-month span's only YoY-comparable month), and the first 12 rows yield NULL `yoy_pct` as intended.
- **Q7 denominator** `COUNT(DISTINCT order_id)` correctly turns multi-line orders into single baskets, so a vendor's AOV is not deflated by line fan-out.

---

## Verdict

**PASS-WITH-NOTES.** All 13 statements are query-logic correct and business-aligned with the locked metric definitions and the 9 sub-questions; there are **zero** correctness or business-alignment mismatches and no syntax/semantic errors. Three advisory notes remain: (1) Q6's per-vendor `LAG` assumes contiguous vendor-months — adopt the dense vendor×month grid if any vendor can miss a month; (2) Q9(a) computes share% on rounded GMV (shares may not sum to exactly 100.00) — optional hardening; (3) the header/end comment says "12 runnable statements" but the file contains 13 — cosmetic only. None of these blocks Stage 5 from running.
