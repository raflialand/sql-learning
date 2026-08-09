-- Q16: Find orders whose total amount is greater than the average total of their own customer's orders.
SELECT o1.order_id, o1.customer_id, o1.total_amount,
       ROUND((SELECT AVG(o2.total_amount)
              FROM orders o2
              WHERE o2.customer_id = o1.customer_id), 2) AS customer_avg
FROM orders o1
WHERE o1.total_amount > (SELECT AVG(o2.total_amount)
                         FROM orders o2
                         WHERE o2.customer_id = o1.customer_id)
ORDER BY o1.customer_id, o1.order_id;
