# Lesson 3.1: Row Counts and Cardinality

Profiling is the DQ engineer's first step with any dataset: **understand the shape of the data before you judge it.** You can't write a meaningful check until you know how many rows exist and how many distinct values live in each column.

---

## Row Counts — "How much data is there?"

The most basic profile metric. Every good audit starts here.

```sql
-- Row counts for every table (run against dq_learning)
SELECT 'customers' AS tbl, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'addresses',   COUNT(*) FROM addresses
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'daily_sales', COUNT(*) FROM daily_sales;
```

**Expected output for our dataset:**

| tbl | row_count |
|-----|-----------|
| customers | 15 |
| products | 12 |
| addresses | 12 |
| orders | 15 |
| order_items | 20 |
| daily_sales | 184 |

**Why it matters:** a row count is your *baseline*. If tomorrow `orders` drops from 15 to 3, something is wrong upstream (a load job failed, a filter changed). Row-count monitoring (Unit 11) catches that automatically.

---

## Count vs Count(Distinct) — The Cardinality Trap

`COUNT(*)` counts rows. `COUNT(DISTINCT col)` counts unique values in a column.

```sql
SELECT
    COUNT(*)               AS total_rows,
    COUNT(email)           AS non_null_emails,
    COUNT(DISTINCT email)  AS distinct_emails
FROM customers;
```

**Expected output:**

| total_rows | non_null_emails | distinct_emails |
|------------|-----------------|-----------------|
| 15 | 13 | 11 |

Let's decode it:

- **total_rows = 15** — every row counts, even fully empty ones.
- **non_null_emails = 13** — `COUNT(email)` skips NULLs. Only customers 5 (Carol) and 14 (empty row) have NULL email.
- **distinct_emails = 11** — two emails are duplicated: `alice.johnson@example.com` (customers 1 & 2) and `ivy.clark@example.com` (customers 11 & 12).

Check the arithmetic: 13 non-null emails. Four of them are two duplicate pairs (2×2 = 4 rows, but only 2 distinct values). The remaining 9 rows have 9 unique emails. So distinct = 2 (from pairs) + 9 = **11**. ✅

---

## Cardinality — How Distinct Is a Column?

**Cardinality** = the number of distinct values relative to row count.

| Cardinality | Meaning | Example |
|-------------|---------|---------|
| **High** (≈ row count) | Nearly every value is unique | `customer_id` (15 rows → 15 distinct) |
| **Low** (few values) | Column holds a small set | `status` (few allowed values) |
| **Unexpected** | Cardinality differs from expectation | `email` distinct < non-null → duplicates! |

```sql
-- Cardtinality comparison for key columns
SELECT
    COUNT(*)                     AS rows,
    COUNT(DISTINCT customer_id)  AS distinct_customer_id,
    COUNT(DISTINCT email)        AS distinct_email,
    COUNT(DISTINCT state)        AS distinct_state
FROM customers;
```

**Expected output:**

| rows | distinct_customer_id | distinct_email | distinct_state |
|------|----------------------|----------------|----------------|
| 15 | 15 | 11 | 11 |

**Interpretation:**
- `customer_id` is a good primary key (15/15 distinct) ✅
- `email` has 11 distinct vs 13 non-null → **duplicates exist** → uniqueness issue
- `state` has 11 distinct values for 15 rows. That is *higher* than the ~50 US states allow — because of **consistency defects**: `'CA'` vs `'California'`, `'OR'` vs `'Oregon'`, and lowercase `'tx'`. `COUNT(DISTINCT)` counts them all as different. This is a perfect example of why profiling *finds* a problem that a *consistency* check (Unit 08) must *resolve*.

---

## The Cardinality Pattern (memorize this)

```
COUNT(DISTINCT key) < COUNT(key)   →  duplicates in that column
COUNT(DISTINCT key) ≈ COUNT(*)     →  good unique identifier
COUNT(DISTINCT key) << COUNT(*)    →  low cardinality, possibly a category/enum
```

---

## English Translation (of this lesson)

> "Profiling starts with row counts — how much data is there? Then I compare count of values to count of distinct values. When distinct is less than non-null, duplicates exist. When distinct is close to the row count, the column is a good unique key. Cardinality tells me about the shape of every column before I write any real checks."

---

## Key Takeaways

1. **Row counts are your baseline** for every table — monitor them over time.
2. `COUNT(*)` vs `COUNT(col)` vs `COUNT(DISTINCT col)` tell you three different things.
3. **Cardinality** (distinct vs total) instantly reveals duplicates and enum-like columns.
4. The pattern `COUNT(DISTINCT key) < COUNT(key)` is your first uniqueness smell.

**Coming up next:** Column statistics — MIN, MAX, AVG, and standard deviation.
