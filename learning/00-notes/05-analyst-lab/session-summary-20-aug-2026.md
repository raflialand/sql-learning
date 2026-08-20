# Summary: SQL Analyst Lab Session

**Date:** 20 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3: Q3b & Q3c corrected + verified against expected results; Q1b filter bug found; Q4a next

---

## Completed

- **Q3b (AOV · Category) corrected:** revised to AOV per category = category revenue ÷ `COUNT(DISTINCT order_id)` (previous draft divided by `SUM(quantity)` = revenue per *item*, not per order).
- **Q3c (Order count · Category) corrected:** `COUNT(oi.order_id)` → `COUNT(DISTINCT oi.order_id)` (double-count fix).
- **Verified both against `retail.db`** (read-only) and they reproduce the model's expected Q3 exactly:

| category | order_count | revenue | AOV |
| --- | --- | --- | --- |
| Merchandise | 737 | 42,145.00 | 57.18 |
| Food | 738 | 13,341.50 | 18.08 |
| Beverage | 861 | 14,747.60 | 17.13 |

- Confirmed Q2a already carries `PARTITION BY store_id` in `work/03-queries.sql`.
- Wrote the corrected Q3b/Q3c into `work/03-queries.sql` (self-applied).

## Key Takeaways

1. **AOV is per ORDER, never per item.** The denominator is `COUNT(DISTINCT order_id)`; `SUM(quantity)` gives average unit price, not basket strength. (Repeat of the "units must match" pattern — #11, #16.)
2. **New dataset finding — `is_active` is NOT harmless.** PRD030 (Seasonal Pumpkin Latte) and PRD031 (Limited Holiday Blend) are `is_active=0` but DO have sales: 236 `order_items` rows across 215 distinct orders (PRD030: 220 units / $1,210.00; PRD031: 244 units / $3,904.00). The expected `03-results.md` note claiming they have "0 units" is wrong for this database.
3. **Therefore Q1b is still wrong.** It filters `WHERE p.is_active = 1`, undercounting Beverage revenue to $9,633.60 instead of the true $14,747.60 (861 → 768 orders). The filter must be removed to match the true category revenue split.
4. **Verify dataset quirks against data, never assume.** The 19-Aug review verdict "is_active=1 harmless (inactive products have no sales)" was assumption-based and is now disproven by the data.
5. Filtering for `is_active` may be intentional for a *sales/performance* question (only sellable items), but it changes the answer — decide deliberately and document it, don't leave it as an invisible filter.

## Mistakes / Notes

- **#17 — Q3b denominator = `SUM(oi.quantity)`:** computed revenue-per-item, labeled it AOV. Root cause: definition slip while rebuilding the query. Fix: revenue ÷ `COUNT(DISTINCT order_id)`.
- **#18 — assumed `is_active=1` filter harmless** (carried over from the 19-Aug review) without re-checking the data. Root cause: trusted an earlier assumption instead of the dataset. Fix: prove filter impact on the DB first.

## Next Steps

1. Q1b: remove `WHERE p.is_active = 1` (verify Beverage returns to 861 / $14,747.60).
2. Q4a: LEFT JOIN + `COALESCE(SUM(...),0)` to flag true zero-sales products (do NOT assume inactive = zero-sales); derive bottom-decile (~3 of 31) from the query.
3. Q4b/c/d: derive the flagged set from Q4a output instead of hardcoding `PRD001/006/015`.
4. Cleanup: remove stray BRW001-only query (Q1a), remove exploratory `SELECT *` statements, split file into one statement per query for the SQLite helper.
5. Verify in Postgres against `expected/03-results.md`; then Step 4 insights + recommendations; compare `work/` vs `expected/`.

---

# Summary: SQL Analyst Lab Session (continued — Q4b price-band deep-dive)

**Date:** 20 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3: Q4b finalized & verified (all 3 underperformers = Cheap); Q4c/Q4d next

---

## Completed

- **Learned `COALESCE`:** returns the first non-NULL argument; `COALESCE(SUM(oi.unit_price * oi.quantity), 0)` turns a no-sales `NULL` into a real `0` so zero-sales products can be flagged.
- **Learned `NTILE(n)`:** window function that splits a sorted set into n equal-sized buckets (1..n). `NTILE(3) OVER(PARTITION BY category ORDER BY unit_price)` = per-category price tertile.
- **Locked the cheap/mid/expensive definition:** **tertile within the product's own category** (NTILE(3) partitioned by category). Rejected whole-menu comparison (menu avg $9.54 is distorted by Merchandise avg $19.39) and category mean (skewed by outliers).
- **Caught the window-after-WHERE trap in Q4b:** `AVG(...) OVER(PARTITION BY category)` written in the same query as the flagged-set filter returned Beverage avg = 3.10 instead of the true 5.25 — the WHERE reduced the partition to 2 rows before the window computed.
- **Fixed Q4b** with the two-CTE pattern: `price_bands` (windows over ALL products) + `underperform` (Q4a flagged set) joined at the end. **Verified output:**

| prod_id | product | category | price | avg_category | band |
| --- | --- | --- | --- | --- | --- |
| PRD001 | Espresso | Beverage | 2.95 | 5.25 | Cheap |
| PRD015 | Chocolate Chip Cookie | Food | 2.50 | 5.81 | Cheap |
| PRD006 | Americano | Beverage | 3.25 | 5.25 | Cheap |

- **Insight forming:** all three flagged products are **cheap within their category** → underperformance is **price-driven** (low-price staples selling fine but generating little revenue), not demand-driven — matches the model's expected finding.

## Key Takeaways

1. **COALESCE(x, 0) = "if NULL, return 0".** Needed because LEFT JOIN + no sales rows = `SUM` is NULL, not 0.
2. **NTILE(3) = position-based thirds**, not value-based. Even group sizes regardless of price gaps; `PARTITION BY category` restarts the thirds per category.
3. **Definition locked before SQL:** cheap/mid/expensive = per-category tertile. The answer *changes* with the reference (Americano is Mid vs whole-menu, Cheap vs own category) — pin it down first.
4. **Window functions run AFTER WHERE.** Filtering first makes `AVG/NTILE OVER(...)` compute over the surviving rows only. Compute windows on the full table, restrict afterwards.
5. **Two-CTE pattern for Bucket 4:** CTE 1 = the flagged set (from Q4a revenue), CTE 2 = the classification over the whole menu; join at the end. No hardcoded IDs.
6. **Correction to my own earlier claim:** Americano is **Cheap**, not Mid — my earlier table was computed with the same filtered-window bug. The full-set computation settles it.

## Mistakes / Notes

- **#19 — Q4b windows over filtered rows:** `AVG(unit_price) OVER(PARTITION BY category)` computed after `WHERE prod_id IN (...)` gave Beverage avg 3.10 (vs true 5.25) and misclassified Americano. Fix below.
- **#20 — hardcoded `IN ('PRD001','PRD006','PRD015')`** in the first Q4b draft (repeat of #10). Fix: `underperform` CTE derived from Q4a.

## ⚠️ Mistake Track & Solutions (dedicated section)

| # | Date | Mistake | Root cause | Solution (verified) |
| --- | --- | --- | --- | --- |
| 20 | 20-Aug | Q4b hardcoded `IN ('PRD001','PRD006','PRD015')` | Repeat of #10 — typed the derived set | `underperform` CTE = Q4a flagged set (`ORDER BY revenue ASC LIMIT 3`); outer `JOIN underperform` |
| 19 | 20-Aug | Q4b windows computed over the filtered rows | `WHERE prod_id IN (...)` runs before window functions, so `AVG/NTILE OVER(PARTITION BY category)` saw only 2–3 rows → avg 3.10 instead of 5.25 | Compute windows over the full `products` table in a `price_bands` CTE, then filter/join in the outer query. **Rule: windows before WHERE.** |
| 18 | 20-Aug | Assumed `is_active=1` filter harmless | Trusted earlier review, not the data | Verify filter impact on the DB; PRD030/031 DO have sales (215 orders) |
| 17 | 20-Aug | Q3b denominator = `SUM(quantity)` | Definition slip | AOV = revenue ÷ `COUNT(DISTINCT order_id)`, never ÷ items |

**Corrected Q4b pattern (the solution that stays):**

```sql
WITH price_bands AS (
	SELECT prod_id, prod_name, category, unit_price,
		ROUND(AVG(unit_price) OVER(PARTITION BY category), 2) AS avg_category_price,
		CASE NTILE(3) OVER(PARTITION BY category ORDER BY unit_price)
			WHEN 1 THEN 'Cheap' WHEN 2 THEN 'Mid' ELSE 'Expensive' END AS price_band
	FROM products
),
underperform AS (
	SELECT p.prod_id, p.prod_name,
		ROUND(COALESCE(SUM(oi.unit_price * oi.quantity), 0), 2) AS revenue
	FROM products p
		LEFT JOIN order_items oi ON oi.product_id = p.prod_id
	GROUP BY p.prod_id, p.prod_name
	ORDER BY revenue ASC
	LIMIT 3
)
SELECT pb.prod_id, pb.prod_name, pb.category, pb.unit_price,
       pb.avg_category_price, pb.price_band
FROM price_bands pb
JOIN underperform up ON up.prod_id = pb.prod_id;
```

## Next Steps

1. Q4c: same two-CTE pattern → `is_active` band for the flagged set (windows over full table first).
2. Q4d: same pattern + `item_per_order` CTE (`COUNT(DISTINCT product_id)` per order) + `COUNT(DISTINCT order_id)`; keep the flagged-set join.
3. Q1b: remove `WHERE p.is_active = 1` (Beverage must return to 861 / $14,747.60).
4. Cleanup: remove stray BRW001-only query after Q1a; split file into one statement per block.
5. Verify in Postgres against `expected/03-results.md`; then Step 4 insights + recommendations; compare `work/` vs `expected/`.

---

# Summary: SQL Analyst Lab Session (continued — Q4c & Q4d finalized; all 12 queries verified)

**Date:** 20 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3: **all 12 sub-questions now match** their queries in `work/03-queries.sql` (verified read-only against `retail.db`)

---

## Completed

- **Q4c (is_active band) finalized:** two-CTE pattern (`underperform` set + `LEFT JOIN products` for `is_active`). Verified: Espresso/Americano/Cookie all **Active** → inactivity is NOT the reason for underperformance.
- **Q4d (basket context) finalized:** `underperform` + `item_per_order` CTEs, joins at order-item level, `COUNT(DISTINCT order_id)` for order count, and the alone/add-on classification. Verified:
  | product | orders | alone | add-on |
  | --- | --- | --- | --- |
  | Americano | 94 | 11 | 83 |
  | Espresso | 100 | 2 | 98 |
  | Cookie | 123 | 4 | 119 |
  Insight: these cheap staples mostly ride along **inside bigger baskets** (98/100 Espresso, 119/123 Cookie) → consistent with the "cheap add-on staple" story from Q4b.
- **Q1b** already cleaned up by the user earlier (the `is_active=1` filter is gone from the file).

## Key Takeaways

1. **`SUM(CASE...)` counts lines; `COUNT(DISTINCT CASE ... THEN order_id END)` counts orders.** When an order can list the same product twice, line-counting inflates the total (Espresso add-on: 102 vs true 98). Basket-classification must count unique carts, not receipt lines.
2. **`item_per_order` is essential, not redundant** — it stamps each order as alone (`product_in_order=1`) vs mixed (`>1`); the CASE just reads that stamp.
3. **`COUNT(SUM(...))` is illegal** (aggregate nesting) and conceptually meaningless — it's one of two distinct forms, never both.
4. **Consistent Bucket 4 pattern across Q4a–d:** define the flagged set from revenue (`underperform`), classify on the full table (or order context), then join — no hardcoded product IDs anywhere.

## Mistakes / Notes

- **#21 — Q4d `SUM(CASE WHEN ...)` counted lines, not orders:** alone+add_on summed to 98/104/127 but true orders are 94/100/123 (~4 duplicate lines per product). Fix: `COUNT(DISTINCT CASE WHEN ... THEN oi.order_id END)`.
- Q4c/Q4d initial drafts repeated the hardcoded-set mistake (pattern #10 / #20) — resolved with the derived `underperform` CTE.

## ⚠️ Mistake Track & Solutions (dedicated section)

| # | Date | Mistake | Root cause | Solution (verified) |
| --- | --- | --- | --- | --- |
| 21 | 20-Aug | Q4d `SUM(CASE...)` counted receipt **lines**, not orders | Same product can appear on 2 lines in one order → double-count | `COUNT(DISTINCT CASE WHEN ipo.product_in_order = 1 THEN oi.order_id END)` |
| 20 | 20-Aug | Q4b hardcoded `IN ('PRD001','PRD006','PRD015')` | Repeat of #10 — typed the derived set | `underperform` CTE = Q4a flagged set; outer JOIN |
| 19 | 20-Aug | Q4b windows computed over the filtered rows | `WHERE` runs before windows → avg 3.10 vs true 5.25 | Compute windows on the full table, filter after (**windows before WHERE**) |
| 18 | 20-Aug | Assumed `is_active=1` filter harmless | Trusted earlier review, not the data | Verify filter impact on the DB; PRD030/031 DO have sales (236 rows / 215 orders) |
| 17 | 20-Aug | Q3b denominator = `SUM(quantity)` | Definition slip | AOV = revenue ÷ `COUNT(DISTINCT order_id)`, never ÷ items |

## Next Steps

1. Cleanup (leave in file for next session): remove stray BRW001-only query after Q1a; fix "Overal" typo; split Q2b into one statement per block for the SQLite helper.
2. Verify all 12 queries in Postgres against `expected/03-results.md` (dialect already `TO_CHAR`).
3. Step 4: surface insights + recommendations (trend + fluctuation + anomaly + root cause + recommendation) → `04-insight.md`; compare `work/` vs `expected/`.

---

*Happy Learning!*
