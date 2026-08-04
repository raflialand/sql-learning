-- =====================================================================
-- DQ-LEARNING: Dirty E-Commerce Dataset (MySQL 8)
-- Purpose: purpose-built dataset for Data Quality practice.
--          Contains intentionally seeded defects across all 6 DQ
--          dimensions. See dq_dataset_schema.md for the defect map.
-- Reference date: 2026-08-03 (any date AFTER this is "in the future")
-- =====================================================================

CREATE DATABASE IF NOT EXISTS dq_learning;
USE dq_learning;

-- =====================================================================
-- DROP TABLES (FK-safe order)
-- =====================================================================
DROP TABLE IF EXISTS daily_sales;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- =====================================================================
-- SCHEMA
-- NOTE: deliberately constraint-light so dirty data can be inserted.
--       Real production schemas enforce these rules; this one lets you
--       find the violations yourself.
-- =====================================================================

CREATE TABLE customers (
    customer_id  INT PRIMARY KEY,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    email        VARCHAR(100),
    phone        VARCHAR(30),
    state        VARCHAR(30),
    signup_date  DATE,
    is_active    TINYINT
);

CREATE TABLE products (
    product_id      INT PRIMARY KEY,
    sku             VARCHAR(20),
    product_name    VARCHAR(100),
    category        VARCHAR(50),
    unit_price      DECIMAL(10,2),
    weight_kg       DECIMAL(8,2),
    discontinued_at DATE,
    is_active       TINYINT
);

CREATE TABLE addresses (
    address_id   INT PRIMARY KEY,
    customer_id  INT,
    address_line VARCHAR(200),
    city         VARCHAR(50),
    country      VARCHAR(50)
);

CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT,
    order_date   DATE,
    ship_city    VARCHAR(50),
    ship_country VARCHAR(50),
    status       VARCHAR(20),
    total_amount DECIMAL(10,2),
    currency     VARCHAR(3)
);

CREATE TABLE order_items (
    item_id     INT PRIMARY KEY,
    order_id    INT,
    product_id  INT,
    qty         INT,
    unit_price  DECIMAL(10,2),
    total_price DECIMAL(10,2),
    currency    VARCHAR(3)
);

CREATE TABLE daily_sales (
    sale_date     DATE,
    region_id     VARCHAR(10),
    total_orders  INT,
    total_revenue DECIMAL(12,2),
    total_items   INT,
    PRIMARY KEY (sale_date, region_id)
);

-- =====================================================================
-- CUSTOMERS  (seeded defects: dupes, NULLs, bad email, mixed-case state)
-- =====================================================================
INSERT INTO customers VALUES
(1,  'Alice',  'Johnson', 'alice.johnson@example.com', '(555) 123-4567', 'NY', '2025-01-15', 1),
(2,  'Alice',  'Johnson', 'alice.johnson@example.com', '(555) 123-4567', 'NY', '2025-01-15', 1),  -- EXACT duplicate of #1
(3,  'Bob',    'Smith',   'bob.smith@example.com',     '555-987-6543',   'CA', '2025-02-10', 1),
(4,  'Bob',    'Smith',   'bob@example.com',           '555-987-6543',   'California', '2025-02-10', 1),  -- NEAR dup of #3 (state mismatch)
(5,  'Carol',  'Davis',   NULL,                        '555-111-2222',   'TX', '2025-03-05', 1),          -- NULL email
(6,  'David',  'Wilson',  'david.wilson@@example.com', '555-333-4444',   'tx', '2025-04-20', 1),          -- INVALID email (double @@), lowercase state
(7,  'Eve',    'Brown',   'eve.brown@example',         NULL,             'FL', '2025-05-11', 1),          -- INVALID email (no TLD), NULL phone
(8,  'Frank',  'Miller',  'frank.miller@example.com',  '555-555-6666',   'NY', NULL,        1),           -- NULL signup_date
(9,  'Grace',  'Lee',     'grace.lee@example.com',     '555.777.8888',   'CA', '2025-06-30', 1),          -- phone uses dots instead of dashes
(10, 'Henry',  'Adams',   'henry.adams@example.com',   NULL,             'WA', '2025-07-14', 0),
(11, 'Ivy',    'Clark',   'ivy.clark@example.com',     '555-222-3333',   'OR', '2025-08-01', 1),
(12, 'Ivy',    'Clark',   'ivy.clark@example.com',     '555-222-3333',   'Oregon', '2025-08-01', 1),      -- NEAR dup of #11 (state name vs abbr)
(13, 'Jack',   'White',   'jack.white@example.com',    '555-444-5555',   'MA', '2025-09-09', 1),
(14, NULL,     NULL,      NULL,                        NULL,             NULL, NULL, 1),                  -- fully empty row
(15, 'Kevin',  'King',    'kevin.king@example.com',    '555-666-7777',   'AZ', '2025-10-20', 1);

-- =====================================================================
-- PRODUCTS  (seeded defects: dup SKU, negative/zero price, bad weight, expired-active)
-- =====================================================================
INSERT INTO products VALUES
(1,  'SKU-1001', 'Wireless Mouse',  'Electronics',    29.99,  0.15,  NULL,       1),
(2,  'SKU-1001', 'Wireless Mouse',  'Electronics',    29.99,  0.15,  NULL,       1),  -- DUPLICATE SKU
(3,  'SKU-1002', 'USB-C Cable',     'Electronics',    -5.00,  0.05,  NULL,       1),  -- NEGATIVE price
(4,  'SKU-1003', 'Desk Lamp',       'Home & Office',  0.00,   1.20,  NULL,       1),  -- ZERO price
(5,  'SKU-1004', 'Office Chair',    'Furniture',      199.99, 150.00, NULL,      1),  -- weight out of range
(6,  'SKU-1005', 'Coffee Maker',    'Appliances',     49.99,  4.50,  '2025-01-01', 1), -- discontinued in past but STILL ACTIVE
(7,  'SKU-1006', 'Notebook',        'Stationery',     4.99,   0.30,  NULL,       1),
(8,  'SKU-1007', 'Pen',             NULL,             1.99,   0.05,  NULL,       1),  -- NULL category
(9,  'SKU-1008', 'Stapler',         'Office',         7.99,   0.40,  NULL,       1),
(10, 'SKU-1009', 'Monitor 24"',     'Electronics',    149.99, 5.00,  NULL,       0),  -- inactive
(11, 'SKU-1006', 'Notebook',        'Stationery',     4.99,   0.30,  NULL,       1),  -- DUPLICATE SKU of #7
(12, 'SKU-1010', 'Paper Ream',      'Office',         5.99,   2.30,  NULL,       1);

-- =====================================================================
-- ADDRESSES  (seeded defects: duplicate address, inconsistent country names)
-- =====================================================================
INSERT INTO addresses VALUES
(1,  1,  '100 Main St',  'New York',      'USA'),
(2,  1,  '100 Main St',  'New York',      'USA'),           -- DUPLICATE address for customer 1
(3,  2,  '200 Oak Ave',  'Los Angeles',   'USA'),
(4,  3,  '300 Pine Rd',  'San Francisco', 'USA'),
(5,  3,  '300 Pine Rd',  'San Francisco', 'US'),            -- inconsistent country ('US' vs 'USA')
(6,  4,  '400 Maple Dr', 'Austin',        'USA'),
(7,  5,  '500 Cedar Ln', 'Dallas',        'USA'),
(8,  6,  '600 Elm St',   'Miami',         'USA'),
(9,  7,  '700 Birch Blvd','Buffalo',      'USA'),
(10, 8,  '800 Walnut St', 'Albany',       'USA'),
(11, 9,  '900 Spruce Ave', 'LA',          'USA'),
(12, 10, '1000 Ash Ct',  'Seattle',       'United States');  -- inconsistent country ('United States' vs 'USA')

-- =====================================================================
-- ORDERS  (seeded defects: orphan FK, NULLs, future date, bad status enum, currency)
-- =====================================================================
INSERT INTO orders VALUES
(1,  1,  '2026-06-01', 'New York',      'USA', 'shipped',   59.98,  'USD'),
(2,  2,  '2026-06-02', 'New York',      'USA', 'shipped',   29.99,  'USD'),
(3,  99, '2026-06-05', 'Boston',        'USA', 'shipped',   99.99,  'USD'),   -- ORPHAN customer_id (no customer 99)
(4,  3,  '2026-06-07', NULL,            'USA', 'pending',   NULL,   'USD'),   -- NULL ship_city + NULL amount
(5,  4,  '2026-08-15', 'San Francisco', 'USA', 'shipped',   199.99, 'USD'),   -- FUTURE order_date (ref date 2026-08-03)
(6,  5,  '2026-06-10', 'Austin',        'USA', 'shipped',   9.98,   'USD'),
(7,  6,  '2026-06-12', 'Dallas',        'USA', 'shipped',   14.97,  'USD'),
(8,  7,  '2026-06-15', 'Miami',         'USA', 'Shipped',   4.99,   'USD'),   -- mixed-case status
(9,  8,  '2026-06-18', 'Buffalo',       'USA', 'SHIPPED',   7.99,   'USD'),   -- uppercase status
(10, 9,  '2026-06-20', 'LA',            'USA', 'shippd',    3.98,   'USD'),   -- TYPO status
(11, 10, '2026-06-22', 'Seattle',       'USA', 'cancelled', 29.99,  'USD'),
(12, 11, '2026-06-25', 'Portland',      'USA', 'shipped',   59.99,  'EUR'),   -- EUR order
(13, 12, '2026-06-27', 'Portland',      'USA', 'shipped',   59.99,  'EUR'),
(14, 13, '2026-06-30', 'Boston',        'USA', 'pending',   149.99, 'USD'),
(15, 14, '2026-07-02', NULL,            'USA', 'shipped',   0.00,   'USD');   -- NULL ship_city, zero total

-- =====================================================================
-- ORDER_ITEMS  (seeded defects: orphan FKs, total mismatch, negative/zero qty, currency mismatch)
-- =====================================================================
INSERT INTO order_items VALUES
(1,  1,  1,  2,  29.99, 59.98,  'USD'),   -- valid (2 x 29.99)
(2,  1,  7,  1,  4.99,  4.99,   'USD'),   -- valid
(3,  2,  1,  1,  29.99, 29.99,  'USD'),   -- valid
(4,  3,  99, 1,  99.99, 99.99,  'USD'),   -- ORPHAN product_id (no product 99)
(5,  4,  3,  1,  5.00,  4.00,   'USD'),   -- MISMATCH: qty x unit_price = 5.00, total says 4.00
(6,  5,  5,  1,  199.99, 199.99, 'USD'),  -- valid
(7,  6,  4,  2,  0.00,  0.00,   'USD'),   -- item from zero-price product
(8,  7,  6,  1,  49.99, 49.99,  'USD'),   -- valid
(9,  8,  8,  1,  1.99,  1.99,   'USD'),   -- valid
(10, 9,  9,  1,  7.99,  7.99,   'USD'),   -- valid
(11, 10, 10, 0,  149.99, 0.00,  'USD'),   -- ZERO qty
(12, 11, 1,  1,  29.99, 29.99,  'USD'),   -- valid
(13, 12, 7,  1,  4.99,  4.99,   'EUR'),   -- consistent with EUR order
(14, 12, 1,  1,  29.99, 29.99,  'USD'),   -- CURRENCY MISMATCH (order is EUR, item is USD)
(15, 13, 2,  1,  29.99, 29.99,  'EUR'),   -- valid
(16, 14, 10, 1,  149.99, 149.99, 'USD'),  -- valid
(17, 14, 5,  2,  199.99, 399.98, 'USD'),  -- valid (2 x 199.99)
(18, 15, 11, 5,  4.99,  24.95,  'USD'),   -- valid (5 x 4.99)
(19, 15, 3,  -1, 5.00,  -5.00,  'USD'),   -- NEGATIVE qty
(20, 999, 1, 1, 29.99, 29.99, 'USD');     -- ORPHAN order_id (no order 999)

-- =====================================================================
-- DAILY_SALES  (seeded defects: spike, dip, NULL metrics)
-- Generated date spine 2026-05-01 .. 2026-07-31 for two regions.
-- Anomalies: big spike 2026-06-15 RGN001, deep dip 2026-06-25 RGN002,
--            NULL revenue 2026-06-05 RGN002, NULL items 2026-07-11 RGN001,
--            distribution shift from 2026-07-21 (promotion baseline raised).
-- =====================================================================
INSERT INTO daily_sales (sale_date, region_id, total_orders, total_revenue, total_items)
WITH RECURSIVE date_spine AS (
    SELECT CAST('2026-05-01' AS DATE) AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM date_spine WHERE d < '2026-07-31'
)
SELECT
    d,
    r.region_id,
    CASE
        WHEN d = '2026-06-15' AND r.region_id = 'RGN001' THEN 520
        WHEN d = '2026-06-25' AND r.region_id = 'RGN002' THEN 3
        WHEN d >= '2026-07-21' THEN 75 + MOD(DAYOFYEAR(d), 15)
        WHEN DAYOFWEEK(d) IN (1,7) THEN 80 + MOD(DAYOFYEAR(d), 12)
        ELSE 48 + MOD(DAYOFYEAR(d), 9)
    END AS total_orders,
    CASE
        WHEN d = '2026-06-15' AND r.region_id = 'RGN001' THEN 520 * 110.00
        WHEN d = '2026-06-25' AND r.region_id = 'RGN002' THEN 3 * 110.00
        WHEN d >= '2026-07-21' THEN (75 + MOD(DAYOFYEAR(d), 15)) * 110.00
        WHEN DAYOFWEEK(d) IN (1,7) THEN (80 + MOD(DAYOFYEAR(d), 12)) * 110.00
        ELSE (48 + MOD(DAYOFYEAR(d), 9)) * 110.00
    END AS total_revenue,
    CASE
        WHEN d = '2026-06-15' AND r.region_id = 'RGN001' THEN 1040
        WHEN d = '2026-06-25' AND r.region_id = 'RGN002' THEN 6
        WHEN d >= '2026-07-21' THEN 2 * (75 + MOD(DAYOFYEAR(d), 15))
        WHEN DAYOFWEEK(d) IN (1,7) THEN 2 * (80 + MOD(DAYOFYEAR(d), 12))
        ELSE 2 * (48 + MOD(DAYOFYEAR(d), 9))
    END AS total_items
FROM date_spine
CROSS JOIN (
    SELECT 'RGN001' AS region_id
    UNION ALL
    SELECT 'RGN002'
) r;

-- Inject the NULL metric rows
UPDATE daily_sales
SET total_revenue = NULL
WHERE sale_date = '2026-06-05' AND region_id = 'RGN002';

UPDATE daily_sales
SET total_items = NULL
WHERE sale_date = '2026-07-11' AND region_id = 'RGN001';

-- =====================================================================
-- VERIFICATION SNIPPET (run after load)
-- SELECT 'customers' AS tbl, COUNT(*) AS rows FROM customers
-- UNION ALL SELECT 'products', COUNT(*) FROM products
-- UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
-- UNION ALL SELECT 'orders', COUNT(*) FROM orders
-- UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
-- UNION ALL SELECT 'daily_sales', COUNT(*) FROM daily_sales;
-- =====================================================================
