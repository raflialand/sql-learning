# Lesson 4.3: Partial vs Full Completeness

Not all completeness is binary. A row can be **fully complete**, **partially complete**, or **fully empty** — and the distinction matters for how you handle it.

---

## The Three States

| State | Meaning | Example |
|-------|---------|---------|
| **Fully complete** | All required fields present | Customer 1 (all fields populated) |
| **Partially complete** | Some required fields missing | Customer 5 (missing email) |
| **Fully empty** | No meaningful data at all | Customer 14 (everything NULL) |

Fully empty rows are usually **junk to quarantine** — you can't trust them, and they poison every downstream aggregate. Partial rows might be salvageable with one field.

---

## Classifying Rows by Completeness

```sql
SELECT
    customer_id,
    first_name, last_name, email, phone, state,
    CASE
        WHEN email IS NULL AND phone IS NULL AND state IS NULL
             AND first_name IS NULL THEN 'fully empty'
        WHEN email IS NULL OR phone IS NULL OR state IS NULL
             OR first_name IS NULL THEN 'partially complete'
        ELSE 'fully complete'
    END AS completeness_level
FROM customers
ORDER BY completeness_level, customer_id;
```

**Expected output (key rows):**

| customer_id | first_name | email | phone | state | completeness_level |
|-------------|------------|-------|-------|-------|--------------------|
| 14 | NULL | NULL | NULL | NULL | fully empty |
| 5 | Carol | NULL | 555-111-2222 | TX | partially complete |
| 7 | Eve | eve.brown@example | NULL | FL | partially complete |
| ... | ... | ... | ... | ... | fully complete |

---

## Counting by Completeness Level

```sql
SELECT
    CASE
        WHEN email IS NULL AND phone IS NULL AND state IS NULL
             AND first_name IS NULL THEN 'fully empty'
        WHEN email IS NULL OR phone IS NULL OR state IS NULL
             OR first_name IS NULL THEN 'partially complete'
        ELSE 'fully complete'
    END AS completeness_level,
    COUNT(*) AS cnt
FROM customers
GROUP BY completeness_level;
```

**Expected output:**

| completeness_level | cnt |
|--------------------|-----|
| fully complete | 8 |
| partially complete | 6 |
| fully empty | 1 |

---

## The Handler's Decision Tree

| Level | Action |
|-------|--------|
| Fully complete | ✅ Proceed |
| Partially complete | Investigate which field; chase the missing value; document known gaps |
| Fully empty | Quarantine / exclude from analysis; likely a system glitch row |

---

## Example: Excluding Junk Rows from a Report

The fully empty customer (14) would corrupt metrics like "average signup age". Exclude or flag it:

```sql
SELECT
    COUNT(*) AS all_customers,
    SUM(CASE WHEN email IS NULL AND first_name IS NULL
             THEN 1 ELSE 0 END) AS fully_empty_customers,
    SUM(CASE WHEN email IS NULL AND first_name IS NULL
             THEN 0 ELSE 1 END) AS usable_customers
FROM customers;
```

**Expected output:** all 15, fully empty 1, usable 14.

> **Data-engineering note:** in a real pipeline you might *flag* the row with a `is_usable = 0` column instead of deleting it, preserving auditability.

---

## When "Full" Is Measured Across Tables

Completeness can also be *cross-table*: an order is only "complete" if it has at least one line item.

```sql
-- Orders with no line items at all (incomplete transaction)
SELECT o.order_id
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.item_id IS NULL;
```

**Expected output:** no rows (every order in the dataset has items — but this check should still run; it protects the integrity of transaction records).

---

## English Translation (of this lesson)

> "Completeness isn't just on/off. Rows can be fully complete, partially complete, or fully empty. I classify rows into these buckets, handle each differently — fully empty rows get quarantined, partial rows get investigated. I can also check cross-table completeness, like orders that must have at least one item."

---

## Key Takeaways

1. Completeness is a **spectrum**: full / partial / empty.
2. **Classify rows** with `CASE WHEN` into the three levels.
3. **Fully empty rows should be quarantined** or flagged, not silently analyzed.
4. Cross-table completeness (e.g., orders ↔ items) is part of the picture.
5. Decide handling rules with the **data owner** — deleting vs flagging is a business call.

---

## Unit 04 Exercises → practice completeness checks.

Move on to `exercises.md`.
