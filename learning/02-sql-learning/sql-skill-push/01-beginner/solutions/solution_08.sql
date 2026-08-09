-- Q8: Which orders do NOT have a recorded payment method?
SELECT order_id, order_date, store_id, total_amount
FROM orders
WHERE payment_method IS NULL;
