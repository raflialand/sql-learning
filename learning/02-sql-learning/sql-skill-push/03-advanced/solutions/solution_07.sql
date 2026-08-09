-- Q7: Compare each subscriber's total data usage against the average usage of their own plan
--     (correlated subquery).
SELECT s.sub_id, s.first_name, s.last_name, p.plan_name,
       ROUND(SUM(u.data_mb), 0) AS total_data_mb,
       ROUND((SELECT AVG(usage2.total_mb)
              FROM (SELECT s2.sub_id, SUM(u2.data_mb) AS total_mb
                    FROM usage_logs u2
                    JOIN subscribers s2 ON u2.sub_id = s2.sub_id
                    WHERE s2.plan_id = s.plan_id
                    GROUP BY s2.sub_id) usage2), 0) AS plan_avg_usage,
       ROUND(SUM(u.data_mb) - (SELECT AVG(usage2.total_mb)
              FROM (SELECT s2.sub_id, SUM(u2.data_mb) AS total_mb
                    FROM usage_logs u2
                    JOIN subscribers s2 ON u2.sub_id = s2.sub_id
                    WHERE s2.plan_id = s.plan_id
                    GROUP BY s2.sub_id) usage2), 0) AS diff_from_plan_avg
FROM usage_logs u
JOIN subscribers s ON u.sub_id = s.sub_id
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY s.sub_id, s.first_name, s.last_name, p.plan_name
ORDER BY s.sub_id;
