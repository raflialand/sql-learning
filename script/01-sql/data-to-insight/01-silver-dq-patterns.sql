-- =====================================================
-- data-to-insight: Silver DQ-dimension SQL patterns
-- =====================================================
-- Reusable check patterns for the 6 data-quality dimensions
-- (Completeness, Uniqueness, Validity, Accuracy, Consistency,
-- Timeliness). `sql-builder` adapts these per dataset.
--
-- RULE: profile the dataset, EVALUATE all 6 dimensions, then
-- APPLY only the effective subset for the current case.
-- A dimension that does not address a real quirk in the dataset
-- is documented as N/A with a reason — never applied blindly.
-- =====================================================

-- -------------------------------------------------------
-- SETUP (per dataset): raw tables already in bronze schema.
-- Reference the bronze table, build cleaned table in silver.
--   CREATE TABLE silver.<table> AS SELECT * FROM bronze.<table>;
-- -------------------------------------------------------

-- -------------------------------------------------------
-- 1. COMPLETENESS — missing / NULL / blank analysis
-- Applies when the dataset has optional columns or missing values.
-- -------------------------------------------------------
SELECT *
FROM silver.<table>
WHERE <col1> IS NULL
   OR <col2> IS NULL
   OR <col1> = ''
   OR <col2> = ' ';

-- Ratio view: how complete is each column?
SELECT
    COUNT(*)                                                        AS total_rows,
    COUNT(<col>)                                                    AS non_null,
    ROUND(100.0 * COUNT(<col>) / NULLIF(COUNT(*), 0), 2)            AS pct_complete
FROM silver.<table>;

-- -------------------------------------------------------
-- 2. UNIQUENESS — duplicate detection & dedup
-- Applies when a natural key should identify exactly one row.
-- -------------------------------------------------------
-- Detect duplicates on the primary/natural key:
SELECT
    <pk>,
    COUNT(*) AS row_num
FROM silver.<table>
GROUP BY <pk>
HAVING COUNT(*) > 1;

-- Dedup pattern (keep one row per grain key):
CREATE TABLE silver.cleaned_<table> AS
WITH dedup AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY <pk> ORDER BY <tiebreak_col>) AS row_num
    FROM silver.<table>
)
SELECT *
FROM dedup
WHERE row_num = 1;

-- -------------------------------------------------------
-- 3. VALIDITY — format, domain, range, reference checks
-- Applies when columns must obey a format or allowed set.
-- -------------------------------------------------------
-- Domain check (value in an allowed set):
SELECT DISTINCT <col>
FROM silver.<table>
WHERE <col> NOT IN ('ValueA', 'ValueB', 'ValueC')
   OR <col> IS NULL;

-- Range check (numeric / date bounds):
SELECT *
FROM silver.<table>
WHERE <amount_col> < 0
   OR <amount_col> <= 0
   OR <date_col> < '2025-01-01'
   OR <date_col> > '2026-12-31';

-- Format check (regex):
SELECT *
FROM silver.<table>
WHERE <col> !~ '^[A-Z]{3}[0-9]{3}$';   -- PostgreSQL regex

-- Reference check (foreign-key lookup):
SELECT *
FROM silver.<child>
WHERE <fk> NOT IN (SELECT <pk> FROM silver.<parent>);

-- -------------------------------------------------------
-- 4. ACCURACY — cross-field, master-data, business rules
-- Applies when a derived value can be cross-checked against its parts.
-- -------------------------------------------------------
-- Cross-field: total equals the sum of line items:
WITH computed AS (
    SELECT
        o.<id>,
        o.<total_col>,
        ROUND(SUM(oi.<qty> * oi.<unit_price>), 2) AS total_check
    FROM silver.<orders> o
    LEFT JOIN silver.<items> oi ON oi.<order_fk> = o.<id>
    GROUP BY o.<id>, o.<total_col>
)
SELECT *
FROM computed
WHERE <total_col> <> total_check;

-- Master-data diff (dirty vs clean reference):
SELECT *
FROM silver.<table> s
LEFT JOIN reference.<clean_table> c ON c.<pk> = s.<pk>
WHERE c.<pk> IS NULL
   OR s.<col> IS DISTINCT FROM c.<col>;

-- -------------------------------------------------------
-- 5. CONSISTENCY — orphans, cross-table, format/unit consistency
-- Applies when the same fact should agree across tables/rows.
-- -------------------------------------------------------
-- Orphan check (child with no parent):
SELECT c.*
FROM silver.<child> c
LEFT JOIN silver.<parent> p ON p.<pk> = c.<fk>
WHERE p.<pk> IS NULL;

-- Cross-table consistency (same value stored twice):
SELECT a.<key>, a.<col> AS a_val, b.<col> AS b_val
FROM silver.<table_a> a
JOIN silver.<table_b> b ON b.<key> = a.<key>
WHERE a.<col> IS DISTINCT FROM b.<col>;

-- Format/unit consistency (case / unit drift):
SELECT DISTINCT <col>, LOWER(<col>) AS normalized
FROM silver.<table>
WHERE <col> <> LOWER(<col>);

-- -------------------------------------------------------
-- 6. TIMELINESS — freshness, batch windows, future dates
-- Applies only to time-sensitive data (e.g. a date that must be
-- "now"-relative). For a static snapshot with no freshness need,
-- mark N/A with reason.
-- -------------------------------------------------------
-- Future-date check (relative to a reference date):
SELECT *
FROM silver.<table>
WHERE <date_col> > '2026-08-03';   -- reference date from the case

-- Freshness / lag:
SELECT MAX(<date_col>) AS latest, MIN(<date_col>) AS earliest
FROM silver.<table>;

-- Batch window check:
SELECT *
FROM silver.<table>
WHERE <date_col> < '2025-12-01'
   OR <date_col> > '2026-01-31';

-- =====================================================
-- USAGE NOTE
-- After running the checks, document the outcome per dimension:
--   [Completeness]  applied / N/A (reason)
--   [Uniqueness]    applied / N/A (reason)
--   [Validity]      applied / N/A (reason)
--   [Accuracy]      applied / N/A (reason)
--   [Consistency]   applied / N/A (reason)
--   [Timeliness]    applied / N/A (reason)
-- Only the applied dimensions produce cleaned_* tables in silver.
-- =====================================================
