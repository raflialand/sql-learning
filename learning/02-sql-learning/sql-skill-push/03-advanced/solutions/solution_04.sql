-- Q4: Rank subscribers by total data usage (descending), show top 10.
SELECT s.sub_id, s.first_name, s.last_name,
       SUM(u.data_mb) AS total_data_mb,
       RANK() OVER (ORDER BY SUM(u.data_mb) DESC) AS usage_rank
FROM usage_logs u
JOIN subscribers s ON u.sub_id = s.sub_id
GROUP BY s.sub_id, s.first_name, s.last_name
ORDER BY usage_rank
LIMIT 10;
