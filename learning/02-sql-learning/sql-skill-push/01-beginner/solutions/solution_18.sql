-- Q18: How many orders were placed in each month of 2025?
SELECT strftime('%Y-%m', order_date) AS month, COUNT(*) AS order_count
FROM orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;
