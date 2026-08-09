-- Q16: Which customer has placed the most orders? Show top 5 customers by order count.
SELECT c.cust_id, c.first_name, c.last_name, COUNT(*) AS order_count
FROM orders o
JOIN customers c ON o.customer_id = c.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY order_count DESC
LIMIT 5;
