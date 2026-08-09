-- Q8: Subscribers who have tickets but never churned (set operation: MINUS / EXCEPT).
SELECT sub_id, first_name, last_name, phone
FROM subscribers
WHERE sub_id IN (SELECT sub_id FROM tickets)
  AND sub_id NOT IN (SELECT sub_id FROM churn)
ORDER BY sub_id;
