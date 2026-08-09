-- Q20: Which customers have NEVER placed an order?
SELECT c.cust_id, c.first_name, c.last_name, c.email
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.cust_id;
