-- Q6: Median total data usage per region (approx: middle row when ordered).
WITH ranked AS (
    SELECT s.region, SUM(u.data_mb) AS total_data_mb,
           ROW_NUMBER() OVER (PARTITION BY s.region ORDER BY SUM(u.data_mb)) AS rn,
           COUNT(*) OVER (PARTITION BY s.region) AS cnt
    FROM usage_logs u
    JOIN subscribers s ON u.sub_id = s.sub_id
    GROUP BY s.region, s.sub_id
)
SELECT region, ROUND(AVG(total_data_mb), 0) AS median_data_mb
FROM ranked
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
GROUP BY region
ORDER BY median_data_mb DESC;
