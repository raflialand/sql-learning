-- Q14: Which vendors have the highest average product price? Show top 5.
SELECT v.vendor_name, ROUND(AVG(p.unit_price), 2) AS avg_price,
       COUNT(p.prod_id) AS product_count
FROM vendors v
JOIN products p ON v.vendor_id = p.vendor_id
WHERE p.is_active = 1
GROUP BY v.vendor_id, v.vendor_name
ORDER BY avg_price DESC
LIMIT 5;
