-- Q5: Which orders were paid by Card AND totaled more than $50?
SELECT order_id, order_date, store_id, payment_method, total_amount
FROM orders
WHERE payment_method = 'Card' AND total_amount > 50
ORDER BY total_amount DESC;
