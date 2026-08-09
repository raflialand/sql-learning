-- Q20: Cohort analysis: for each signup quarter, count how many subscribers are still active,
--      and what % that represents of the cohort.
WITH cohorts AS (
    SELECT sub_id,
           strftime('%Y-Q' || ((CAST(strftime('%m', signup_date) AS INTEGER) + 2) / 3), signup_date) AS cohort
    FROM subscribers
)
SELECT c.cohort,
       COUNT(*) AS total_subs,
       SUM(CASE WHEN s.status = 'Active' THEN 1 ELSE 0 END) AS still_active,
       ROUND(SUM(CASE WHEN s.status = 'Active' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS active_pct
FROM cohorts c
JOIN subscribers s ON c.sub_id = s.sub_id
GROUP BY c.cohort
ORDER BY c.cohort;
