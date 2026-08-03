# Lesson 1.2: The Six Dimensions of Data Quality

Six dimensions give every data quality problem a precise name. When you name a problem correctly, you know exactly what kind of SQL check to write.

| # | Dimension | Question it answers | Example defect |
|---|-----------|---------------------|----------------|
| 1 | **Completeness** | Is all expected data present? | `email` is NULL for a customer |
| 2 | **Uniqueness** | Is each record represented exactly once? | Two rows with the same customer email |
| 3 | **Validity** | Does the data conform to its defined format/domain? | `status = 'shippd'` (typo); price `-5.00` |
| 4 | **Accuracy** | Does the data reflect the real world? | `qty * unit_price ≠ total_price` |
| 5 | **Consistency** | Does the data agree across systems/rows? | Customer state `'CA'` in one table, `'California'` in another |
| 6 | **Timeliness** | Is the data available when needed and up to date? | Order dated in the future; stale snapshot |

---

## 1. Completeness — "Is anything missing?"

A field is **complete** when it holds the value the business expects. NULL is not the only completeness problem — an empty string `''` or a value of `0` can be a completeness issue too, depending on the business rule.

```sql
-- Find customers with a missing email
SELECT customer_id, first_name, last_name
FROM customers
WHERE email IS NULL;
```

**Business framing:** Marketing cannot reach a customer whose email is missing → that customer's campaign revenue is lost.

---

## 2. Uniqueness — "Is anything duplicated?"

Every real-world entity should appear exactly once. A customer might exist twice because of a manual entry error or a bad merge.

```sql
-- Find emails that appear more than once
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

**Business framing:** Duplicate profiles mean double mailings, double costs, and split customer history.

---

## 3. Validity — "Does it obey the rules?"

Validity is about **format and domain**, not about whether the value is "true". The email `bob@example.com` is *valid* (well-formed) even if Bob doesn't actually read it.

```sql
-- Emails that are not well-formed (need one @, dot, etc.)
SELECT customer_id, email
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
```

**Business framing:** An invalid email bounces → delivery rate drops → sender reputation suffers.

---

## 4. Accuracy — "Does it match reality?"

A value can be complete, unique, and valid — and still **wrong**. Accuracy checks compare data against a source of truth: reality, a calculation, or a master record.

```sql
-- Line items where the stored total contradicts qty * unit_price
SELECT item_id, qty, unit_price, total_price,
       qty * unit_price AS expected_total
FROM order_items
WHERE qty * unit_price <> total_price;
```

**Business framing:** Finance books revenue from `total_price`. If it is wrong, the books are wrong.

---

## 5. Consistency — "Do the records agree with each other?"

The same fact should look the same across tables, systems, and rows. Common issues: `'CA'` vs `'California'`, an order referencing a customer that doesn't exist, USD items under an EUR order.

```sql
-- Orders whose customer does not exist (orphan)
SELECT o.order_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

**Business framing:** A join that silently drops orphans produces understated revenue.

---

## 6. Timeliness — "Is it fresh and on time?"

Data must arrive when it is needed, and reflect the correct time window. Timeliness covers future dates, stale snapshots, and delayed batch loads.

```sql
-- Orders dated after "today" (reference date 2026-08-03)
SELECT order_id, order_date
FROM orders
WHERE order_date > '2026-08-03';
```

**Business framing:** A dashboard showing yesterday's incomplete data leads to wrong operational calls.

---

## The Dimensions in One Table

| Dimension | What it is NOT | Check pattern |
|-----------|----------------|---------------|
| Completeness | Not about whether the value is right | `IS NULL`, `= ''` |
| Uniqueness | Not about whether the value is valid | `GROUP BY ... HAVING COUNT(*) > 1` |
| Validity | Not about whether the value is true | `REGEXP`, `BETWEEN`, `IN` |
| Accuracy | Not about format — about truth | recompute / compare to master |
| Consistency | Not about a single row — about agreement | `JOIN ... IS NULL`, cross-table diff |
| Timeliness | Not about the past — about now vs. expected | date comparisons, `DATEDIFF` |

---

## English Translation (of this lesson)

> "There are six ways data can be wrong: something is missing (completeness), something is duplicated (uniqueness), something breaks a format or domain rule (validity), something contradicts reality (accuracy), something disagrees across records or tables (consistency), or something is late or premature (timeliness). Each dimension maps to a recognizable pattern of SQL."

---

## Key Takeaways

1. The 6 dimensions give a **common vocabulary** shared across every DQ tool and framework.
2. Each dimension has a **distinct SQL check pattern** you will master in Units 04–09.
3. A single bad record can violate **multiple dimensions** at once (e.g., a NULL email is a completeness issue; an invalid email is a validity issue).
4. When you find a defect, always **label its dimension** — it focuses remediation.

**Coming up next:** Roles and frameworks in the data quality world.
