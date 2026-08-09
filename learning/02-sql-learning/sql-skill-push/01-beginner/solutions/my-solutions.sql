-- Q1: Which products are currently active? Show them from cheapest to most expensive.
SELECT *
FROM products
WHERE active = 1
ORDER BY unit_price ASC;
-- Q2: What are the distinct product categories in the menu?
SELECT DISTINCT category
FROM products;
-- Q3: Which customers signed up in 2025? List their name, city and signup date.
SELECT CONCAT(first_name, ' ', last_name) AS `name`,
    city,
    signup_date
FROM customers
WHERE YEAR(signup_date) = 2025
ORDER BY signup_date ASC;
-- Q4: How many orders were placed at store BRW001 (Manhattan)?
SELECT COUNT(*) AS total_orders
FROM orders
WHERE store_id = 'BRW001';
-- Q5: Which orders were paid by Card AND totaled more than $50?
SELECT *
FROM orders
WHERE payment_method = 'Card'
    AND total_amount > 50;