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
