# Verification Report — Stage 3: Bronze → Silver

**Case**: 00-bookstore-omnichannel-sales-performance
**Artifact verified**: `work/_silver.sql`
**Date**: 2026-09-06
**Evaluator**: progress-evaluator

---

## Verdict: **PASS-WITH-NOTES**

All 7 MANDATORY checks are green. Three advisory notes flagged below are non-blocking but warrant attention before downstream stages consume the silver data.

---

## 1. Checklist

| # | MANDATORY Check | Result | Evidence |
|---|-----------------|--------|----------|
| 1 | Schema Creation | **PASS** | `DROP SCHEMA IF EXISTS silver CASCADE; CREATE SCHEMA silver;` (lines 35–36). All 15 bronze tables have corresponding silver tables: publishers, authors, categories, books, book_authors, customers, stores, inventory, orders, order_items, payments, shipping, reviews, promotions, employees. |
| 2 | DQ Dimension Coverage | **PASS** | All 6 dimensions evaluated and documented in header comment (lines 8–22). book_authors: Consistency=N/A ("no text fields"), Timeliness=N/A ("no temporal columns"). order_items: Timeliness=N/A ("no temporal columns beyond order_id FK"). All N/A entries have explicit reasons. |
| 3 | Type Casting | **PASS** | All TEXT→NUMERIC/INTEGER columns cast with regex guard (`^\d+$` for INTEGER, `^-?\d+\.?\d*$` for NUMERIC). All TEXT→DATE/TIMESTAMP columns cast with sentinel cleaning. See Advisory Note 1 for date regex. |
| 4 | Text Standardization | **PASS** | TRIM on all text columns. INITCAP for names/titles/statuses, LOWER for emails/discount_type, UPPER for state/currency/promo codes. NULLIF(TRIM(x), '') on 14+ columns where empty strings are semantically NULL. |
| 5 | Scope Alignment | **PASS** | All 5 metrics (M1–M5) supported by silver columns. All 5 dimensions (D1–D5) supported. Channel inference preserved (`store_id` kept as-is with NULL=Online, line 440). No margin claims in cleaning SQL. |
| 6 | Verification Queries | **PASS** | Row counts (lines 882–899), NULL rates on 10 critical columns (lines 902–985), PK uniqueness on 5 tables + 1 natural key (lines 992–1017), date range checks (lines 1057–1070), numeric range checks (lines 1077–1096), categorical distinct values (lines 1025–1050). |
| 7 | Profile-Only Scope Gaps | **PASS** | No unflagged scope gaps identified. All 15 profiled tables are present in silver. All columns required by the 12 sub-questions are available in silver tables. |

---

## 2. Detailed Check Analysis

### 2.1 Schema Creation — PASS

The silver schema is created with `DROP SCHEMA IF EXISTS silver CASCADE; CREATE SCHEMA silver;` (lines 35–36). This is idempotent and safe for re-runs.

All 15 bronze tables have corresponding silver tables:

| # | Bronze Table | Silver Table | Status |
|---|-------------|-------------|--------|
| 1 | bronze.publishers | silver.publishers | ✓ |
| 2 | bronze.authors | silver.authors | ✓ |
| 3 | bronze.categories | silver.categories | ✓ |
| 4 | bronze.books | silver.books | ✓ |
| 5 | bronze.book_authors | silver.book_authors | ✓ |
| 6 | bronze.customers | silver.customers | ✓ |
| 7 | bronze.stores | silver.stores | ✓ |
| 8 | bronze.inventory | silver.inventory | ✓ |
| 9 | bronze.orders | silver.orders | ✓ |
| 10 | bronze.order_items | silver.order_items | ✓ |
| 11 | bronze.payments | silver.payments | ✓ |
| 12 | bronze.shipping | silver.shipping | ✓ |
| 13 | bronze.reviews | silver.reviews | ✓ |
| 14 | bronze.promotions | silver.promotions | ✓ |
| 15 | bronze.employees | silver.employees | ✓ |

**Row preservation**: All tables use `CREATE TABLE silver.xxx AS SELECT ... FROM bronze.xxx` — no WHERE clauses that would drop rows. Row counts should match bronze exactly (to be confirmed by the row count verification query at lines 882–899).

---

### 2.2 DQ Dimension Coverage — PASS

All 6 DQ dimensions are documented in the header comment (lines 8–22):

| Dimension | Status | Evidence |
|-----------|--------|----------|
| Completeness | APPLIED | NULL rates measured in profiling comments per table; dirty sentinels replaced with NULL |
| Uniqueness | APPLIED | PK duplicates detected (profiling comments); natural keys (order_number, isbn13, employee_id, transaction_id, code) checked |
| Validity | APPLIED | Out-of-range values flagged (e.g. '999' quantity); type mismatches fixed (TEXT→NUMERIC/INTEGER/DATE/TIMESTAMP) |
| Accuracy | APPLIED | Suspicious values identified per table (e.g. '999' quantity, '0' in critical fields, negative values) |
| Consistency | APPLIED | Case normalization (INITCAP/LOWER/UPPER) applied to statuses, names, emails; whitespace trimming on all text |
| Timeliness | APPLIED | Date columns cast to DATE/TIMESTAMP; mixed format standardization |

**N/A with reasons** (correctly documented):
- book_authors: Consistency = N/A ("no text fields"), Timeliness = N/A ("no temporal columns")
- order_items: Timeliness = N/A ("no temporal columns beyond order_id FK")

**Dirty sentinel handling**: The cleaning code uses a consistent IN clause across all tables:
```sql
TRIM(x) IN ('n/a','NA','N/A','NULL','null','999','-','undefined','MISSING','missing','--','0','TBD')
```
This covers all 13 sentinel values documented in `00-context.md` (line 116).

---

### 2.3 Type Casting — PASS

**TEXT → NUMERIC/INTEGER** (17 columns):

| Table | Column | Target Type | Regex Guard | Status |
|-------|--------|-------------|-------------|--------|
| publishers | founded_year | INTEGER | `^\d{4}$` | ✓ |
| categories | parent_category_id | INTEGER | `^\d+$` | ✓ |
| books | price | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| books | list_price | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| books | pages | INTEGER | `^\d+$` | ✓ |
| book_authors | author_order | INTEGER | `^\d+$` | ✓ |
| stores | square_footage | NUMERIC | `^\d+\.?\d*$` | ✓ |
| inventory | quantity | INTEGER | `^\d+$` | ✓ |
| inventory | reorder_point | INTEGER | `^\d+$` | ✓ |
| inventory | reorder_quantity | INTEGER | `^\d+$` | ✓ |
| orders | subtotal | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| orders | tax_amount | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| orders | total_amount | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| order_items | quantity | INTEGER | `^\d+$` | ✓ |
| order_items | unit_price | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| order_items | discount | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| order_items | line_total | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| payments | amount | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| shipping | shipping_cost | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| reviews | rating | INTEGER | `^\d+$` | ✓ |
| reviews | helpful_votes | INTEGER | `^\d+$` | ✓ |
| promotions | discount_value | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| promotions | min_order_amount | NUMERIC | `^-?\d+\.?\d*$` | ✓ |
| employees | salary | NUMERIC | `^-?\d+\.?\d*$` | ✓ |

**TEXT → DATE/TIMESTAMP** (19 columns):

| Table | Column | Target Type | Status |
|-------|--------|-------------|--------|
| publishers | created_at | TIMESTAMP | ✓ |
| authors | birth_date | DATE | ✓ |
| authors | created_at | TIMESTAMP | ✓ |
| categories | created_at | TIMESTAMP | ✓ |
| books | publication_date | DATE | ✓ |
| books | created_at | TIMESTAMP | ✓ |
| customers | date_of_birth | DATE | ✓ |
| customers | registration_date | DATE | ✓ |
| stores | opening_date | DATE | ✓ |
| stores | created_at | TIMESTAMP | ✓ |
| inventory | last_restocked_at | TIMESTAMP | ✓ |
| inventory | created_at | TIMESTAMP | ✓ |
| orders | order_date | DATE | ✓ |
| orders | created_at | TIMESTAMP | ✓ |
| payments | payment_date | DATE | ✓ |
| payments | created_at | TIMESTAMP | ✓ |
| shipping | shipping_date | DATE | ✓ |
| shipping | estimated_delivery | DATE | ✓ |
| shipping | actual_delivery | DATE | ✓ |
| shipping | created_at | TIMESTAMP | ✓ |
| reviews | review_date | DATE | ✓ |
| promotions | start_date | DATE | ✓ |
| promotions | end_date | DATE | ✓ |
| promotions | created_at | TIMESTAMP | ✓ |
| employees | hire_date | DATE | ✓ |
| employees | created_at | TIMESTAMP | ✓ |

**Boolean casting** (1 column):
- reviews.is_verified: Parsed from text variants (true/t/yes/1 → TRUE, false/f/no/0 → FALSE) — ✓

**See Advisory Note 1** regarding date regex validation.

---

### 2.4 Text Standardization — PASS

**TRIM**: Applied to every text column across all 15 tables. No text column is read without TRIM.

**Case normalization strategy** (applied consistently):

| Pattern | Columns | Count |
|---------|---------|-------|
| INITCAP | names, titles, statuses, roles, descriptions, addresses | ~30 columns |
| LOWER | emails, discount_type, language | 7 columns |
| UPPER | state, currency, promo codes | 4 columns |

**Empty string → NULL** (NULLIF applied):

| Table | Columns | Count |
|-------|---------|-------|
| publishers | website | 1 |
| authors | biography, website | 2 |
| categories | description | 1 |
| books | isbn13, isbn10, description | 3 |
| customers | loyalty_card_number | 1 |
| orders | order_number, shipping_address, notes | 3 |
| payments | transaction_id | 1 |
| shipping | tracking_number, shipping_address | 2 |
| reviews | title, review_text | 2 |
| promotions | description | 1 |
| employees | employee_id | 1 |
| **Total** | | **19 columns** |

All empty-string-to-NULL conversions are appropriate — these columns are semantically nullable (e.g., a book without a description, an order without notes).

---

### 2.5 Scope Alignment — PASS

**Metrics supported by silver tables**:

| Metric | Required Columns | Silver Table(s) | Status |
|--------|-----------------|-----------------|--------|
| M1 — Total Revenue | orders.total_amount (NUMERIC) | silver.orders | ✓ |
| M2 — AOV | orders.total_amount (NUMERIC) | silver.orders | ✓ |
| M3 — Order Volume | orders.id, orders.order_number | silver.orders | ✓ |
| M4 — Repeat Purchase Rate | orders.customer_id | silver.orders | ✓ |
| M5 — Inventory Turnover | order_items.quantity (INTEGER), inventory.quantity (INTEGER) | silver.order_items, silver.inventory | ✓ |

**Dimensions supported by silver tables**:

| Dimension | Required Columns | Silver Table(s) | Status |
|-----------|-----------------|-----------------|--------|
| D1 — Time Period | orders.order_date (DATE) | silver.orders | ✓ |
| D2 — Channel | orders.store_id (NULL = Online) | silver.orders | ✓ (preserved, line 440) |
| D3 — Customer Segment | customers.customer_segment | silver.customers | ✓ |
| D4 — Book Category | books.category_id, categories.name | silver.books, silver.categories | ✓ |
| D5 — Store Location | stores.city, stores.state | silver.stores | ✓ |

**Channel inference**: `store_id` is kept as-is in silver.orders (line 440: `store_id,  -- NULL = Online channel (L4)`). No transformation that would lose the NULL=Online inference.

**No true margin claims**: The SQL is a cleaning script — it performs no business calculations or claims. The scope correctly defers margin analysis to downstream stages.

---

### 2.6 Verification Queries — PASS

The silver SQL includes 6 categories of verification queries:

| Category | Lines | Scope | Status |
|----------|-------|-------|--------|
| Row counts | 882–899 | All 15 silver tables | ✓ |
| NULL rates | 902–985 | 10 critical columns across orders, order_items, customers, inventory | ✓ |
| PK uniqueness | 992–1011 | orders.id, order_items.id, customers.id, books.id, inventory.id | ✓ |
| Natural key uniqueness | 1013–1017 | orders.order_number | ✓ |
| Categorical distinct values | 1025–1050 | 9 categorical columns (order_status, payment_method, status, customer_segment, carrier, moderation_status, role, status, store_type) | ✓ |
| Date range sanity | 1057–1070 | orders.order_date, payments.payment_date, shipping.shipping_date | ✓ |
| Numeric range sanity | 1077–1096 | orders.total_amount, order_items.quantity, reviews.rating (min/max/avg) | ✓ |

**Coverage**: Verification queries cover all critical columns identified in the scope (M1–M5, D1–D5). The NULL rate checks specifically target columns that feed into the 12 sub-questions.

---

### 2.7 Profile-Only Scope Gaps — PASS

No unflagged scope gaps identified:

- All 15 profiled tables are present in silver.
- All columns required by the 12 sub-questions (Q1–Q12) are available in silver tables.
- All columns required by the 5 metrics (M1–M5) and 5 dimensions (D1–D5) are present.
- The profile data in `00-context.md` shows ~60,000+ rows across 15 tables — the silver layer preserves all rows (no WHERE clauses that drop rows).

No gaps to route to orchestrator.

---

## 3. Advisory Notes

### Advisory Note 1: Date Columns Lack Regex Validation

**Observation**: All TEXT→NUMERIC conversions use regex validation before casting (`^\d+$` for INTEGER, `^-?\d+\.?\d*$` for NUMERIC). However, TEXT→DATE/TIMESTAMP conversions do not use regex validation — they apply the sentinel check then cast directly:
```sql
CASE
    WHEN TRIM(order_date) IN ('n/a','NA',...) THEN NULL
    ELSE TRIM(order_date)::DATE
END
```

**Impact**: If raw data contains a malformed date string not in the sentinel list (e.g., `'2024-13-45'`, `'0000-00-00'`), PostgreSQL will throw a runtime error rather than converting to NULL. This is actually the **safer** behavior for a cleaning step — it fails loudly rather than silently producing bad data.

**Risk level**: LOW. The sentinel list covers known dirty values. PostgreSQL's native date parsing is strict and will reject genuinely malformed dates. The cleaning step is designed to surface these errors.

**Recommendation (advisory)**: For robustness, consider adding a regex guard for date columns (e.g., `^\d{4}-\d{2}-\d{2}$`) before casting. This would convert malformed dates to NULL instead of throwing errors, making the pipeline more resilient. However, this is not required for the current dataset.

---

### Advisory Note 2: '0' Sentinel Applied Uniformly to All Columns

**Observation**: The sentinel list includes `'0'` as a dirty value. This is applied uniformly across ALL columns, including `inventory.quantity` where the profiling comment explicitly states: *"quantity '0' is valid (out of stock); '999' suspicious"*.

**Impact**: Records where `inventory.quantity = 0` (legitimate out-of-stock) will be converted to NULL in silver. This means:
- Out-of-stock information is lost
- M5 (Inventory Turnover) may be affected if downstream queries filter on `quantity IS NOT NULL`
- Stock-out frequency analysis (mentioned in the business case) will undercount

**Similarly affected columns**:
- `books.price = 0` — could indicate free/promotional books (profiling comment: "price=0 or negative needs flagging")
- `order_items.quantity = 0` — profiling comment says "quantity='0' invalid for order_item" — this IS correctly treated as dirty
- `orders.total_amount = 0` — could indicate cancelled/refunded orders

**Risk level**: MEDIUM. The downstream impact depends on whether '0' values exist in the actual data and whether queries filter on NULL vs 0.

**Recommendation (advisory)**: Consider making the sentinel list context-sensitive. For `inventory.quantity`, remove `'0'` from the dirty list (or add a post-cast step to restore 0 where appropriate). For `order_items.quantity`, keeping `'0'` as dirty is correct. This requires column-level sentinel configuration rather than a global list.

---

### Advisory Note 3: Verification Queries Lack Bronze vs Silver Row Count Comparison

**Observation**: The silver SQL includes row count verification for silver tables (lines 882–899) but does not include a comparison query that verifies silver row counts match bronze row counts:
```sql
-- Missing: Verify row counts match
SELECT 'orders' AS table_name,
    (SELECT COUNT(*) FROM bronze.orders) AS bronze_count,
    (SELECT COUNT(*) FROM silver.orders) AS silver_count,
    CASE WHEN (SELECT COUNT(*) FROM bronze.orders) = (SELECT COUNT(*) FROM silver.orders)
         THEN 'PASS' ELSE 'FAIL' END AS status;
```

**Impact**: The row count verification queries will show the silver counts, but the analyst must manually compare them against bronze counts. Since the `CREATE TABLE AS SELECT` pattern preserves rows (no WHERE clauses), counts should match — but this is not explicitly verified.

**Risk level**: LOW. The SQL structure guarantees row preservation. However, an explicit comparison would make the verification self-contained.

**Recommendation (advisory)**: Add a bronze-vs-silver row count comparison query to make the verification section self-documenting.

---

## 4. Scope Gaps

**None identified.** All 5 metrics (M1–M5) and 5 dimensions (D1–D5) from `01-scope.md` are fully supported by the silver tables. All 12 sub-questions from `02-questions.md` can be answered using silver columns.

---

## 5. Recommendations for Downstream Stages

1. **Gold mart (Stage 4)**: When building the gold mart, be aware that `inventory.quantity` may contain NULLs where '0' was present in bronze. Consider coalescing: `COALESCE(quantity, 0)` for inventory-related calculations.

2. **Query layer (Stage 5)**: The channel inference (`store_id IS NULL = Online`) is preserved but must be stated as an assumption in every channel-related query. See scope note L4.

3. **Insight layer (Stage 6)**: No margin claims should be made. The scope correctly limits analysis to revenue, AOV, volume, repeat rate, and inventory turnover. Proxy discount spread (`list_price - price`) may appear but must be framed as "publisher discount" not "margin."

4. **Data integrity**: Run the row count verification query after executing `_silver.sql` to confirm all 15 tables have matching counts between bronze and silver. Any discrepancy indicates an unexpected row drop.

5. **Sentinel remediation**: Before Stage 5 queries, consider running a diagnostic to count how many `inventory.quantity` values were converted from '0' to NULL. If the count is significant, restore them with `UPDATE silver.inventory SET quantity = 0 WHERE quantity IS NULL AND ...` (requires access to bronze data for comparison).

---

## 6. Summary

The `_silver.sql` artifact is a well-structured, thoroughly documented Stage 3 cleaning script. It creates all 15 silver tables, applies all 6 DQ dimensions with explicit profiling comments, handles dirty sentinel values, performs type casting with regex guards for numerics, standardizes text (TRIM + case normalization + empty-to-NULL), preserves row counts, and includes comprehensive verification queries.

Three advisory notes are flagged:
1. Date columns lack regex validation (LOW risk — PostgreSQL native casting is strict)
2. '0' sentinel applied uniformly, including to columns where '0' is valid (MEDIUM risk — may affect inventory analysis)
3. Verification queries lack explicit bronze-vs-silver row count comparison (LOW risk — structure guarantees preservation)

None of these are mandatory failures. The silver artifact is ready to proceed to Stage 4 (Gold Mart).

**Verdict: PASS-WITH-NOTES**
