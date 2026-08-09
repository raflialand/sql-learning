-- Q15: How many times was each payment method used?
SELECT payment_method, COUNT(*) AS usage_count
FROM orders
GROUP BY payment_method
ORDER BY usage_count DESC;
