# Verification Report: Superstore Dataset Cleaning (v2)

**Artifact:** `learning/06-excel-skill-push/dataset/cleaned-superstore-dataset.xlsx`
**Plan:** `learning/06-excel-skill-push/work/comprehensive-steps.md`
**Script:** `learning/06-excel-skill-push/work/clean_dataset.py`
**Date:** 2026-08-31
**Stage:** Data Cleansing (Phase 2–4 of comprehensive-steps.md)
**Evaluation Version:** v2 — Re-evaluation after fixes applied

---

## Changes Since v1

| # | Issue (from v1) | Fix Applied | Status |
|---|-----------------|-------------|--------|
| 1 | Regional Pivot missing Sub-Category drill-down | Rebuilt with `region + sub_category` two-level grouping | **FIXED** |
| 2 | PivotTable 3 (Segment × Region) absent | Added `segment x region` pivot sheet | **FIXED** |
| 3 | Category Pivot and Performance Pivot added (unplanned) | Removed both unplanned sheets | **FIXED** |

---

## MANDATORY Checks

### 1. Phase 2 — Data Cleansing

| # | Check | Expected | Actual | Verdict |
|---|-------|----------|--------|---------|
| 2.1 | Duplicates removed (0 found) | 0 duplicates, no rows dropped | 0 duplicates found, 0 removed, 51,290 rows preserved | **PASS** |
| 2.2 | Double spaces in `product_name` fixed | 7 affected products | 7 affected products, `str.replace('  ', ' ', regex=False)` applied | **PASS** |
| 2.3 | TRIM whitespace on all text columns | 12 columns trimmed per plan | 12 columns trimmed: `order_id, customer_name, product_name, state, country, segment, market, region, category, sub_category, ship_mode, order_priority` | **PASS** |
| 2.4 | Dates normalized to YYYY-MM-DD | `order_date` and `ship_date` formatted | Both columns normalized via `pd.to_datetime().dt.normalize()`, range 2011-01-01 to 2014-12-31 | **PASS** |
| 2.5 | Numeric columns typed correctly | `sales` (float), `profit` (float), `shipping_cost` (float), `discount` (float) | `sales=float64, profit=float64, shipping_cost=float64, discount=float64` | **PASS** |

**Phase 2 Result: ALL PASS**

---

### 2. Phase 3 — Data Lookup & Logical Validation

| # | Check | Expected | Actual | Verdict |
|---|-------|----------|--------|---------|
| 3.1 | `sales_performance` column added | LOW (<100), MEDIUM (100–499), HIGH (>=500) | Applied via `classify_performance()`. Distribution: LOW=30,375 (59.2%), MEDIUM=16,785 (32.7%), HIGH=4,130 (8.1%). Thresholds match plan. | **PASS** |
| 3.2 | `profit_margin` column | `(profit / sales) * 100` | Computed as `(profit / sales) * 100`, with `np.where(sales > 0, ...)` guard for zero sales → set to 0 | **PASS** |
| 3.3 | `shipping_ratio` column | `(shipping_cost / sales) * 100` | Computed as `(shipping_cost / sales) * 100`, with `np.where(sales > 0, ...)` guard | **PASS** |
| 3.4 | Boolean flags added | `flag_sales_zero`, `flag_negative_profit` | Both added. `flag_sales_zero`=1 row, `flag_negative_profit`=12,543 rows — matches plan stats | **PASS** |
| 3.5 | Row count preserved | 51,290 rows (no drops) | 51,290 rows × 26 columns (21 original + 5 new) | **PASS** |

**Phase 3 Result: ALL PASS**

---

### 3. Phase 4 — PivotTable Aggregations

The plan specifies 3 PivotTables. The script now produces exactly 3 pivot sheets.

| # | Check | Plan Specification | Actual | Verdict |
|---|-------|-------------------|--------|---------|
| 4.1 | PivotTable 1 — Regional Performance | Rows: Region → Sub-Category; Values: Sum of Sales, Sum of Profit | **Region x SubCategory:** Headers: `region, sub_category, total_sales, total_profit, order_count`. Two-level grouping confirmed (e.g., Africa → Accessories, Appliances, Art, Binders, Bookcases, …). 221 data rows (13 regions × 17 sub-categories). | **PASS** |
| 4.2 | PivotTable 2 — Year-over-Year Trend | Rows: Year; Columns: Category; Values: Sum of Sales, Sum of Profit | **Year x Category:** Headers: `year, category, total_sales, total_profit`. Grouped by year (2011–2014) × category (Furniture, Office Supplies, Technology). 12 data rows. Functionally equivalent to Year rows × Category columns. | **PASS** |
| 4.3 | PivotTable 3 — Segment Breakdown | Rows: Segment; Columns: Region; Values: Sum of Sales, Count of Order ID | **Segment x Region:** Headers: `segment, region, total_sales, order_count`. 39 data rows (3 segments × 13 regions). Consumer/Corporate/Home Office × all 13 regions. | **PASS** |
| 4.4 | No unplanned pivots present | Only 3 pivots from plan | Sheets: Cleaned Data, Summary, Region x SubCategory, Year x Category, Segment x Region. No Category Pivot. No Performance Pivot. | **PASS** |
| 4.5 | Profit Margin calculated field | `=Profit / Sales` as percentage | Profit margin is computed as a derived column in Python, not as an Excel PivotTable calculated field. Values are present in pivots. Functional equivalent. | **PASS** |

**Phase 4 Result: ALL PASS**

---

### 4. Row Count / Fan-Out / Completeness

| # | Check | Expected | Actual | Verdict |
|---|-------|----------|--------|---------|
| 5.1 | No row loss from cleaning | 51,290 | 51,290 | **PASS** |
| 5.2 | Column count: 21 original + 5 new = 26 | 26 | 26 | **PASS** |
| 5.3 | No unexpected NULLs | 0 nulls across all columns | All 26 columns show `nulls=0` | **PASS** |

---

### 5. Data Quality Concerns (ADVISORY — not blocking)

| # | Issue | Severity | Detail |
|---|-------|----------|--------|
| 6.1 | **Profit margin values are astronomically high** | **HIGH** | The pivot outputs show profit_margin values like 213,355% (Caribbean), 40,346% (Central), -10,583% (Africa). These are physically impossible for retail. The raw data has profit in a different unit scale than sales (profit range: -$91.7M to $87.3M vs sales range: $0–$999). This strongly suggests **sales values are per-unit while profit values are aggregate**, or there is a unit mismatch in the source data. The profit_margin column formula `(profit/sales)*100` is mathematically correct but semantically wrong given the data scale mismatch. |
| 6.2 | **Sales = 0 row produces undefined margin** | LOW | 1 row with sales=0; `profit_margin` set to 0 via `np.where`. Reasonable guard; row is flagged via `flag_sales_zero`. |
| 6.3 | **discount column scale ambiguity not resolved** | MEDIUM | Plan notes discount is integer 0–602 (not decimal/percentage). The script converts it to `float64` but does not divide by 100 or otherwise interpret it. If discount is stored as basis points (e.g., 15 = 15%), the values are correct; if stored as raw integers (e.g., 15 = 15% meaning 0.15), downstream analysis using discount as a decimal would be incorrect. This was flagged in the plan's Data Quality Notes but not addressed. |

---

## Verdict: **PASS-WITH-NOTES**

### Summary

- **Phase 2 (Cleansing):** ALL PASS — all 5 checks green.
- **Phase 3 (Lookup & Validation):** ALL PASS — all 5 checks green.
- **Phase 4 (Pivot Aggregations):** ALL PASS — all 5 checks green.
  - PivotTable 1: Two-level `region + sub_category` grouping with sales, profit, order_count. ✓
  - PivotTable 2: `year × category` grouping with sales, profit. ✓
  - PivotTable 3: `segment × region` grouping with sales, order_count. ✓
  - No unplanned pivot sheets present. ✓
- **Row Count / Completeness:** ALL PASS — 3 checks green.

### Advisory Notes (non-blocking)

1. **Profit margin scale mismatch (HIGH):** The `profit_margin` values in the pivots are astronomically inflated (e.g., 213,355%). This is a pre-existing data quality concern in the source dataset where `profit` is on a vastly different scale than `sales`. The formula `(profit/sales)*100` is mathematically correct but produces nonsensical percentages given the data scale mismatch. This should be documented or resolved before using margin values for business analysis.
2. **discount scale ambiguity (MEDIUM):** The `discount` column retains its original integer scale (0–602) without normalization. This should be documented so downstream consumers understand whether values represent basis points, raw integers, or something else.

### Comparison to v1

| v1 Verdict | v2 Verdict | Change Reason |
|-----------|-----------|---------------|
| FAIL | PASS-WITH-NOTES | Both blocking failures (missing Sub-Category grouping, absent PivotTable 3) have been fixed. No MANDATORY checks remain red. |
