-- Q9: Rank each order within its customer by amount (1 = largest). Show top 2 orders per customer.
WITH ranked AS (
    SELECT o.order_id, o.customer_id, o.total_amount,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.total_amount DESC) AS rn
    FROM orders o
)
SELECT r.customer_id, r.order_id, r.total_amount, r.rn
FROM ranked r
WHERE r.rn <= 2
ORDER BY r.customer_id, r.rn;
