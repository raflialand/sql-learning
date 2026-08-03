# Lesson 8.3: Format and Unit Consistency

Values can be *individually valid* yet *collectively inconsistent*: same fact, different casing, separators, or units. **Format consistency** (cosmetic) and **unit consistency** (semantic) both matter.

---

## Format Consistency — "Same thing, different look"

These all represent the same US phone format problem:

- `555-123-4567` (dashes)
- `555.123.4567` (dots)
- `(555) 123-4567` (parentheses + space)

Same logical value, three formats. Frequency analysis reveals it:

```sql
SELECT
    CASE
        WHEN phone REGEXP '^\\('            THEN 'parens format'
        WHEN phone LIKE '%.%'               THEN 'dot format'
        WHEN phone LIKE '%-%'               THEN 'dash format'
        ELSE 'other'
    END AS phone_format,
    COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY phone_format
ORDER BY cnt DESC;
```

**Expected output:**

| phone_format | cnt |
|--------------|-----|
| dash format | 9 |
| parens format | 2 |
| dot format | 1 |

**The business rule** decides whether this is a defect:
- If the standard is "dashes only" → dot (customer 9) and parens (customers 1, 2) formats are invalid → **validity** issue (Unit 06).
- If any 10-digit US format is accepted → formats are *individually* valid, but the **inconsistency** across rows is a **consistency** issue.

Either way, you must **canonicalize**: store one standard format.

---

## Canonicalization Pattern

Normalize to a single format for comparison, grouping, and dedup:

```sql
-- Strip non-digits to compare phones as pure numbers
SELECT
    customer_id,
    phone,
    REGEXP_REPLACE(phone, '[^0-9]', '') AS canonical_phone
FROM customers
WHERE phone IS NOT NULL
ORDER BY canonical_phone;
```

**Expected output (first rows):**

| customer_id | phone | canonical_phone |
|-------------|-------|-----------------|
| 9 | 555.777.8888 | 5557778888 |
| 5 | 555-111-2222 | 5551112222 |
| ... | ... | ... |
| 1 | (555) 123-4567 | 5551234567 |
| 2 | (555) 123-4567 | 5551234567 |

Now you can compare/dedup phones ignoring format. This is exactly the normalization we used in Unit 05.

> **Note:** `REGEXP_REPLACE(phone, '[^0-9]', '')` strips every non-digit. MySQL 8 supports it natively.

---

## Unit Consistency — "Same thing, different measure"

Units are *semantic*: a price in USD vs EUR, a weight in kg vs lb. Mixing units produces silently wrong numbers.

```sql
-- Orders priced in a non-USD currency (consistency: default is USD)
SELECT order_id, total_amount, currency
FROM orders
WHERE currency <> 'USD';
```

**Expected output (2 rows):**

| order_id | total_amount | currency |
|----------|--------------|----------|
| 12 | 59.99 | EUR |
| 13 | 59.99 | EUR |

Two orders in EUR while the rest of the dataset is USD. If the reporting layer assumes USD, these two orders are misinterpreted by ~exchange rate.

---

## Cross-Table Unit Consistency (recap from 8.2)

Item 14 is USD under an EUR order — a unit mismatch across tables:

```sql
SELECT oi.item_id, oi.currency AS item_currency, o.currency AS order_currency
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.currency <> o.currency;
```

**Expected output:** item 14 (USD vs EUR).

---

## Consistency Cheat Sheet

| Type | Question | Pattern |
|------|----------|---------|
| Format consistency | Do values share one format? | Frequency by format, `REGEXP_REPLACE` to canonicalize |
| Case consistency | Is casing uniform? | `UPPER(col) <> col` |
| Unit consistency | Is one unit used? | `WHERE currency <> 'USD'` |
| Cross-table | Do tables agree? | join + `COALESCE` compare (8.2) |
| Intra-table | Does one entity look the same? | self-join on natural key (8.2) |

---

## The Normalization Decision

Consistency fixes are a **design decision**:
1. Choose the **canonical format/unit** with the business.
2. **Enforce at entry** (validation in the app) and **at transform** (normalization in the pipeline).
3. **Monitor** with frequency checks (Unit 11) so new inconsistencies are caught.

---

## English Translation (of this lesson)

> "Values can be individually valid but collectively inconsistent — different phone separators, mixed currency units. Format inconsistency is cosmetic; unit inconsistency is semantic. I detect them with frequency-by-format queries and canonicalize with REGEXP_REPLACE. I always set a canonical format/unit with the business, then enforce and monitor it."

---

## Key Takeaways

1. **Format consistency** (casing, separators) vs **unit consistency** (currency, measure) are different defects.
2. **`REGEXP_REPLACE(..., '[^0-9]', '')`** canonicalizes phones for comparison/dedup.
3. **Frequency-by-format** queries reveal inconsistent formatting instantly.
4. Mixed **currency** breaks financial aggregates silently.
5. Consistency fixes require a **canonical standard** agreed with the business.

---

## Unit 08 Exercises → practice consistency checks.

Move on to `exercises.md`.
