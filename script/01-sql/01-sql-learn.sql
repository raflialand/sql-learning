-- Practice Exercise
-- SQL learn Week 7
--
-- 1. Find the highest and lowest rated product reviews (by rating score)
SELECT *
FROM product_reviews
;
--
SELECT *
FROM products
;
--
describe products;
--
SELECT `p`.`name`,
AVG(pr.rating) AS rating
FROM products p
LEFT JOIN product_reviews pr
	ON p.id = pr.product_id
WHERE pr.rating IS NOT NULL
GROUP BY p.id, `p`.`name`
ORDER BY rating DESC
;
--
-- 2. Find the most expensive product in each category using MIN/MAX
SELECT *
FROM products
;
--
SELECT *
FROM categories
;
--
SELECT c.name AS category,
p.name AS most_expensive_product,
p.price,
ROW_NUMBER() 
	OVER(PARTITION BY c.id ORDER BY p.price DESC) AS rn
FROM categories c 
JOIN products p
	ON c.id = p.category_id
;
--
WITH product_price_rank AS
(
	SELECT c.name AS category,
	p.name AS most_expensive_product,
	p.price,
	ROW_NUMBER() 
		OVER(PARTITION BY c.id ORDER BY p.price DESC) AS rn
	FROM categories c 
	JOIN products p
		ON c.id = p.category_id
)
SELECT category, most_expensive_product, price
FROM product_price_rank
WHERE rn = 1
;
--
-- 3. Find the earliest and latest shipment delivery dates
SELECT *
FROM shipments
;
--
SELECT MAX(shipment_date) AS shipment_date
FROM shipments
UNION ALL
SELECT MIN(shipment_date)
FROM shipments
;
--
SELECT MIN(delivery_date) AS earliest_date,
	MAX(delivery_date) AS latest_date
FROM shipments
;
--
-- 4. Find employees with the longest and shortest tenure (using hire_date)
SELECT * 
FROM employees
;
--
SELECT `name` AS employee, 
	hire_date,
    CASE
		WHEN hire_date = (SELECT MIN(hire_date) FROM employees) THEN 'Highest Tenure'
        WHEN hire_date = (SELECT MAX(hire_date) FROM employees) THEN 'Lowest Tenure'
        ELSE 'MIDDLE'
        END AS tenure_label
FROM employees
WHERE hire_date = (SELECT MAX(hire_date) FROM employees)
	OR hire_date = (SELECT MIN(hire_date) FROM employees)
ORDER BY hire_date
;
--
-- 5. Find the first and last product (by name alphabetically) in each category
SELECT *
FROM products
;
--
WITH product_catalog AS
(
	SELECT `name`,
		CASE
			WHEN `name` = (SELECT MAX(`name`) FROM products) THEN 'Last Product'
			WHEN `name` = (SELECT MIN(`name`) FROM products) THEN 'First Product'
			ELSE NULL
			END AS product_label
	FROM products
)
SELECT *
FROM product_catalog
WHERE product_label IS NOT NULL
;
--
WITH product_catalog AS
(
SELECT c.`name` AS category,
	p.`name` AS product,
	ROW_NUMBER() OVER(PARTITION BY c.name ORDER BY p.name ASC) AS first_rank,
    ROW_NUMBER() OVER(PARTITION BY c.name ORDER BY p.name DESC) AS last_rank
FROM products p
JOIN categories c
	ON p.category_id = c.id
)
SELECT category,
	product,
    CASE
		WHEN first_rank = 1 THEN 'First Product'
        WHEN last_rank = 1 THEN 'Last Product'
        END AS product_label
FROM product_catalog
WHERE first_rank = 1 OR last_rank = 1
ORDER BY category, product
;

