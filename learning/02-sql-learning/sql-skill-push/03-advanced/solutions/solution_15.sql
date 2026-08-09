-- Q15: For each subscriber, find the first and last payment date and how many payments they made.
SELECT sub_id,
       MIN(pay_date) AS first_pay_date,
       MAX(pay_date) AS last_pay_date,
       COUNT(*) AS payment_count
FROM payments
GROUP BY sub_id
ORDER BY payment_count DESC, sub_id;
