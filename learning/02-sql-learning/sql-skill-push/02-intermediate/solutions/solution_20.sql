-- Q20: Compare payment methods by success rate (paid vs failed+refunded).
SELECT method,
       COUNT(*) AS total_payments,
       ROUND(SUM(CASE WHEN status = 'Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS paid_pct,
       ROUND(SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failed_pct,
       ROUND(SUM(CASE WHEN status = 'Refunded' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS refunded_pct
FROM payments
GROUP BY method
ORDER BY paid_pct DESC;
