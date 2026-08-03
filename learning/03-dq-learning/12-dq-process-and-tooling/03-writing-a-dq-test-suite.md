# Lesson 12.3: Writing a DQ Test Suite

A **DQ test suite** is a structured collection of checks for one dataset — the pattern every tool (dbt, GE, Soda) follows. This lesson shows you how to write a suite in plain SQL, mirroring how tools structure their own.

---

## The Anatomy of a DQ Test

Every test has the same shape:

```
A SQL query that returns rows ONLY when the data is bad.
Zero rows returned = test passes.
```

That's it. If the query returns anything, the test failed and you investigate the returned rows.

---

## A Complete Test Suite for `customers`

```sql
-- TEST: CUST-001 completeness — email must be present
SELECT customer_id, 'missing email' AS failure
FROM customers
WHERE email IS NULL OR TRIM(email) = '';

-- TEST: CUST-002 uniqueness — no duplicate emails
SELECT email, COUNT(*) AS cnt, 'duplicate email' AS failure
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;

-- TEST: CUST-003 validity — email format
SELECT customer_id, email, 'invalid email format' AS failure
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

-- TEST: CUST-004 validity — state in allowed set (normalized)
SELECT customer_id, state, 'non-standard state' AS failure
FROM customers
WHERE state IS NOT NULL
  AND UPPER(state) NOT IN ('AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
                           'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
                           'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
                           'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
                           'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY');
```

---

## Naming & Organization Conventions

| Rule | Example |
|------|---------|
| Name tests `TABLE-###` | `CUST-001`, `ORD-002` |
| Group by dimension | completeness / uniqueness / validity / ... |
| Keep one test per rule | small, diagnosable failures |
| Return the offending rows | not just counts — so you can act |

---

## The Suite-as-One-Query Pattern

Combine all tests into a single result for a dashboard:

```sql
SELECT 'CUST-001' AS test_id, 'completeness' AS dimension,
       'missing email' AS rule, COUNT(*) AS failures
FROM customers
WHERE email IS NULL OR TRIM(email) = ''
UNION ALL
SELECT 'CUST-002', 'uniqueness', 'duplicate email', COUNT(*)
FROM (SELECT email FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'CUST-003', 'validity', 'invalid email format', COUNT(*)
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
UNION ALL
SELECT 'CUST-004', 'validity', 'non-standard state', COUNT(*)
FROM customers
WHERE state IS NOT NULL
  AND UPPER(state) NOT IN ('AL','AK','AZ',...);
```

**Expected output:**

| test_id | dimension | rule | failures |
|---------|-----------|------|----------|
| CUST-001 | completeness | missing email | 2 |
| CUST-002 | uniqueness | duplicate email | 2 |
| CUST-003 | validity | invalid email format | 2 |
| CUST-004 | validity | non-standard state | 3 |

---

## Test Suites for the Full Dataset

| Suite | Key tests |
|-------|-----------|
| `customers` | completeness, uniqueness, validity (above) |
| `products` | unit_price > 0, sku unique, weight bounds, lifecycle |
| `orders` | total not NULL, no future dates, status domain, no orphans |
| `order_items` | qty > 0, total = qty×price, currency matches order |
| `daily_sales` | revenue not NULL, row-count monitor, spike/shift detectors |

---

## Running the Suite

```bash
# Run each test; zero rows = pass
mysql -u root -p dq_learning < suite_customers.sql
```

Or wrap in a loop that turns "returns rows" into an exit code (for CI/cron):

```bash
# A test fails if it returns any rows
mysql -u root -p dq_learning -e "<test_sql>" | grep -q . && echo "FAIL: CUST-001" || echo "PASS: CUST-001"
```

---

## English Translation (of this lesson)

> "A DQ test suite is a set of SQL queries, each returning rows only when data is bad. Zero rows = pass. I name tests, group by dimension, and return offending rows. I can combine them into one summary query for dashboards, and wire them into CI or cron so they run automatically."

---

## Key Takeaways

1. **A test = a query that returns rows only on failure.**
2. Organize with **naming (`TABLE-###`)**, dimension, and a rule.
3. Return **offending rows**, not just counts.
4. Combine into a **single summary query** for dashboards.
5. Wire into **CI/cron** so tests run automatically — this is the DQ engineer's job.

---

## Unit 12 Exercises → practice writing suites and mapping to tools.

Move on to `exercises.md`.
