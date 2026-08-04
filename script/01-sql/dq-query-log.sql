-- [The Six Dimensions of Data Quality]
--
-- 1. [COMPLETENESS] check, "is anything missing?"
-- find customers with a missing email
SELECT customer_id,
    first_name,
    last_name
FROM customers
WHERE email IS NULL;
--
-- 2. [UNIQUENESS] check, "is anything duplicated?"
-- find emails that appear more than once
SELECT email,
    COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
--
-- 3. [VALIDITY] check, "does it obey the rules?"
-- email that are not well-formed (need one @, dot, etc.)
SELECT customer_id,
    email
FROM customers
WHERE email IS NOT NULL
    AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
--
-- 4. [ACCURACY] check, "does it match reality?"
-- line items where the stored total contradicts qty * unit_price
SELECT item_id,
    qty,
    unit_price,
    total_price,
    qty * unit_price AS expected_total
FROM order_items
WHERE qty * unit_price <> total_price;
--
-- 5. [CONSISTENCY] check, "do the records agree with each other?"
-- orders whose customer does not exist (orphan)
SELECT o.order_id
FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
--
-- 6. [TIMELINESS] check, "is it fresh and on time?"
-- orders dated afer "today" (reference date 2026-08-03)
SELECT order_id,
    order_date
FROM orders
WHERE order_date > '2026-08-03';