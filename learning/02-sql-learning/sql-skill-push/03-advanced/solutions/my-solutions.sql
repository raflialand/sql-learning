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
WITH ranked AS(
    SELECT 
        s.region,
        SUM(ul.data_mb) AS total_data_mb,
        ROW_NUMBER() OVER(PARTITION BY s.region ORDER BY SUM(ul.data_mb)) AS rn,
        COUNT(*) OVER(PARTITION BY s.region) AS n
    FROM subscribers s
        JOIN usage_logs ul ON ul.sub_id = s.sub_id
    GROUP BY
        s.region,
        s.sub_id
)
SELECT
    region,
    ROUND(AVG(total_data_mb), 0) AS median_data_mb
FROM ranked
WHERE rn IN (FLOOR((n + 1) / 2), FLOOR((n + 2) / 2))
GROUP BY region
ORDER BY median_data_mb DESC;
--
-- Q7: Compare each subscriber's total data usage against the average usage of their own plan (correlated subquery).
WITH total_data AS(
    SELECT 
        s.sub_id,
        s.first_name,
        s.last_name,
        p.plan_name,
        ROUND(SUM(ul.data_mb), 0) AS total_data_mb
    FROM subscribers s
        JOIN plans p        ON p.plan_id = s.plan_id
        JOIN usage_logs ul  ON ul.sub_id = s.sub_id
    GROUP BY
        s.sub_id,
        s.first_name,
        s.last_name,
        p.plan_name
), avg_data_plan AS(
    SELECT 
        plan_name,
        ROUND(AVG(total_data_mb), 0) AS plan_avg_usage
    FROM total_data
    GROUP BY plan_name
)
SELECT
    td.sub_id,
    td.first_name,
    td.last_name,
    td.plan_name,
    td.total_data_mb,
    adp.plan_avg_usage,
    td.total_data_mb - adp.plan_avg_usage AS diff_from_plan_avg
FROM total_data td
    JOIN avg_data_plan adp ON adp.plan_name = td.plan_name
ORDER BY td.sub_id;
--
-- Q8: Which subscribers have support tickets but never churned?
SELECT
    sub_id,
    first_name,
    last_name,
    phone
FROM subscribers
WHERE sub_id    IN (SELECT sub_id FROM tickets)
    AND sub_id  NOT IN (SELECT sub_id FROM churn)
ORDER BY sub_id;
--
-- Q9: For each subscriber, show their next payment date (LEAD) to spot missed
SELECT 
    sub_id,
    pay_date,
    amount,
    LEAD(pay_date)  OVER(PARTITION BY sub_id ORDER BY pay_date) AS next_pay_date,
    LEAD(amount)    OVER(PARTITION BY sub_id ORDER BY pay_date) AS next_pay_amount
FROM payments
ORDER BY
    sub_id, 
    pay_date;
--
-- 10: Show monthly ticket volume with a 3-month moving average.
WITH monthly AS( 
    SELECT
        DATE_FORMAT(created_date, '%Y-%m') AS `month`,
        COUNT(*) AS ticket_count
    FROM tickets
    GROUP BY DATE_FORMAT(created_date, '%Y-%m')
)
SELECT
    `month`,
    ticket_count,
    ROUND(AVG(ticket_count) 
        OVER(ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly
ORDER By `month`;
--
-- Q11: Generate a continuous series of months and show ticket counts, including months with zero tickets.