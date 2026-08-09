-- Q3: How many products does each category contain? Include parent + subcategories.
SELECT c.cat_name, COUNT(p.prod_id) AS product_count
FROM categories c
LEFT JOIN products p ON p.cat_id = c.cat_id
GROUP BY c.cat_id, c.cat_name
ORDER BY product_count DESC, c.cat_name;
