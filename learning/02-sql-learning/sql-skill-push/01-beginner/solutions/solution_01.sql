-- Q1: Which products are currently active? Show them from cheapest to most expensive.
SELECT prod_id, prod_name, category, unit_price
FROM products
WHERE is_active = 1
ORDER BY unit_price ASC;
