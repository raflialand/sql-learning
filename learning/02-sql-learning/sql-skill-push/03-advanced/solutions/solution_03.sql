-- Q3: Running total of revenue by billing month.
WITH monthly_rev AS (
    SELECT bill_date,
           ROUND(SUM(amount), 2) AS revenue
    FROM billing
    GROUP BY bill_date
)
SELECT bill_date, revenue,
       ROUND(SUM(revenue) OVER (ORDER BY bill_date), 2) AS running_revenue
FROM monthly_rev;
