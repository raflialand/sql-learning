-- Solutions: Unit 11 — DQ Monitoring & Reporting
-- Run against dq_learning

-- =====================================================================
-- Exercise 11.1 — Customers scorecard
-- =====================================================================
SELECT 'Completeness' AS dimension, 'email not NULL' AS rule,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS metric,
       99.0 AS threshold,
       CASE WHEN COUNT(email) * 100.0 / COUNT(*) >= 99 THEN 'PASS' ELSE 'FAIL' END AS status
FROM customers
UNION ALL
SELECT 'Uniqueness', 'no duplicate emails',
       COUNT(*), 0,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (SELECT email FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1) d
UNION ALL
SELECT 'Validity', 'email format valid',
       COUNT(*), 0,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
-- Expected: all FAIL (86.7 / 2 / 2)

-- =====================================================================
-- Exercise 11.2 — Overall score (first two rules)
-- =====================================================================
WITH scorecard AS (
    SELECT 'Completeness' AS dimension, 'email not NULL' AS rule,
           ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS metric, 99.0 AS threshold,
           CASE WHEN COUNT(email) * 100.0 / COUNT(*) >= 99 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM customers
    UNION ALL
    SELECT 'Uniqueness', 'no duplicate emails', COUNT(*), 0,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
    FROM (SELECT email FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1) d
)
SELECT
    COUNT(*) AS total_rules,
    SUM(status = 'PASS') AS passed,
    SUM(status = 'FAIL') AS failed,
    ROUND(SUM(status = 'PASS') * 100.0 / COUNT(*), 0) AS overall_score
FROM scorecard;
-- Expected: 2 / 0 / 2 / 0

-- =====================================================================
-- Exercise 11.3 — Multi-dataset scorecard
-- =====================================================================
SELECT 'customers' AS dataset, 'Completeness' AS dimension,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS metric, 99.0 AS threshold,
       CASE WHEN COUNT(email) * 100.0 / COUNT(*) >= 99 THEN 'PASS' ELSE 'FAIL' END AS status
FROM customers
UNION ALL
SELECT 'orders', 'Completeness',
       ROUND(COUNT(total_amount) * 100.0 / COUNT(*), 1), 100.0,
       CASE WHEN COUNT(total_amount) * 100.0 / COUNT(*) >= 100 THEN 'PASS' ELSE 'FAIL' END
FROM orders
UNION ALL
SELECT 'products', 'Validity',
       ROUND(SUM(unit_price > 0) * 100.0 / COUNT(*), 1), 100.0,
       CASE WHEN SUM(unit_price > 0) * 100.0 / COUNT(*) >= 100 THEN 'PASS' ELSE 'FAIL' END
FROM products;
-- Expected: 3 FAIL rows

-- =====================================================================
-- Exercise 11.4 — Alert query (aggregate + HAVING, no GROUP BY)
-- =====================================================================
SELECT 'email_completeness' AS alert,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS actual
FROM customers
HAVING actual < 99;
-- Expected: 1 row (86.7)

-- =====================================================================
-- Exercise 11.5 — Rule catalog table + sample rules
-- =====================================================================
CREATE TABLE dq_rule_catalog (
    rule_id     VARCHAR(20) PRIMARY KEY,
    dataset     VARCHAR(50) NOT NULL,
    dimension   VARCHAR(20) NOT NULL,
    rule_name   VARCHAR(200) NOT NULL,
    rule_sql    TEXT NOT NULL,
    threshold   DECIMAL(10,2) NOT NULL,
    severity    VARCHAR(10) NOT NULL,
    owner       VARCHAR(100),
    active      TINYINT DEFAULT 1
);

INSERT INTO dq_rule_catalog VALUES
('DQ-CUST-001', 'customers', 'Completeness',
 'email must not be NULL or empty',
 'SELECT customer_id FROM customers WHERE email IS NULL OR TRIM(email) = ''''',
 0, 'HIGH', 'Marketing Steward', 1),
('DQ-CUST-002', 'customers', 'Uniqueness',
 'no duplicate emails',
 'SELECT email FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1',
 0, 'HIGH', 'Marketing Steward', 1),
('DQ-ORD-001', 'orders', 'Timeliness',
 'no future order dates',
 'SELECT order_id FROM orders WHERE order_date > CURDATE()',
 0, 'HIGH', 'Finance Steward', 1);

-- =====================================================================
-- Exercise 11.6 — History table + sample results
-- =====================================================================
CREATE TABLE dq_check_results (
    check_id    INT AUTO_INCREMENT PRIMARY KEY,
    run_date    DATE NOT NULL,
    rule_id     VARCHAR(20) NOT NULL,
    violations  INT NOT NULL,
    status      VARCHAR(10) NOT NULL
);

INSERT INTO dq_check_results (run_date, rule_id, violations, status) VALUES
('2026-08-01', 'DQ-CUST-001', 0, 'PASS'),
('2026-08-02', 'DQ-CUST-001', 2, 'FAIL');

-- =====================================================================
-- Exercise 11.7 — Trend query
-- =====================================================================
SELECT run_date, violations, status
FROM dq_check_results
WHERE rule_id = 'DQ-CUST-001'
ORDER BY run_date DESC
LIMIT 7;

-- =====================================================================
-- Exercise 11.8 (TRANSLATE — for reference)
-- With no GROUP BY, COUNT(...) collapses the whole table to one row.
-- HAVING filters that one row; when the condition is false the result set
-- is empty, so "no rows" = healthy, "one row" = fire the alert.

-- =====================================================================
-- Exercise 11.9 (TRANSLATE — for reference)
-- NOT EXISTS prevents duplicate alerts: it only inserts when there is no
-- existing OPEN alert for the same rule, so repeated runs don't spam.

-- =====================================================================
-- Exercise 11.10 — Fixed: HAVING for aggregates
-- =====================================================================
SELECT 'email_completeness' AS alert,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS actual
FROM customers
HAVING actual < 99;

-- =====================================================================
-- Exercise 11.11 — Fixed: HAVING (alias) instead of WHERE
-- =====================================================================
SELECT 'email_completeness' AS alert,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS actual
FROM customers
HAVING actual < 99;

-- =====================================================================
-- Exercise 11.12 — Fixed: count duplicate GROUPS, not rows
-- =====================================================================
SELECT 'no dup emails' AS rule_name,
       COUNT(*) AS duplicate_groups,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM (
    SELECT email
    FROM customers
    WHERE email IS NOT NULL
    GROUP BY email
    HAVING COUNT(*) > 1
) g;
-- Expected: 2 duplicate groups -> FAIL
