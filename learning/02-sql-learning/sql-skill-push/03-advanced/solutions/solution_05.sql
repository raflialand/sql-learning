-- Q5: Divide subscribers into 4 usage quartiles (NTILE) based on total data usage.
WITH usage_totals AS (
    SELECT sub_id, SUM(data_mb) AS total_data_mb
    FROM usage_logs
    GROUP BY sub_id
)
SELECT sub_id, total_data_mb,
       NTILE(4) OVER (ORDER BY total_data_mb) AS usage_quartile
FROM usage_totals
ORDER BY total_data_mb;
