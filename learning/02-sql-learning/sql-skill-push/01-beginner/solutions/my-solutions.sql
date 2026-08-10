-- [Beginner SQL Skill Push]
-- Q1: Which products are currently active? Show them from cheapest to most expensive.
SELECT *
FROM products
WHERE active = 1
ORDER BY unit_price ASC;
--
-- Q2: What are the distinct product categories in the menu?
SELECT DISTINCT category
FROM products;
--
-- Q3: Which customers signed up in 2025? List their name, city and signup date.
SELECT CONCAT(first_name, ' ', last_name) AS `name`,
    city,
    signup_date
FROM customers
WHERE YEAR(signup_date) = 2025
ORDER BY signup_date ASC;
--
-- Q4: How many orders were placed at store BRW001 (Manhattan)?
SELECT COUNT(*) AS total_orders
FROM orders
WHERE store_id = 'BRW001';
--
-- Q5: Which orders were paid by Card AND totaled more than $50?
SELECT *
FROM orders
WHERE payment_method = 'Card'
    AND total_amount > 50;
--
-- Q6: Which products are priced between $3 and $6?
SELECT prod_id,
    prod_name,
    unit_price
FROM products
WHERE unit_price BETWEEN 3 AND 6;
--
-- Q7: Which products have "Coffee" anywhere in their name?
SELECT prod_id,
    prod_name
FROM products
WHERE prod_name LIKE '%Coffee%';
--
-- Q8: Which orders do NOT have a recorded payment method?
SELECT *
FROM orders
WHERE payment_method IS NULL
    OR payment_method = '';
--
-- Q9: What are the 5 most expensive products on the menu?
SELECT prod_id,
    prod_name,
    unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 5;
--
-- Q10: What are the 5 largest orders, and what store did each come from?
SELECT order_id,
    total_amount,
    store_id
FROM orders
ORDER By total_amount DESC
LIMIT 5;
--
-- Q11: How many orders were placed at each store?
SELECT store_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY store_id;
--
-- Q12: What is the total revenue per store?
SELECT store_id,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY store_id;
--
-- Q13: What is the average order value at each store?
SELECT store_id,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY store_id;
--
-- Q14: Which product categories bring in the most revenue? (revenue = qty × unit_price)
SELECT p.category,
    SUM(oi.quantity * unit_price) AS total_revenue
FROM order_items
    LEFT JOIN products p ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY total_revenue DESC;
--
-- Q15: How many times was each payment method used?
SELECT payment_method,
    COUNT(*) AS payment_count
FROM orders
GROUP BY payment_method;
ORDER BY payment_method DESC;