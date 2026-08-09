-- Q17: Count orders per month for 2025, showing month name and count.
SELECT strftime('%Y-%m', order_date) AS month,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS revenue
FROM orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;
