-- Q6: Which products are priced between $3 and $6?
SELECT prod_id, prod_name, category, unit_price
FROM products
WHERE unit_price BETWEEN 3 AND 6
ORDER BY unit_price;
