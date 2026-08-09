-- Q7: Which inactive (discontinued) products were still ordered by customers?
SELECT DISTINCT p.prod_id, p.prod_name, c.cat_name, p.unit_price
FROM products p
JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = 0
  AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.prod_id)
ORDER BY p.prod_id;
