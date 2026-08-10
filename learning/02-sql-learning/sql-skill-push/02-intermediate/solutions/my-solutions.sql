-- [Intermediate SQL Skill Push]
-- Q1: For each order, show the customer's full name and country.
SELECT o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS `name`,
    c.country
FROM orders o
    LEFT JOIN customers c ON c.cust_id = o.customer_id;
--
-- Q2: Which orders have NOT been paid yet? Show orders with no matching payment row.
SELECT o.order_id,
    p.status AS payment_status
FROM orders o
    LEFT JOIN payments p ON o.order_id = p.order_id
WHERE p.status IS NULL;
--
-- Q3: How many products does each category contain? Include both parent and subcategories.
SELECT c.cat_id AS category_id,
    c.cat_name AS category,
    COUNT(p.prod_id) AS product_count
FROM categories c
    LEFT JOIN products p ON c.cat_id = p.cat_id
GROUP BY c.cat_id,
    c.cat_name
ORDER BY product_count DESC;
--
-- Q4: Total revenue per category (from order items), for categories with more than $500k revenue.
SELECT c.cat_id AS category_id,
    c.cat_name AS category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM categories c
    LEFT JOIN products p ON c.cat_id = p.cat_id
    LEFT JOIN order_items oi ON p.prod_id = oi.product_id
GROUP BY c.cat_id,
    c.cat_name
HAVING total_revenue > 500000
ORDER By total_revenue DESC;
--
-- Q5: Average order value per country, for countries whose average exceeds the overall average order value.
SELECT c.country,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.customer_id
GROUP BY c.country
HAVING avg_order_value > (
        SELECT ROUND(AVG(total_amount), 2)
        FROM orders
    );
--
-- Q6: Which customers placed orders worth more than the overall average order value?