# Lesson 3.2: Column Statistics — MIN, MAX, AVG, STDDEV

Summary statistics expose out-of-range values and distribution shapes before you write a single validation rule. If `MIN(unit_price)` is negative, you already found a validity problem — profiling did the work for you.

---

## The Statistics Query

```sql
SELECT
    COUNT(*)              AS rows,
    COUNT(unit_price)     AS non_null,
    MIN(unit_price)       AS min_price,
    MAX(unit_price)       AS max_price,
    ROUND(AVG(unit_price), 2) AS avg_price,
    ROUND(STDDEV_POP(unit_price), 2) AS stddev_price
FROM products;
```

**Expected output:**

| rows | non_null | min_price | max_price | avg_price | stddev_price |
|------|----------|-----------|-----------|-----------|--------------|
| 12 | 12 | -5.00 | 199.99 | 40.08 | 63.05 |

**What it tells you:**
- `min_price = -5.00` → **a negative price exists** → validity defect (price must be > 0). You don't even need a separate check — the statistic screams at you.
- `max_price = 199.99` → plausible for an office chair. Fine.
- `avg_price = 40.08` with a large `stddev` (63.05) → prices are spread widely; expected for a catalog mixing a $1.99 pen and a $199.99 chair.

> **Rule of thumb:** every time a statistic is *implausible for the domain*, you've found a candidate defect. MIN below zero, MAX above a known bound, AVG way off expectation — all point to something to investigate.

---

## Nulls Hide from Statistics

Statistics silently ignore NULLs. `AVG`, `MIN`, `MAX`, `STDDEV` all skip NULL rows. So statistics tell you about *present* values only.

```sql
-- Compare against COUNT(*) to see NULL behavior
SELECT
    COUNT(*)         AS total_rows,
    COUNT(ship_city) AS non_null_city,
    COUNT(DISTINCT ship_city) AS distinct_city
FROM orders;
```

**Expected output:**

| total_rows | non_null_city | distinct_city |
|------------|---------------|---------------|
| 15 | 13 | 11 |

Two rows have NULL `ship_city` (orders 4 and 15). Profiling already spotted the completeness issue that Unit 04 will formalize.

---

## When Statistics Reveal a Consistency Problem

Statistics assume values are comparable. When formats differ, statistics get *weird*:

```sql
SELECT state, COUNT(*) AS cnt
FROM customers
WHERE state IS NOT NULL
GROUP BY state
ORDER BY state;
```

**Expected output:**

| state | cnt |
|-------|-----|
| AZ | 1 |
| CA | 2 |
| California | 1 |
| FL | 1 |
| MA | 1 |
| NY | 3 |
| OR | 1 |
| Oregon | 1 |
| TX | 1 |
| tx | 1 |
| WA | 1 |

`'CA'`, `'California'`, `'tx'` are the *same* logical state represented three different ways. A statistics query just showed you the consistency defect in Unit 08's domain. Profiling doesn't fix it — but it *points you right at it*.

---

## Statistics on Dates

Date statistics reveal timeliness issues instantly.

```sql
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    DATEDIFF(CURDATE(), MAX(order_date)) AS days_since_latest
FROM orders;
```

**Expected output (reference date 2026-08-03):**

| earliest_order | latest_order | days_since_latest |
|----------------|--------------|-------------------|
| 2026-06-01 | 2026-08-15 | -12 |

`days_since_latest = -12` (negative) means the most recent order is **12 days in the future**. A single `MAX` caught the future-date defect in Unit 09's domain. 

> **Profiling = free checks.** A well-built profile query surfaces defects across multiple dimensions before you write any explicit rules.

---

## The Profiling Cheat Sheet

| Metric | Question it answers |
|--------|---------------------|
| `COUNT(*)` | How many rows exist? |
| `COUNT(col)` vs `COUNT(*)` | How many NULLs in this column? |
| `COUNT(DISTINCT col)` | How many unique values? (cardinality) |
| `MIN(col)` | Is the lower bound plausible? |
| `MAX(col)` | Is the upper bound plausible? |
| `AVG(col)` | Is the typical value sensible? |
| `STDDEV_POP(col)` | How spread out is it? |
| `MIN/MAX(date)` | Are dates in the expected window? |

---

## English Translation (of this lesson)

> "Summary statistics are free detection. A negative minimum price, a future maximum date, or extra distinct states all reveal defects without writing validation rules. I profile with MIN, MAX, AVG, STDDEV, and counts — then use the anomalies I spot to drive my explicit checks."

---

## Key Takeaways

1. **Statistics surface validity defects** — an implausible MIN/MAX is a red flag.
2. Statistics **ignore NULLs** — always compare against `COUNT(*)`.
3. `GROUP BY` on categorical columns exposes **format inconsistency** (`CA` vs `California`).
4. Date statistics reveal **timeliness defects** (future dates, stale data).
5. Profiling finds candidates; the dimension units turn them into formal rules.

**Coming up next:** Frequency distributions.
