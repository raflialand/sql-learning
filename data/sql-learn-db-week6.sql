-- E-Commerce Learning Database - Week 6 Migration
-- RDBMS: SQLite
-- Purpose: Add tables and data for JOIN Operations module (Week 6)

-- ==================== PRAGMA ====================
PRAGMA foreign_keys = ON;

-- ==================== ADD COLUMNS TO EXISTING TABLES ====================

-- Add manager_id to employees (for Self JOIN demo)
ALTER TABLE employees ADD COLUMN manager_id INTEGER REFERENCES employees(id);

-- Add promotion_id to orders (for Multiple JOIN demo)
ALTER TABLE orders ADD COLUMN promotion_id INTEGER REFERENCES promotions(id);

-- ==================== FIX DATA ISSUES ====================

-- Insert customer 8 (fixes orphan order reference - order_id=4 references customer_id=8)
-- Use explicit id=8 to match the order reference
INSERT OR REPLACE INTO customers (id, name, email, city, join_date) VALUES
    (8, 'Emma Davis', 'emma.d@email.com', 'Seattle', '2023-09-15');

-- ==================== NEW TABLE: suppliers ====================
-- Purpose: LEFT JOIN demo - products with optional supplier info

CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    city TEXT,
    country TEXT DEFAULT 'USA',
    rating REAL DEFAULT 3.0,
    is_active INTEGER DEFAULT 1,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO suppliers (name, email, city, country, rating) VALUES
    ('Tech Supply Co', 'orders@techsupply.com', 'San Francisco', 'USA', 4.5),
    ('Fashion Wholesale', 'sales@fashionwholesale.com', 'Los Angeles', 'USA', 4.2),
    ('Book Distributors Inc', 'contact@bookdist.com', 'New York', 'USA', 4.8),
    ('Garden Goods Ltd', 'info@gardengoods.com', 'Seattle', 'USA', 3.9),
    ('Sports Unlimited', 'orders@sportsunlim.com', 'Denver', 'USA', 4.1);

-- ==================== NEW TABLE: promotions ====================
-- Purpose: Multiple JOIN demo - orders with optional promotion discounts

CREATE TABLE promotions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    discount_percent REAL NOT NULL,
    min_purchase REAL DEFAULT 0,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    max_uses INTEGER DEFAULT 100,
    is_active INTEGER DEFAULT 1
);

INSERT INTO promotions (code, discount_percent, min_purchase, start_date, end_date, max_uses, is_active) VALUES
    ('SAVE10', 10.0, 50.0, '2024-01-01', '2024-12-31', 500, 1),
    ('SAVE20', 20.0, 100.0, '2024-01-01', '2024-12-31', 300, 1),
    ('SUMMER25', 25.0, 75.0, '2024-06-01', '2024-08-31', 200, 1),
    ('FLASH50', 50.0, 200.0, '2024-04-01', '2024-04-30', 50, 1),
    ('EXPIRED99', 15.0, 0.0, '2023-01-01', '2023-12-31', 100, 0);

-- ==================== NEW TABLE: shipments ====================
-- Purpose: RIGHT JOIN demo - orders with optional shipment tracking

CREATE TABLE shipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER REFERENCES orders(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    shipment_date TEXT,
    delivery_date TEXT,
    tracking_number TEXT,
    status TEXT DEFAULT 'pending'
        CHECK (status IN ('pending', 'shipped', 'delivered', 'returned', 'cancelled'))
);

-- Note: Only orders 1,2,3,5,6,7 have shipments
-- Orders 4,8,9,10,11,12 have NO shipments (for RIGHT JOIN demo)
INSERT INTO shipments (order_id, supplier_id, shipment_date, delivery_date, tracking_number, status) VALUES
    (1, 1, '2024-01-16', '2024-01-18', 'SHIP001', 'delivered'),
    (2, 1, '2024-01-19', '2024-01-22', 'SHIP002', 'delivered'),
    (3, 2, '2024-02-21', '2024-02-24', 'SHIP003', 'delivered'),
    (5, 1, '2024-03-06', NULL, 'SHIP004', 'shipped'),
    (6, 4, '2024-03-11', NULL, 'SHIP005', 'shipped'),
    (7, 2, '2024-03-16', '2024-03-19', 'SHIP006', 'delivered');

-- ==================== NEW TABLE: product_reviews ====================
-- Purpose: FULL OUTER JOIN demo - products with optional reviews

CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER REFERENCES products(id),
    customer_id INTEGER REFERENCES customers(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Note: Products 1,3,4,7,10 have reviews
-- Products 2,5,6,8,9,11,12 have NO reviews (for FULL OUTER JOIN demo)
INSERT INTO product_reviews (product_id, customer_id, rating, review_text, review_date) VALUES
    (1, 1, 5, 'Excellent laptop! Fast processor and beautiful display.', '2024-02-01'),
    (1, 2, 4, 'Good laptop but a bit pricey for the specs.', '2024-02-10'),
    (3, 1, 5, 'Amazing sound quality! Best headphones I have owned.', '2024-02-15'),
    (4, 3, 4, 'Nice soft cotton t-shirt. Good value for money.', '2024-03-01'),
    (7, 4, 5, 'Must read for anyone learning SQL! Clear and practical.', '2024-03-15'),
    (10, 5, 4, 'Comfortable running shoes. Great arch support.', '2024-04-01');

-- ==================== NEW TABLE: gift_cards ====================
-- Purpose: LEFT JOIN demo - customers with optional gift card usage

CREATE TABLE gift_cards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    customer_id INTEGER REFERENCES customers(id),
    initial_amount REAL NOT NULL,
    current_balance REAL NOT NULL,
    issue_date TEXT NOT NULL,
    expiration_date TEXT,
    is_redeemed INTEGER DEFAULT 0
);

-- Note: Customers 1,2 have gift cards (some redeemed, some not)
-- Customers 3,4,5,6,7 have NO gift cards
-- 2 gift cards have NULL customer_id (unassigned)
INSERT INTO gift_cards (code, customer_id, initial_amount, current_balance, issue_date, expiration_date, is_redeemed) VALUES
    ('GC100', 1, 100.00, 0.00, '2024-01-01', '2025-01-01', 1),
    ('GC200', 1, 50.00, 35.50, '2024-02-15', '2025-02-15', 1),
    ('GC300', 2, 75.00, 75.00, '2024-03-01', '2025-03-01', 0),
    ('GC400', NULL, 25.00, 25.00, '2024-03-10', '2025-03-10', 0),
    ('GC500', NULL, 100.00, 100.00, '2024-04-01', '2025-04-01', 0);

-- ==================== UPDATE EMPLOYEE MANAGERS ====================
-- Set up manager relationships for Self JOIN demo
-- Alice Johnson (id=1) is the CEO (no manager)
-- Bob Smith (id=2) and Henry Wilson (id=8) report to Alice

UPDATE employees SET manager_id = 1 WHERE id IN (2, 8);

-- Carol White (id=3) and Grace Lee (id=9) report to Frank Miller (id=6) in Marketing
UPDATE employees SET manager_id = 6 WHERE id IN (3, 9);

-- Eve Davis (id=5) reports to Henry Wilson (id=8) in HR
UPDATE employees SET manager_id = 8 WHERE id = 5;

-- Frank Miller (id=6) reports to David Brown (id=4) in IT
UPDATE employees SET manager_id = 4 WHERE id = 6;

-- David Brown (id=4) is the CTO (no manager above him)

-- ==================== UPDATE ORDER PROMOTIONS ====================
-- Link some orders to promotions for Multiple JOIN demo

UPDATE orders SET promotion_id = 1 WHERE id IN (1, 2);      -- SAVE10
UPDATE orders SET promotion_id = 2 WHERE id IN (5, 6);      -- SAVE20
UPDATE orders SET promotion_id = 3 WHERE id = 7;            -- SUMMER25
UPDATE orders SET promotion_id = 4 WHERE id = 9;             -- FLASH50
-- Orders 3,4,8,10,11,12 have no promotion (NULL)

-- ==================== VERIFICATION QUERIES ====================

-- Verify all tables have data
SELECT 'departments' as table_name, COUNT(*) as row_count FROM departments
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'promotions', COUNT(*) FROM promotions
UNION ALL SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL SELECT 'product_reviews', COUNT(*) FROM product_reviews
UNION ALL SELECT 'gift_cards', COUNT(*) FROM gift_cards;

-- Expected counts:
-- departments: 4, employees: 8, customers: 8, categories: 5, products: 12
-- orders: 12, order_items: 20, suppliers: 5, promotions: 5
-- shipments: 6, product_reviews: 6, gift_cards: 5
