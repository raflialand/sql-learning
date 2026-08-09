-- Q13: What is the average order value at each store?
SELECT store_id, ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY store_id
ORDER BY avg_order_value DESC;
