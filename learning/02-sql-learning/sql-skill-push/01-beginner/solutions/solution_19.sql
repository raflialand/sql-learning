-- Q19: What is the average order value per month, and which month had the highest?
SELECT strftime('%Y-%m', order_date) AS month, ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY avg_order_value DESC;
