-- Q17: What is each subscriber's data usage share vs the region total? (window ratio)
WITH region_totals AS (
    SELECT s.region, SUM(u.data_mb) AS region_data
    FROM usage_logs u
    JOIN subscribers s ON u.sub_id = s.sub_id
    GROUP BY s.region
)
SELECT s.sub_id, s.region, SUM(u.data_mb) AS sub_data,
       rt.region_data,
       ROUND(SUM(u.data_mb) * 100.0 / rt.region_data, 2) AS pct_of_region
FROM usage_logs u
JOIN subscribers s ON u.sub_id = s.sub_id
JOIN region_totals rt ON s.region = rt.region
GROUP BY s.sub_id, s.region, rt.region_data
ORDER BY pct_of_region DESC;
