-- Q6: Which customers placed orders worth more than the overall average order value?
SELECT DISTINCT c.cust_id, c.first_name, c.last_name
FROM customers c
JOIN orders o ON c.cust_id = o.customer_id
WHERE o.total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY c.cust_id;
