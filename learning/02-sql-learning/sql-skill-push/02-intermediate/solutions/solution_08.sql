-- Q8: Total revenue and order count per month, with a running total of revenue over time.
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           COUNT(*) AS order_count,
           ROUND(SUM(total_amount), 2) AS revenue
    FROM orders
    GROUP BY strftime('%Y-%m', order_date)
)
SELECT month, order_count, revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_revenue
FROM monthly
ORDER BY month;
