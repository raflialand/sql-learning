-- Q2: Which orders have NOT been paid yet? Show orders with no matching payment row.
SELECT o.order_id, o.order_date, o.customer_id, o.total_amount
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL
ORDER BY o.order_id;
