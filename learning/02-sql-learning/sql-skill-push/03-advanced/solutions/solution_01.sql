-- Q1: Revenue per plan across the two billing months, with a grand total.
SELECT p.plan_name,
       ROUND(SUM(b.amount), 2) AS total_revenue
FROM billing b
JOIN subscribers s ON b.sub_id = s.sub_id
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY p.plan_id, p.plan_name
ORDER BY total_revenue DESC;
