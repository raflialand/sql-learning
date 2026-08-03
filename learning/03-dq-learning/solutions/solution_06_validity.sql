-- Solutions: Unit 06 — Validity
-- Run against dq_learning

-- =====================================================================
-- Exercise 6.1 — Invalid emails
-- =====================================================================
SELECT customer_id, email
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
-- Expected: customer 6, 7

-- =====================================================================
-- Exercise 6.2 — Diagnose invalid emails
-- =====================================================================
SELECT
    customer_id,
    email,
    CASE
        WHEN email LIKE '%@@%' THEN 'double @'
        WHEN email NOT LIKE '%@%' THEN 'missing @'
        WHEN email NOT LIKE '%.%' THEN 'missing dot'
        ELSE 'other'
    END AS issue
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
-- Expected: 6 -> double @, 7 -> missing dot

-- =====================================================================
-- Exercise 6.3 — Invalid prices
-- =====================================================================
SELECT product_id, sku, product_name, unit_price
FROM products
WHERE unit_price <= 0;
-- Expected: product 3 (-5.00), product 4 (0.00)

-- =====================================================================
-- Exercise 6.4 — Invalid quantities
-- =====================================================================
SELECT item_id, order_id, qty, unit_price, total_price
FROM order_items
WHERE qty <= 0 OR qty > 100;
-- Expected: item 11 (qty 0), item 19 (qty -1)

-- =====================================================================
-- Exercise 6.5 — Invalid statuses (NOT IN)
-- =====================================================================
SELECT order_id, status
FROM orders
WHERE status NOT IN ('shipped', 'pending', 'cancelled');
-- Expected: orders 8, 9, 10. Order 4 (NULL) is skipped because
-- NULL NOT IN (...) evaluates to UNKNOWN, which WHERE drops.

-- =====================================================================
-- Exercise 6.6 — Invalid statuses including NULL
-- =====================================================================
SELECT order_id, status
FROM orders
WHERE status IS NULL
   OR status NOT IN ('shipped', 'pending', 'cancelled');
-- Expected: orders 4, 8, 9, 10

-- =====================================================================
-- Exercise 6.7 — Out-of-range weight
-- =====================================================================
SELECT product_id, sku, product_name, weight_kg
FROM products
WHERE weight_kg < 0.1 OR weight_kg > 50;
-- Expected: product 5 (150.00)

-- =====================================================================
-- Exercise 6.8 — Reference validation of statuses
-- =====================================================================
CREATE TEMPORARY TABLE ref_status (status VARCHAR(20) PRIMARY KEY);
INSERT INTO ref_status VALUES ('shipped'), ('pending'), ('cancelled');

SELECT o.order_id, o.status
FROM orders o
LEFT JOIN ref_status s ON o.status = s.status
WHERE s.status IS NULL;
-- Expected: orders 4, 8, 9, 10 (NULL caught by the join)

DROP TEMPORARY TABLE ref_status;

-- =====================================================================
-- Exercise 6.9 (TRANSLATE — for reference)
-- Returns customers whose email fails the anchored email regex. ^ and $
-- anchor the match to the whole string, so partial matches are not
-- counted as valid.

-- =====================================================================
-- Exercise 6.10 (TRANSLATE — for reference)
-- LEFT JOIN against an allowed status set; rows with no match are invalid.
-- More robust than NOT IN because a NULL status fails the join, so it is
-- reported, whereas NULL NOT IN (...) silently drops the row.

-- =====================================================================
-- Exercise 6.11 — Fixed: IS NULL not = NULL
-- =====================================================================
SELECT order_id, status
FROM orders
WHERE status NOT IN ('shipped', 'pending', 'cancelled')
   OR status IS NULL;

-- =====================================================================
-- Exercise 6.12 — Fixed: anchors added
-- =====================================================================
SELECT customer_id, email
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
-- Expected: customers 6 and 7

-- =====================================================================
-- Exercise 6.13 — Fixed: find violations not valid rows
-- =====================================================================
SELECT item_id, qty
FROM order_items
WHERE qty <= 0 OR qty IS NULL;
-- Expected: item 11 (qty 0), item 19 (qty -1)
