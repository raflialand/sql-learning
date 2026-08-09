-- Q19: Ticket handling time in days for resolved tickets (correlated + date diff).
SELECT ticket_id, sub_id, category, created_date, resolved_date,
       julianday(resolved_date) - julianday(created_date) AS handling_days
FROM tickets
WHERE resolved_date IS NOT NULL
ORDER BY handling_days DESC;
