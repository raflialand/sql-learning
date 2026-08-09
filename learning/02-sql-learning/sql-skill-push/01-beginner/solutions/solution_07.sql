-- Q7: Which products have "Coffee" anywhere in their name?
SELECT prod_id, prod_name, category, unit_price
FROM products
WHERE prod_name LIKE '%Coffee%';
