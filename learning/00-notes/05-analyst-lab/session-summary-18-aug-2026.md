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

---

# Summary: SQL Analyst Lab Session (continued — Buckets 3 & 4 locked)

**Date:** 18 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 2 complete; all 4 buckets locked in `work/02-questions.md`

---

## Completed

- **Bucket 3 — Performance Measurement (locked):**
  1. AOV by Store — efficiency contest, best vs worst in one question
  2. AOV by Category — stronger basket
  3. Order count by Category — volume/traffic driver
- **Bucket 4 — KPI Reporting (locked):**
  1. Q4a: bottom-decile Revenue products (~3 of 31) + zero-sales flag
  2. Q4b: price position (cheap/mid/expensive) — drill-down on `unit_price`
  3. Q4c: active vs inactive — drill-down on `is_active`
  4. Q4d: bought alone vs as add-ons in bigger orders — basket context
- **Wrote `work/02-questions.md`** — main question + 12 sub-questions across 4 buckets, each with metric × dimension and a "why it answers" note.

## Key Takeaways

1. Bucket 3 is a *contest* (head-to-head snapshot, no time axis, no % change); ranking raw Revenue ≈ Bucket 1's level split — the new lens is efficiency (AOV), not size.
2. Explained with a lemonade-stand analogy: 100 cups × $1 vs 30 cups × $3 — Revenue says Stand A wins, AOV says Stand B is the better performer.
3. Bucket 4 = the "why" behind a flagged number, digging one dimension deeper; you anchored on the bottom-decile product and drilled into price/status/basket.
4. "Highest store" vs "lowest store" is ONE ranking question, not two — best & worst come from a single ranked result.
5. Circular-trap caught: "lowest quantity sold" is redundant with bottom-decile revenue (already = low sales); "never purchased" kept as a real anomaly check (dataset has 2 inactive products).

## Mistakes / Notes

- Drafted "which store has lowest AOV but highest order count" → redirected: that's a Bucket 3 store contest duplicating Q3a, not a Bucket 4 "why" drill.
- Q3 initial draft (Revenue split by Store / Category) duplicated Bucket 1 verbatim → rebuilt around AOV / Order count to add the performance lens.

## Next Steps

1. Step 3: write SQL queries for the 12 sub-questions against `retail.db` (via `python ../sql-skill-push/_tools/run_query.py`), verify against `expected/03-results.md`.
2. Step 4: surface insights + recommendations (trend + fluctuation + anomaly + root cause + recommendation).
3. Compare `work/` vs `expected/` (01-scope, 02-questions, 03-queries, 03-results, 04-insight).

---

# Summary: SQL Analyst Lab Session (continued — Step 3 prep + window functions)

**Date:** 18 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 01 — Step 3 prep; no queries written yet

---

## Completed

- Clarified Step 3 scope: 12 locked sub-questions, but the model answer (`expected/03-queries.sql`) bundles them into 6 queries (e.g. Q1 outputs revenue + order count + AOV in one statement). Keeping the extra KPI drill-downs (Q4b price band, Q4c active flag, Q4d basket context) would mean ~9 queries.
- Walked through the Step 3 loop: one sub-question → one query → run → verify `(N rows)` count against `expected/03-results.md` → collect into `work/03-queries.sql`.
- Key tool constraint: `run_query.py` executes **one SQL statement per file** (whole file passed to `cur.execute`), so one query per file — that's why the model file says "split and run each block above a blank line."
- Learned the MoM % change window function: `LAG()` + `OVER (ORDER BY month)`.
- Translated the model Q4 query from SQLite to PostgreSQL.

## Key Takeaways

1. `LAG(col) OVER (ORDER BY x)` — each row "sees" the previous row; `(cur − prev) / prev × 100` = MoM % change. The `ORDER BY` inside `OVER` defines the previous row; the outer query's ORDER BY does NOT affect the window.
2. First row's MoM % is `NULL` (no previous period) — expected, not a bug.
3. SQLite vs Postgres: `LAG() OVER` is standard SQL, identical in both. Only the date formatter differs — `strftime('%Y-%m', ...)` (SQLite) → `TO_CHAR(order_date, 'YYYY-MM')` or `DATE_TRUNC('month', order_date)` (Postgres).
4. Chain-wide trend = Q1a revenue · month; store/category splits are level questions; MoM belongs to the Growth Rates bucket (% change lens).

## Mistakes / Notes

- None this session — approach discussion only; queries not yet written.

## Next Steps

1. Write and run Step 3 queries (SQLite helper first), verify against `expected/03-results.md`.
2. Optionally re-run the MoM query in Postgres for practice (TO_CHAR + LAG).
3. Step 4 insights + recommendations.
4. Compare `work/` vs `expected/`.

---

*Happy Learning!*
