-- [DUPLICATES CHECK]
--
-- [Expected Row]
SELECT 'categories' t, COUNT(*) FROM categories UNION ALL
SELECT 'vendors', COUNT(*) FROM vendors UNION ALL
SELECT 'products', COUNT(*) FROM products UNION ALL
SELECT 'customers', COUNT(*) FROM customers UNION ALL
SELECT 'orders', COUNT(*) FROM orders UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items UNION ALL
SELECT 'payments', COUNT(*) FROM payments UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments;
--
--
-- [Dupes categories]
SELECT * FROM categories;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM categories
GROUP BY 1, 2, 3
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;
--
--
--
SELECT * FROM customers;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM customers
GROUP BY 1, 2, 3, 4, 5, 6, 7
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;
--
--
-- [Dupes order_items]
SELECT * FROM order_items;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM order_items
GROUP BY 1, 2, 3, 4, 5
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;
--
--
-- [Dupes orders]
SELECT * FROM orders;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM orders
GROUP BY 1, 2, 3, 4, 5
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;
--
--
-- [Dupes payments]
SELECT * FROM payments;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM payments
GROUP BY 1, 2, 3, 4, 5, 6
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;
--
--
-- [Dupes products]
SELECT * FROM products;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM products
GROUP BY 1, 2, 3, 4, 5, 6, 7
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;
--
--
-- [Dupes shipments]
SELECT * FROM shipments;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM shipments
GROUP BY 1, 2, 3, 4, 5, 6
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;
--
--
-- [Dupes vendors]
SELECT * FROM vendors;
--
WITH dupe_check AS(
SELECT *,
	COUNT(*) AS duplicates
FROM vendors
GROUP BY 1, 2, 3
)
SELECT *
FROM dupe_check
WHERE duplicates > 1;