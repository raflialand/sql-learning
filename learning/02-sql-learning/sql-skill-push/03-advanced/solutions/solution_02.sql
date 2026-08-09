-- Q2: Month-over-month revenue change using LAG.
WITH monthly_rev AS (
    SELECT bill_date,
           ROUND(SUM(amount), 2) AS revenue
    FROM billing
    GROUP BY bill_date
)
SELECT bill_date, revenue,
       LAG(revenue) OVER (ORDER BY bill_date) AS prev_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY bill_date), 2) AS change
FROM monthly_rev;
