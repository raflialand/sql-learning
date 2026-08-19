# Summary: SQL Analyst Lab Session

**Date:** 19 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3 queries drafted (Postgres) and reviewed vs sub-questions; fix plan agreed but NOT applied

---

## Completed

- Drafted Step 3 SQL queries in `work/03-queries.sql` (PostgreSQL dialect, `TO_CHAR`).
- Reviewed each query against the 12 sub-questions in `work/02-questions.md`.
- Verified two logic bugs against the actual SQLite data (read-only checks) and confirmed the dialect constraint (`TO_CHAR` does not exist in SQLite — verified `no such function: TO_CHAR`).

## Query review verdicts (12 sub-questions)

| # | Verdict | Note |
| --- | --- | --- |
| Q1a | ✅ logic | stray BRW001-only extra query should be removed |
| Q1b | ✅ | `is_active=1` filter harmless (inactive products have no sales) |
| Q1c | ✅ | — |
| Q2a | ❌ bug | `LAG OVER(ORDER BY month)` missing `PARTITION BY store_id` → MoM compares across stores |
| Q2b | ❌ missing | needs AOV + Order count × Store × Month MoM %, on the flagged store |
| Q3a | ✅ | — |
| Q3b | ❌ wrong | query = category revenue (duplicate of Q1b); needs AOV per category |
| Q3c | ⚠️ | `COUNT(order_id)` double-counts → use `COUNT(DISTINCT order_id)` |
| Q4a | ⚠️ | INNER JOIN hides zero-sales products; need LEFT JOIN + COALESCE + decile rule |
| Q4b | ✅ | — |
| Q4c | ✅ | — |
| Q4d | ✅ | — |

## Bug proof (from the data)

- Q2a as-written: BRW002 Jan-2025 shows MoM −6.1% (against BRW001!) when its first month must be `NULL`; BRW001 Feb shows +50.2% instead of true +51.8%.
- Q3c as-written: Beverage order count = 1,397 vs true 861 distinct orders.

## Key Takeaways

1. "Growing/shrinking" (Bucket 2) = MoM % change, not level — a high-revenue store can be shrinking; focus = largest absolute dollar loss (size × change), not lowest revenue and not steepest %.
2. Q4a has two requirements: bottom-decile band (~10% of 31 ≈ 3 products) PLUS an explicit zero-sales flag.
3. Basket context (Q4d) = distinct product count per order (1 → bought alone, >1 → add-on).
4. This project's verified dataset is SQLite; `work/03-queries.sql` is intentionally PostgreSQL (`TO_CHAR`), so it can't be verified with the SQLite helper `run_query.py` — verify in the user's Postgres instance instead.

## Mistakes / Notes

- None (review-only session; no queries executed against the lab DB by the user).

## Next Steps (fix plan — approved but NOT applied yet)

1. Q2a: `LAG(revenue) OVER(PARTITION BY store_id ORDER BY month)`.
2. Q2b: rebuild as AOV + Order count by Store × Month with MoM %; remove the two unrelated queries (order count by store; Merchandise quantity).
3. Q3b: AOV per Category = category revenue ÷ `COUNT(DISTINCT order_id)`.
4. Q3c: `COUNT(oi.order_id)` → `COUNT(DISTINCT oi.order_id)`.
5. Q4a: LEFT JOIN + `COALESCE(SUM(...),0)` to flag zero-sales products; keep bottom-decile (~3 of 31); derive flagged set for Q4b/c/d instead of hardcoding `PRD001/006/015`.
6. Cleanup: remove exploratory `SELECT *` statements; split file so each query is one standalone statement; remove stray BRW001-only query.
7. Verify queries in Postgres against `expected/03-results.md` data (load same retail data).
8. Then Step 4: insights + recommendations, and compare `work/` vs `expected/`.

---

# Summary: SQL Analyst Lab Session (continued — Q2a review + Q2b deep-dive)

**Date:** 19 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3: Q2a fixed & verified; Q2b locked (BRW003 = volume-driven); Q3b next

---

## Completed

- **Q2a fixed & verified:** added `PARTITION BY store_id` to the `LAG` window. Verified on data — BRW002 Jan-25 no longer shows bogus −6.1% (now `NULL`), BRW001 Feb-25 = +51.83% (true per-store MoM).
- **Focus store decided = BRW003** (biggest recurring dollar loss across the year).
- **Q2b built & locked:** two queries (count lever MoM % + AOV lever MoM %), scoped to `store_id = 'BRW003'`.
- **Diagnosis:** BRW003's May & Sep collapses are **volume-driven** (order count fell more than AOV).

## Focus-store decision (evidence from the data)

| Store | Bad months | Total $ lost | Pattern |
| --- | --- | --- | --- |
| BRW003 | 5 | −$2,848.75 | Two ~−$1.1k collapses (May, Sep) + recent small bleed |
| BRW001 | 6 | −$2,249.40 | Many small dips, none catastrophic |
| BRW002 | 4 | −$1,431.45 | Moderate dips |

**Rule:** focus = largest **absolute dollar** loss (size × change), NOT steepest % and NOT lowest revenue. Recurring > one-off. If no store is significantly shrinking, fall back to Bucket 1 level findings (model's BRW002 volume-gap example).

## Key learnings from the discussion

1. **Level vs change:** "shrinking" (Bucket 2) = negative MoM %, a %-change concept — a high-revenue store can be shrinking. Level questions live in Bucket 1.
2. **Volume vs basket:** `Revenue = Order count × AOV`. Order volume = traffic (`COUNT(*)`), basket size = money per visit (`AOV`). Volume problem → traffic lever (promos/footfall); basket problem → menu/price lever (upsell/bundles).
3. **Integer division trap:** integer ÷ integer truncates (`-12/32 = 0`). `* 100.0` must come **before** `/`, or cast to numeric (`(oc::numeric - LAG(oc))/LAG(oc)`). `COUNT(*)` is integer → trap; `SUM(total_amount)` is numeric → safe. `* 100` (no `.0`) does NOT help.
4. **Comparable levers:** absolute diff (`−12` orders) is not comparable to a % (−22.8%); both levers must be % (MoM) to diagnose.
5. **Q2b "basket size" ≠ Q4d "basket context":** AOV (money per order) vs distinct-item count per order (alone vs add-on). Same word, different metrics.
6. **Syntax:** `SELECT *` followed by another column needs a comma (`SELECT *, ROUND(...)` or explicit column list).

## Final locked Q2b queries (Postgres)

```sql
WITH monthly_order_count AS(
	SELECT
		TO_CHAR(order_date, 'YYYY-MM') AS month,
		store_id,
		COUNT(*) AS order_count
	FROM orders
	WHERE store_id = 'BRW003'
	GROUP BY month, store_id
)
SELECT *,
	ROUND((order_count - LAG(order_count) OVER(PARTITION BY store_id ORDER BY month)) * 100.0 / LAG(order_count) OVER(PARTITION BY store_id ORDER BY month), 2) AS count_mom_pct
FROM monthly_order_count;
```

```sql
WITH monthly_revenue AS(
	SELECT
		TO_CHAR(order_date, 'YYYY-MM') AS month,
		store_id,
		COUNT(*) AS order_count,
		ROUND(SUM(total_amount),2) AS revenue,
		ROUND(SUM(total_amount) / COUNT(*), 2) AS avg_order_value
	FROM orders
	WHERE store_id = 'BRW003'
	GROUP BY month, store_id
)
SELECT *,
	ROUND((avg_order_value - LAG(avg_order_value) OVER(PARTITION BY store_id ORDER BY month)) / LAG(avg_order_value) OVER(PARTITION BY store_id ORDER BY month) * 100.0, 2) AS aov_diff_pct
FROM monthly_revenue;
```

**Reading the result:** May-25 count −37.5% vs AOV −22.8%; Sep-25 count −28.6% vs AOV −14.9% → **volume-driven** (fewer orders, not smaller tickets). First row per store is `NULL` (expected).

## Mistakes / Notes

- `SELECT *` + ROUND without comma → syntax error.
- `count_diff` as absolute orders — not comparable to the AOV %; changed to `count_mom_pct`.
- `* 100.0` after `/` → all `0.00` (integer division); before `/` → correct.
- Q2a `LAG OVER(ORDER BY month)` without `PARTITION BY store_id` → MoM compared across stores.

## Next Steps

1. Q3b: AOV per Category = category revenue ÷ `COUNT(DISTINCT order_id)` (current query is category revenue = Q1b duplicate).
2. Q3c: `COUNT(oi.order_id)` → `COUNT(DISTINCT oi.order_id)` (Beverage 1,397 vs true 861).
3. Q4a: LEFT JOIN + `COALESCE(SUM(...),0)` to flag zero-sales products; keep bottom-decile (~3 of 31).
4. Q4b/c/d: derive flagged set from Q4a instead of hardcoding `PRD001/006/015`.
5. Cleanup: remove exploratory `SELECT *` statements; split statements; remove stray BRW001-only query.
6. Verify in Postgres; then Step 4: insights + recommendations; compare `work/` vs `expected/`.

---

# Mistake Log (cumulative)

Every mistake made during Case 01, tracked so I can review and avoid repeating them. Newest on top.

| # | Date | Mistake | Where it happened | Root cause | Lesson / Fix |
| --- | --- | --- | --- | --- | --- |
| 16 | 19-Aug | `* 100.0` placed **after** the `/` → all `0.00` | Q2b count lever | Integer division runs first (`-12/32 = 0`), then ×100 | Put `* 100.0` **before** `/` for integer columns, or cast (`(oc::numeric - LAG(oc))/LAG(oc)`) |
| 15 | 19-Aug | `count_diff` as **absolute** orders (−12) | Q2b | Can't compare "orders" against a % (−22.8%) | Both levers must be **% (MoM)** to diagnose volume vs basket |
| 14 | 19-Aug | `SELECT *` followed by `ROUND(...)` with no comma | Q2b | `*` already ends the select list | `SELECT *, ROUND(...)` or list columns explicitly |
| 13 | 19-Aug | Q3c `COUNT(oi.order_id)` double-counts multi-line orders | Q3c | An order with 3 line items counts 3× | `COUNT(DISTINCT oi.order_id)` (Beverage: 1,397 → 861) |
| 12 | 19-Aug | Q4a INNER JOIN hides zero-sales products | Q4a | Products with no `order_items` rows get dropped | LEFT JOIN + `COALESCE(SUM(...),0)` to surface & flag them |
| 11 | 19-Aug | Q3b answered **category revenue** (= Q1b duplicate) | Q3b | Missed the performance lens | AOV per category = revenue ÷ `COUNT(DISTINCT order_id)` |
| 10 | 19-Aug | Hardcoded `PRD001/006/015` in Q4b/c/d | Q4b/c/d | Manually typed the flagged set | Derive flagged set from Q4a output |
| 9 | 19-Aug | Q2a `LAG OVER(ORDER BY month)` without `PARTITION BY store_id` | Q2a | MoM compared **across stores** (BRW002 Jan = −6.1% bogus) | `OVER(PARTITION BY store_id ORDER BY month)` |
| 8 | 19-Aug | Q2b answered "total order count by store" — no month, no AOV, no MoM | Q2b | Wrong scope for a Growth Rates question | Q2b = AOV + Order count × Month with MoM %, on the **flagged** store only |
| 7 | 19-Aug | Q2b included a Merchandise-quantity query | Q2b | Unrelated exploration left in | Remove; Q2b is volume-vs-basket on the flagged store |
| 6 | 18-Aug | Drafted "which store has lowest AOV but highest order count" | Step 2 Bucket 4 | Duplicated the Bucket 3 store contest | It's a contest question (Bucket 3), not a "why" drill (Bucket 4) |
| 5 | 18-Aug | Q3 draft = Revenue split by Store/Category (verbatim Bucket 1) | Step 2 Bucket 3 | Forgot the performance lens | Rebuild around AOV / Order count for the head-to-head contest |
| 4 | 18-Aug | Drafted Order-count MoM + Revenue MoM with identical dimensions | Step 2 Bucket 2 | Redundant duplicates | Collapse into one headline (Revenue) + one driver (AOV/Count) |
| 3 | 18-Aug | "Month over month" mislabeled as a Trends question | Step 2 Bucket 2 | Confused level with change | MoM = Growth Rates (% change lens), not Trends |
| 2 | 18-Aug | Product proposed as a dimension | Step 1 | Same axis as Category | Product is a Category drill-down, not an independent axis |
| 1 | 18-Aug | Items sold proposed as a metric | Step 1 | Redundant with AOV (already baked in) | Keep Revenue / Order count / AOV only |

## Top 3 patterns to watch

1. **Units must match** (#15, #16): percentages only compare to percentages — always normalize levers to the same scale.
2. **Lens discipline** (#3, #5, #6, #8): each bucket has ONE lens (level / % change / contest / why). Reusing another bucket's lens = duplicate, not analysis.
3. **Never hardcode derived values** (#10, #13): let the query compute the set/count; don't type the answer in.

---

*Happy Learning!*
