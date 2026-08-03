# Exercises: Unit 05 — Uniqueness

*All exercises run against `dq_learning`.*

---

## Part A: Write the Query

### Exercise 5.1 — Duplicate emails

Write a query that finds emails appearing more than once in `customers`.

**Expected:** alice.johnson@example.com (2), ivy.clark@example.com (2).

### Exercise 5.2 — Duplicate SKUs

Write a query finding duplicate SKUs in `products`.

**Expected:** SKU-1001 (2), SKU-1006 (2).

### Exercise 5.3 — Duplicate addresses

Write a query finding duplicate (customer_id, address_line, city, country) rows in `addresses`.

**Expected:** customer 1's 100 Main St address (2).

### Exercise 5.4 — Duplicates by business key

Write a query finding duplicate (first_name, last_name, phone) in customers.

**Expected:** Alice Johnson (2), Bob Smith (2), Ivy Clark (2).

### Exercise 5.5 — Dedup with ROW_NUMBER

Using a CTE and `ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id)`, return the duplicate rows (rn > 1).

**Expected:** customer 2 and customer 12.

### Exercise 5.6 — Keep latest

Modify the query to keep the **latest** customer_id per email. Show the customer_id kept per email.

**Expected keeps:** Alice → 2, Ivy → 12.

### Exercise 5.7 — Count removable duplicates

Write a query counting how many customer rows a dedup by email would remove.

**Expected:** 2.

### Exercise 5.8 — Normalized composite uniqueness

Using `REPLACE` to normalize the phone (strip dashes), write the composite uniqueness check on (first_name, last_name, normalized phone).

**Expected:** Alice (2), Bob (2), Ivy (2).

---

## Part B: Translate the Query

### Exercise 5.9

Explain what this returns and why it might over-report:

```sql
SELECT first_name, last_name, phone, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, phone
HAVING COUNT(*) > 1;
```

*(Hint: why would phone format matter here?)*

### Exercise 5.10

Explain the purpose and the role of `rn`:

```sql
WITH ranked AS (
    SELECT customer_id, email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id, email
FROM ranked
WHERE rn = 1;
```

---

## Part C: Debug the Query

### Exercise 5.11 — Buggy duplicate detection

**Intended purpose:** find duplicate emails.

```sql
SELECT email, COUNT(*) AS cnt
FROM customers
GROUP BY email;
```

**Bug:** returns every email, not just duplicates. Fix with `HAVING`.

### Exercise 5.12 — Buggy dedup ordering

**Intended purpose:** keep the *earliest* customer per email (rn = 1).

```sql
WITH ranked AS (
    SELECT customer_id, email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY email) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id, email FROM ranked WHERE rn = 1;
```

**Bug:** `ORDER BY email` makes the ordering meaningless (all same value). Fix to order by `customer_id` (ascending = earliest).

### Exercise 5.13 — Buggy normalization

**Intended purpose:** normalize phones by stripping dashes.

```sql
SELECT REPLACE(phone, '-') AS p, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY p
HAVING COUNT(*) > 1;
```

**Bug:** `REPLACE` needs a third argument (the replacement string). Fix: `REPLACE(phone, '-', '')`. Also note `GROUP BY p` uses the alias — that is allowed in MySQL.

---

## Self-Assessment Checkpoint

- [ ] I can detect exact duplicates with `GROUP BY ... HAVING COUNT(*) > 1`
- [ ] I can choose the right business key for uniqueness
- [ ] I can deduplicate with `ROW_NUMBER() OVER (PARTITION BY ...)`
- [ ] I can decide which row to keep (earliest/latest/fullest) — a business rule
- [ ] I can normalize values (TRIM/LOWER/REPLACE) to catch near-duplicates
- [ ] I know never to hard-delete duplicates without business review

**Ready to continue?** Move to **Unit 06 — Validity**.
