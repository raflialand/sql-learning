-- Q17: Which customers have spent more than $100 in total, and how much?
SELECT c.cust_id, c.first_name, c.last_name, ROUND(SUM(o.total_amount), 2) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > 100
ORDER BY total_spent DESC
LIMIT 10;
