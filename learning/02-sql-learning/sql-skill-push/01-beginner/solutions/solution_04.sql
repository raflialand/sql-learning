-- Q4: How many orders were placed at store BRW001 (Manhattan)?
SELECT store_id, COUNT(*) AS order_count
FROM orders
WHERE store_id = 'BRW001';
