# Week 6: JOIN Operations

**Database:** `sql-learn.db` (after running `sql-learn-db-week6.sql` migration)
**Tables:** departments, employees, customers, categories, products, orders, order_items, suppliers, shipments, product_reviews, gift_cards, promotions
**Duration:** 7 days, 1-2 hours/day

---

## Database Schema Reference

### Core Tables (from Week 5)

```sql
-- Departments
CREATE TABLE departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    budget REAL
);

-- Employees (added: manager_id for Self JOIN)
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    department_id INTEGER REFERENCES departments(id),
    hire_date TEXT,
    salary REAL,
    manager_id INTEGER REFERENCES employees(id)
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

-- Orders (added: promotion_id for Multiple JOIN)
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER REFERENCES customers(id),
    order_date TEXT,
    status TEXT DEFAULT 'pending',
    total REAL,
    promotion_id INTEGER REFERENCES promotions(id)
);

-- Order Items
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER DEFAULT 1,
    price REAL NOT NULL
);
```

### New Tables (for Week 6)

```sql
-- Suppliers
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

-- Promotions
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

-- Shipments
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

-- Product Reviews
CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER REFERENCES products(id),
    customer_id INTEGER REFERENCES customers(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Gift Cards
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
```

---

## Sample Data Summary

**Departments (4):** Sales, Marketing, IT, HR

**Employees (8):** Alice Johnson (CEO), Bob Smith, Carol White, David Brown (CTO), Eve Davis, Frank Miller, Grace Lee, Henry Wilson

**Manager Hierarchy:** Alice → Bob, Henry | David → Frank | Frank → Carol, Grace | Henry → Eve

**Customers (8):** John Doe, Jane Smith, Mike Johnson, Sarah Brown, Tom Wilson, Lisa Garcia, Kevin Martinez, Emma Davis

**Categories (5):** Electronics, Clothing, Books, Home & Garden, Sports

**Products (12):** Laptop ($999.99), Smartphone ($699.99), Headphones ($149.99), T-Shirt ($29.99), Jeans ($59.99), Jacket ($89.99), SQL Mastery ($49.99), Python Guide ($39.99), Garden Tools Set ($79.99), Running Shoes ($119.99), Basketball ($34.99), Yoga Mat ($24.99)

**Orders (12):** Mix of completed, pending, shipped, and cancelled with totals $49.99 - $1049.98

**Suppliers (5):** Tech Supply Co, Fashion Wholesale, Book Distributors Inc, Garden Goods Ltd, Sports Unlimited

**Shipments (6):** Orders 1,2,3,5,6,7 have shipments. Orders 4,8,9,10,11,12 have NO shipments.

**Product Reviews (6):** Products 1,3,4,7,10 have reviews. Products 2,5,6,8,9,11,12 have NO reviews.

**Promotions (5):** SAVE10 (10%), SAVE20 (20%), SUMMER25 (25%), FLASH50 (50%), EXPIRED99 (15%, inactive)

---

## What is a JOIN?

A JOIN combines rows from two or more tables based on a related column. Think of it like connecting data:

| Analogy | Database |
|---------|----------|
| **Venn Diagram** | Two circles (tables) with overlapping area (matched rows) |
| **Phone Book + Address Book** | Link a person's phone to their address via name |
| **Order Form + Customer File** | Connect an order to customer details via customer_id |

### JOIN Types Overview

| JOIN Type | Returns | Use Case |
|-----------|---------|----------|
| **INNER** | Only matching rows | Find orders with valid customers |
| **LEFT** | All left + matched right | All customers, even those who never ordered |
| **RIGHT** | All right + matched left | All orders, even those without shipments |
| **FULL** | All rows from both | All products, all reviews, matched or not |
| **CROSS** | Every combination | Generate all possible pairs |
| **SELF** | Table joined to itself | Employee + their manager |

---

## Day 1: INNER JOIN - Finding Matches

### What is INNER JOIN?

INNER JOIN returns only rows that have a match in BOTH tables. No match = no row.

```
Table A          Table B
┌────┬────┐      ┌────┬────┐
│ id │ A  │      │ id │ B  │
├────┼────┤      ├────┼────┤
│ 1  │ x  │      │ 1  │ y  │  ← Match!
│ 2  │ y  │      │ 3  │ z  │  ← Match!
│ 3  │ z  │      │ 5  │ w  │  ← Match!
└────┴────┘      └────┴────┘

INNER JOIN Result:
┌────┬────┬────┬────┐
│ id │ A  │ id │ B  │
├────┼────┼────┼────┤
│ 1  │ x  │ 1  │ y  │
│ 2  │ y  │ 3  │ z  │
│ 3  │ z  │ 5  │ w  │
└────┴────┴────┴────┘
```

### Syntax

```sql
SELECT columns
FROM table1
INNER JOIN table2 ON table1.column = table2.column;
```

### Example 1: Orders with Customer Names

```sql
SELECT o.id, o.order_date, o.total, c.name AS customer_name, c.city
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;
```

**Output:**
| id | order_date | total | customer_name | city |
|----|------------|-------|---------------|------|
| 1 | 2024-01-15 | 1049.98 | John Doe | New York |
| 2 | 2024-01-18 | 749.98 | Jane Smith | Los Angeles |
| 3 | 2024-02-20 | 89.98 | Mike Johnson | Chicago |
| ... | ... | ... | ... | ... |

**HR Translation:** "I need to see all orders with their customer information. Show me the order ID, date, total, and which customer placed it, including their city. Only show orders that have valid customer references."

### Example 2: Products with Category Names

```sql
SELECT p.id, p.name AS product_name, p.price, c.name AS category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.id
ORDER BY c.name, p.price;
```

**Output:**
| id | product_name | price | category_name |
|----|--------------|-------|---------------|
| 7 | SQL Mastery | 49.99 | Books |
| 8 | Python Guide | 39.99 | Books |
| 11 | Basketball | 34.99 | Sports |
| ... | ... | ... | ... |

### Example 3: Employees with Department Names

```sql
SELECT e.id, e.name AS employee_name, e.salary, d.name AS department
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
ORDER BY d.name, e.salary DESC;
```

**Output:**
| id | employee_name | salary | department |
|----|---------------|--------|------------|
| 4 | David Brown | 7000 | IT |
| 6 | Frank Miller | 6500 | IT |
| 1 | Alice Johnson | 5500 | Sales |
| ... | ... | ... | ... |

**HR Translation:** "Show me all employees grouped by their department. Include their salaries so I can see who's in each team and how much they're earning."

### Example 4: Order Items with Product Details

```sql
SELECT oi.id, oi.order_id, p.name AS product_name, oi.quantity, oi.price,
       (oi.quantity * oi.price) AS line_total
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = 1;
```

**Output:**
| id | order_id | product_name | quantity | price | line_total |
|----|----------|--------------|----------|-------|------------|
| 1 | 1 | Laptop | 1 | 999.99 | 999.99 |
| 2 | 1 | Headphones | 1 | 149.99 | 149.99 |

### Practice Exercises

1. Write an INNER JOIN to find all orders with status 'completed' showing customer name and total
2. Show products that belong to the 'Electronics' category (use INNER JOIN, not WHERE)
3. Find all employees in the 'Sales' department with their hire dates
4. List order_items for order_id = 6, showing product name, quantity, and price
5. Show all customers from 'New York' who have placed orders

---

## Day 2: LEFT JOIN - Including the Left Side

### What is LEFT JOIN?

LEFT JOIN returns ALL rows from the LEFT table, plus matching rows from the RIGHT table. If no match, NULL values appear for right table columns.

```
Table A          Table B
┌────┬────┐      ┌────┬────┐
│ id │ A  │      │ id │ B  │
├────┼────┤      ├────┼────┤
│ 1  │ x  │      │ 1  │ y  │
│ 2  │ y  │      │ 3  │ z  │
│ 4  │ w  │ ← No match in B
└────┴────┘      └────┴────┘

LEFT JOIN Result:
┌────┬────┬────┬────┐
│ id │ A  │ id │ B  │
├────┼────┼────┼────┤
│ 1  │ x  │ 1  │ y  │
│ 2  │ y  │ 3  │ z  │
│ 4  │ w  │NULL│NULL│ ← Included with NULLs
└────┴────┴────┴────┘
```

### Example 1: All Customers and Their Orders (If Any)

```sql
SELECT c.id, c.name AS customer_name, o.id AS order_id, o.total
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
ORDER BY c.id, o.id;
```

**Output:**
| id | customer_name | order_id | total |
|----|---------------|----------|-------|
| 1 | John Doe | 1 | 1049.98 |
| 1 | John Doe | 4 | 149.99 |
| 2 | Jane Smith | 2 | 749.98 |
| 3 | Mike Johnson | 3 | 89.98 |
| ... | ... | ... | ... |

**HR Translation:** "Show me all customers in our system. For each customer, also show any orders they have placed. If a customer hasn't ordered anything yet, still show their name but leave the order fields blank."

### Example 2: Customers WITHOUT Orders (Finding NULLs)

```sql
SELECT c.id, c.name AS customer_name, o.id AS order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;
```

**Result:** (Should return no rows - all 8 customers have orders)

### Example 3: Products with Optional Supplier Info

```sql
SELECT p.id, p.name AS product_name, p.price, s.name AS supplier_name, s.city
FROM products p
LEFT JOIN suppliers s ON p.supplier_id = s.id
ORDER BY p.id;
```

**Note:** Currently no products have supplier_id set, so all supplier columns will be NULL.

**HR Translation:** "List all products we sell. If a product comes from a specific supplier, show that supplier's information. If we don't have supplier info for a product, just show the product details with blank supplier fields."

### Example 4: LEFT JOIN with Aggregation

```sql
SELECT c.id, c.name AS customer_name,
       COUNT(o.id) AS order_count,
       COALESCE(SUM(o.total), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;
```

**Output:**
| id | customer_name | order_count | total_spent |
|----|---------------|-------------|-------------|
| 1 | John Doe | 2 | 1199.97 |
| 2 | Jane Smith | 2 | 799.97 |
| 3 | Mike Johnson | 2 | 149.97 |
| ... | ... | ... | ... |

### Example 5: Gift Cards - Customers with Optional Gift Cards

```sql
SELECT c.id, c.name AS customer_name, gc.code, gc.current_balance, gc.is_redeemed
FROM customers c
LEFT JOIN gift_cards gc ON c.id = gc.customer_id
ORDER BY c.id;
```

**Output:**
| id | customer_name | code | current_balance | is_redeemed |
|----|---------------|------|-----------------|-------------|
| 1 | John Doe | GC100 | 0.00 | 1 |
| 1 | John Doe | GC200 | 35.50 | 1 |
| 2 | Jane Smith | GC300 | 75.00 | 0 |
| 3 | Mike Johnson | NULL | NULL | NULL |
| ... | ... | ... | ... | ... |

**HR Translation:** "I want to see all customers and their gift card status. Show me which customers have gift cards, what the remaining balance is, and whether it's been redeemed. Customers without gift cards should still appear in the list."

### Practice Exercises

1. Show all customers and their order counts (include customers with 0 orders)
2. List all products with their reviews (products without reviews should still appear)
3. Find customers who have NOT placed any orders
4. Show all departments and the number of employees in each (departments with 0 employees should appear)
5. List all promotions and the orders that used them (unused promotions should still appear)

---

## Day 3: RIGHT JOIN & FULL OUTER JOIN

### What is RIGHT JOIN?

RIGHT JOIN returns ALL rows from the RIGHT table, plus matching rows from the LEFT table. SQLite does NOT support RIGHT JOIN, but you can simulate it by reversing the table order and using LEFT JOIN.

```sql
-- RIGHT JOIN (not supported in SQLite)
SELECT o.id, o.total, s.id AS shipment_id, s.status
FROM orders o
RIGHT JOIN shipments s ON o.id = s.order_id;

-- Equivalent in SQLite (swap tables and use LEFT)
SELECT o.id, o.total, s.id AS shipment_id, s.status
FROM shipments s
LEFT JOIN orders o ON s.order_id = o.id;
```

### What is FULL OUTER JOIN?

FULL OUTER JOIN returns ALL rows from BOTH tables. If there's no match, NULLs appear on the appropriate side. SQLite does NOT support FULL OUTER JOIN.

```sql
-- FULL OUTER JOIN (not supported in SQLite)
SELECT p.name AS product, r.rating, r.review_text
FROM products p
FULL OUTER JOIN product_reviews r ON p.id = r.product_id;

-- Equivalent in SQLite (using UNION)
SELECT p.name AS product, r.rating, r.review_text
FROM products p
LEFT JOIN product_reviews r ON p.id = r.product_id
UNION
SELECT p.name AS product, r.rating, r.review_text
FROM product_reviews r
LEFT JOIN products p ON r.product_id = p.id;
```

### Example 1: All Shipments with Their Orders (Simulating RIGHT JOIN)

```sql
-- Simulating RIGHT JOIN: All shipments, with order details if available
SELECT s.id AS shipment_id, s.tracking_number, s.status,
       o.id AS order_id, o.total, c.name AS customer_name
FROM shipments s
LEFT JOIN orders o ON s.order_id = o.id
LEFT JOIN customers c ON o.customer_id = c.id
ORDER BY s.id;
```

**Output:**
| shipment_id | tracking_number | status | order_id | total | customer_name |
|-------------|-----------------|--------|----------|-------|---------------|
| 1 | SHIP001 | delivered | 1 | 1049.98 | John Doe |
| 2 | SHIP002 | delivered | 2 | 749.98 | Jane Smith |
| 3 | SHIP003 | delivered | 3 | 89.98 | Mike Johnson |
| ... | ... | ... | ... | ... | ... |

**HR Translation:** "Show me all shipments we've created. For each shipment, include the order details and customer name if we have them. I need to see every shipment regardless of whether the order information is complete."

### Example 2: Orders WITHOUT Shipments (Finding the Missing)

```sql
-- Find orders that don't have shipments
SELECT o.id AS order_id, o.order_date, o.total, o.status
FROM orders o
LEFT JOIN shipments s ON o.id = s.order_id
WHERE s.id IS NULL
ORDER BY o.id;
```

**Output:**
| order_id | order_date | total | status |
|----------|------------|-------|---------|
| 4 | 2024-02-28 | 149.99 | pending |
| 8 | 2024-04-05 | 89.98 | shipped |
| 9 | 2024-04-10 | 59.99 | completed |
| 10 | 2024-04-15 | 179.98 | shipped |
| 11 | 2024-05-01 | 198.97 | pending |
| 12 | 2024-05-10 | 154.98 | completed |

**HR Translation:** "I need to identify which orders haven't been shipped yet. These are orders that need attention - they should have shipments but don't."

### Example 3: Simulating FULL OUTER JOIN - Products and Reviews

```sql
-- All products and all reviews, matched or not
SELECT p.id AS product_id, p.name AS product_name, p.price,
       r.id AS review_id, r.rating, r.review_text, r.customer_id
FROM products p
LEFT JOIN product_reviews r ON p.id = r.product_id
UNION
SELECT p.id AS product_id, p.name AS product_name, p.price,
       r.id AS review_id, r.rating, r.review_text, r.customer_id
FROM product_reviews r
LEFT JOIN products p ON r.product_id = p.id
ORDER BY product_id, review_id;
```

**Output (partial):**
| product_id | product_name | price | review_id | rating | review_text | customer_id |
|------------|--------------|-------|-----------|--------|-------------|-------------|
| 1 | Laptop | 999.99 | 1 | 5 | Excellent laptop! | 1 |
| 1 | Laptop | 999.99 | 2 | 4 | Good but pricey | 2 |
| 2 | Smartphone | 699.99 | NULL | NULL | NULL | NULL |
| 3 | Headphones | 149.99 | 3 | 5 | Amazing sound | 1 |
| ... | ... | ... | ... | ... | ... | ... |

**HR Translation:** "I need a complete view of products and their reviews. Show me all products we sell, and if they have reviews, show those too. Products without reviews should still appear in the list."

### Example 4: Products WITHOUT Reviews

```sql
-- Find products that have no reviews
SELECT p.id, p.name, p.price
FROM products p
LEFT JOIN product_reviews r ON p.id = r.product_id
WHERE r.id IS NULL
ORDER BY p.id;
```

**Output:**
| id | name | price |
|----|------|-------|
| 2 | Smartphone | 699.99 |
| 5 | Jeans | 59.99 |
| 6 | Jacket | 89.99 |
| 8 | Python Guide | 39.99 |
| 9 | Garden Tools Set | 79.99 |
| 11 | Basketball | 34.99 |
| 12 | Yoga Mat | 24.99 |

### Example 5: FULL OUTER JOIN - Gift Cards and Customers

```sql
-- All customers and all gift cards (including unassigned cards)
SELECT c.id AS customer_id, c.name AS customer_name, c.email,
       gc.id AS gift_card_id, gc.code, gc.current_balance
FROM customers c
LEFT JOIN gift_cards gc ON c.id = gc.customer_id
UNION
SELECT c.id AS customer_id, c.name AS customer_name, c.email,
       gc.id AS gift_card_id, gc.code, gc.current_balance
FROM gift_cards gc
LEFT JOIN customers c ON gc.customer_id = c.id
WHERE c.id IS NULL
ORDER BY customer_id, gift_card_id;
```

**Output (partial):**
| customer_id | customer_name | email | gift_card_id | code | current_balance |
|-------------|---------------|-------|--------------|------|-----------------|
| 1 | John Doe | john.doe@email.com | 1 | GC100 | 0.00 |
| 1 | John Doe | john.doe@email.com | 2 | GC200 | 35.50 |
| 2 | Jane Smith | jane.smith@email.com | 3 | GC300 | 75.00 |
| 3 | Mike Johnson | mike.j@email.com | NULL | NULL | NULL |
| ... | ... | ... | ... | ... | ... |
| NULL | NULL | NULL | 4 | GC400 | 25.00 |
| NULL | NULL | NULL | 5 | GC500 | 100.00 |

**HR Translation:** "I want to see the complete picture: all customers we have and all gift cards in the system. Some gift cards might not be assigned to anyone yet (show as NULL customer), and some customers might not have gift cards (show with NULL gift card info)."

### Practice Exercises

1. Find orders that don't have any shipments assigned
2. List all products with their average rating (products without reviews should show NULL)
3. Show customers who have placed orders but never used a gift card
4. Find products that have reviews but have never been ordered
5. List all promotions and orders that used them (unused promotions should appear with NULL order info)

---

## Day 4: CROSS JOIN & Self JOIN

### What is CROSS JOIN?

CROSS JOIN returns the CARTESIAN PRODUCT - every possible combination of rows from both tables. No ON clause is needed.

```
Table A          Table B
┌────┬────┐      ┌────┬────┐
│ id │ A  │      │ id │ B  │
├────┼────┤      ├────┼────┤
│ 1  │ x  │      │ 1  │ y  │
│ 2  │ y  │      │ 2  │ z  │
└────┴────┘      └────┴────┘

CROSS JOIN Result (2 × 2 = 4 rows):
┌────┬────┬────┬────┐
│ id │ A  │ id │ B  │
├────┼────┼────┼────┤
│ 1  │ x  │ 1  │ y  │
│ 1  │ x  │ 2  │ z  │
│ 2  │ y  │ 1  │ y  │
│ 2  │ y  │ 2  │ z  │
└────┴────┴────┴────┘
```

### What is Self JOIN?

Self JOIN joins a table to ITSELF. Useful for hierarchical data like employee-manager relationships.

```sql
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### Example 1: All Category × Status Combinations (CROSS JOIN)

```sql
-- Generate all possible category-status pairs for a report
SELECT c.name AS category, s.status
FROM categories c
CROSS JOIN (SELECT DISTINCT status FROM orders) s
ORDER BY c.name, s.status;
```

**Output:**
| category | status |
|----------|--------|
| Books | cancelled |
| Books | completed |
| Books | pending |
| Books | shipped |
| Clothing | cancelled |
| ... | ... |

**HR Translation:** "I need to generate a matrix showing every category combined with every order status. This will help me see if we have orders in all possible category-status combinations."

### Example 2: All Products × All Suppliers (CROSS JOIN)

```sql
-- Create a comparison matrix of products and potential suppliers
SELECT p.name AS product, p.price, s.name AS supplier, s.rating
FROM products p
CROSS JOIN suppliers s
WHERE s.is_active = 1
ORDER BY p.name, s.rating DESC;
```

**Output (partial):**
| product | price | supplier | rating |
|---------|-------|----------|--------|
| Laptop | 999.99 | Tech Supply Co | 4.5 |
| Laptop | 999.99 | Fashion Wholesale | 4.2 |
| Laptop | 999.99 | Book Distributors | 4.8 |
| ... | ... | ... | ... |

### Example 3: Employee-Manager Relationships (Self JOIN)

```sql
SELECT e.id, e.name AS employee_name, e.salary,
       m.id AS manager_id, m.name AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
ORDER BY m.name, e.name;
```

**Output:**
| id | employee_name | salary | manager_id | manager_name |
|----|---------------|--------|------------|--------------|
| 4 | David Brown | 7000 | NULL | NULL |
| 1 | Alice Johnson | 5500 | NULL | NULL |
| 2 | Bob Smith | 4800 | 1 | Alice Johnson |
| 8 | Henry Wilson | 5100 | 1 | Alice Johnson |
| 6 | Frank Miller | 6500 | 4 | David Brown |
| 3 | Carol White | 5200 | 6 | Frank Miller |
| ... | ... | ... | ... | ... |

**HR Translation:** "Show me our company hierarchy. For each employee, show who their manager is. The top executives (Alice and David) have no manager above them."

### Example 4: Colleagues in Same Department (Self JOIN variant)

```sql
-- Find employees who share the same department (excluding self-matches)
SELECT e1.name AS employee, e1.department_id, e2.name AS colleague
FROM employees e1
INNER JOIN employees e2 ON e1.department_id = e2.department_id
WHERE e1.id < e2.id
ORDER BY e1.department_id, e1.name;
```

**Output:**
| employee | department_id | colleague |
|----------|---------------|-----------|
| Alice Johnson | 1 | Bob Smith |
| Alice Johnson | 1 | Henry Wilson |
| Bob Smith | 1 | Henry Wilson |
| Carol White | 2 | Grace Lee |
| David Brown | 3 | Frank Miller |

**HR Translation:** "I need a list of colleague pairs - employees who work in the same department. This helps identify who might collaborate or who can cover for each other."

### Example 5: CROSS JOIN for Report Matrix

```sql
-- Monthly sales summary matrix
SELECT c.name AS category,
       SUM(CASE WHEN strftime('%m', o.order_date) = '01' THEN oi.quantity ELSE 0 END) AS Jan,
       SUM(CASE WHEN strftime('%m', o.order_date) = '02' THEN oi.quantity ELSE 0 END) AS Feb,
       SUM(CASE WHEN strftime('%m', o.order_date) = '03' THEN oi.quantity ELSE 0 END) AS Mar,
       SUM(CASE WHEN strftime('%m', o.order_date) = '04' THEN oi.quantity ELSE 0 END) AS Apr
FROM categories c
CROSS JOIN orders o
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
WHERE p.category_id = c.id
GROUP BY c.name
ORDER BY c.name;
```

### Practice Exercises

1. Generate all possible combinations of customers and promotion codes
2. Find employees who are managers (have at least one direct report)
3. List all products with all possible order statuses as columns (using CROSS JOIN)
4. Show the management chain for a specific employee (e.g., Eve Davis)
5. Create a price comparison matrix: products vs suppliers showing price differences

---

## Day 5: Multiple JOINs in One Query

### What are Multiple JOINs?

Multiple JOINs connect three or more tables in a single query. Each JOIN builds on the previous one.

```sql
SELECT a.col, b.col, c.col
FROM table_a a
INNER JOIN table_b b ON a.b_id = b.id
INNER JOIN table_c c ON b.c_id = c.id
WHERE conditions;
```

### Example 1: Full Order Details (Orders → Customers → Order Items → Products)

```sql
SELECT o.id AS order_id,
       o.order_date,
       c.name AS customer_name,
       c.city,
       p.name AS product_name,
       oi.quantity,
       oi.price,
       (oi.quantity * oi.price) AS line_total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
WHERE o.status = 'completed'
ORDER BY o.order_date DESC, o.id;
```

**Output (partial):**
| order_id | order_date | customer_name | city | product_name | quantity | price | line_total |
|----------|------------|---------------|------|--------------|----------|-------|------------|
| 3 | 2024-02-20 | Mike Johnson | Chicago | T-Shirt | 2 | 29.99 | 59.98 |
| 3 | 2024-02-20 | Mike Johnson | Chicago | Jeans | 1 | 59.99 | 59.99 |
| 1 | 2024-01-15 | John Doe | New York | Laptop | 1 | 999.99 | 999.99 |
| ... | ... | ... | ... | ... | ... | ... | ... |

**HR Translation:** "I need a complete order report showing every item purchased. Include customer details, product names, quantities, prices, and the line totals. Only show completed orders, sorted by date."

### Example 2: Orders with Promotion Discounts (Orders → Promotions)

```sql
SELECT o.id AS order_id,
       o.total AS original_total,
       p.code AS promo_code,
       p.discount_percent,
       o.total * (1 - p.discount_percent / 100) AS discounted_total
FROM orders o
LEFT JOIN promotions p ON o.promotion_id = p.id
WHERE p.is_active = 1
ORDER BY o.id;
```

**Output:**
| order_id | original_total | promo_code | discount_percent | discounted_total |
|----------|----------------|------------|-------------------|------------------|
| 1 | 1049.98 | SAVE10 | 10 | 944.98 |
| 2 | 749.98 | SAVE10 | 10 | 674.98 |
| 5 | 999.99 | SAVE20 | 20 | 799.99 |
| ... | ... | ... | ... | ... |

### Example 3: Complete Order Pipeline (Orders → Shipments → Suppliers)

```sql
SELECT o.id AS order_id,
       o.status AS order_status,
       o.total,
       s.id AS shipment_id,
       s.tracking_number,
       s.status AS shipment_status,
       sup.name AS supplier_name
FROM orders o
LEFT JOIN shipments s ON o.id = s.order_id
LEFT JOIN suppliers sup ON s.supplier_id = sup.id
ORDER BY o.id;
```

**Output:**
| order_id | order_status | total | shipment_id | tracking_number | shipment_status | supplier_name |
|----------|--------------|-------|-------------|-----------------|-----------------|---------------|
| 1 | completed | 1049.98 | 1 | SHIP001 | delivered | Tech Supply Co |
| 2 | completed | 749.98 | 2 | SHIP002 | delivered | Tech Supply Co |
| 3 | completed | 89.98 | 3 | SHIP003 | delivered | Fashion Wholesale |
| 4 | pending | 149.99 | NULL | NULL | NULL | NULL |
| ... | ... | ... | ... | ... | ... | ... |

### Example 4: Product Performance Report (Products → Categories → Order Items)

```sql
SELECT c.name AS category,
       p.name AS product,
       p.price,
       COUNT(DISTINCT oi.order_id) AS times_ordered,
       SUM(oi.quantity) AS total_quantity_sold,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
INNER JOIN categories c ON p.category_id = c.id
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY c.name, p.id, p.name, p.price
ORDER BY total_revenue DESC;
```

**Output:**
| category | product | price | times_ordered | total_quantity_sold | total_revenue |
|----------|---------|-------|---------------|---------------------|---------------|
| Electronics | Laptop | 999.99 | 2 | 2 | 1999.98 |
| Electronics | Headphones | 149.99 | 4 | 4 | 599.96 |
| Sports | Running Shoes | 119.99 | 2 | 2 | 239.98 |
| ... | ... | ... | ... | ... | ... |

**HR Translation:** "I need a product performance report showing how well each product sells. Group by category, show revenue generated, times ordered, and total quantity sold. This helps identify our best and worst performing products."

### Example 5: Customer Lifetime Value (Customers → Orders → Order Items)

```sql
SELECT c.id,
       c.name AS customer_name,
       c.city,
       COUNT(o.id) AS total_orders,
       SUM(o.total) AS total_spent,
       AVG(o.total) AS avg_order_value,
       MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name, c.city
HAVING COUNT(o.id) > 0
ORDER BY total_spent DESC;
```

**Output:**
| id | customer_name | city | total_orders | total_spent | avg_order_value | last_order_date |
|----|---------------|------|--------------|-------------|-----------------|-----------------|
| 1 | John Doe | New York | 2 | 1199.97 | 599.99 | 2024-02-28 |
| 2 | Jane Smith | Los Angeles | 2 | 799.97 | 399.99 | 2024-03-15 |
| 5 | Tom Wilson | Houston | 2 | 334.96 | 167.48 | 2024-04-15 |
| ... | ... | ... | ... | ... | ... | ... |

### Example 6: Complex Report with Multiple JOINs and Aggregation

```sql
SELECT d.name AS department,
       e.name AS employee,
       COUNT(DISTINCT o.id) AS orders_handled,
       SUM(o.total) AS revenue_generated,
       p.code AS promotion_used
FROM departments d
INNER JOIN employees e ON d.id = e.department_id
LEFT JOIN orders o ON e.id = o.customer_id
LEFT JOIN promotions p ON o.promotion_id = p.id
GROUP BY d.name, e.name, p.code
ORDER BY d.name, revenue_generated DESC;
```

### Practice Exercises

1. Create a report showing all completed orders with customer name, product names, and total
2. Show all orders with their shipment status and supplier information
3. Find the top 3 customers by total spending with their order count
4. Create a product summary showing category, product name, times ordered, and revenue
5. Show employees with their department and manager names in one report

---

## Day 6: JOINs with Filtering, Sorting & Advanced Patterns

### Combining JOINs with WHERE, ORDER BY, and LIMIT

### Example 1: Top 5 Most Expensive Orders with Customer Details

```sql
SELECT o.id AS order_id,
       o.order_date,
       c.name AS customer_name,
       o.total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed'
ORDER BY o.total DESC
LIMIT 5;
```

**Output:**
| order_id | order_date | customer_name | total |
|----------|------------|---------------|-------|
| 1 | 2024-01-15 | John Doe | 1049.98 |
| 5 | 2024-03-05 | Sarah Brown | 999.99 |
| 2 | 2024-01-18 | Jane Smith | 749.98 |
| 6 | 2024-03-10 | Tom Wilson | 179.98 |
| 7 | 2024-03-20 | Lisa Garcia | 119.99 |

### Example 2: All Pending Orders from Customers in New York

```sql
SELECT o.id AS order_id,
       o.order_date,
       o.total,
       c.name AS customer_name,
       c.city
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'pending'
  AND c.city = 'New York'
ORDER BY o.order_date;
```

**Output:**
| order_id | order_date | total | customer_name | city |
|----------|------------|-------|---------------|------|
| 4 | 2024-02-28 | 149.99 | John Doe | New York |
| 11 | 2024-05-01 | 198.97 | Sarah Brown | New York |

### Example 3: Product Stats for Electronics Category

```sql
SELECT p.name AS product,
       p.price,
       COUNT(oi.id) AS times_ordered,
       COALESCE(SUM(oi.quantity), 0) AS total_sold,
       COALESCE(SUM(oi.quantity * oi.price), 0) AS revenue
FROM products p
INNER JOIN categories c ON p.category_id = c.id
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE c.name = 'Electronics'
GROUP BY p.id, p.name, p.price
ORDER BY revenue DESC;
```

**Output:**
| product | price | times_ordered | total_sold | revenue |
|---------|-------|---------------|------------|---------|
| Laptop | 999.99 | 2 | 2 | 1999.98 |
| Headphones | 149.99 | 4 | 4 | 599.96 |
| Smartphone | 699.99 | 1 | 1 | 699.99 |

### Example 4: Multiple JOINs with CASE for Conditional Display

```sql
SELECT o.id AS order_id,
       c.name AS customer,
       CASE
           WHEN o.total > 500 THEN 'High Value'
           WHEN o.total > 100 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS value_category,
       s.tracking_number,
       CASE
           WHEN s.status = 'delivered' THEN 'On Time'
           WHEN s.status = 'shipped' THEN 'In Transit'
           ELSE 'Not Shipped'
       END AS delivery_status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
LEFT JOIN shipments s ON o.id = s.order_id
WHERE o.status = 'completed'
ORDER BY o.total DESC;
```

### Example 5: Subquery with JOIN for Complex Filtering

```sql
-- Products that cost more than the average price in their category
SELECT p.name AS product,
       p.price,
       c.name AS category,
       p.price - (
           SELECT AVG(p2.price)
           FROM products p2
           WHERE p2.category_id = p.category_id
       ) AS price_vs_avg
FROM products p
INNER JOIN categories c ON p.category_id = c.id
WHERE p.price > (
    SELECT AVG(price) FROM products WHERE category_id = p.category_id
)
ORDER BY category, price DESC;
```

### Example 6: JOIN with DISTINCT to Avoid Duplicates

```sql
-- All unique customers who have purchased in Electronics or Clothing
SELECT DISTINCT c.id, c.name AS customer_name, c.email
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
WHERE p.category_id IN (
    SELECT id FROM categories WHERE name IN ('Electronics', 'Clothing')
)
ORDER BY c.name;
```

### Example 7: LEFT JOIN with COALESCE for Reporting

```sql
-- Monthly revenue by category with zero values for months with no sales
SELECT strftime('%m', o.order_date) AS month,
       c.name AS category,
       COALESCE(SUM(oi.quantity * oi.price), 0) AS revenue
FROM categories c
CROSS JOIN orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id AND p.category_id = c.id
WHERE o.status = 'completed'
GROUP BY month, c.name
ORDER BY month, revenue DESC;
```

### Example 8: Self JOIN with Multiple Levels of Management

```sql
-- Show employee, their manager, and the manager's manager
SELECT e.name AS employee,
       e.salary AS emp_salary,
       m.name AS manager,
       m.salary AS mgr_salary,
       mm.name AS skip_level_manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
LEFT JOIN employees mm ON m.manager_id = mm.id
ORDER BY mm.name, m.name, e.name;
```

**Output:**
| employee | emp_salary | manager | mgr_salary | skip_level_manager |
|----------|------------|---------|------------|-------------------|
| David Brown | 7000 | NULL | NULL | NULL |
| Frank Miller | 6500 | David Brown | 7000 | NULL |
| Carol White | 5200 | Frank Miller | 6500 | David Brown |
| Grace Lee | 4900 | Frank Miller | 6500 | David Brown |
| Alice Johnson | 5500 | NULL | NULL | NULL |
| Bob Smith | 4800 | Alice Johnson | 5500 | NULL |
| Henry Wilson | 5100 | Alice Johnson | 5500 | NULL |
| Eve Davis | 4500 | Henry Wilson | 5100 | Alice Johnson |

**HR Translation:** "I want to see the full management chain for each employee - who they report to, and who that person reports to. This helps understand our organizational structure and salary bands at different levels."

### Practice Exercises

1. Find the top 3 products by revenue in each category
2. List all customers from New York or Los Angeles who have spent over $500
3. Show all orders with their customer city and shipment status, ordered by total descending
4. Find products that have never been ordered (using LEFT JOIN with NULL check)
5. Create a report showing each department, employee count, average salary, and total salary budget

---

## Day 7: Review & Mini Quiz

### Summary: What You Learned This Week

| Day | Topic | Key Concept |
|-----|-------|-------------|
| 1 | INNER JOIN | Only matching rows from both tables |
| 2 | LEFT JOIN | All left table rows + matched right (NULL if no match) |
| 3 | RIGHT/FULL OUTER | All rows from one/both tables (SQLite uses UNION workaround) |
| 4 | CROSS JOIN | Cartesian product - all combinations |
| 5 | Self JOIN | Table joined to itself for hierarchical data |
| 6 | Multiple JOINs | Chains of JOINs connecting many tables |

---

## Mini Quiz (10 Questions)

### Q1: INNER JOIN Basic

Write a query to show all orders with their customer names and cities.

```sql
SELECT o.id, o.order_date, o.total, c.name AS customer_name, c.city
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
ORDER BY o.id;
```

---

### Q2: LEFT JOIN to Find Missing Records

Find customers who have NEVER placed an order.

```sql
SELECT c.id, c.name, c.email
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.id IS NULL;
```

---

### Q3: Multiple JOINs

Show order details: order_id, customer_name, product_name, quantity, price.

```sql
SELECT o.id AS order_id,
       c.name AS customer_name,
       p.name AS product_name,
       oi.quantity,
       oi.price
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
ORDER BY o.id;
```

---

### Q4: LEFT JOIN with Aggregation

Show each customer with their total number of orders and total spent.

```sql
SELECT c.id, c.name,
       COUNT(o.id) AS order_count,
       COALESCE(SUM(o.total), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;
```

---

### Q5: Self JOIN

Show each employee with their manager's name.

```sql
SELECT e.name AS employee,
       m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
ORDER BY m.name, e.name;
```

---

### Q6: Simulating RIGHT JOIN

Find orders that don't have shipments (use LEFT JOIN).

```sql
SELECT o.id AS order_id, o.order_date, o.total
FROM orders o
LEFT JOIN shipments s ON o.id = s.order_id
WHERE s.id IS NULL;
```

---

### Q7: Simulating FULL OUTER JOIN

Show all products and their reviews (products without reviews should still appear).

```sql
SELECT p.id, p.name AS product, r.id AS review_id, r.rating
FROM products p
LEFT JOIN product_reviews r ON p.id = r.product_id
UNION
SELECT p.id, p.name AS product, r.id AS review_id, r.rating
FROM product_reviews r
LEFT JOIN products p ON r.product_id = p.id
ORDER BY id, review_id;
```

---

### Q8: CROSS JOIN

Generate all combinations of categories and order statuses.

```sql
SELECT c.name AS category, s.status
FROM categories c
CROSS JOIN (SELECT DISTINCT status FROM orders) s
ORDER BY c.name, s.status;
```

---

### Q9: Multiple JOINs with WHERE and ORDER BY

Find the top 3 highest-grossing completed orders with customer names.

```sql
SELECT o.id, c.name AS customer, o.total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed'
ORDER BY o.total DESC
LIMIT 3;
```

---

### Q10: LEFT JOIN with NULL Check

Find products that have never received a review.

```sql
SELECT p.id, p.name, p.price
FROM products p
LEFT JOIN product_reviews r ON p.id = r.product_id
WHERE r.id IS NULL
ORDER BY p.id;
```

---

## Quick Reference Card

### JOIN Types Summary

| JOIN | Returns | NULL Columns |
|------|---------|--------------|
| **INNER** | Only matching rows | None |
| **LEFT** | All left + matched right | Right side if no match |
| **RIGHT** | All right + matched left | Left side if no match (not in SQLite) |
| **FULL** | All rows from both | Both sides where no match (not in SQLite) |
| **CROSS** | Every combination | N/A (no ON clause) |
| **SELF** | Table to itself | Depends on type |

### Syntax

```sql
-- INNER/LEFT/RIGHT/FULL
SELECT columns
FROM table1
[JOINTYPE] JOIN table2 ON condition
[JOINTYPE] JOIN table3 ON condition;

-- CROSS (no ON clause)
SELECT columns
FROM table1 CROSS JOIN table2;

-- SELF
SELECT a.col, b.col
FROM table1 a
[JOINTYPE] JOIN table1 b ON a.related_id = b.id;
```

### SQLite Workarounds

```sql
-- RIGHT JOIN (swap tables + LEFT)
SELECT ... FROM right_table LEFT JOIN left_table ON condition;

-- FULL OUTER JOIN (UNION)
SELECT ... FROM t1 LEFT JOIN t2 ON condition
UNION
SELECT ... FROM t2 LEFT JOIN t1 ON condition;
```

### Common Patterns

| Pattern | Query |
|---------|-------|
| Find rows with no match | `LEFT JOIN ... WHERE right_table.id IS NULL` |
| Keep all rows from both | `FULL OUTER JOIN` or `UNION` approach |
| Hierarchical data | Self JOIN with manager_id |
| Generate combinations | CROSS JOIN |

---

## Milestone Checklist (End of Week 6)

- [ ] Can write INNER JOIN queries to connect related tables
- [ ] Can use LEFT JOIN to include all rows from one table
- [ ] Can simulate RIGHT JOIN by swapping table order
- [ ] Can implement FULL OUTER JOIN using UNION
- [ ] Can use CROSS JOIN to generate all combinations
- [ ] Can write Self JOIN for hierarchical data
- [ ] Can chain multiple JOINs in a single query
- [ ] Can debug JOIN issues (missing data, NULLs, duplicates)

---

## Week 6 Summary

**Topics Covered:**
- INNER JOIN - Matched rows from both tables
- LEFT JOIN - All left + matched right (NULL if no match)
- RIGHT JOIN - All right + matched left (use LEFT with swapped tables)
- FULL OUTER JOIN - All rows from both (use UNION in SQLite)
- CROSS JOIN - Cartesian product of all rows
- Self JOIN - Table joined to itself for hierarchies
- Multiple JOINs - Chaining several tables together
- JOIN with filtering, sorting, aggregation, and subqueries

**Goal:** Pass Week 6 quiz with score > 80%

---

## Next Week Preview

**Week 7: Aggregation & GROUP BY**
- COUNT, SUM, AVG, MIN, MAX functions
- GROUP BY clause for grouping data
- HAVING clause for filtering groups
- Multiple aggregations
- Aggregating across JOINed tables
- Date-based aggregation

---

*Week 6 of 12 — Part of the 3-Month SQL Learning Roadmap*
