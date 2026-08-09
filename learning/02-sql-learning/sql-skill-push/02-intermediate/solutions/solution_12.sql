-- Q12: Flag orders as "Large", "Medium", or "Small" based on their total amount.
SELECT order_id, order_date, total_amount,
       CASE
           WHEN total_amount >= 4000 THEN 'Large'
           WHEN total_amount >= 1500 THEN 'Medium'
           ELSE 'Small'
       END AS order_size
FROM orders
ORDER BY order_id;
