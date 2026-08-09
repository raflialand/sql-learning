-- Q19: Which products sell above their category's average price, based on actual sale prices?
WITH prod_avg AS (
    SELECT p.prod_id, p.prod_name, p.cat_id,
           AVG(oi.unit_price) AS avg_sale_price
    FROM products p
    JOIN order_items oi ON p.prod_id = oi.product_id
    WHERE p.is_active = 1
    GROUP BY p.prod_id, p.prod_name, p.cat_id
),
cat_avg AS (
    SELECT cat_id, AVG(avg_sale_price) AS cat_avg_sale
    FROM prod_avg
    GROUP BY cat_id
)
SELECT pa.prod_id, pa.prod_name, ROUND(pa.avg_sale_price, 2) AS avg_sale_price,
       ROUND(ca.cat_avg_sale, 2) AS category_avg_sale
FROM prod_avg pa
JOIN cat_avg ca ON pa.cat_id = ca.cat_id
WHERE pa.avg_sale_price > ca.cat_avg_sale
ORDER BY pa.cat_id, pa.avg_sale_price DESC;
