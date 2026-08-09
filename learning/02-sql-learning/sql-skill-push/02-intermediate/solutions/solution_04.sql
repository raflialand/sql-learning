-- Q4: Total revenue per category (from order items), for categories with > $500k revenue.
SELECT c.cat_name, ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.prod_id
JOIN categories c ON p.cat_id = c.cat_id
GROUP BY c.cat_id, c.cat_name
HAVING SUM(oi.quantity * oi.unit_price) > 500000
ORDER BY total_revenue DESC;
