-- Q14: Which product categories bring in the most revenue? (revenue = qty x unit_price)
SELECT p.category, ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY total_revenue DESC;
