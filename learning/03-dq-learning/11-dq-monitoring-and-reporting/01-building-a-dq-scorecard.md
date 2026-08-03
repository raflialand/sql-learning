# Lesson 11.1: Building a DQ Scorecard

Monitoring means **measuring quality repeatedly over time**, not once. A **DQ scorecard** gives every dataset a per-dimension pass/fail status and an overall score — the report executives and stewards actually read.

---

## Scorecard Design

One row per dimension, one score per rule. The standard format:

| Dimension | Rule | Status | Metric | Threshold |
|-----------|------|--------|--------|-----------|
| Completeness | email not NULL | FAIL | 86.7% | ≥ 99% |
| Completeness | total_amount not NULL | FAIL | 93.3% | 100% |
| Uniqueness | no dup emails | FAIL | 2 pairs | 0 |
| Validity | email format | FAIL | 2 bad | 0 |
| Accuracy | item total matches | FAIL | 1 bad | 0 |
| Consistency | no orphans | FAIL | 3 | 0 |
| Timeliness | no future dates | FAIL | 1 | 0 |

The scorecard is just a **view** over your existing checks (Units 04–10), expressed as a table.

---

## The Scorecard Query (customers)

```sql
SELECT
    'Completeness'  AS dimension,
    'email not NULL' AS rule,
    ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS metric,
    99.0 AS threshold,
    CASE WHEN COUNT(email) * 100.0 / COUNT(*) >= 99 THEN 'PASS' ELSE 'FAIL' END AS status
FROM customers
UNION ALL
SELECT
    'Uniqueness',
    'no duplicate emails',
    COUNT(*),
    0,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT email FROM customers
    WHERE email IS NOT NULL
    GROUP BY email HAVING COUNT(*) > 1
) dupes
UNION ALL
SELECT
    'Validity',
    'email format valid',
    COUNT(*),
    0,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
```

**Expected output:**

| dimension | rule | metric | threshold | status |
|-----------|------|--------|-----------|--------|
| Completeness | email not NULL | 86.7 | 99.0 | FAIL |
| Uniqueness | no duplicate emails | 2 | 0 | FAIL |
| Validity | email format valid | 2 | 0 | FAIL |

Three FAILs already — the scorecard compresses your audit into one readable table.

---

## Adding an Overall Score

A simple score: percentage of PASSed rules.

```sql
WITH scorecard AS (
    SELECT 'Completeness' AS dimension, 'email not NULL' AS rule,
           ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS metric, 99.0 AS threshold,
           CASE WHEN COUNT(email) * 100.0 / COUNT(*) >= 99 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM customers
    UNION ALL
    SELECT 'Uniqueness', 'no duplicate emails', COUNT(*), 0,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM (SELECT email FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1) d
)
SELECT
    COUNT(*)                                  AS total_rules,
    SUM(status = 'PASS')                      AS passed,
    SUM(status = 'FAIL')                      AS failed,
    ROUND(SUM(status = 'PASS') * 100.0 / COUNT(*), 0) AS overall_score
FROM scorecard;
```

**Expected output:**

| total_rules | passed | failed | overall_score |
|-------------|--------|--------|---------------|
| 2 | 0 | 2 | 0 |

---

## The Multi-Dataset Scorecard

For monitoring many tables, structure by table + dimension:

```sql
SELECT 'customers' AS dataset, 'Completeness' AS dimension,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS metric, 99.0 AS threshold,
       CASE WHEN COUNT(email) * 100.0 / COUNT(*) >= 99 THEN 'PASS' ELSE 'FAIL' END AS status
FROM customers
UNION ALL
SELECT 'orders', 'Completeness',
       ROUND(COUNT(total_amount) * 100.0 / COUNT(*), 1), 100.0,
       CASE WHEN COUNT(total_amount) * 100.0 / COUNT(*) >= 100 THEN 'PASS' ELSE 'FAIL' END
FROM orders
UNION ALL
SELECT 'products', 'Validity',
       ROUND(SUM(unit_price > 0) * 100.0 / COUNT(*), 1), 100.0,
       CASE WHEN SUM(unit_price > 0) * 100.0 / COUNT(*) >= 100 THEN 'PASS' ELSE 'FAIL' END
FROM products;
```

**Expected output:**

| dataset | dimension | metric | threshold | status |
|---------|-----------|--------|-----------|--------|
| customers | Completeness | 86.7 | 99.0 | FAIL |
| orders | Completeness | 93.3 | 100.0 | FAIL |
| products | Validity | 83.3 | 100.0 | FAIL |

---

## Scorecard Best Practices

1. **Store rules as a catalog** (Lesson 11.2), generate the scorecard from it.
2. **Track over time** — keep a history table so you can show trends ("quality fell this week").
3. **Weight by severity** — a Finance accuracy failure should weigh more than a cosmetic one.
4. **Version thresholds** — document who set them and why.
5. **Make it a VIEW or scheduled table** so it's always current.

---

## English Translation (of this lesson)

> "A DQ scorecard is a table: one row per rule, showing the metric, the threshold, and PASS/FAIL per dimension. It compresses my audit into something executives read. I add an overall score (% rules passed) and structure by dataset and dimension. The scorecard is generated from the same checks I already built."

---

## Key Takeaways

1. **Scorecard = metric + threshold + status per rule**, grouped by dimension.
2. Compute an **overall score** = % rules passed.
3. Structure by **dataset → dimension → rule** for multi-table monitoring.
4. **Track over time** and **weight by severity** for real monitoring value.
5. The scorecard reuses every check you built in Units 04–10.

**Coming up next:** The DQ rule catalog.
