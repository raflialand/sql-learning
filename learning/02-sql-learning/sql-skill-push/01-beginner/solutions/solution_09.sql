-- Q9: What are the 5 most expensive products on the menu?
SELECT prod_id, prod_name, category, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 5;
