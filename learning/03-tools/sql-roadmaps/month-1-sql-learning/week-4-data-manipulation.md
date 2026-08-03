# Week 4: Data Manipulation (CRUD)

**Databases:** `sql-learn-db.sql` (E-Commerce) and `library-db.sql` (Library)
**Tables (sql-learn-db):** departments, employees, customers, categories, products, orders, order_items
**Tables (library-db):** genres, publishers, authors, books, author_books, book_copies, members, loans, fines
**Duration:** 7 days, 1-2 hours/day

---

## Database Schema Reference

### sql-learn-db.sql (E-Commerce Database)

```sql
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

-- Order Items
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER DEFAULT 1,
    price REAL NOT NULL
);
```

### library-db.sql (Library Database)

```sql
-- Genres
CREATE TABLE genres (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT
);

-- Publishers
CREATE TABLE publishers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT,
    website TEXT,
    phone TEXT
);

-- Authors
CREATE TABLE authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    bio TEXT,
    nationality TEXT
);

-- Books
CREATE TABLE books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    subtitle TEXT,
    genre_id INTEGER REFERENCES genres(id),
    publisher_id INTEGER REFERENCES publishers(id),
    isbn TEXT UNIQUE,
    published_year INTEGER,
    pages INTEGER,
    edition TEXT
);

-- Book Copies
CREATE TABLE book_copies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER REFERENCES books(id),
    barcode TEXT UNIQUE,
    condition TEXT,
    acquisition_date TEXT,
    notes TEXT
);

-- Members
CREATE TABLE members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    address TEXT,
    membership_date TEXT NOT NULL,
    membership_type TEXT DEFAULT 'standard'
);

-- Loans
CREATE TABLE loans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER REFERENCES members(id),
    book_copy_id INTEGER REFERENCES book_copies(id),
    loan_date TEXT NOT NULL,
    due_date TEXT NOT NULL,
    return_date TEXT,
    notes TEXT
);

-- Fines
CREATE TABLE fines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    loan_id INTEGER REFERENCES loans(id),
    amount REAL NOT NULL,
    issued_date TEXT NOT NULL,
    paid_date TEXT,
    paid_amount REAL
);
```

---

## Sample Data Summary

### sql-learn-db.sql

**Departments (4):** Sales, Marketing, IT, HR

**Employees (8):** Alice Johnson ($5500), Bob Smith ($4800), Carol White ($5200), David Brown ($7000), Eve Davis ($4500), Frank Miller ($6500), Grace Lee ($4900), Henry Wilson ($5100)

**Customers (8):** John Doe, Jane Smith, Mike Johnson, Sarah Brown, Tom Wilson, Lisa Garcia, Kevin Martinez, Amy Taylor

**Categories (5):** Electronics, Clothing, Books, Home & Garden, Sports

**Products (12):** Laptop ($999.99), Smartphone ($699.99), Headphones ($149.99), T-Shirt ($29.99), Jeans ($59.99), Jacket ($89.99), SQL Mastery ($49.99), Python Guide ($39.99), Garden Tools Set ($79.99), Running Shoes ($119.99), Basketball ($34.99), Yoga Mat ($24.99)

**Orders (12):** Mix of completed, pending, shipped, and cancelled statuses with totals ranging from $49.99 to $1049.98

### library-db.sql

**Genres (5):** Fiction, Non-Fiction, Science Fiction, Mystery, Biography

**Publishers (5):** Penguin Random House, HarperCollins, Simon Schuster, Macmillan, Scholastic

**Authors (8):** George Orwell, Jane Austen, Isaac Asimov, Agatha Christie, Mark Twain, Stephen King, J.K. Rowling, Paulo Coelho

**Books (15):** Including classics like 1984, Pride and Prejudice, Foundation, Murder on the Orient Express, Harry Potter and the Sorcerer's Stone

**Members (10):** Alice Johnson (premium), Bob Williams, Carol Davis, David Brown (premium), Eve Martinez, Frank Garcia, Grace Wilson (premium), Henry Taylor, Ivy Anderson, Jack Thomas

**Loans (20):** Mix of returned and currently borrowed books

**Fines (8):** Various fines issued for late returns

---

## What is Data Manipulation?

Data Manipulation Language (DML) allows you to **change data** in your database. Think of it as:

| Operation | What It Does | Analogy |
|-----------|--------------|---------|
| **INSERT** | Add new data | Writing a new entry in a notebook |
| **UPDATE** | Modify existing data | Erasing and rewriting something |
| **DELETE** | Remove data | Crossing something out |

**Important:** These operations change your actual data. Always be careful, especially with UPDATE and DELETE!

---

## Day 1: INSERT - Adding Single Row

### What is INSERT?

INSERT adds new rows (records) to a table. Every new row must match the table's structure.

### Syntax - Method 1: Specify All Columns

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES (value1, value2, value3);
```

### Examples

```sql
-- Add a new department
INSERT INTO departments (name, budget)
VALUES ('Finance', 60000);
```

```sql
-- Add a new employee
INSERT INTO employees (name, email, department_id, hire_date, salary)
VALUES ('Sarah Connor', 'sarah@company.com', 1, '2026-06-25', 5200);
```

**After running this query, the new employee appears in the table:**

| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 9 | Sarah Connor | sarah@company.com | 1 | 2026-06-25 | 5200 |

### Syntax - Method 2: Values for All Columns

If you provide values for ALL columns (in order), you can omit the column names:

```sql
INSERT INTO departments
VALUES (5, 'Legal', 75000);
```

### Syntax - Method 3: Insert with NULL

```sql
-- Add a customer without email
INSERT INTO customers (name, email, city, join_date)
VALUES ('Tom Harris', NULL, 'Boston', '2026-06-25');
```

### Library Database Examples

```sql
-- Add a new genre
INSERT INTO genres (name, description)
VALUES ('Horror', 'Stories designed to frighten and unsettle readers');
```

```sql
-- Add a new author
INSERT INTO authors (name, email, phone, bio, nationality)
VALUES ('H.G. Wells', 'wells@example.com', NULL, 'English writer of science fiction', 'British');
```

```sql
-- Add a new member
INSERT INTO members (name, email, phone, address, membership_date, membership_type)
VALUES ('New Member', 'new@email.com', '555-9999', '123 Main St', '2026-06-25', 'standard');
```

### Practice Exercises

1. Add a new category called "Toys" to sql-learn-db
2. Add a new customer: Lisa Park, lisa.park@email.com, Seattle, 2026-06-25
3. Add a new publisher: Oxford University Press, Oxford UK, https://oup.com
4. Add a new book copy for "1984" with barcode "BK001C", condition "Fair"

---

## Day 2: INSERT - Adding Multiple Rows

### Inserting Multiple Rows at Once

You can add several rows in a single INSERT statement - much faster than multiple queries.

### Syntax

```sql
INSERT INTO table_name (column1, column2, column3)
VALUES
    (value1a, value2a, value3a),
    (value1b, value2b, value3b),
    (value1c, value2c, value3c);
```

### Examples

```sql
-- Add multiple products at once
INSERT INTO products (name, category_id, price, stock)
VALUES
    ('Tablet', 1, 449.99, 75),
    ('Keyboard', 1, 79.99, 200),
    ('Mouse', 1, 29.99, 300);
```

```sql
-- Add multiple customers at once
INSERT INTO customers (name, email, city, join_date)
VALUES
    ('Mike Ross', 'mike@email.com', 'Chicago', '2026-06-25'),
    ('Rachel Green', 'rachel@email.com', 'New York', '2026-06-25'),
    ('Ross Geller', 'ross@email.com', 'Boston', '2026-06-25');
```

```sql
-- Add multiple books at once
INSERT INTO books (title, genre_id, publisher_id, isbn, published_year, pages, edition)
VALUES
    ('The Time Machine', 3, 1, '978-0143039500', 1895, 120, '1st'),
    ('War of the Worlds', 3, 1, '978-0143039510', 1898, 180, '1st'),
    ('The Invisible Man', 3, 2, '978-0143039520', 1899, 150, '1st');
```

**After running these queries, multiple new rows appear in the tables.**

### Library Database Examples

```sql
-- Add multiple members
INSERT INTO members (name, email, phone, address, membership_date, membership_type)
VALUES
    ('John Smith', 'john.s@email.com', '555-2001', '100 Oak Ave', '2026-06-25', 'standard'),
    ('Jane Doe', 'jane.d@email.com', '555-2002', '200 Pine Rd', '2026-06-25', 'premium'),
    ('Bob Wilson', 'bob.w@email.com', NULL, NULL, '2026-06-25', 'standard');
```

```sql
-- Add multiple book copies
INSERT INTO book_copies (book_id, barcode, condition, acquisition_date, notes)
VALUES
    (3, 'BK003B', 'Good', '2026-06-25', 'New copy'),
    (3, 'BK003C', 'Fair', '2026-06-25', NULL),
    (7, 'BK007B', 'Excellent', '2026-06-25', 'Replacement copy');
```

### Why Insert Multiple Rows?

| Method | Queries | Performance |
|--------|---------|-------------|
| Single INSERT | 3 queries | Slower |
| Multi-row INSERT | 1 query | Faster |

### Practice Exercises

1. Add 3 new products in category 5 (Sports): Football ($49.99, 100), Tennis Racket ($89.99, 50), Golf Balls ($34.99, 200)
2. Add 2 new customers from different cities
3. Add 2 new authors with complete information
4. Add 3 new members with different membership types

---

## Day 3: UPDATE - Modifying Data

### What is UPDATE?

UPDATE changes existing data in a table. It's like editing a document - you modify specific information without replacing the entire record.

### Syntax

```sql
UPDATE table_name
SET column1 = new_value1,
    column2 = new_value2
WHERE condition;
```

**Warning:** If you forget the WHERE clause, ALL rows will be updated!

### Examples

```sql
-- Update a single employee's salary
UPDATE employees
SET salary = 6000
WHERE name = 'Sarah Connor';
```

**Before:**
| id | name | salary |
|----|------|--------|
| 9 | Sarah Connor | 5200 |

**After:**
| id | name | salary |
|----|------|--------|
| 9 | Sarah Connor | 6000 |

```sql
-- Update multiple columns at once
UPDATE employees
SET salary = 5800,
    email = 'sarah.connor@company.com'
WHERE id = 9;
```

```sql
-- Update product price
UPDATE products
SET price = 899.99
WHERE name = 'Laptop';
```

```sql
-- Update customer's city
UPDATE customers
SET city = 'Los Angeles'
WHERE name = 'John Doe';
```

### Library Database Examples

```sql
-- Update a member's membership type
UPDATE members
SET membership_type = 'premium'
WHERE name = 'Bob Williams';
```

```sql
-- Update a book's published year
UPDATE books
SET published_year = 1950
WHERE title = '1984';
```

```sql
-- Update an author's email
UPDATE authors
SET email = 'orwell.new@example.com'
WHERE name = 'George Orwell';
```

### Update with String Values

```sql
-- Update order status
UPDATE orders
SET status = 'shipped'
WHERE id = 5;
```

### Update with Calculations

```sql
-- Increase salary by 10%
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = 1;
```

**Before:**
| name | salary |
|------|--------|
| Alice Johnson | 5500 |
| Bob Smith | 4800 |
| Henry Wilson | 5100 |

**After (10% raise for Sales dept):**
| name | salary |
|------|--------|
| Alice Johnson | 6050 |
| Bob Smith | 5280 |
| Henry Wilson | 5610 |

### Practice Exercises

1. Update Alice Johnson's salary to $6000
2. Change the status of order #12 to 'completed'
3. Update all products in category 2 (Clothing) to have stock = 0 (out of stock)
4. Update Carol Davis's membership type to 'premium' in library-db

---

## Day 4: UPDATE - Conditional Updates

### Updating Based on Conditions

Often you need to update rows that match specific criteria, not just one row.

### Examples

```sql
-- Update all employees in IT department
UPDATE employees
SET salary = salary + 500
WHERE department_id = 3;
```

```sql
-- Update all pending orders to 'cancelled'
UPDATE orders
SET status = 'cancelled'
WHERE status = 'pending' AND order_date < '2024-01-01';
```

```sql
-- Update products with low stock
UPDATE products
SET price = price * 0.9
WHERE stock < 50;
```

### Using UPDATE with Multiple Conditions

```sql
-- Update employees hired after 2022 in Sales or Marketing
UPDATE employees
SET salary = salary * 1.05
WHERE hire_date > '2022-01-01'
  AND department_id IN (1, 2);
```

### Library Database Examples

```sql
-- Mark all overdue loans (past due_date and not returned)
UPDATE loans
SET notes = 'OVERDUE - Please return immediately'
WHERE due_date < '2024-05-01'
  AND return_date IS NULL;
```

```sql
-- Update book conditions based on acquisition date
UPDATE book_copies
SET condition = 'Poor'
WHERE acquisition_date < '2020-01-01'
  AND condition = 'Fair';
```

```sql
-- Premium members get extended loan period
UPDATE members
SET membership_type = 'premium'
WHERE membership_date < '2021-01-01'
  AND membership_type = 'standard';
```

### Update with String Operations

```sql
-- Add a note to incomplete member records
UPDATE members
SET notes = 'INCOMPLETE PROFILE - Please update contact info'
WHERE email IS NULL OR phone IS NULL;
```

### Practice Exercises

1. Give a $500 bonus to all employees hired before 2021
2. Update all shipped orders with total > $500 to status = 'delivered'
3. Update all books with less than 250 pages to have 'Short Book' in the edition field
4. Update all standard members who joined before 2022 to premium membership

---

## Day 5: DELETE - Removing Data

### What is DELETE?

DELETE removes rows from a table permanently. It's like crossing an item off a list - the row is gone.

### Syntax

```sql
DELETE FROM table_name
WHERE condition;
```

**Warning:** DELETE is permanent! Unlike in Excel, there's no "Ctrl+Z" to undo. Always double-check your WHERE clause.

### Examples

```sql
-- Delete a specific customer
DELETE FROM customers
WHERE name = 'Tom Harris';
```

```sql
-- Delete a specific order
DELETE FROM orders
WHERE id = 10;
```

```sql
-- Delete products with zero stock
DELETE FROM products
WHERE stock = 0;
```

### Before and After DELETE

**Before deleting order #10:**

| id | customer_id | total | status |
|----|-------------|-------|--------|
| 9 | 7 | 198.97 | completed |
| 10 | 8 | 89.98 | shipped |
| 11 | 3 | 59.99 | completed |

**After DELETE WHERE id = 10:**

| id | customer_id | total | status |
|----|-------------|-------|--------|
| 9 | 7 | 198.97 | completed |
| 11 | 3 | 59.99 | completed |

### Library Database Examples

```sql
-- Delete a loan record (after book is returned and fine paid)
DELETE FROM loans
WHERE id = 2;
```

```sql
-- Delete book copies with damaged condition
DELETE FROM book_copies
WHERE condition = 'Poor';
```

```sql
-- Delete members who never borrowed (no loans)
DELETE FROM members
WHERE id NOT IN (SELECT DISTINCT member_id FROM loans);
```

### Delete with Conditions

```sql
-- Delete old pending orders (older than 6 months)
DELETE FROM orders
WHERE status = 'pending'
  AND order_date < '2024-01-01';
```

```sql
-- Delete customers who never placed an order
DELETE FROM customers
WHERE id NOT IN (SELECT DISTINCT customer_id FROM orders);
```

```sql
-- Delete books published before 1900
DELETE FROM books
WHERE published_year < 1900;
```

### The Danger of DELETE Without WHERE

**This will DELETE ALL ROWS from the table:**

```sql
-- NEVER DO THIS BY ACCIDENT!
DELETE FROM customers;
```

**This deletes everything in the table - irreversible!**

### Practice Exercises

1. Delete the order with id = 8
2. Delete all cancelled orders
3. Delete customers named 'Mike Johnson'
4. Delete authors with no books (use subquery if needed, or note it for later)

---

## Day 6: Transactions - Protecting Your Data

### What are Transactions?

Transactions ensure that your data changes happen safely. They let you:

1. **Save changes** (COMMIT) when everything is correct
2. **Undo changes** (ROLLBACK) when something goes wrong

### Why Transactions Matter

Imagine you're transferring money between bank accounts:

```
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- If both succeed: COMMIT
-- If something fails: ROLLBACK (undo everything)
```

Without transactions, if the second UPDATE fails, you'd lose $100!

### Syntax

```sql
BEGIN TRANSACTION;
-- Your INSERT, UPDATE, or DELETE statements
COMMIT;  -- Save changes permanently
```

Or if something goes wrong:

```sql
BEGIN TRANSACTION;
-- Your statements
ROLLBACK;  -- Undo all changes
```

### Examples

```sql
-- Safe UPDATE with transaction
BEGIN TRANSACTION;
UPDATE employees SET salary = 7000 WHERE id = 4;
COMMIT;
```

```sql
-- Safe DELETE with transaction
BEGIN TRANSACTION;
DELETE FROM orders WHERE status = 'cancelled' AND order_date < '2024-01-01';
COMMIT;
```

```sql
-- Undo a mistake
BEGIN TRANSACTION;
UPDATE products SET price = 899.99 WHERE name = 'Laptop';
-- Oops, wrong price!
ROLLBACK;
```

### Transaction in Library Database

```sql
-- Add a new member and their first loan
BEGIN TRANSACTION;
INSERT INTO members (name, email, phone, address, membership_date, membership_type)
VALUES ('New Member', 'new@library.com', '555-3000', '456 Oak St', '2026-06-25', 'standard');

UPDATE members SET membership_type = 'premium' WHERE email = 'new@library.com';
COMMIT;
```

### When to Use Transactions

| Situation | Use Transaction? |
|-----------|-----------------|
| Single INSERT/UPDATE/DELETE | Optional (but good practice) |
| Multiple related changes | **Required** |
| Deleting important data | **Required** |
| Changes affecting multiple tables | **Required** |

### Practice Exercises

1. Begin a transaction, add a new department, then commit
2. Begin a transaction, update two employees' salaries, then rollback
3. Begin a transaction, delete old pending orders, then commit
4. Begin a transaction, add a new author and a new book for that author, then commit

---

## Day 7: Review & Mini Quiz

### Summary: What You Learned This Week

| Day | Topic | Command |
|-----|-------|---------|
| 1 | INSERT Single Row | `INSERT INTO table (col1, col2) VALUES (val1, val2)` |
| 2 | INSERT Multiple Rows | `INSERT INTO table (col1, col2) VALUES (...), (...), (...)` |
| 3 | UPDATE Basics | `UPDATE table SET col = value WHERE condition` |
| 4 | UPDATE Conditions | `UPDATE table SET col = val WHERE cond1 AND cond2` |
| 5 | DELETE | `DELETE FROM table WHERE condition` |
| 6 | Transactions | `BEGIN TRANSACTION; ... COMMIT/ROLLBACK;` |

---

## Mini Quiz (10 Questions)

### Q1: Insert a new customer named "Alex Chen", email "alex@email.com", city "Seattle", join date "2026-06-25"

```sql
INSERT INTO customers (name, email, city, join_date)
VALUES ('Alex Chen', 'alex@email.com', 'Seattle', '2026-06-25');
```

### Q2: Insert two new products at once - "Monitor" ($299.99, 50 stock) and "Mousepad" ($19.99, 200 stock), both in Electronics (category_id = 1)

```sql
INSERT INTO products (name, category_id, price, stock)
VALUES
    ('Monitor', 1, 299.99, 50),
    ('Mousepad', 1, 19.99, 200);
```

### Q3: Update the salary of "Alice Johnson" to $6000

```sql
UPDATE employees
SET salary = 6000
WHERE name = 'Alice Johnson';
```

### Q4: Give all employees in department 2 (Marketing) a 10% raise

```sql
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = 2;
```

### Q5: Update the status of order #5 to 'shipped'

```sql
UPDATE orders
SET status = 'shipped'
WHERE id = 5;
```

### Q6: Delete the customer named "Alex Chen"

```sql
DELETE FROM customers
WHERE name = 'Alex Chen';
```

### Q7: Delete all pending orders from before 2024

```sql
DELETE FROM orders
WHERE status = 'pending' AND order_date < '2024-01-01';
```

### Q8: Using a transaction, update David Brown's salary to $7500, then commit

```sql
BEGIN TRANSACTION;
UPDATE employees SET salary = 7500 WHERE name = 'David Brown';
COMMIT;
```

### Q9: Using a transaction, delete order #3, then rollback

```sql
BEGIN TRANSACTION;
DELETE FROM orders WHERE id = 3;
ROLLBACK;
```

### Q10: Insert a new library member with name "Test User", email NULL, phone NULL, address NULL, membership_date "2026-06-25", membership_type "standard"

```sql
INSERT INTO members (name, email, phone, address, membership_date, membership_type)
VALUES ('Test User', NULL, NULL, NULL, '2026-06-25', 'standard');
```

---

## Quick Reference Card

| Command | Purpose | Syntax |
|---------|---------|--------|
| INSERT | Add new rows | `INSERT INTO table (cols) VALUES (vals)` |
| UPDATE | Modify existing data | `UPDATE table SET col = val WHERE cond` |
| DELETE | Remove rows | `DELETE FROM table WHERE cond` |
| BEGIN TRANSACTION | Start safe mode | `BEGIN TRANSACTION;` |
| COMMIT | Save changes | `COMMIT;` |
| ROLLBACK | Undo changes | `ROLLBACK;` |

### Safety Rules

1. **Always use WHERE with UPDATE and DELETE** (unless you mean to affect all rows)
2. **Use transactions** for multiple related changes
3. **Test with SELECT first** - run `SELECT * FROM table WHERE...` to see what you'll affect before modifying
4. **Backup important data** before bulk operations

### Example: Preview Before Modify

```sql
-- First, check what you'll update:
SELECT * FROM employees WHERE department_id = 1;

-- Only after verifying, run the UPDATE:
UPDATE employees SET salary = salary * 1.10 WHERE department_id = 1;
```

---

## Milestone Checklist (End of Week 4)

- [ ] Can insert single rows into a table
- [ ] Can insert multiple rows in one query
- [ ] Can update specific rows with WHERE
- [ ] Can update multiple rows with conditions
- [ ] Can update multiple columns at once
- [ ] Can delete specific rows with WHERE
- [ ] Understands the danger of UPDATE/DELETE without WHERE
- [ ] Can use BEGIN TRANSACTION, COMMIT, and ROLLBACK
- [ ] Knows to preview data before modifying

---

## Week 4 Summary

**Topics Covered:**
- INSERT - Adding single rows
- INSERT - Adding multiple rows
- UPDATE - Modifying existing data
- UPDATE - Conditional updates with multiple criteria
- DELETE - Removing data
- Transactions - BEGIN TRANSACTION, COMMIT, ROLLBACK
- Safety best practices

**Goal:** Pass Week 4 quiz with score > 80%

---

*Week 4 of 12 — Part of the 3-Month SQL Learning Roadmap*
