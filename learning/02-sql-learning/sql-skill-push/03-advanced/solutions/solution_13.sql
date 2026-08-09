-- Q13: Cross-tab / pivot: ticket category counts by status (one row per category).
SELECT category,
       SUM(CASE WHEN status = 'Open' THEN 1 ELSE 0 END) AS open_count,
       SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) AS resolved_count,
       SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) AS closed_count,
       COUNT(*) AS total
FROM tickets
GROUP BY category
ORDER BY total DESC;
