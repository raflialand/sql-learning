# Retail Mart Table — Design Discussion (Case 01 Brew & Co.)

**Date:** 21 August 2026
**Topic:** Personal discussion — designing one mart table that answers every bucket question (all 12 sub-questions) of Case 01 Brew & Co.

---

## Context

- Question: given `retail.db` (the verified sql-skill-push beginner dataset) and `work/02-questions.md` (12 sub-questions across 4 buckets), can we build ONE mart table that answers every bucket question?
- Goal: replace ad-hoc per-question joins with a single denormalized fact table that each question reads via a simple `GROUP BY`.

---

## Dataset analysis (verified read-only on `retail.db`)

- 4 tables: `orders` (1,200), `order_items` (3,647), `products` (31), `customers` (350). 13 months (2025-01 → 2026-01), 3 stores (BRW001/002/003), 3 categories (Beverage 12, Food 10, Merchandise 9).
- **One revenue measure works** — `SUM(orders.total_amount)` = `SUM(oi.unit_price * oi.quantity)` = $70,234.10; `total_amount` equals the line sum for ALL 1,200 orders (0 mismatches). So the mart carries a single `line_revenue` and every existing verified number reproduces.
- **154 orders repeat a product on 2+ lines** → confirms Q4d's `COUNT(DISTINCT CASE ...)` lesson (#21); the mart must pre-stamp each order's basket size.
- **All 31 products have sales** (0 zero-sales products) — the zero-sales flag only matters if you LEFT JOIN from `products`.
- No sub-question slices by customer/payment method → those dims are omitted.

---

## Mart design — one fact table at the line grain

`mart_order_items`: one row per order-item line (3,647 rows), fully denormalized, derived flags pre-computed. Every bucket question becomes a `GROUP BY` on it.

**Columns:** `order_id, order_date, month_key, store_id, category, prod_id, prod_name, is_active, menu_price, price_band, quantity, line_revenue, distinct_products, alone_flag`

**Derived flags (computed before any WHERE — the #19 "windows before WHERE" lesson):**
- `price_band` = `NTILE(3)` per category → Cheap/Mid/Expensive (Q4b)
- `distinct_products` = distinct products per order, via a `basket` CTE (SQLite forbids `COUNT(DISTINCT ...) OVER`; two-CTE pattern matches the locked Q4b/Q4d pattern)
- `alone_flag` = 1 if `distinct_products = 1` (Q4d)

```sql
WITH basket AS (
    SELECT order_id, COUNT(*) AS line_count,
           COUNT(DISTINCT product_id) AS distinct_products
    FROM order_items GROUP BY order_id
),
price_band AS (
    SELECT prod_id,
           CASE NTILE(3) OVER (PARTITION BY category ORDER BY unit_price)
                WHEN 1 THEN 'Cheap' WHEN 2 THEN 'Mid' ELSE 'Expensive' END AS price_band
    FROM products
),
mart_order_items AS (
    SELECT o.order_id, o.order_date,
           substr(o.order_date,1,7) AS month_key, o.store_id,
           p.category, p.prod_id, p.prod_name, p.is_active, p.unit_price AS menu_price,
           pb.price_band, oi.quantity,
           ROUND(oi.unit_price * oi.quantity,2) AS line_revenue,
           b.distinct_products,
           CASE WHEN b.distinct_products = 1 THEN 1 ELSE 0 END AS alone_flag
    FROM order_items oi
    JOIN orders o   ON o.order_id  = oi.order_id
    JOIN products p ON p.prod_id   = oi.product_id
    JOIN basket b   ON b.order_id  = o.order_id
    LEFT JOIN price_band pb ON pb.prod_id = p.prod_id
)
SELECT * FROM mart_order_items;
```

---

## Bucket → answer mapping

| Q | Pattern on mart | Verifies against |
| --- | --- | --- |
| Q1a | `GROUP BY month_key` → `SUM(line_revenue)` | $4,000 → $6,360 → $4,519 ✓ |
| Q1b | `GROUP BY category` → `SUM` + share | Merch 60% ✓ |
| Q1c | `GROUP BY store_id` → `SUM` | 24,189 / 21,963 / 24,082 ✓ |
| Q2a | `GROUP BY store_id, month_key` → `LAG ... OVER(PARTITION BY store_id ORDER BY month_key)` | May −51.7%, Sep −39.2% ✓ |
| Q2b | same + `COUNT(DISTINCT order_id)` & `revenue/count` as AOV, both with MoM | count −37.5% vs AOV −22.8% ✓ |
| Q3a | `GROUP BY store_id` → `SUM(line_revenue)/COUNT(DISTINCT order_id)` | $59.43 / $57.20 / $58.88 ✓ |
| Q3b | `GROUP BY category` → AOV | $57.18 ≫ $18.08 > $17.13 ✓ |
| Q3c | `GROUP BY category` → `COUNT(DISTINCT order_id)` | 861 / 738 / 737 ✓ |
| Q4a | `GROUP BY prod_id` → `SUM(line_revenue)`, bottom decile (~3); LEFT JOIN `products` for zero-sales flag | Espresso/Cookie/Americano ✓ |
| Q4b | underperformers → read `price_band` (windowed over all products) | all Cheap ✓ |
| Q4c | underperformers → read `is_active` | all Active ✓ |
| Q4d | `COUNT(DISTINCT order_id)` vs `COUNT(DISTINCT CASE WHEN alone_flag=1 THEN order_id END)` | 2/98, 11/83, 4/119 ✓ |

---

## Design decisions / trade-offs

1. **Single revenue measure** — line revenue is proven identical to order `total_amount` on this DB, so one column serves chain/store/category/product levels. (If a future dataset drifts, order-level revenue must stay on `orders` and category splits on line revenue.)
2. **Line grain (3,647 rows)** — the finest grain answers every aggregation; a pre-aggregated cross-join cube would be ~3,627 mostly-empty rows and break distinct-order counting. Star-schema fact table wins.
3. **Zero-sales flag needs a `products` LEFT JOIN on top of the mart** — the mart joins *from* `order_items`, so unsold products wouldn't appear. All 31 sell in this dataset, but the flag logic stays correct.
4. **Q1a uses `SUM(line_revenue)`** instead of `SUM(total_amount)` — equal here, so the mart stays self-contained.
5. **`basket` CTE instead of `COUNT(DISTINCT ...) OVER`** — SQLite does not allow DISTINCT in aggregate window functions; also matches the locked two-CTE Q4b/d pattern.
6. **Windows before WHERE** (#19) — `price_band` is computed over the full `products` table before any underperformer filter.

---

## Proposed next steps

- Save the mart as `learning/02-sql-learning/sql-analyst-lab/01-brew-and-co/work/05-mart.sql` (SQLite, one statement → `run_query.py`-ready).
- Optional: add a Postgres variant (`TO_CHAR`/`DATE_TRUNC`) alongside.
- Verify all 12 outputs against `expected/03-results.md` after creation.
- Note: the mart is dataset-specific (retail.db); each case in the lab needs its own mart.

---

*Happy Learning!*

---

# Follow-up — Grain, Row Order, and the Materialized-Key Trap

**Date:** 24 August 2026
**Topic:** Continued discussion on `mart_order_items` — what defines the grain, whether it's ordered, and why the grain key vanishes when materializing.

---

## Grain and uniqueness

- The mart is **line-grained**: one row per `order_items` line (3,647 rows). The only guaranteed unique key is **`item_id`** (the `order_items` PK).
- `(order_id, order_date, store_id, product_id)` is **NOT** unique — 154 orders repeat a product on 2+ lines, so that combo yields duplicate mart rows for them. Grouping by it would collapse a 2-line order into 1 and under-count `quantity`/`line_revenue`.

## The invisible-grain problem

- **Grain is not visible from the columns alone.** Nothing in the mart's own SELECT list identifies the row.
- Someone assuming order grain would double-count revenue on the 154 repeat-line orders silently → that's how bad aggregations ship.
- Remedy principle: every mart should **declare** its grain ("one row = one order-item line" in the header comment) and, ideally, **prove** it (carry the grain key + sanity-check `COUNT(*) = COUNT(DISTINCT item_id)`).

## Row order — no default

- The mart has **no `ORDER BY`** (confirmed in `05-mart.sql`), so its row order is undefined — SQL sets are unordered by definition; order only exists via explicit `ORDER BY` (or `ORDER BY` inside a window).
- This holds for big-company marts too: no engine guarantees row order without `ORDER BY`.
- "Tidy" splits in two:
  - **Row order** — never tidy, and nobody should rely on it.
  - **Design tidiness** (documented grain, keys, naming, lineage) — big companies DO enforce this.
- Practical upshot: order only matters where a query needs it (e.g. the mart's Q2a/Q2b use `LAG ... OVER (PARTITION BY ... ORDER BY month_key)`).

## The materialized-key trap

- If you `CREATE TABLE mart_order_items AS SELECT ...`, the physical table **only has the projected columns** — `item_id` is not among them, so you cannot select it later. A materialized table inherits its columns from the query that built it.
- Fix (plan): add `oi.item_id` to the SELECT inside the mart CTE (both `05-mart.sql` and `05-mart-postgres.sql`) *before* creating the table, then verify `COUNT(*) = COUNT(DISTINCT item_id)` = 3,647 and re-check bucket outputs against `expected/03-results.md`.
- No restructuring needed — same grain, same joins; the row just becomes provably unique.

## Key takeaway

1. Grain lives in the source PK, not the projected columns — surface it (`item_id`) so the mart can prove its own grain.
2. SQL row order is never a guarantee; "tidy" is a design property, not a physical one.
3. Materialization keeps only what the query selects — project your grain key before you `CREATE TABLE ... AS`.

---

*Happy Learning!*
