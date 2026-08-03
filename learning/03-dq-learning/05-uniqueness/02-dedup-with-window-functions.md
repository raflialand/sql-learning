# Lesson 5.2: Deduplicating with Window Functions

Detecting duplicates is finding them. **Deduplicating** is removing the extras — usually keeping one row per entity. The tool for this is `ROW_NUMBER() OVER (PARTITION BY ...)`.

---

## The Dedup Pattern

```sql
WITH ranked AS (
    SELECT
        customer_id,
        first_name, last_name, email, phone, state,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id, first_name, last_name, email, rn
FROM ranked
WHERE rn > 1;   -- these are the duplicates
```

**Expected output (2 rows):**

| customer_id | first_name | last_name | email | rn |
|-------------|------------|-----------|-------|-----|
| 2 | Alice | Johnson | alice.johnson@example.com | 2 |
| 12 | Ivy | Clark | ivy.clark@example.com | 2 |

**How it works:** `PARTITION BY email` groups rows by email; `ORDER BY customer_id` orders them inside each group; `ROW_NUMBER()` assigns 1, 2, 3… So `rn = 1` is the row you *keep*, `rn > 1` are the duplicates.

---

## Keeping One Row Per Entity (the dedup result)

```sql
WITH ranked AS (
    SELECT
        customer_id, first_name, last_name, email, phone, state,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id, first_name, last_name, email, phone, state
FROM ranked
WHERE rn = 1
ORDER BY customer_id;
```

This is the **canonical dedup query**. It returns one row per email — the earliest `customer_id` wins.

---

## Choosing the "Keep" Row

The `ORDER BY` inside `OVER()` decides which row to keep. Business context selects the rule:

| Rule | ORDER BY | Keeps |
|------|----------|-------|
| Keep earliest | `ORDER BY customer_id ASC` | oldest record |
| Keep latest | `ORDER BY customer_id DESC` | newest record |
| Keep most complete | `ORDER BY (email IS NOT NULL) + (phone IS NOT NULL) DESC` | fullest record |
| Keep active | `ORDER BY is_active DESC, customer_id` | active over inactive |

```sql
-- Keep the most recent customer record (latest customer_id wins)
WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id DESC) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id, first_name, last_name, email, rn
FROM ranked
WHERE rn = 1
ORDER BY customer_id;
```

---

## Counting How Many Rows a Dedup Would Remove

```sql
WITH ranked AS (
    SELECT email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT COUNT(*) AS rows_to_remove
FROM ranked
WHERE rn > 1;
```

**Expected output: `2`** — exactly the two duplicate rows (customers 2 and 12).

---

## Important Warning: Don't DELETE Blindly

Real-world dedup is **never a raw DELETE**:

1. **Choose the keep rule with the business** — "keep earliest" isn't always right.
2. **Merge history first** — the duplicate may hold orders the kept row doesn't.
3. **Back up / flag** — prefer `UPDATE ... SET is_active = 0` or a `dup_of` column over hard deletes, for auditability.

```sql
-- SAFE approach: flag duplicates instead of deleting
WITH ranked AS (
    SELECT customer_id,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id,
       CASE WHEN rn = 1 THEN 'KEEP' ELSE 'DUPLICATE' END AS action
FROM ranked
ORDER BY customer_id;
```

---

## English Translation (of this lesson)

> "To deduplicate, I number rows within each entity group using ROW_NUMBER() OVER (PARTITION BY key). Row number 1 is the keeper; higher numbers are duplicates. The ORDER BY inside decides which row to keep — a business decision. And I never hard-delete duplicates; I flag or merge them."

---

## Key Takeaways

1. **`ROW_NUMBER() OVER (PARTITION BY <key> ORDER BY <choice>)`** is the dedup tool.
2. `rn = 1` keep, `rn > 1` duplicate.
3. The **keep rule is a business decision** (earliest/latest/most-complete/active).
4. **Never raw-DELETE** — merge, flag, or archive instead.
5. Same pattern works for any key: email, SKU, address.

**Coming up next:** Composite keys and fuzzy (near) duplicates.
