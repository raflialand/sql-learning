-- Q12: Churn rate by region (churned subscribers / total subscribers per region).
SELECT s.region,
       COUNT(DISTINCT s.sub_id) AS total_subs,
       COUNT(DISTINCT c.sub_id) AS churned,
       ROUND(COUNT(DISTINCT c.sub_id) * 100.0 / COUNT(DISTINCT s.sub_id), 2) AS churn_rate_pct
FROM subscribers s
LEFT JOIN churn c ON s.sub_id = c.sub_id
GROUP BY s.region
ORDER BY churn_rate_pct DESC;
