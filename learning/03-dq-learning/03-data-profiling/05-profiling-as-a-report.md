# Lesson 3.5: Profiling as a Report

Profiling is not a series of one-off queries — it's a **repeatable report** you can run any time you need to understand a dataset. This lesson shows how to consolidate profiling into a compact, reusable report.

---

## The Profiling Report Pattern

A good profiling report answers three questions for every table:

1. **How big is it?** (row count)
2. **How complete is it?** (NULL rates per column)
3. **How consistent is it?** (cardinality per column)

Here's a single consolidated report for `customers`:

```sql
SELECT
    'customers' AS dataset,
    COUNT(*)    AS row_count,
    COUNT(DISTINCT customer_id) AS distinct_ids,
    ROUND(SUM(customer_id IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_id,
    ROUND(SUM(first_name  IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_first_name,
    ROUND(SUM(last_name   IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_last_name,
    ROUND(SUM(email       IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_email,
    ROUND(SUM(phone       IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_phone,
    ROUND(SUM(state       IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_state,
    ROUND(SUM(signup_date IS NULL) * 100.0 / COUNT(*), 1) AS pct_null_signup
FROM customers;
```

**Expected output:**

| dataset | row_count | distinct_ids | pct_null_id | pct_null_first | pct_null_last | pct_null_email | pct_null_phone | pct_null_state | pct_null_signup |
|---------|-----------|--------------|-------------|----------------|---------------|----------------|----------------|----------------|-----------------|
| customers | 15 | 15 | 0.0 | 6.7 | 6.7 | 13.3 | 20.0 | 6.7 | 13.3 |

This one row is your whole `customers` profile. Read it: identity column 100% populated, email 13.3% missing, phone 20% missing.

---

## The Multi-Table Profiling Report

For a quick survey across the whole database, chain tables with `UNION ALL`:

```sql
SELECT 'customers'   AS tbl, COUNT(*) AS rows, COUNT(DISTINCT customer_id) AS distinct_keys FROM customers
UNION ALL SELECT 'products',   COUNT(*), COUNT(DISTINCT product_id) FROM products
UNION ALL SELECT 'addresses',  COUNT(*), COUNT(DISTINCT address_id) FROM addresses
UNION ALL SELECT 'orders',     COUNT(*), COUNT(DISTINCT order_id) FROM orders
UNION ALL SELECT 'order_items',COUNT(*), COUNT(DISTINCT item_id) FROM order_items
UNION ALL SELECT 'daily_sales',COUNT(*), COUNT(DISTINCT CONCAT(sale_date,'|',region_id)) FROM daily_sales;
```

**Expected output:**

| tbl | rows | distinct_keys |
|-----|------|---------------|
| customers | 15 | 15 |
| products | 12 | 12 |
| addresses | 12 | 12 |
| orders | 15 | 15 |
| order_items | 20 | 20 |
| daily_sales | 184 | 184 |

**Check for surprises:** distinct keys should equal rows for every table here — if any row-count ≠ distinct-key-count, the declared key isn't actually unique (a red flag to investigate in Unit 05).

---

## Comparing a Table to a Reference

When you have a clean reference (our `dq_clean_*` tables), the report becomes **comparative**:

```sql
-- Is the row count of customers sane relative to the clean reference?
SELECT
    (SELECT COUNT(*) FROM customers)        AS dirty_customers,
    (SELECT COUNT(*) FROM dq_clean_customers) AS clean_customers,
    (SELECT COUNT(*) FROM customers) - (SELECT COUNT(*) FROM dq_clean_customers) AS delta
```

**Expected output:** 15 vs 13 → delta **+2** (customers 14 and 15 only exist in the dirty table). A row-count delta is a legitimate finding: either extra junk or missing masters.

---

## The Profiling Report Template (use this as a starting point)

```
## PROFILING REPORT — <dataset name>
Date: <date>   |  Reference date: 2026-08-03

| Metric | Value | Finding |
|--------|-------|---------|
| Row count | <n> | baseline |
| Distinct keys | <n> | <ok / duplication?> |
| NULL rate — <col> | <pct>% | <needs check?> |
| NULL rate — <col> | <pct>% | <needs check?> |
| Min/Max — <numeric col> | <min> .. <max> | <implausible?> |
| Top frequencies — <categorical col> | <vals> | <typos/casing?> |

### Actions to take
- [ ] Rule to write (which dimension?)
- [ ] Follow-up check needed
```

---

## Profiling Drives Everything (the pipeline)

```
Profile report
   │  reveals
   ▼
Candidate issues (counts, stats, frequencies, NULLs)
   │  formalize into
   ▼
Rules per dimension (Units 04-10)  →  rules catalog (Unit 11)
```

Every future unit assumes you have a **profile report** in hand. It is your map of the data.

---

## English Translation (of this lesson)

> "Profiling is a repeatable report, not a one-off. I consolidate row counts, NULL rates, cardinality, min/max, and frequency into a single view per table, then compare it to clean references when available. The profile report is my map of the data — it tells me where to look before I write any formal rules."

---

## Key Takeaways

1. A profile report = **row count + NULL rates + cardinality + stats + frequencies** per table.
2. `UNION ALL` chains tables into one **database-level survey**.
3. Comparative profiling against a **clean reference** quantifies deltas.
4. The report feeds **rule-writing** in Units 04–10 and the **catalog** in Unit 11.

---

## Unit 03 Exercises → now practice profiling.

Move on to `exercises.md`.
