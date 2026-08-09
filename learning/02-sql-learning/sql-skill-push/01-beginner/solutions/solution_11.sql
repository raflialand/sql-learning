-- Q11: How many orders were placed at each store?
SELECT store_id, COUNT(*) AS order_count
FROM orders
GROUP BY store_id
ORDER BY order_count DESC;
