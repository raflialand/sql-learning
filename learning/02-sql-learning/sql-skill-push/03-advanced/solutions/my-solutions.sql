-- [Advanced SQL Skill Push]
-- Q1: What is the total revenue per plan across the two billing months?
SELECT
   p.plan_name,
   ROUND(SUM(b.amount), 2) AS total_revenue
FROM plans p
    JOIN subscribers s ON s.plan_id = p.plan_id
    JOIN billing b ON b.sub_id = s.sub_id
GROUP BY 
    p.plan_id, 
    p.plan_name
ORDER BY total_revenue DESC;
--
-- Q2: Show month-over-month revenue change using LAG.
WITH revenue_and_prev_revenue AS(
    SELECT
        bill_date,
        ROUND(SUM(amount), 2) AS revenue,
        ROUND(LAG(SUM(amount), 1) OVER(ORDER BY bill_date), 2) AS prev_month_revenue
    FROM billing
    GROUP BY bill_date
)
SELECT
    bill_date,
    revenue,
    prev_month_revenue,
    revenue - prev_month_revenue AS change
FROM revenue_and_prev_revenue;
--
-- Q3: Show revenue per billing month with a running (cumulative) total.

