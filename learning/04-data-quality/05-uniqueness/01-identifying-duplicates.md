# Lesson 5.1: Identifying Duplicates

**Uniqueness** answers: *is every real-world entity represented exactly once?* Duplicates waste money (double mailings), corrupt metrics (double-counted revenue), and split history (a customer's purchases in two rows).

---

## Exact Duplicates — the Basic Detection

Find values that repeat in a *key* column:

```sql
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

**Expected output:**

| email | cnt |
|-------|-----|
| alice.johnson@example.com | 2 |
| ivy.clark@example.com | 2 |

These are **exact duplicates by email** — customers 1&2 and 11&12.

---

## Exact Row Duplicates — the whole row repeats

Sometimes an entire row is duplicated (same name, email, phone, everything):

```sql
SELECT first_name, last_name, email, phone, state, COUNT(*) AS cnt
FROM customers
GROUP BY first_name, last_name, email, phone, state
HAVING COUNT(*) > 1;
```

**Expected output:**

| first_name | last_name | email | phone | state | cnt |
|------------|-----------|-------|-------|-------|-----|
| Alice | Johnson | alice.johnson@example.com | (555) 123-4567 | NY | 2 |

Only Alice is a *perfect* row duplicate. Ivy's pair differs in `state` (`OR` vs `Oregon`) — that's a **near duplicate** (Lesson 5.3).

---

## Duplicate SKUs in Products

```sql
SELECT sku, COUNT(*) AS cnt
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;
```

**Expected output:**

| sku | cnt |
|-----|-----|
| SKU-1001 | 2 |
| SKU-1006 | 2 |

---

## Duplicate Addresses

```sql
SELECT customer_id, address_line, city, country, COUNT(*) AS cnt
FROM addresses
GROUP BY customer_id, address_line, city, country
HAVING COUNT(*) > 1;
```

**Expected output:**

| customer_id | address_line | city | country | cnt |
|-------------|--------------|------|---------|-----|
| 1 | 100 Main St | New York | USA | 2 |

Customer 1 has the same address twice.

---

## The "Duplicates by Business Key" Pattern

A **business key** is what *should* be unique in the real world — even if it isn't the primary key:

```sql
-- Duplicates by business key (full name + phone)
SELECT first_name, last_name, phone, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, phone
HAVING COUNT(*) > 1;
```

**Expected output:**

| first_name | last_name | phone | cnt |
|------------|-----------|-------|-----|
| Alice | Johnson | (555) 123-4567 | 2 |
| Bob | Smith | 555-987-6543 | 2 |

Bob now appears twice too (customers 3 & 4) — they share a phone but differ in email and state. A business-key check finds duplicates a single-column check misses.

---

## Why This Matters (business impact)

| Duplicate | Impact |
|-----------|--------|
| Two Alice rows | Two catalog mailings, split purchase history → wrong LTV |
| Two Bob rows | Email sent to two addresses for one person, or double mail |
| Two SKU-1006 rows | Inventory counted twice; stock report overstates stock |

---

## English Translation (of this lesson)

> "Duplicates are entities recorded more than once. I detect them with GROUP BY + HAVING COUNT(*) > 1 on the relevant key — an email, a full row, a business key like name+phone. Single-column checks miss near-duplicates, so I use the business key from Unit 02."

---

## Key Takeaways

1. The detection pattern is **`GROUP BY <key> HAVING COUNT(*) > 1`**.
2. Choose the key by **business meaning**, not convenience.
3. **Exact row duplicates** and **duplicates by business key** are different queries.
4. Duplicates have concrete costs: wasted spend, inflated metrics, split history.

**Coming up next:** Deduplicating with window functions.
