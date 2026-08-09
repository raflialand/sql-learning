-- Q5: Average order value per country, for countries whose average order value exceeds the overall average.
SELECT c.country, ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.cust_id
GROUP BY c.country
HAVING AVG(o.total_amount) > (SELECT AVG(total_amount) FROM orders)
ORDER BY avg_order_value DESC;
