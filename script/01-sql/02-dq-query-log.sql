-- [Querying based on Business Context]
-- This script is used to query the data quality logs based on specific business contexts.
--
-- DQ rule 1: completeness of total_amount
SELECT COUNT(*) AS null_total_amount
FROM orders
WHERE total_amount IS NULL;
--
-- DQ rule 2: validity of status
SELECT status,
    COUNT(*) AS cnt
FROM orders
GROUP BY status
HAVING status NOT IN('shipped', 'pending', 'cancelled');