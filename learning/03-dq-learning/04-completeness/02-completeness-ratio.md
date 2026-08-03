# Lesson 4.2: Completeness Ratio

Finding missing records is step one. The **completeness ratio** — what percentage of expected values are present — turns findings into a number you can govern with a threshold.

---

## The Completeness Ratio Formula

```
completeness ratio = (non-null count) / (total rows) × 100
```

The complement is the **NULL rate** you measured in Unit 03. Ratio = 100 − NULL rate.

---

## Per-Column Completeness

```sql
SELECT
    COUNT(*)                                  AS total_rows,
    COUNT(email)                              AS emails_present,
    ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS email_completeness_pct
FROM customers;
```

**Expected output:**

| total_rows | emails_present | email_completeness_pct |
|------------|----------------|------------------------|
| 15 | 13 | 86.7 |

86.7% complete means **13.3% missing** — for a marketing-critical field, that likely fails the threshold.

---

## Setting Thresholds with Business Context

The threshold depends on the use case (Unit 02):

| Field | Consumer | Threshold example |
|-------|----------|-------------------|
| `customers.email` | Marketing campaigns | ≥ 99% complete (hard stop below 98%) |
| `orders.total_amount` | Finance revenue | 100% complete (every order must have a total) |
| `customers.phone` | Support contact | ≥ 90% complete (nice-to-have) |
| `daily_sales.total_revenue` | Executive dashboard | 100% complete |

```sql
-- A completeness rule: fail if email completeness < 99%
SELECT
    CASE
        WHEN ROUND(COUNT(email) * 100.0 / COUNT(*), 1) >= 99 THEN 'PASS'
        ELSE 'FAIL'
    END AS email_completeness_check
FROM customers;
```

**Expected output: `FAIL`** (86.7% < 99%). This is how a completeness *rule with threshold* works — the exact pattern you'll catalog in Unit 11.

---

## Completeness of a Full Table (multi-column)

```sql
SELECT
    ROUND(COUNT(email)     * 100.0 / COUNT(*), 1) AS email_pct,
    ROUND(COUNT(phone)     * 100.0 / COUNT(*), 1) AS phone_pct,
    ROUND(COUNT(state)     * 100.0 / COUNT(*), 1) AS state_pct,
    ROUND(COUNT(signup_date)* 100.0 / COUNT(*), 1) AS signup_pct,
    ROUND(COUNT(first_name)* 100.0 / COUNT(*), 1) AS first_name_pct
FROM customers;
```

**Expected output:**

| email_pct | phone_pct | state_pct | signup_pct | first_name_pct |
|-----------|-----------|-----------|------------|----------------|
| 86.7 | 80.0 | 93.3 | 93.3 | 93.3 |

Every one of these can be compared against its business threshold in one glance.

---

## Row-Level Completeness (the "how full is each row" view)

Sometimes you want to know how complete each *row* is:

```sql
SELECT
    customer_id,
    (COALESCE(first_name, '') <> '') + (COALESCE(last_name, '') <> '') +
    (COALESCE(email, '') <> '') + (COALESCE(phone, '') <> '') +
    (COALESCE(state, '') <> '') AS fields_present,
    6 AS total_expected_fields
FROM customers
ORDER BY fields_present;
```

**Expected output:** customer 14 has `fields_present = 0` (fully empty). Everyone else has ≥ 3.

> Note: MySQL treats boolean expressions as 0/1, so you can add them. This is MySQL-specific — in other engines use `CASE WHEN ... THEN 1 ELSE 0 END`.

---

## The Completeness Report Pattern (reusable)

```sql
SELECT
    'orders.total_amount' AS field,
    COUNT(*) AS total,
    ROUND(COUNT(total_amount) * 100.0 / COUNT(*), 1) AS completeness_pct
FROM orders
UNION ALL
SELECT 'orders.status', COUNT(*),
       ROUND(COUNT(status) * 100.0 / COUNT(*), 1)
FROM orders
UNION ALL
SELECT 'orders.ship_city', COUNT(*),
       ROUND(COUNT(ship_city) * 100.0 / COUNT(*), 1)
FROM orders;
```

**Expected output:**

| field | total | completeness_pct |
|-------|-------|------------------|
| orders.total_amount | 15 | 93.3 |
| orders.status | 15 | 93.3 |
| orders.ship_city | 15 | 86.7 |

---

## English Translation (of this lesson)

> "The completeness ratio converts missing values into a percentage: present values over total rows. Each field gets a threshold from the business, and I write PASS/FAIL checks comparing the ratio to the threshold. I can also profile row-level completeness to find rows that are almost entirely empty."

---

## Key Takeaways

1. **Ratio = `COUNT(col) / COUNT(*) × 100`** — the completeness score.
2. Thresholds come from **business context** (finance = 100%, marketing = 99%, support = 90%).
3. A completeness check is a **PASS/FAIL** comparison against the threshold.
4. **Row-level completeness** finds "mostly empty" rows (like customer 14).
5. Build reusable **report patterns** with `UNION ALL`.

**Coming up next:** Partial vs full completeness.
