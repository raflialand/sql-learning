-- Solutions: Unit 05 — Uniqueness
-- Run against dq_learning

-- =====================================================================
-- Exercise 5.1 — Duplicate emails
-- =====================================================================
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;

-- =====================================================================
-- Exercise 5.2 — Duplicate SKUs
-- =====================================================================
SELECT sku, COUNT(*) AS cnt
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;

-- =====================================================================
-- Exercise 5.3 — Duplicate addresses
-- =====================================================================
SELECT customer_id, address_line, city, country, COUNT(*) AS cnt
FROM addresses
GROUP BY customer_id, address_line, city, country
HAVING COUNT(*) > 1;

-- =====================================================================
-- Exercise 5.4 — Duplicates by business key (name + phone)
-- =====================================================================
SELECT first_name, last_name, phone, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, phone
HAVING COUNT(*) > 1;
-- Expected: Alice Johnson (2), Bob Smith (2), Ivy Clark (2)

-- =====================================================================
-- Exercise 5.5 — Dedup: show the duplicate rows (rn > 1)
-- =====================================================================
WITH ranked AS (
    SELECT
        customer_id, first_name, last_name, email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id, first_name, last_name, email, rn
FROM ranked
WHERE rn > 1;
-- Expected: customer 2 and 12

-- =====================================================================
-- Exercise 5.6 — Keep the LATEST customer per email
-- =====================================================================
WITH ranked AS (
    SELECT
        customer_id, email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id DESC) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT email, customer_id
FROM ranked
WHERE rn = 1
ORDER BY customer_id;
-- Expected keeps: alice -> 2, ivy -> 12

-- =====================================================================
-- Exercise 5.7 — Count removable duplicates
-- =====================================================================
WITH ranked AS (
    SELECT email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT COUNT(*) AS rows_to_remove
FROM ranked
WHERE rn > 1;
-- Expected: 2

-- =====================================================================
-- Exercise 5.8 — Normalized composite uniqueness (strip dashes)
-- =====================================================================
SELECT
    first_name,
    last_name,
    REPLACE(phone, '-', '') AS normalized_phone,
    COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, REPLACE(phone, '-', '')
HAVING COUNT(*) > 1;
-- Expected: Alice (2), Bob (2), Ivy (2)

-- =====================================================================
-- Exercise 5.9 (TRANSLATE — for reference)
-- Counts customers grouped by name+phone, showing only groups with >1.
-- Could UNDER-report because phone formats differ (dashes vs dots vs parens)
-- so the same person's phones may not match after grouping.

-- =====================================================================
-- Exercise 5.10 (TRANSLATE — for reference)
-- Returns the earliest customer_id per email (rn=1). The rn numbers rows
-- within each email group by customer_id ascending; rn=1 = keep row.

-- =====================================================================
-- Exercise 5.11 — Fixed: add HAVING for duplicates only
-- =====================================================================
SELECT email, COUNT(*) AS cnt
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- =====================================================================
-- Exercise 5.12 — Fixed: order by customer_id (earliest wins)
-- =====================================================================
WITH ranked AS (
    SELECT customer_id, email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY customer_id ASC) AS rn
    FROM customers
    WHERE email IS NOT NULL
)
SELECT customer_id, email FROM ranked WHERE rn = 1;

-- =====================================================================
-- Exercise 5.13 — Fixed: REPLACE with replacement argument
-- =====================================================================
SELECT REPLACE(phone, '-', '') AS p, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY p
HAVING COUNT(*) > 1;
