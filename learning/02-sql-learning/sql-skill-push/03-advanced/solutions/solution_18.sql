-- Q18: Find subscribers whose data usage exceeds their plan's allowance.
SELECT s.sub_id, s.first_name, s.last_name, p.plan_name, p.data_gb AS plan_data_gb,
       SUM(u.data_mb) AS total_data_mb,
       ROUND(SUM(u.data_mb) / 1024.0, 2) AS total_data_gb
FROM usage_logs u
JOIN subscribers s ON u.sub_id = s.sub_id
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY s.sub_id, s.first_name, s.last_name, p.plan_name, p.data_gb
HAVING SUM(u.data_mb) > p.data_gb * 1024
ORDER BY total_data_gb DESC;
