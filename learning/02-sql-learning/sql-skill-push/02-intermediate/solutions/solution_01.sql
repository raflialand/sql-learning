-- Q1: For each order, show the customer's full name and country.
SELECT o.order_id, o.order_date, c.first_name, c.last_name, c.country, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.cust_id
ORDER BY o.order_id;
