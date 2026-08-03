# Lesson 4.1: Missing Required Fields

**Completeness** answers one question: *is all expected data present?* The most direct check is "which rows are missing a value in a field that the business requires?"

Business context (Unit 02) tells you *which* fields are required. Completeness checks then enforce that decision.

---

## The Basic Missing-Field Check

```sql
-- Customers that marketing cannot reach (no email)
SELECT customer_id, first_name, last_name, email
FROM customers
WHERE email IS NULL;
```

**Expected output (2 rows):**

| customer_id | first_name | last_name | email |
|-------------|------------|-----------|-------|
| 5 | Carol | Davis | NULL |
| 14 | NULL | NULL | NULL |

---

## Required-Field Checks for Orders (finance context)

From the Unit 02 expectations sheet: `total_amount`, `customer_id`, and `order_date` are required.

```sql
-- Orders missing a required field
SELECT order_id, customer_id, order_date, total_amount, status
FROM orders
WHERE total_amount IS NULL
   OR customer_id IS NULL
   OR order_date IS NULL;
```

**Expected output (1 row):**

| order_id | customer_id | order_date | total_amount | status |
|----------|-------------|------------|--------------|--------|
| 4 | 3 | 2026-06-07 | NULL | pending |

Order 4 has no `total_amount` → finance cannot book its revenue. That's the *business meaning* of this completeness defect.

---

## Required Fields per Table (the checklist)

| Table | Business-required fields | Check pattern |
|-------|--------------------------|---------------|
| `customers` | email (marketing), first/last name | `WHERE email IS NULL OR first_name IS NULL` |
| `products` | sku, unit_price | `WHERE sku IS NULL OR unit_price IS NULL` |
| `orders` | total_amount, customer_id, order_date | `WHERE total_amount IS NULL OR ...` |
| `order_items` | qty, unit_price, total_price | `WHERE qty IS NULL OR unit_price IS NULL` |
| `addresses` | customer_id | `WHERE customer_id IS NULL` |
| `daily_sales` | total_revenue | `WHERE total_revenue IS NULL` |

---

## The Trap: `IS NULL` Won't Catch Empty Strings

In many systems, a missing value is stored as `''` or `' '` instead of NULL. Always check for both when the business rule is "must have a value":

```sql
-- Empty-string emails are just as useless as NULL emails
SELECT customer_id, email
FROM customers
WHERE email IS NULL
   OR TRIM(email) = '';
```

> **Tip:** `TRIM(email) = ''` catches `''`, `'   '`, and any whitespace-only value. Decide with the data owner whether empty strings should be treated as missing (usually yes).

---

## Grouping Missing Records by a Reason

Once you find missing records, **categorize them** — it focuses remediation:

```sql
-- Which states have customers we cannot email?
SELECT
    COALESCE(state, 'UNKNOWN') AS state,
    COUNT(*)                   AS customers_missing_email
FROM customers
WHERE email IS NULL
   OR TRIM(email) = ''
GROUP BY state
ORDER BY customers_missing_email DESC;
```

**Expected output:**

| state | customers_missing_email |
|-------|------------------------|
| UNKNOWN | 1 |
| TX | 1 |

Customer 14 (fully empty) has no state → bucket `UNKNOWN`. Customer 5 is in TX. Remediation can now be targeted ("re-contract these TX customers").

---

## English Translation (of this lesson)

> "Completeness means all required fields are present. I check required columns with `IS NULL` — and also catch empty strings with `TRIM(col) = ''` when the business treats them as missing. I group findings so remediation can be targeted."

---

## Key Takeaways

1. **Completeness = presence of required values** — driven by business rules from Unit 02.
2. The basic pattern is `WHERE <required_col> IS NULL`.
3. **Empty strings are missing too** — use `TRIM(col) = ''`.
4. **Group findings** (by state, date, region) to target remediation.
5. Multiple required fields → combine with `OR` in one check.

**Coming up next:** Completeness ratio — how *much* is complete.
