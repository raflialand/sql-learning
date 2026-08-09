-- Q3: Which customers signed up in 2025? List their name, city and signup date.
SELECT cust_id, first_name, last_name, city, signup_date
FROM customers
WHERE signup_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY signup_date;
