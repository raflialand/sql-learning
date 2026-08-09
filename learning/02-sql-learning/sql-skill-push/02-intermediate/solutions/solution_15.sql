-- Q15: Which customers have made more than 3 orders? Use a CTE + HAVING.
WITH customer_orders AS (
    SELECT o.customer_id, c.first_name, c.last_name,
           COUNT(*) AS order_count,
           ROUND(SUM(o.total_amount), 2) AS total_spent
    FROM orders o
    JOIN customers c ON o.customer_id = c.cust_id
    GROUP BY o.customer_id, c.first_name, c.last_name
)
SELECT customer_id, first_name, last_name, order_count, total_spent
FROM customer_orders
WHERE order_count > 3
ORDER BY order_count DESC;
