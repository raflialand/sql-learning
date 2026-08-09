-- Q10: What are the 5 largest orders, and what store did each come from?
SELECT order_id, order_date, store_id, total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 5;
