# Summary: SQL Analyst Lab Session

**Date:** 26 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 4, Step A: Running Log **Buckets 1–4 drafted & verified**; Bucket 4 closed this session (Q4d grain bug found & fixed); Steps B–E pending

---

## Completed

- **Bucket 4 (Q4a–d) reviewed, verified against both `retail.db` (raw) and the mart (`retail_gold.db` / Postgres `gold.mart_retail`), and closed.**
  - **Q4a** — Espresso $598.85, Chocolate Chip Cookie $622.50, Americano $624.00 = confirmed true bottom-3 by revenue. Zero-sales flag answered: **none exist — all 31 products sold at least once.**
  - **Q4b** — all three are **cheap** (≤ $3.25 vs category avg $5.25 Beverage / $5.81 Food).
  - **Q4c** — all **active** (`is_active = 1`) → underperformance is NOT a deactivation / stale-menu problem.
  - **Q4d** — **grain bug found & fixed** (details below). Correct basket-context counts: Espresso 2/98, Americano 11/83, Cookie 4/119.
- **All 12 sub-questions (Q1a–Q4d) are now answered and verified.** Bucket 4 done.

## Q4d deep-dive (the bug + the lesson)

**Symptom:** recorded counts (Espresso 2-102, Americano 11-87, Cookie 5-122) didn't match distinct-order truth (2/98, 11/83, 4/119).

**Root cause:** `gold.mart_retail` is **line-grain** (one row per order-item line — 3,647 rows for only 1,200 distinct orders). `alone_flag` is an **order-level** flag stamped onto every line row of that order. My original query `SUM(CASE WHEN mr.alone_flag = 1 THEN 1 ELSE 0 END)` counted **rows / line items**, so an order containing the same product on multiple lines was double-counted (e.g. Espresso = 104 lines across 100 orders).

**Fix — count baskets, not lines:**

```sql
WITH flagged_product AS(
    SELECT product_id, product_name,
           ROUND(SUM(line_revenue), 2) AS prod_revenue
    FROM gold.mart_retail
    GROUP BY product_id, product_name
    ORDER BY prod_revenue ASC
    LIMIT 3
)
SELECT fp.product_id, fp.product_name,
       mr.price_band, mr.is_active,
       COUNT(DISTINCT CASE WHEN mr.alone_flag = 1 THEN mr.order_id END) AS alone_orders,
       COUNT(DISTINCT CASE WHEN mr.alone_flag = 0 THEN mr.order_id END) AS addon_orders
FROM flagged_product fp
JOIN gold.mart_retail mr ON mr.product_id = fp.product_id
GROUP BY fp.product_id, fp.product_name, mr.price_band, mr.is_active;
```

**Why `order_id`:** `alone_flag` is order-level and "bought alone vs add-on" is a **basket metric**. `COUNT(DISTINCT order_id)` collapses all line rows of the same cart into one vote; `item_id` is line-unique (still counts lines) and `product_id` isn't unique per basket. The ELI5 anchor: **count shopping carts (`order_id`), not cookies (rows)**.

## Key Takeaways

1. **Grain discipline before aggregating** — know the mart grain (line vs order vs order-product) *before* writing the aggregate. Basket-level metric ⇒ `COUNT(DISTINCT order_id)`; line-level metric ⇒ `COUNT(*)`.
2. **Flags are stamped at their defining grain** — `alone_flag` is per-order, so any use of it must collapse to order level or you silently double-count.
3. **Underperformance here is price-driven, not demand-driven** — the bottom products are cheap (≤ $3.25), active, high-volume staples (192–249 units) bought ~90%+ as add-ons in bigger baskets. Low revenue = low price, not slow movement.
4. Verified counts: Espresso 2/98 (98% add-ons), Americano 11/83 (88%), Cookie 4/119 (97%).

## Mistakes / Notes

- **Q4d regression of #13 / #21** — counted line items instead of distinct orders in the mart query. The raw-based Q4d in `work/03-queries.sql` was already correct (`COUNT(DISTINCT ...)`); the mart version reintroduced the bug. Root cause: forgot the mart is line-grain. Lesson: **check grain, then count baskets**.

## Next Steps

1. **Step B** — classify Running Log facts (Buckets 1–4) into the 5 components (Trend / Fluctuation / Anomaly / Root cause / Recommendation). Strong candidates already flagged in the 21-aug notes.
2. **Step C** — one strong insight paragraph (Trend → Fluctuation → Anomaly → Root cause → Recommendation).
3. **Step D** — 2–4 recommendations (compute the BRW002 opportunity yourself — don't copy the $2,200).
4. **Step E** — self-check (5 components present, every claim traceable, PRD030/031 discrepancy addressed).
5. Compare `work/04-insight.md` vs `expected/04-insight.md`; reconcile seasonal-items discrepancy.
6. Close Case 01 → update progress snapshot → Case 02 (MarketHub).

---

*Happy Learning!*
