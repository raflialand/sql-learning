-- Q10: Moving average of ticket volume by month (3-month window).
WITH monthly_tickets AS (
    SELECT strftime('%Y-%m', created_date) AS month, COUNT(*) AS ticket_count
    FROM tickets
    GROUP BY strftime('%Y-%m', created_date)
)
SELECT month, ticket_count,
       ROUND(AVG(ticket_count) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly_tickets
ORDER BY month;
