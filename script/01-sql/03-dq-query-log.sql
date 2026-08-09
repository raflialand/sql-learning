-- Rule 1  
SELECT customer_id, 
	first_name, 
	last_name, 
	email, 
	is_active
FROM customers
WHERE email IS NULL
OR email = '' 
;
-- Rule 2 
SELECT customer_id,
	first_name,
	last_name,
	email,
	is_active
FROM customers
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
;
-- Rule 3
SELECT email,
	COUNT(*) AS `count`
FROM customers
GROUP BY email
HAVING COUNT(*) > 1
AND email IS NOT NULL
;
