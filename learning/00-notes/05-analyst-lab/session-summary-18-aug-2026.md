# Summary: SQL Analyst Lab Session

**Date:** 18 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 1 (Scope) completed

---

## Completed

- Case 01 (Brew & Co.): started; Step 1 scope locked and saved to `work/01-scope.md`
  - 3 metrics: Revenue, Order count, AOV
  - 3 dimensions: Store, Category, Month
  - Definitions fixed: Revenue = `orders.total_amount`; AOV = revenue ÷ orders per grouping; "underperforming product" = bottom-decile (~10%) of product revenue

## Key Takeaways

1. Northstar metrics must pass three filters: relevance (answers the question), sensitivity (moves with the business), actionability (gives a lever).
2. Revenue = Order count × AOV — the decomposition that makes both levers visible and answerable ("more visits vs more per visit").
3. "Where should we focus" = the literal "where": Store as a dimension; Product is a drill-down of Category, not an independent axis.
4. Fix ambiguous definitions (e.g. "underperforming product" = bottom-decile revenue) before writing any SQL so every query means the same thing.

## Mistakes / Notes

- Items sold rejected as a metric: redundant with AOV (already baked in), and it distorts across price points.
- Product rejected as a dimension: same axis as Category; its idea (promote hidden-gem low-sellers) moves to Step 2's KPI Reporting bucket.
- Decile lesson: bottom decile = lowest ~10% of a ranked list → ~3 of 31 products.

## Discussion highlights

1. You argued items sold to detect low-price-volume trends → challenged: it's already inside AOV.
2. You picked Product for "promote the hidden-gem product" → challenged: it's a Category drill-down; the promotion investigation belongs to the Step 2 bottom-decile dig.
3. We built the Revenue = count × AOV decomposition together → you locked Option A (Revenue / Order count / AOV).
4. You defined "bottom-decile" only after I explained decile ranking → locked Option A (bottom 10%).

## Next Steps

1. Step 2: decompose the main question ("How is sales performance, and where should we focus next month?") into sub-questions mapped to the 4 buckets (Overall Trends · Growth Rates · Performance Measurement · KPI Reporting).

---

# Summary: SQL Analyst Lab Session (continued — Step 2 decomposition)

**Date:** 18 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 2 in progress; Buckets 1 & 2 locked

---

## Completed

- Case 01 (Brew & Co.) Step 2: decomposed the main question into sub-questions for 2 of 4 buckets.
- **Bucket 1 — Overall Trends (locked):**
  1. Revenue trend by Month (chain-wide) → Revenue · Month
  2. Revenue split by Category → Revenue · Category
  3. Revenue split by Store → Revenue · Store
  - AOV-by-month trend deliberately dropped (deferred to Bucket 2 — level trend is redundant with Revenue trend).
- **Bucket 2 — Growth Rates (locked):**
  1. Q2a (headline): Which store is growing/shrinking Revenue MoM — where should next month's focus go? → Revenue · Store × Month, MoM % change
  2. Q2b (diagnosis, conditional on a flagged store): Did the change come from order volume or basket size? → AOV vs Order count · Store × Month, MoM % change

## Key Takeaways

1. Sub-questions are built ONLY from the Step 1 pool (Revenue / Order count / AOV × Store / Category / Month) — one metric sliced by one dimension (sometimes two); no new metrics/dimensions sneak in per bucket.
2. The only thing new in the Growth Rates bucket is the lens: the metric becomes % change (MoM), not the level.
3. Two filters for picking metric×dimension combos: (1) does *change* answer the business question? (2) is it the headline (Revenue) or the diagnosis (Count/AOV)?
4. "Flag a store" = anomaly detection: a store whose MoM change deviates from the chain's normal pattern becomes the focus target; Q2b fires only for that store (dig one dimension deeper = root cause = strong insight).
5. Avoid the "all metrics × all dimensions" trap — Q1/Q2 draft (Order count MoM + Revenue MoM, same dims) was redundant and collapsed into one headline + one diagnostic.

## Mistakes / Notes

- Drafted Order-count MoM and Revenue MoM with identical dimensions — caught as duplicate; merged into a single headline (Revenue) + single driver (AOV/Count).
- "Month over month" phrasing was mislabeled as a Trends question at first — it belongs to Growth Rates (% change), not level trends.
- Asked whether AOV-by-month trend is necessary → answer: optional as a level trend; its payoff is the Bucket 2 growth diagnosis.

## Next Steps

1. Bucket 3 — Performance Measurement: segment comparisons head-to-head at the same point in time (no time axis, no % change) — e.g. Store vs Store on Revenue/AOV, Category vs Category; user drafts sub-questions (not yet drafted).
2. Bucket 4 — KPI Reporting: the "why" behind a number (e.g. underperforming-product bottom decile), digging one dimension deeper.
3. Lock full `work/02-questions.md`, then Step 3 SQL queries.
