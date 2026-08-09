-- Q14: Which subscribers churned AND still have unpaid bills? (INTERSECT of two sets)
SELECT sub_id, phone, first_name, last_name
FROM subscribers
WHERE sub_id IN (SELECT sub_id FROM churn)
INTERSECT
SELECT s.sub_id, s.phone, s.first_name, s.last_name
FROM subscribers s
JOIN billing b ON s.sub_id = b.sub_id
WHERE b.status IN ('Unpaid', 'Overdue');
