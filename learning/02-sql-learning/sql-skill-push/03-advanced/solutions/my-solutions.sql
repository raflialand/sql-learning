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
WITH month_revenue(bill_date, revenue) AS(
    SELECT
        bill_date,
        ROUND(SUM(amount), 2)
    FROM billing
    GROUP BY bill_date
)
SELECT
    bill_date,
    revenue,
    SUM(revenue) OVER(ORDER BY bill_date)
FROM month_revenue;
--
-- Q4: Rank subscribers by total data usage (descending), show the top 10.
WITH usage_rank_table AS(
    SELECT 
        s.sub_id,
        s.first_name,
        s.last_name,
        ROUND(SUM(ul.data_mb), 2) AS total_data_mb,
        RANK() OVER(ORDER BY SUM(ul.data_mb) DESC) AS usage_rank
    FROM subscribers s
        JOIN usage_logs ul ON ul.sub_id = s.sub_id
    GROUP BY 
        s.sub_id,
        s.first_name,
        s.last_name
    ORDER BY usage_rank ASC
)
SELECT *
FROM usage_rank_table
WHERE usage_rank <= 10;
--
-- Q5: Divide subscribers into 4 usage quartiles based on total data usage.
SELECT
    s.sub_id,
    SUM(ul.data_mb) AS total_data_mb,
    NTILE(4) OVER(ORDER BY SUM(ul.data_mb)) AS usage_quartile
FROM subscribers s
    JOIN usage_logs ul ON ul.sub_id = s.sub_id
GROUP BY s.sub_id
ORDER BY usage_quartile, total_data_mb;
--
-- Q6: What is the median total data usage per region? (approx: the middle row when ordered)
