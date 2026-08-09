-- Q16: Which subscribers never made a payment but received a bill? (anti-join)
SELECT s.sub_id, s.first_name, s.last_name, s.phone, s.region,
       COUNT(b.bill_id) AS bills_issued
FROM subscribers s
JOIN billing b ON s.sub_id = b.sub_id
WHERE NOT EXISTS (SELECT 1 FROM payments p WHERE p.sub_id = s.sub_id)
GROUP BY s.sub_id, s.first_name, s.last_name, s.phone, s.region
ORDER BY bills_issued DESC, s.sub_id;
