# Lesson 3.4: NULL-Rate Analysis

NULLs are the most common data quality problem — and the most common profiling target. The **NULL rate** is the percentage of rows where a column has no value. It directly feeds the Completeness dimension (Unit 04).

---

## The One-Query NULL Report

This query computes the NULL rate for every column of a table in a single pass:

```sql
SELECT
    COUNT(*)                                        AS total_rows,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END)  AS null_email,
    ROUND(SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_null_email,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END)  AS null_phone,
    ROUND(SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_null_phone,
    SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) AS null_signup,
    ROUND(SUM(CASE WHEN signup_date IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_null_signup
FROM customers;
```

**Expected output:**

| total_rows | null_email | pct_null_email | null_phone | pct_null_phone | null_signup | pct_null_signup |
|------------|-----------|----------------|------------|----------------|-------------|-----------------|
| 15 | 2 | 13.3 | 3 | 20.0 | 2 | 13.3 |

**Decode:** 2 of 15 customers (13.3%) are missing an email — that's marketing reach lost. 3 (20%) missing a phone. 2 missing signup date (customers 8 and 14).

> **TIP — the trick that makes this compact:** `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` counts violations in one aggregate pass, and `COUNT(*)` gives the denominator. This pattern powers your rule catalog later.

---

## A Generic NULL Profile (any table)

Here's a reusable pattern — one row per column instead of one column per column:

```sql
SELECT
    'customers' AS tbl,
    'email'     AS col,
    COUNT(*) AS total_rows,
    SUM(email IS NULL) AS null_count,
    ROUND(SUM(email IS NULL) * 100.0 / COUNT(*), 1) AS null_pct
FROM customers
UNION ALL
SELECT 'customers', 'phone', COUNT(*), SUM(phone IS NULL),
       ROUND(SUM(phone IS NULL) * 100.0 / COUNT(*), 1)
FROM customers;
```

> MySQL lets you write `SUM(email IS NULL)` — a boolean is 1/0. Handy, but the explicit `CASE WHEN` form is more portable (works in SQL Server, PostgreSQL, etc.). Use whichever you prefer; we'll favor `CASE WHEN` for portability.

---

## NULL vs Empty String vs Zero — They're Different

Profiling must distinguish three different "no value" states:

```sql
SELECT
    COUNT(*)                                   AS total,
    SUM(email IS NULL)                         AS null_values,
    SUM(email = '')                            AS empty_strings,
    SUM(email IS NOT NULL AND email = '')      AS whitespace_or_empty
FROM customers;
```

- **NULL** — the value was never provided.
- **`''`** (empty string) — provided but empty; often means "unknown" or a bad form default.
- **`0` or `' '`** — sometimes used as a placeholder, but that's a *validity* concern.

In our dataset `email` NULLs = 2, and there are no empty-string emails — but you must always check. A column could have 10,000 `''` values and 0 NULLs; profiling only the NULL count would miss it entirely.

---

## NULL Rates Across a Whole Table (powerful)

The most useful profile — every column, its NULL rate, sorted:

```sql
SELECT
    COUNT(*)                                   AS total_rows,
    SUM(customer_id IS NULL)                   AS null_customer_id,
    SUM(first_name IS NULL)                    AS null_first_name,
    SUM(last_name IS NULL)                     AS null_last_name,
    SUM(email IS NULL)                         AS null_email,
    SUM(phone IS NULL)                         AS null_phone,
    SUM(state IS NULL)                         AS null_state,
    SUM(signup_date IS NULL)                   AS null_signup,
    SUM(is_active IS NULL)                     AS null_is_active
FROM customers;
```

**Expected output:**

| total_rows | null_customer_id | null_first | null_last | null_email | null_phone | null_state | null_signup | null_is_active |
|------------|------------------|------------|-----------|------------|------------|------------|-------------|----------------|
| 15 | 0 | 1 | 1 | 2 | 3 | 1 | 2 | 0 |

Customer 14 is the fully empty row — it drives most of the NULL counts. A profiling pass finds it instantly.

---

## NULL Rate → Completeness Rule

The NULL rate becomes a **rule with a threshold**:

- **Rule:** `email` must be NULL in ≤ 1% of customer rows.
- **Check:** `SELECT ... SUM(email IS NULL) * 100.0 / COUNT(*)` → currently 13.3% → **FAIL**.

You'll formalize this in Unit 04. Profiling provides the *number*; the completeness unit turns it into a *governed rule*.

---

## English Translation (of this lesson)

> "I profile NULL rates for every column with SUM(CASE WHEN ... IS NULL) over COUNT(*). I distinguish NULL, empty string, and zero — they're different defects. A NULL rate above the business threshold becomes a completeness rule. NULL analysis is the bridge between profiling and the completeness dimension."

---

## Key Takeaways

1. **NULL rate = `SUM(col IS NULL) / COUNT(*)`** — compute per column.
2. Distinguish **NULL vs empty string vs zero** — they need different handling.
3. One **generic pattern** profiles any table; reuse it everywhere.
4. NULL-rate numbers feed the **completeness rules** in Unit 04.

**Coming up next:** Profiling as a report.
