-- Q9: For each subscriber, show their next payment date (LEAD) to spot missed payments.
SELECT p.sub_id, p.pay_date, p.amount,
       LEAD(p.pay_date) OVER (PARTITION BY p.sub_id ORDER BY p.pay_date) AS next_pay_date,
       LEAD(p.amount) OVER (PARTITION BY p.sub_id ORDER BY p.pay_date) AS next_pay_amount
FROM payments p
ORDER BY p.sub_id, p.pay_date;
