# Lesson 6.1: Format Validation

**Validity** answers: *does the value conform to its defined format and domain?* It is NOT about whether the value is true (that's accuracy) — just whether it obeys the rules.

The workhorse for format checks in MySQL is **`REGEXP`** (regular expressions).

---

## The Email Format Check

A valid email looks like `local@domain.tld`. The classic pattern:

```sql
SELECT customer_id, email
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
```

**Expected output (2 rows):**

| customer_id | email |
|-------------|-------|
| 6 | david.wilson@@example.com |
| 7 | eve.brown@example |

**Why these two?** Let's check each non-null email against the pattern:

- `alice.johnson@example.com` ✅ valid
- `bob.smith@example.com` ✅ valid
- `bob@example.com` ✅ valid (has `@` + domain + TLD)
- `david.wilson@@example.com` ❌ double `@@`
- `eve.brown@example` ❌ no TLD (`.example` has no dot)
- `frank.miller@example.com` ✅
- `grace.lee@example.com` ✅
- `henry.adams@example.com` ✅
- `ivy.clark@example.com` ✅
- `jack.white@example.com` ✅
- `kevin.king@example.com` ✅

> **Note:** `bob@example.com` (customer 4) *passes* the format check — it is well-formed. The regex only tests format, not whether the address is real (that would be accuracy).

---

## Anatomy of the Email Regex

```
^[A-Za-z0-9._%+-]+    local part: letters, digits, . _ % + - (one or more)
@                     the @ separator
[A-Za-z0-9.-]+        domain: letters, digits, dots, dashes
\.                    a literal dot
[A-Za-z]{2,}$         TLD: 2+ letters, at end
```

> `^` anchors the start, `$` anchors the end — without them, `email NOT REGEXP '...'` would match substrings and produce false negatives.

---

## Checking the Invalid Values Directly

To see *what kind* of invalidity each has:

```sql
SELECT
    customer_id,
    email,
    CASE
        WHEN email LIKE '%@@%'      THEN 'double @'
        WHEN email NOT LIKE '%@%'   THEN 'missing @'
        WHEN email NOT LIKE '%.%'   THEN 'missing dot'
        WHEN email NOT REGEXP '[a-zA-Z]{2,}$' THEN 'bad TLD'
        ELSE 'other'
    END AS issue
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
```

**Expected output:**

| customer_id | email | issue |
|-------------|-------|-------|
| 6 | david.wilson@@example.com | double @ |
| 7 | eve.brown@example | missing dot |

Diagnostic checks like this make findings actionable — you know exactly what to fix.

---

## Phone Format Check

Phones in our dataset use `(555) 123-4567`, `555-123-4567`, `555.123.4567`, and `555-555-0100`. A strict format rule: 10 digits, optionally with `-` separators:

```sql
SELECT customer_id, phone
FROM customers
WHERE phone IS NOT NULL
  AND phone NOT REGEXP '^\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}$';
```

**Expected output (3 rows):**

| customer_id | phone |
|-------------|-------|
| 9 | 555.777.8888 |
| 1 | (555) 123-4567 |
| 2 | (555) 123-4567 |

> **Business note:** whether `555.777.8888` is "invalid" depends on the rule. If the business says "phone must use dashes", then dot-separated phones are invalid (a **validity** defect). If the business accepts any 10-digit US format, they're fine — only the **format inconsistency** with other rows matters (a **consistency** concern, Unit 08). Context decides.

---

## Date Format Validation

Date columns in `DATE` type are already validated by MySQL (invalid dates fail to insert). But **strings** and **datetime** fields need checks:

```sql
-- Look for order dates that don't fit the expected pattern
SELECT order_id, order_date
FROM orders
WHERE order_date NOT BETWEEN '2026-01-01' AND '2026-08-03';
```

We'll cover date logic fully in Unit 09 (Timeliness). For validity, the key idea: **if a column's type doesn't enforce the format, add a query that does.**

---

## The Validity Pattern Library

| Data type | Check pattern |
|-----------|---------------|
| Email | `NOT REGEXP '^...@...\\..+$'` |
| Phone | `NOT REGEXP '^...$'` per business format |
| Postal code | `NOT REGEXP '^[0-9]{5}$'` or `'^[0-9]{5}(-[0-9]{4})?$'` |
| Currency | `currency NOT IN ('USD','EUR',...)` |
| Date string | `NOT REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'` + a valid date test |

---

## English Translation (of this lesson)

> "Validity means the value obeys its format and domain rules. I check formats with REGEXP — anchored with ^ and $ to avoid false matches. A diagnostic CASE classifies each invalid value so the fix is obvious. Whether a format deviation is a defect depends on the business rule."

---

## Key Takeaways

1. **Validity = format/domain conformance**, not truthfulness.
2. **`REGEXP` + anchors (`^...$`)** is the format-checking workhorse.
3. Classify invalid values with **`CASE` diagnostics** to make fixes actionable.
4. **Business rules decide** what "valid" means (e.g., phone format).
5. Date/type enforcement depends on the column type — some checks come free from the database.

**Coming up next:** Domain and range validation.
