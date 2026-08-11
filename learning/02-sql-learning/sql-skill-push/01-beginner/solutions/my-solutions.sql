-- [Beginner SQL Skill Push]
-- Q1: Which products are currently active? Show them from cheapest to most expensive.
SELECT *
FROM products
WHERE is_active = 1
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
FROM order_items oi
    LEFT JOIN products p ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY total_revenue DESC;
--
-- Q15: How many times was each payment method used?
SELECT payment_method,
    COUNT(*) AS payment_count
FROM orders
GROUP BY payment_method
ORDER BY payment_method DESC;
--
-- Q16: Which customer has placed the most orders? Show the top 5 customers by order count.
SELECT c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS `name`,
    COUNT(o.order_id) AS order_count
FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.customer_id
GROUP BY c.cust_id
ORDER BY order_count DESC
LIMIT 5;
--
-- Q17: Which customers have spent more than $100 in total, and how much? Show the top 10.
SELECT c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS `name`,
    SUM(o.total_amount) AS total_spent
FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.customer_id
GROUP BY c.cust_id
HAVING total_spent > 100
ORDER BY total_spent DESC
LIMIT 10;
--
-- Q18: How many orders were placed in each month of 2025?
SELECT MONTH(order_date) AS order_month,
    COUNT(*) AS total_orders
FROM orders
WHERE YEAR(order_date) = 2025
GROUP BY MONTH(order_date)
ORDER BY order_month ASC;
--
-- Q19: What is the average order value per month, and which month had the highest?
SELECT YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY YEAR(order_date),
    MONTH(order_date)
ORDER BY YEAR(order_date),
    average_order_value DESC;
--
-- Q20: Which customers have NEVER placed an order?
SELECT c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS `name`
FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.customer_id
WHERE o.order_id IS NULL;