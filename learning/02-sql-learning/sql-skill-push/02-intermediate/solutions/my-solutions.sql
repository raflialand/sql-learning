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
SELECT DISTINCT c.cust_id AS customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM orders o
    LEFT JOIN customers c ON c.cust_id = o.customer_id
WHERE o.total_amount > (
        SELECT ROUND(AVG(total_amount), 2)
        FROM orders
    );
--
-- Q7: Which inactive (discontinued) products were still ordered by customers?
SELECT DISTINCT p.prod_id AS product_id,
    p.prod_name AS product_name,
    c.cat_name AS category,
    p.unit_price AS price
FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.prod_id
    LEFT JOIN categories c ON c.cat_id = p.cat_id
WHERE p.is_active = 0
    AND oi.order_id IS NOT NULL
ORDER BY p.prod_id;
--
-- Q8: Total revenue and order count per month, with a running total of revenue over time.
WITH monthly_revenue AS (
    SELECT YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        COUNT(*) AS order_count,
        ROUND(SUM(total_amount), 2) AS revenue
    FROM orders
    GROUP BY YEAR(order_date),
        MONTH(order_date)
)
SELECT *,
    ROUND(SUM(revenue), 2) OVER(
        ORDER BY year,
            month
    ) AS running_revenue
FROM monthly_revenue;
--
-- Q9: Rank each order within its customer by amount (1 = largest). Show the top 2 orders per customer.
WITH order_rank AS(
    SELECT c.cust_id AS customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        o.order_id AS order_id,
        o.total_amount AS total_amount,
        ROW_NUMBER() OVER(
            PARTITION BY c.cust_id
            ORDER BY o.total_amount DESC
        ) AS rn
    FROM customers c
        LEFT JOIN orders o ON c.cust_id = o.customer_id
)
SELECT customer_id,
    order_id,
    total_amount,
    rn
FROM order_rank
WHERE rn <= 2
ORDER BY customer_id,
    rn;
--
-- Q10: For each active product, show its price compared to the average price of its category.
SELECT prod_id,
    prod_name,
    unit_price,
    ROUND(AVG(unit_price) OVER(PARTITION BY cat_id), 2) AS cat_avg_price,
    ROUND(
        unit_price - AVG(unit_price) OVER(PARTITION BY cat_id),
        2
    ) AS diff_from_avg
FROM products
WHERE is_active = 1;
--
-- Q11: Revenue breakdown by order status using conditional aggregation.
SELECT SUM(
        CASE
            WHEN status = 'Completed' THEN total_amount
            ELSE 0
        END
    ) AS completed_rev,
    SUM(
        CASE
            WHEN status = 'Shipped' THEN total_amount
            ELSE 0
        END
    ) AS shipped_rev,
    SUM(
        CASE
            WHEN status = 'Pending' THEN total_amount
            ELSE 0
        END
    ) AS pending_rev,
    SUM(
        CASE
            WHEN status = 'Cancelled' THEN total_amount
            ELSE 0
        END
    ) AS cancelled_rev
FROM orders;
--
-- Q12: Flag orders as "Large", "Medium", or "Small" based on their total amount.
SELECT order_id, 
    order_date, 
    total_amount,
    CASE
        WHEN total_amount >= 4000 THEN 'Large'
        WHEN total_amount >= 1500 THEN 'Medium'
        ELSE 'Small'
        END AS order_size
FROM orders
ORDER BY order_id;
--
-- Q13: How many orders fall into each order-size bucket?
WITH order_bucket AS(
    SELECT order_id, 
    order_date, 
    total_amount,
    CASE
        WHEN total_amount >= 4000 THEN 'Large'
        WHEN total_amount >= 1500 THEN 'Medium'
        ELSE 'Small'
        END AS order_size
    FROM orders
)
SELECT order_size,
    COUNT(*) AS order_count,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM order_bucket
GROUP BY order_size
ORDER BY order_count DESC;
--
-- Q14: Which vendors have the highest average product price? Show the top 5.
SELECT v.vendor_name, 
    ROUND(AVG(p.unit_price), 2) AS avg_price,
    COUNT(p.prod_id) AS product_count
FROM vendors v
    LEFT JOIN products p ON v.vendor_id = p.vendor_id
WHERE p.is_active = 1
GROUP BY v.vendor_name
ORDER BY avg_price DESC
LIMIT 5;
--
-- Q15: Which customers have made more than 3 orders? Show their total spend too.
WITH order_count_table AS(
    SELECT c.cust_id AS customer_id,
        c.first_name,
        c.last_name,
        COUNT(o.order_id) AS order_count,
        ROUND(SUM(o.total_amount), 2) AS total_spent
    FROM customers c
        LEFT JOIN orders o ON c.cust_id = o.customer_id
    GROUP BY c.cust_id, 
        c.first_name, 
        c.last_name
)
SELECT *
FROM order_count_table
WHERE order_count > 3
ORDER BY order_count DESC;
--
-- Q16: Find orders whose total is greater than the average total of their own customer's orders.