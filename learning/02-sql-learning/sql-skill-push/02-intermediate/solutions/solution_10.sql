-- Q10: For each product, show its price compared to the average price of its category.
SELECT p.prod_id, p.prod_name, p.unit_price,
       ROUND(AVG(p.unit_price) OVER (PARTITION BY p.cat_id), 2) AS cat_avg_price,
       ROUND(p.unit_price - AVG(p.unit_price) OVER (PARTITION BY p.cat_id), 2) AS diff_from_avg
FROM products p
WHERE p.is_active = 1
ORDER BY p.cat_id, p.unit_price DESC;
