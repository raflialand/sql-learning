-- Q13: How many orders fall into each order-size bucket?
SELECT
    CASE
        WHEN total_amount >= 4000 THEN 'Large'
        WHEN total_amount >= 1500 THEN 'Medium'
        ELSE 'Small'
    END AS order_size,
    COUNT(*) AS order_count,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders
GROUP BY
    CASE
        WHEN total_amount >= 4000 THEN 'Large'
        WHEN total_amount >= 1500 THEN 'Medium'
        ELSE 'Small'
    END
ORDER BY order_count DESC;
