-- =====================================================================
-- DQ-LEARNING: CLEAN E-Commerce Reference Dataset (MySQL 8)
-- Purpose: a "source of truth" / master-data reference used by Unit 07
--          (Accuracy). Compare the dirty dq_dataset.sql against this one
--          to detect records whose values contradict master data.
-- Reference date: 2026-08-03
-- =====================================================================

CREATE DATABASE IF NOT EXISTS dq_learning;
USE dq_learning;

-- =====================================================================
-- DROP TABLES (FK-safe order)
-- =====================================================================
DROP TABLE IF EXISTS dq_clean_daily_sales;
DROP TABLE IF EXISTS dq_clean_order_items;
DROP TABLE IF EXISTS dq_clean_orders;
DROP TABLE IF EXISTS dq_clean_addresses;
DROP TABLE IF EXISTS dq_clean_products;
DROP TABLE IF EXISTS dq_clean_customers;

-- =====================================================================
-- SCHEMA (mirrors dq_dataset.sql but clean)
-- =====================================================================

CREATE TABLE dq_clean_customers (
    customer_id  INT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    email        VARCHAR(100) NOT NULL,
    phone        VARCHAR(30),
    state        VARCHAR(30),
    signup_date  DATE,
    is_active    TINYINT
);

CREATE TABLE dq_clean_products (
    product_id      INT PRIMARY KEY,
    sku             VARCHAR(20) NOT NULL UNIQUE,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    unit_price      DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
    weight_kg       DECIMAL(8,2),
    discontinued_at DATE,
    is_active       TINYINT
);

CREATE TABLE dq_clean_addresses (
    address_id   INT PRIMARY KEY,
    customer_id  INT NOT NULL,
    address_line VARCHAR(200),
    city         VARCHAR(50),
    country      VARCHAR(50)
);

CREATE TABLE dq_clean_orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT NOT NULL,
    order_date   DATE NOT NULL,
    ship_city    VARCHAR(50),
    ship_country VARCHAR(50),
    status       VARCHAR(20),
    total_amount DECIMAL(10,2),
    currency     VARCHAR(3)
);

CREATE TABLE dq_clean_order_items (
    item_id     INT PRIMARY KEY,
    order_id    INT NOT NULL,
    product_id  INT NOT NULL,
    qty         INT NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    currency    VARCHAR(3)
);

CREATE TABLE dq_clean_daily_sales (
    sale_date     DATE,
    region_id     VARCHAR(10),
    total_orders  INT,
    total_revenue DECIMAL(12,2),
    total_items   INT,
    PRIMARY KEY (sale_date, region_id)
);

-- =====================================================================
-- CLEAN CUSTOMERS (master record for customers 1-13; note corrected #6/#7)
-- =====================================================================
INSERT INTO dq_clean_customers VALUES
(1,  'Alice',  'Johnson', 'alice.johnson@example.com', '(555) 123-4567', 'NY',   '2025-01-15', 1),
(2,  'Alice',  'Johnson', 'alice.johnson@example.com', '(555) 123-4567', 'NY',   '2025-01-15', 1),
(3,  'Bob',    'Smith',   'bob.smith@example.com',     '555-987-6543',   'CA',   '2025-02-10', 1),
(4,  'Bob',    'Smith',   'bob.smith@example.com',     '555-987-6543',   'CA',   '2025-02-10', 1),
(5,  'Carol',  'Davis',   'carol.davis@example.com',   '555-111-2222',   'TX',   '2025-03-05', 1),
(6,  'David',  'Wilson',  'david.wilson@example.com',  '555-333-4444',   'TX',   '2025-04-20', 1),
(7,  'Eve',    'Brown',   'eve.brown@example.com',     '555-555-0100',   'FL',   '2025-05-11', 1),
(8,  'Frank',  'Miller',  'frank.miller@example.com',  '555-555-6666',   'NY',   '2025-06-01', 1),
(9,  'Grace',  'Lee',     'grace.lee@example.com',     '555-777-8888',   'CA',   '2025-06-30', 1),
(10, 'Henry',  'Adams',   'henry.adams@example.com',   '555-555-0900',   'WA',   '2025-07-14', 0),
(11, 'Ivy',    'Clark',   'ivy.clark@example.com',     '555-222-3333',   'OR',   '2025-08-01', 1),
(12, 'Ivy',    'Clark',   'ivy.clark@example.com',     '555-222-3333',   'OR',   '2025-08-01', 1),
(13, 'Jack',   'White',   'jack.white@example.com',    '555-444-5555',   'MA',   '2025-09-09', 1);

-- =====================================================================
-- CLEAN PRODUCTS (correct price/weight; master record for products 1-12)
-- =====================================================================
INSERT INTO dq_clean_products VALUES
(1,  'SKU-1001', 'Wireless Mouse',  'Electronics',    29.99,  0.15,  NULL, 1),
(2,  'SKU-1001', 'Wireless Mouse',  'Electronics',    29.99,  0.15,  NULL, 1),
(3,  'SKU-1002', 'USB-C Cable',     'Electronics',    9.99,   0.05,  NULL, 1),
(4,  'SKU-1003', 'Desk Lamp',       'Home & Office',  24.99,  1.20,  NULL, 1),
(5,  'SKU-1004', 'Office Chair',    'Furniture',      199.99, 12.00, NULL, 1),
(6,  'SKU-1005', 'Coffee Maker',    'Appliances',     49.99,  4.50,  '2026-01-01', 0),
(7,  'SKU-1006', 'Notebook',        'Stationery',     4.99,   0.30,  NULL, 1),
(8,  'SKU-1007', 'Pen',             'Stationery',     1.99,   0.05,  NULL, 1),
(9,  'SKU-1008', 'Stapler',         'Office',         7.99,   0.40,  NULL, 1),
(10, 'SKU-1009', 'Monitor 24"',     'Electronics',    149.99, 5.00,  NULL, 0),
(11, 'SKU-1006', 'Notebook',        'Stationery',     4.99,   0.30,  NULL, 1),
(12, 'SKU-1010', 'Paper Ream',      'Office',         5.99,   2.30,  NULL, 1);

-- =====================================================================
-- CLEAN ADDRESSES
-- =====================================================================
INSERT INTO dq_clean_addresses VALUES
(1,  1,  '100 Main St',   'New York',      'USA'),
(2,  2,  '200 Oak Ave',   'Los Angeles',   'USA'),
(3,  3,  '300 Pine Rd',   'San Francisco', 'USA'),
(4,  4,  '400 Maple Dr',  'Austin',        'USA'),
(5,  5,  '500 Cedar Ln',  'Dallas',        'USA'),
(6,  6,  '600 Elm St',    'Miami',         'USA'),
(7,  7,  '700 Birch Blvd', 'Buffalo',      'USA'),
(8,  8,  '800 Walnut St', 'Albany',        'USA'),
(9,  9,  '900 Spruce Ave', 'Los Angeles',  'USA'),
(10, 10, '1000 Ash Ct',   'Seattle',       'USA'),
(11, 11, '1100 Willow Dr', 'Portland',     'USA'),
(12, 12, '1200 Oakwood Rd', 'Portland',    'USA'),
(13, 13, '1300 Cedar Ct', 'Boston',        'USA');

-- =====================================================================
-- CLEAN ORDERS (matches order totals to item sums; all shipped statuses normalized)
-- =====================================================================
INSERT INTO dq_clean_orders VALUES
(1,  1,  '2026-06-01', 'New York',      'USA', 'shipped',   59.98,  'USD'),
(2,  2,  '2026-06-02', 'New York',      'USA', 'shipped',   29.99,  'USD'),
(3,  3,  '2026-06-05', 'Boston',        'USA', 'shipped',   99.99,  'USD'),
(4,  4,  '2026-06-07', 'San Francisco', 'USA', 'pending',   5.00,   'USD'),
(5,  5,  '2026-06-10', 'Austin',        'USA', 'shipped',   199.99, 'USD'),
(6,  6,  '2026-06-12', 'Dallas',        'USA', 'shipped',   0.00,   'USD'),
(7,  7,  '2026-06-15', 'Miami',         'USA', 'shipped',   49.99,  'USD'),
(8,  8,  '2026-06-18', 'Buffalo',       'USA', 'shipped',   1.99,   'USD'),
(9,  9,  '2026-06-20', 'Los Angeles',   'USA', 'shipped',   7.99,   'USD'),
(10, 10, '2026-06-22', 'Seattle',       'USA', 'cancelled', 0.00,   'USD'),
(11, 11, '2026-06-25', 'Portland',      'USA', 'shipped',   4.99,   'EUR'),
(12, 12, '2026-06-27', 'Portland',      'USA', 'shipped',   29.99,  'EUR'),
(13, 13, '2026-06-30', 'Boston',        'USA', 'pending',   149.99, 'USD');

-- =====================================================================
-- CLEAN ORDER_ITEMS (totals always equal qty * unit_price; currency matches order)
-- =====================================================================
INSERT INTO dq_clean_order_items VALUES
(1,  1,  1,  2,  29.99, 59.98,  'USD'),
(2,  1,  7,  1,  4.99,  4.99,   'USD'),
(3,  2,  1,  1,  29.99, 29.99,  'USD'),
(4,  3,  5,  1,  99.99, 99.99,  'USD'),
(5,  4,  3,  1,  5.00,  5.00,   'USD'),
(6,  5,  5,  1,  199.99, 199.99, 'USD'),
(7,  6,  4,  2,  0.00,  0.00,   'USD'),
(8,  7,  6,  1,  49.99, 49.99,  'USD'),
(9,  8,  8,  1,  1.99,  1.99,   'USD'),
(10, 9,  9,  1,  7.99,  7.99,   'USD'),
(11, 10, 10, 1,  149.99, 149.99, 'USD'),
(12, 11, 7,  1,  4.99,  4.99,   'EUR'),
(13, 12, 1,  1,  29.99, 29.99,  'EUR'),
(14, 13, 10, 1,  149.99, 149.99, 'USD');

-- =====================================================================
-- CLEAN DAILY_SALES (consistent baseline; no spikes or dips; no NULL metrics)
-- =====================================================================
WITH RECURSIVE date_spine AS (
    SELECT CAST('2026-05-01' AS DATE) AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM date_spine WHERE d < '2026-07-31'
)
INSERT INTO dq_clean_daily_sales (sale_date, region_id, total_orders, total_revenue, total_items)
SELECT
    d,
    r.region_id,
    48 + MOD(DAYOFYEAR(d), 9) AS total_orders,
    (48 + MOD(DAYOFYEAR(d), 9)) * 110.00 AS total_revenue,
    2 * (48 + MOD(DAYOFYEAR(d), 9)) AS total_items
FROM date_spine
CROSS JOIN (
    SELECT 'RGN001' AS region_id
    UNION ALL
    SELECT 'RGN002'
) r;
