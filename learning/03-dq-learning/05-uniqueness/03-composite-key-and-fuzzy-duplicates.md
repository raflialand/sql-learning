# Lesson 5.3: Composite Keys and Fuzzy (Near) Duplicates

Not all duplicates are exact. Two records for the same person can differ in email, state spelling, or phone format. Catching **near duplicates** requires **composite keys** and **normalization**.

---

## Composite Keys — uniqueness across multiple columns

A single column may not identify an entity. Use several together:

```sql
-- Is (first_name, last_name, phone) unique?
SELECT first_name, last_name, phone, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, phone
HAVING COUNT(*) > 1;
```

**Expected output (3 rows):**

| first_name | last_name | phone | cnt |
|------------|-----------|-------|-----|
| Alice | Johnson | (555) 123-4567 | 2 |
| Bob | Smith | 555-987-6543 | 2 |
| Ivy | Clark | 555-222-3333 | 2 |

Customers 3 & 4 (Bob) share a phone but have different emails (`bob.smith@example.com` vs `bob@example.com`) and different state spelling (`CA` vs `California`). Ivy's pair (11 & 12) differs only in state spelling (`OR` vs `Oregon`). Only a **composite** check catches these.

---

## Normalization — making values comparable

Before comparing, **normalize** values so cosmetic differences vanish:

| Transform | SQL | Fixes |
|-----------|-----|-------|
| Trim whitespace | `TRIM(col)` | `' NY '` vs `'NY'` |
| Lowercase | `LOWER(col)` | `'ny'` vs `'NY'` |
| Collapse punctuation | `REPLACE(col, '-', '')` | `'555-1234'` vs `'5551234'` |

```sql
-- Normalized composite uniqueness: name + normalized phone
SELECT
    first_name,
    last_name,
    REPLACE(phone, '-', '') AS normalized_phone,
    COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, REPLACE(phone, '-', '')
HAVING COUNT(*) > 1;
```

**Expected output (now more groups):**

| first_name | last_name | normalized_phone | cnt |
|------------|-----------|------------------|-----|
| Alice | Johnson | (555) 1234567 | 2 |
| Bob | Smith | 5559876543 | 2 |
| Ivy | Clark | 5552223333 | 2 |

> **Note:** normalization must match the domain. `REPLACE('-', '')` fixes dashes; dots and parentheses need their own handling. Real systems use a canonicalization function.

---

## Fuzzy Duplicates — same entity, messier data

Normalization can't fix everything (e.g., `'CA'` vs `'California'`). For those, use **similarity** — but SQL has no built-in fuzzy match. Two practical SQL approximations:

### 1. Soundex (same-sounding names)

```sql
-- Names that sound the same
SELECT first_name, last_name, phone, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, phone
HAVING COUNT(*) > 1
UNION
SELECT c1.first_name, c1.last_name, c1.phone, 1 AS cnt
FROM customers c1
JOIN customers c2
  ON SOUNDEX(c1.first_name) = SOUNDEX(c2.first_name)
 AND c1.last_name = c2.last_name
 AND c1.phone = c2.phone
 AND c1.customer_id <> c2.customer_id
WHERE c1.phone IS NOT NULL;
```

> `SOUNDEX()` groups names that sound alike (`'Ivy'`/`'Ivi'`). In our dataset, the near-dupes are caught by the *composite* check; soundex is for harder cases.

### 2. Partial key overlap (same last name + state)

```sql
-- Possible near-duplicates: same last name, same state, close emails
SELECT c1.customer_id AS a, c2.customer_id AS b,
       c1.first_name, c2.first_name, c1.last_name, c1.email, c2.email
FROM customers c1
JOIN customers c2
  ON c1.last_name = c2.last_name
 AND c1.state = c2.state
 AND c1.customer_id < c2.customer_id;
```

**This is a *suspicion* query** — output needs human review before it becomes a confirmed duplicate. Fuzzy matching always produces candidates, not verdicts.

---

## The Near-Duplicate Decision Flow

```
normalize (trim/lower/strip punctuation)
      ▼
composite key check  →  exact after normalization → confirmed duplicate
      ▼
similarity check (soundex, overlap) → candidate → HUMAN REVIEW → confirmed?
      ▼
no rule → escalate to data owner
```

---

## Business Impact of Near Duplicates

The `CA`/`California` and `Bob`/`Bob` cases are the *real-world* problem: an identity resolution (IDR) team exists precisely to solve this. Your SQL checks:

1. **Find the candidates** (composite + normalized checks).
2. **Quantify** how many entities are affected.
3. **Feed** the business's identity-resolution process.

---

## English Translation (of this lesson)

> "Near duplicates hide behind cosmetic differences. I use composite keys — several columns together — and normalize values (trim, lowercase, strip punctuation) before comparing. When normalization isn't enough, soundex and overlap checks produce candidate pairs for human review. Fuzzy checks always output suspects, never verdicts."

---

## Key Takeaways

1. **Composite keys** catch duplicates a single column can't.
2. **Normalize** (TRIM/LOWER/REPLACE) before comparing — it catches formatting variants.
3. **Fuzzy** checks (SOUNDEX, overlap) produce *candidates* needing human review.
4. Always escalate uncertain cases to the **data owner**.
5. Near-duplicate resolution (identity resolution) is a discipline of its own.

---

## Unit 05 Exercises → practice uniqueness checks.

Move on to `exercises.md`.
