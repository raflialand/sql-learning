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

# Summary: SQL Analyst Lab Session (continued — Step 4 prep: framework alignment + insight-building guide)

**Date:** 20 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3 all 12 queries verified; Step 4 (04-insight) drafted next using the guide below

---

## Discussion: framework alignment (data-to-insight.md vs our work)

- The guide (`learning/04-data-to-insight/data-to-insight.md`) describes a **two-level decomposition**: big business question → 4 bucket-level questions (one per lens) → sub-questions per bucket. Our `02-questions.md` is the **one-level version**: 1 main question → 12 sub-questions grouped by bucket (buckets = labels/lenses, not explicit questions).
- **Verdict: functionally identical.** Our sub-questions each answer one lens and are built only from the Step 1 pool; the `Locked summary` table already names each lens (level / % change / contest / why).
- **Decision: continue as-is.** Bucket-level headers are optional polish, addable as a 5-min retro-fit. The insight is a cross-bucket synthesis that does NOT depend on them. Only real risk = a flat Running Log feeling unwieldy; solved by grouping findings under the 5 insight components instead.
- The model's `04-insight.md` running log also presents one big question → flat sub-question list, confirming the one-level presentation is acceptable.
- **Postgres verification** is a mechanical sanity check (file executes + matches `expected/03-results.md`), NOT a logic re-review — all 12 query logics already approved/verified against SQLite data. Deferred, non-blocking.

---

## ⚠️ Step 4 — Insight-Building Guide (dedicated section, to apply when drafting `work/04-insight.md`)

### Step A — Build the Running Log (facts first, no interpretation)
For each of the 12 sub-questions, write one **factual line** (metric shows X when sliced by Y) traceable to exactly one query result. Verified reference values for cross-checking:

| # | Finding (write own) | Verified reference |
| --- | --- | --- |
| Q1a | … | Revenue rose $4,000 (Jan) → $6,360 peak (Aug), fell to $4,519 (Oct), Q4 recovers |
| Q1b | … | Merchandise $42,145 (60%), Beverage $14,748, Food $13,342 |
| Q1c | … | BRW001 $24,189 ≈ BRW003 $24,082 ≫ BRW002 $21,963 (≈9% gap) |
| Q2a | … | +22% Feb, +15% Aug, **−17% May, −17% Sep**; BRW003 = biggest $ loss |
| Q2b | … | BRW003: May count −37.5% vs AOV −22.8% → **volume-driven** |
| Q3a | … | AOV flat across stores (~$59 / $59 / $57) |
| Q3b | … | AOV: Merchandise $57.18 ≫ Food $18.08 > Beverage $17.13 |
| Q3c | … | Orders: Beverage 861 > Food 738 > Merchandise 737 |
| Q4a | … | Espresso $598.85, Cookie $622.50, Americano $624.00; **no zero-sales product** |
| Q4b | … | All 3 **Cheap** in their category (avg 5.25 / 5.81) |
| Q4c | … | All 3 **Active** |
| Q4d | … | Espresso 2-alone/98-add-on (100); Americano 11/83 (94); Cookie 4/119 (123) |

### Step B — Classify facts into the 5 insight components
| Component | Pull from | What the data says |
| --- | --- | --- |
| Trend | Q1a | Up 59% Jan→Aug, down 29% into Oct, Q4 recovery |
| Fluctuation | Q2a | Feb +22% / Aug +15% spikes; May & Sep −17% dips — repeatable seasonality |
| Anomaly 1 | Q1c + Q3a | BRW002 trails ~9% **but AOV flat** → gap is orders, not baskets |
| Anomaly 2 | Q2b | BRW003 collapses are **volume-driven** (orders fall, AOV holds) |
| Anomaly 3 | Q4a–d | Underperformers = cheap, active, add-on staples → price-driven, not demand-driven |
| Root cause | cross-bucket | AOV flat everywhere → **all revenue movement is volume**; Merchandise (60%) decides good vs bad months |
| Recommendation | all | Replicate Aug merchandise window; fix BRW002 volume; protect cheap staples; plan around May/Sep dips |

### Step C — Write the strong insight (one paragraph, this order)
**Trend → Fluctuation → Anomaly → Root cause → Recommendation.** Weak version to avoid: *"Merchandise has the highest revenue. Stores are doing okay."* Model's strong example = the bar (see `expected/04-insight.md`, but DON'T read it until the draft is done).

### Step D — Recommendations (2–4, each specific + a number)
1. Replicate the August merchandise window (~$1.4k over July) before the Sep dip.
2. Fix BRW002 volume first — **compute the opportunity yourself**: (avg store orders − BRW002 orders) × AOV. Do NOT copy the model's "$2,200" blindly; verify it.
3. Protect the cheap staples — Espresso/Cookie/Americano are traffic heroes (98/100 & 119/123 as add-ons); keep stocked despite thin per-unit revenue.
4. Plan for the seasonal dips — May & Sep recur; run retention offers before the drop.

### Step E — Self-check before comparing to model
- All 5 components present and highlighted? 
- Every claim traceable to a Step A query result?
- **Flag data-vs-model discrepancy:** our runs show Pumpkin Latte ($1,210) and Holiday Blend ($3,904) DID sell — the model claims they "sold nothing." The insight follows **our** data.

### Workflow
1. Draft `work/04-insight.md` (Running Log + insight + recommendations) myself first.
2. Coach against the weak-vs-strong standard (no peeking at `expected/04-insight.md`).
3. Then compare + reconcile the seasonal-items discrepancy.

---

# Summary: SQL Analyst Lab Session (continued — cleanup confirmed; Step 4 plan locked)

**Date:** 20 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3 cleanup complete; Step 4 (04-insight) plan ready, draft pending

---

## Completed

- **Cleaned `work/03-queries.sql`** (verified in-file):
  - Stray BRW001-only query removed (Q1a now = chain-wide + by-store month breakdown only).
  - "Overal" typo fixed.
  - **Q2b already split into 2 blocks** (`monthly_order_count` + `monthly_revenue`, `--` separator at line 74).
  - One statement per block throughout (Q1a–Q4d) — SQLite helper-ready.
- Q1b `is_active=1` filter confirmed gone.
- **Step 4 insight-building plan re-confirmed** (from earlier 20-aug guide): Steps A–E — Running Log → 5-component classification → strong insight paragraph → recommendations with numbers → self-check.

## Key Takeaways

1. Pre-flight cleanup for Step 4 is fully done — next session can go straight into drafting `work/04-insight.md`.
2. Remaining non-blocking task: Postgres verify of the 12 queries vs `expected/03-results.md` (mechanical sanity check; logic already approved against SQLite).

## Next Steps

1. Step 4 — draft `work/04-insight.md`: Step A Running Log (one factual line per query, verified reference table), Step B 5-component classification, Step C strong insight paragraph (Trend → Fluctuation → Anomaly → Root cause → Recommendation), Step D 2–4 numbered recommendations (compute BRW002 opportunity yourself, don't copy $2,200), Step E self-check (5 components present, claims traceable, flag PRD030/031 discrepancy).
2. Compare `work/04-insight.md` vs `expected/04-insight.md`; reconcile seasonal-items discrepancy.
3. Optional: Postgres verify of the 12 queries vs `expected/03-results.md`.
4. Close Case 01 → update progress snapshot table → next case.

---

*Happy Learning!*
