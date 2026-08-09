-- Q12: What is the total revenue per store?
SELECT o.store_id, ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM orders o
GROUP BY o.store_id
ORDER BY total_revenue DESC;
