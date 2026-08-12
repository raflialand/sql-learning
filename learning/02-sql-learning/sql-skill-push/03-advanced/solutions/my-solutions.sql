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
