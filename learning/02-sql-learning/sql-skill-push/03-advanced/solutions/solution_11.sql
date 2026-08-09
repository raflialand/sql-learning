-- Q11: Which months had no tickets at all? Generate a continuous month series with a recursive CTE
--     and LEFT JOIN actual ticket counts.
WITH RECURSIVE months(month) AS (
    SELECT '2025-06-01'
    UNION ALL
    SELECT date(month, '+1 month')
    FROM months
    WHERE month < '2026-01-01'
)
SELECT strftime('%Y-%m', m.month) AS month,
       COALESCE(t.ticket_count, 0) AS ticket_count
FROM months m
LEFT JOIN (
    SELECT strftime('%Y-%m', created_date) AS month, COUNT(*) AS ticket_count
    FROM tickets
    GROUP BY strftime('%Y-%m', created_date)
) t ON t.month = strftime('%Y-%m', m.month)
ORDER BY month;
