# Lesson 3.3: Frequency Distributions

A **frequency distribution** shows how often each value appears. It is the single most revealing profile for categorical data — it exposes typos, unexpected values, and skewed distributions at a glance.

---

## The Classic Frequency Query

```sql
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status
ORDER BY cnt DESC;
```

**Expected output:**

| status | cnt |
|--------|-----|
| shipped | 9 |
| pending | 2 |
| Shipped | 1 |
| SHIPPED | 1 |
| shippd | 1 |
| cancelled | 1 |

**Read the distribution:**
- The dominant value `shipped` appears 9×.
- But `Shipped`, `SHIPPED`, and `shippd` all represent the *same* status. Case differences (consistency) and a typo (validity) inflate the value count.
- One `cancelled`, two `pending` — fine.

**Business impact:** if Ops automation matches on exact `'shipped'`, the 3 variant-status orders (orders 8, 9, 10) would never be processed correctly. The distribution made the defect visible in one glance.

---

## Frequency on Numeric Columns

For numeric data, bucketing turns a distribution into insight:

```sql
SELECT
    CASE
        WHEN unit_price < 0   THEN 'negative'
        WHEN unit_price = 0   THEN 'zero'
        WHEN unit_price < 50  THEN '0-50'
        WHEN unit_price < 100 THEN '50-100'
        WHEN unit_price < 200 THEN '100-200'
        ELSE '200+'
    END AS price_band,
    COUNT(*) AS cnt
FROM products
GROUP BY price_band
ORDER BY price_band;
```

**Expected output:**

| price_band | cnt |
|------------|-----|
| negative | 1 |
| zero | 1 |
| 0-50 | 8 |
| 100-200 | 2 |

**Read the distribution:** the `negative` and `zero` buckets are *impossible* for a product catalog — those are validity defects surfaced by bucketing. (Check: 29.99, 29.99, 49.99, 4.99, 1.99, 7.99, 4.99, 5.99 → 8 rows in 0-50; 199.99, 149.99 → 2 rows in 100-200.)

---

## Frequency on Customer Data

```sql
SELECT state, COUNT(*) AS cnt
FROM customers
WHERE state IS NOT NULL
GROUP BY state
ORDER BY cnt DESC;
```

**Expected output:**

| state | cnt |
|-------|-----|
| NY | 3 |
| CA | 2 |
| AZ | 1 |
| California | 1 |
| FL | 1 |
| MA | 1 |
| OR | 1 |
| Oregon | 1 |
| TX | 1 |
| tx | 1 |
| WA | 1 |

The distribution shows `NY` (3) as dominant, then a flat tail. But `California`/`CA` and `Oregon`/`OR` and `tx` reveal the normalization problem. Frequency distributions are the *fastest* way to find messy categorical data.

---

## Frequency + Percentage

Add percentages to put counts in context:

```sql
SELECT
    status,
    COUNT(*) AS cnt,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders
GROUP BY status
ORDER BY cnt DESC;
```

| status | cnt | pct |
|--------|-----|-----|
| shipped | 9 | 60.00 |
| pending | 2 | 13.33 |
| Shipped | 1 | 6.67 |
| SHIPPED | 1 | 6.67 |
| shippd | 1 | 6.67 |
| cancelled | 1 | 6.67 |

> **Note:** the `OVER ()` window function computes the grand total (15) — you'll master it in Unit 10.

---

## Using Frequency to Drive Checks

A frequency distribution is a *smell detector*. When you see values that shouldn't exist (typos, wrong case, out-of-range buckets), you then write the *formal* check in the relevant dimension unit:

| Smell found | Formal check lives in |
|-------------|----------------------|
| `Shipped` vs `shipped` | Unit 06 Validity / Unit 08 Consistency |
| `shippd` typo | Unit 06 Validity |
| `negative` / `zero` prices | Unit 06 Validity |
| `CA` vs `California` | Unit 08 Consistency |

---

## English Translation (of this lesson)

> "Frequency distributions show me how often each value appears. For categorical data they instantly reveal typos, wrong casing, and unexpected values. For numeric data, bucketing reveals impossible ranges. I use distributions to find smells, then formalize them into dimension-specific checks."

---

## Key Takeaways

1. `GROUP BY ... ORDER BY cnt DESC` is the **frequency query** you'll use constantly.
2. Distributions instantly expose **typos, casing variants, and unexpected values**.
3. **Bucketing** numbers with `CASE WHEN` reveals impossible ranges.
4. Percentages give context via window functions (`OVER ()`).
5. Distribution smells → formal checks in later units.

**Coming up next:** NULL-rate analysis.
