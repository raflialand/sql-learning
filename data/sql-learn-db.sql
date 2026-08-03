-- E-Commerce Learning Database for SQL Practice
-- RDBMS: SQLite

-- Drop tables if exist (for clean re-run)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- Departments
CREATE TABLE departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    budget REAL
);

-- Employees
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    department_id INTEGER REFERENCES departments(id),
    hire_date TEXT,
    salary REAL
);

-- Customers
CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    city TEXT,
    join_date TEXT
);

-- Categories
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

-- Products
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    price REAL NOT NULL,
    stock INTEGER DEFAULT 0
);

-- Orders
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER REFERENCES customers(id),
    order_date TEXT,
    status TEXT DEFAULT 'pending',
    total REAL
);

-- Order Items (junction table)
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER DEFAULT 1,
    price REAL NOT NULL
);

-- ==================== SAMPLE DATA ====================

-- Departments
INSERT INTO departments (name, budget) VALUES
    ('Sales', 50000),
    ('Marketing', 30000),
    ('IT', 45000),
    ('HR', 25000);

-- Employees
INSERT INTO employees (name, email, department_id, hire_date, salary) VALUES
    ('Alice Johnson', 'alice@company.com', 1, '2022-01-15', 5500),
    ('Bob Smith', 'bob@company.com', 1, '2021-06-20', 4800),
    ('Carol White', 'carol@company.com', 2, '2023-03-10', 5200),
    ('David Brown', 'david@company.com', 3, '2020-11-05', 7000),
    ('Eve Davis', 'eve@company.com', 4, '2022-08-30', 4500),
    ('Frank Miller', 'frank@company.com', 3, '2021-02-14', 6500),
    ('Grace Lee', 'grace@company.com', 2, '2023-01-20', 4900),
    ('Henry Wilson', 'henry@company.com', 1, '2022-07-08', 5100);

-- Customers
INSERT INTO customers (name, email, city, join_date) VALUES
    ('John Doe', 'john.doe@email.com', 'New York', '2023-01-10'),
    ('Jane Smith', 'jane.smith@email.com', 'Los Angeles', '2023-02-15'),
    ('Mike Johnson', 'mike.j@email.com', 'Chicago', '2023-03-20'),
    ('Sarah Brown', 'sarah.b@email.com', 'New York', '2023-04-05'),
    ('Tom Wilson', 'tom.w@email.com', 'Houston', '2023-05-12'),
    ('Lisa Garcia', 'lisa.g@email.com', 'Phoenix', '2023-06-18'),
    ('Kevin Martinez', 'kevin.m@email.com', 'Chicago', '2023-07-22'),
    ('Amy Taylor', 'amy.t@email.com', 'Los Angeles', '2023-08-30');

-- Categories
INSERT INTO categories (name) VALUES
    ('Electronics'),
    ('Clothing'),
    ('Books'),
    ('Home & Garden'),
    ('Sports');

-- Products
INSERT INTO products (name, category_id, price, stock) VALUES
    ('Laptop', 1, 999.99, 50),
    ('Smartphone', 1, 699.99, 100),
    ('Headphones', 1, 149.99, 200),
    ('T-Shirt', 2, 29.99, 500),
    ('Jeans', 2, 59.99, 300),
    ('Jacket', 2, 89.99, 150),
    ('SQL Mastery', 3, 49.99, 80),
    ('Python Guide', 3, 39.99, 120),
    ('Garden Tools Set', 4, 79.99, 40),
    ('Running Shoes', 5, 119.99, 75),
    ('Basketball', 5, 34.99, 200),
    ('Yoga Mat', 5, 24.99, 150);

-- Orders
INSERT INTO orders (customer_id, order_date, status, total) VALUES
    (1, '2024-01-15', 'completed', 1049.98),
    (2, '2024-01-18', 'completed', 749.98),
    (3, '2024-02-20', 'completed', 89.98),
    (1, '2024-02-28', 'completed', 149.99),
    (4, '2024-03-05', 'pending', 999.99),
    (5, '2024-03-10', 'shipped', 179.98),
    (2, '2024-03-15', 'completed', 49.99),
    (6, '2024-03-20', 'cancelled', 119.99),
    (7, '2024-04-01', 'completed', 198.97),
    (8, '2024-04-05', 'shipped', 89.98),
    (3, '2024-04-10', 'completed', 59.99),
    (5, '2024-04-15', 'completed', 154.98);

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
    (1, 1, 1, 999.99),
    (1, 3, 1, 149.99),
    (2, 2, 1, 699.99),
    (3, 4, 2, 29.99),
    (3, 5, 1, 59.99),
    (4, 3, 1, 149.99),
    (5, 1, 1, 999.99),
    (6, 10, 1, 119.99),
    (6, 12, 1, 24.99),
    (6, 11, 1, 34.99),
    (7, 7, 1, 49.99),
    (8, 10, 1, 119.99),
    (9, 3, 1, 149.99),
    (9, 6, 1, 89.99),
    (9, 8, 1, 39.99),
    (10, 4, 2, 29.99),
    (10, 5, 1, 59.99),
    (11, 5, 1, 59.99),
    (12, 9, 1, 79.99),
    (12, 12, 3, 24.99);
