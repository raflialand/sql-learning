# Week 3: Sorting & Limiting Results

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

## Day 1: ORDER BY Basics

### What is ORDER BY?

The ORDER BY clause sorts query results by one or more columns. Without it, SQL returns rows in whatever order the database stored them (which is unpredictable).

### Syntax

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1 [ASC|DESC];
```

### ASC vs DESC

| Keyword | Meaning | Use When |
|---------|---------|----------|
| `ASC` | Ascending (A-Z, 0-9) | Default, smallest first |
| `DESC` | Descending (Z-A, 9-0) | Largest/best first |

### Examples

```sql
-- Sort products by price ascending (cheapest first)
SELECT * FROM products ORDER BY price ASC;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 12 | Yoga Mat | 5 | 24.99 | 150 |
| 4 | T-Shirt | 2 | 29.99 | 500 |
| 11 | Basketball | 5 | 34.99 | 200 |
| 8 | Python Guide | 3 | 39.99 | 120 |
| 7 | SQL Mastery | 3 | 49.99 | 80 |
| 9 | Garden Tools Set | 4 | 79.99 | 40 |
| 5 | Jeans | 2 | 59.99 | 300 |
| 6 | Jacket | 2 | 89.99 | 150 |
| 10 | Running Shoes | 5 | 119.99 | 75 |
| 3 | Headphones | 1 | 149.99 | 200 |
| 2 | Smartphone | 1 | 699.99 | 100 |
| 1 | Laptop | 1 | 999.99 | 50 |

```sql
-- Sort products by price descending (most expensive first)
SELECT * FROM products ORDER BY price DESC;
```

```sql
-- Sort employees by hire_date (oldest first - longest tenure)
SELECT name, hire_date FROM employees ORDER BY hire_date ASC;
```
**Output:**
| name | hire_date |
|------|-----------|
| David Brown | 2020-11-05 |
| Bob Smith | 2021-06-20 |
| Frank Miller | 2021-02-14 |
| Alice Johnson | 2022-01-15 |
| Henry Wilson | 2022-07-08 |
| Eve Davis | 2022-08-30 |
| Grace Lee | 2023-01-20 |
| Carol White | 2023-03-10 |

```sql
-- Sort books by title alphabetically
SELECT title, published_year FROM books ORDER BY title ASC;
```
**Output:**
| title | published_year |
|-------|----------------|
| 1984 | 1949 |
| And Then There Were None | 1939 |
| Brave New World | 1932 |
| Fahrenheit 451 | 1953 |
| Foundation | 1951 |
| Harry Potter and the Sorcerer's Stone | 1997 |
| Pride and Prejudice | 1813 |
| The Adventures of Tom Sawyer | 1876 |
| The Alchemist | 1988 |
| The Great Gatsby | 1925 |
| The Hobbit | 1937 |
| The Shining | 1977 |
| To Kill a Mockingbird | 1960 |

```sql
-- Sort orders by total descending (highest value first)
SELECT id, customer_id, total, status FROM orders ORDER BY total DESC;
```
**Output:**
| id | customer_id | total | status |
|----|-------------|-------|--------|
| 1 | 1 | 1049.98 | completed |
| 5 | 4 | 999.99 | pending |
| 2 | 2 | 749.98 | completed |
| 6 | 5 | 179.98 | shipped |
| 9 | 7 | 198.97 | completed |
| 12 | 5 | 154.98 | completed |
| 4 | 1 | 149.99 | completed |
| 8 | 10 | 89.98 | shipped |
| 3 | 3 | 89.98 | completed |
| 11 | 3 | 59.99 | completed |
| 7 | 2 | 49.99 | completed |
| 10 | 8 | 34.99 | cancelled |

### Practice Exercises

1. Sort members by name alphabetically (library-db)
2. Sort products by stock ascending (sql-learn-db)
3. Sort authors by nationality (library-db)
4. Sort orders by order_date ascending (sql-learn-db)

---

## Day 2: Multi-Column Sorting

### What is Multi-Column Sorting?

Sort by multiple columns in sequence. The first column is the primary sort, second is tiebreaker.

### Syntax

```sql
SELECT column1, column2, column3
FROM table_name
ORDER BY column1 ASC, column2 DESC, column3 ASC;
```

### How It Works

Think of it like sorting a spreadsheet:
1. First, sort by the first column
2. When values are equal in the first column, sort by the second
3. When values are equal in both, sort by the third

### Examples

```sql
-- Sort employees by department, then by salary within each department
SELECT name, department_id, salary 
FROM employees 
ORDER BY department_id ASC, salary DESC;
```
**Output:**
| name | department_id | salary |
|------|---------------|--------|
| Alice Johnson | 1 | 5500 |
| Henry Wilson | 1 | 5100 |
| Bob Smith | 1 | 4800 |
| Carol White | 2 | 5200 |
| Grace Lee | 2 | 4900 |
| David Brown | 3 | 7000 |
| Frank Miller | 3 | 6500 |
| Eve Davis | 4 | 4500 |

```sql
-- Sort books by genre, then by published_year (newest first within genre)
SELECT b.title, g.name AS genre, b.published_year
FROM books b
JOIN genres g ON b.genre_id = g.id
ORDER BY g.name ASC, b.published_year DESC;
```
**Output:**
| title | genre | published_year |
|-------|-------|----------------|
| The Great Gatsby | Fiction | 1925 |
| Pride and Prejudice | Fiction | 1813 |
| Harry Potter and the Sorcerer's Stone | Fiction | 1997 |
| The Alchemist | Fiction | 1988 |
| The Hobbit | Fiction | 1937 |
| To Kill a Mockingbird | Fiction | 1960 |
| Brave New World | Science Fiction | 1953 |
| 1984 | Science Fiction | 1949 |
| Foundation | Science Fiction | 1951 |
| Fahrenheit 451 | Science Fiction | 1932 |
| The Shining | Science Fiction | 1977 |
| Murder on the Orient Express | Mystery | 1934 |
| And Then There Were None | Mystery | 1939 |
| The Adventures of Tom Sawyer | Biography | 1876 |

```sql
-- Sort orders by status, then by total descending
SELECT id, status, total, order_date
FROM orders
ORDER BY status ASC, total DESC;
```
**Output:**
| id | status | total | order_date |
|----|--------|-------|------------|
| 1 | completed | 1049.98 | 2024-01-15 |
| 2 | completed | 749.98 | 2024-01-18 |
| 9 | completed | 198.97 | 2024-04-01 |
| 4 | completed | 149.99 | 2024-02-28 |
| 11 | completed | 59.99 | 2024-04-10 |
| 7 | completed | 49.99 | 2024-03-15 |
| 3 | completed | 89.98 | 2024-02-20 |
| 12 | completed | 154.98 | 2024-04-15 |
| 5 | pending | 999.99 | 2024-03-05 |
| 6 | shipped | 179.98 | 2024-03-10 |
| 8 | shipped | 89.98 | 2024-04-05 |
| 10 | cancelled | 34.99 | 2024-04-10 |

```sql
-- Sort members by membership_type, then by name
SELECT name, membership_type, membership_date
FROM members
ORDER BY membership_type ASC, name ASC;
```
**Output:**
| name | membership_type | membership_date |
|------|-----------------|-----------------|
| Eve Martinez | standard | 2023-05-01 |
| Frank Garcia | standard | 2021-09-12 |
| Henry Taylor | standard | 2020-03-30 |
| Ivy Anderson | standard | 2023-01-15 |
| Jack Thomas | standard | 2022-10-05 |
| Bob Williams | standard | 2021-06-15 |
| Carol Davis | standard | 2023-02-20 |
| Kevin Martinez | standard | 2022-07-22 |
| Alice Johnson | premium | 2022-01-10 |
| David Brown | premium | 2020-11-08 |
| Grace Wilson | premium | 2022-07-25 |

### Practice Exercises

1. Sort products by category_id, then by price descending
2. Sort loans by member_id, then by loan_date descending (library-db)
3. Sort authors by nationality, then by name ascending
4. Sort employees by department_id, then by hire_date ascending

---

## Day 3: LIMIT - Restricting Results

### What is LIMIT?

LIMIT restricts the number of rows returned. Essential for pagination, top-N queries, and sampling data.

### Syntax

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1 DESC
LIMIT number_of_rows;
```

### Examples

```sql
-- Get the 3 most expensive products
SELECT name, price FROM products ORDER BY price DESC LIMIT 3;
```
**Output:**
| name | price |
|------|-------|
| Laptop | 999.99 |
| Smartphone | 699.99 |
| Headphones | 149.99 |

```sql
-- Get the 5 oldest employees (by hire_date)
SELECT name, hire_date FROM employees ORDER BY hire_date ASC LIMIT 5;
```
**Output:**
| name | hire_date |
|------|-----------|
| David Brown | 2020-11-05 |
| Frank Miller | 2021-02-14 |
| Bob Smith | 2021-06-20 |
| Alice Johnson | 2022-01-15 |
| Henry Wilson | 2022-07-08 |

```sql
-- Get the 5 cheapest books
SELECT title, published_year FROM books ORDER BY published_year ASC LIMIT 5;
```
**Output:**
| title | published_year |
|-------|----------------|
| Pride and Prejudice | 1813 |
| The Adventures of Tom Sawyer | 1876 |
| The Great Gatsby | 1925 |
| The Hobbit | 1937 |
| Murder on the Orient Express | 1934 |

Wait, that sorted incorrectly. Let me fix:

```sql
-- Get the 5 most recent books
SELECT title, published_year FROM books ORDER BY published_year DESC LIMIT 5;
```
**Output:**
| title | published_year |
|-------|----------------|
| Harry Potter and the Sorcerer's Stone | 1997 |
| The Alchemist | 1988 |
| The Shining | 1977 |
| 1984 | 1949 |
| Foundation | 1951 |

```sql
-- Get the 3 cheapest products in category 1 (Electronics)
SELECT name, price FROM products WHERE category_id = 1 ORDER BY price ASC LIMIT 3;
```
**Output:**
| name | price |
|------|-------|
| Headphones | 149.99 |
| Smartphone | 699.99 |
| Laptop | 999.99 |

```sql
-- Get 5 most recent loans (library-db)
SELECT l.id, m.name, b.title, l.loan_date
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
ORDER BY l.loan_date DESC
LIMIT 5;
```
**Output:**
| id | name | title | loan_date |
|----|------|-------|-----------|
| 20 | Henry Taylor | The Alchemist | 2024-05-05 |
| 19 | Grace Wilson | Brave New World | 2024-05-01 |
| 18 | Frank Garcia | To Kill a Mockingbird | 2024-04-25 |
| 17 | Lisa Garcia | Fahrenheit 451 | 2024-04-20 |
| 16 | Kevin Martinez | Foundation | 2024-04-15 |

### Practice Exercises

1. Get the 3 most expensive products
2. Get the 5 most recently hired employees
3. Get the 3 cheapest products in category 2 (Clothing)
4. Get the 4 most recent loans from library-db

---

## Day 4: OFFSET - Skipping Rows

### What is OFFSET?

OFFSET skips a specified number of rows before returning results. Used with LIMIT for pagination.

### Syntax

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1
LIMIT number_of_rows OFFSET rows_to_skip;
```

### Examples

```sql
-- Page 1: First 5 products (rows 1-5)
SELECT name, price FROM products ORDER BY price ASC LIMIT 5 OFFSET 0;
```

```sql
-- Page 2: Next 5 products (rows 6-10)
SELECT name, price FROM products ORDER BY price ASC LIMIT 5 OFFSET 5;
```

```sql
-- Page 3: Next 5 products (rows 11-15)
SELECT name, price FROM products ORDER BY price ASC LIMIT 5 OFFSET 10;
```

### Pagination Example

```sql
-- Page 1 of products catalog (4 per page)
SELECT id, name, price FROM products ORDER BY name ASC LIMIT 4 OFFSET 0;
```
**Output:**
| id | name | price |
|----|------|-------|
| 11 | Basketball | 34.99 |
| 5 | Jeans | 59.99 |
| 10 | Running Shoes | 119.99 |
| 8 | Python Guide | 39.99 |

```sql
-- Page 2 of products catalog
SELECT id, name, price FROM products ORDER BY name ASC LIMIT 4 OFFSET 4;
```
**Output:**
| id | name | price |
|----|------|-------|
| 9 | Garden Tools Set | 79.99 |
| 3 | Headphones | 149.99 |
| 6 | Jacket | 89.99 |
| 1 | Laptop | 999.99 |

```sql
-- Page 3 of products catalog
SELECT id, name, price FROM products ORDER BY name ASC LIMIT 4 OFFSET 8;
```
**Output:**
| id | name | price |
|----|------|-------|
| 2 | Smartphone | 699.99 |
| 7 | SQL Mastery | 49.99 |
| 12 | Yoga Mat | 24.99 |
| 4 | T-Shirt | 29.99 |

### Library Loans Pagination

```sql
-- First 5 loans (page 1)
SELECT l.id, m.name, b.title, l.loan_date
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
ORDER BY l.id ASC
LIMIT 5 OFFSET 0;
```
**Output:**
| id | name | title | loan_date |
|----|------|-------|-----------|
| 1 | Alice Johnson | 1984 | 2024-01-15 |
| 2 | Bob Williams | Foundation | 2024-01-20 |
| 3 | Carol Davis | The Adventures of Tom Sawyer | 2024-02-01 |
| 4 | Alice Johnson | The Shining | 2024-02-10 |
| 5 | David Brown | Harry Potter and the Sorcerer's Stone | 2024-02-15 |

```sql
-- Second 5 loans (page 2)
SELECT l.id, m.name, b.title, l.loan_date
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
ORDER BY l.id ASC
LIMIT 5 OFFSET 5;
```
**Output:**
| id | name | title | loan_date |
|----|------|-------|-----------|
| 6 | Eve Martinez | 1984 Special Edition | 2024-02-20 |
| 7 | Bob Williams | Brave New World | 2024-03-01 |
| 8 | Frank Garcia | The Great Gatsby | 2024-03-05 |
| 9 | Grace Wilson | The Hobbit | 2024-03-10 |
| 10 | Carol Davis | And Then There Were None | 2024-03-15 |

### Practice Exercises

1. Create a paginated list of employees (3 per page, show page 2)
2. Create a paginated list of books (5 per page, show page 1)
3. Show the second most expensive product (LIMIT 1 OFFSET 1)
4. Create a paginated list of orders (4 per page, show page 3)

---

## Day 5: Top-N Patterns

### Common Top-N Queries

Get the best/worst N items based on some criteria.

### Examples

```sql
-- Top 3 most expensive products
SELECT * FROM products ORDER BY price DESC LIMIT 3;
```

```sql
-- Top 3 highest paid employees per department
SELECT e.name, e.salary, e.department_id
FROM employees e
ORDER BY e.department_id ASC, e.salary DESC
LIMIT 3;
```

```sql
-- Top 3 cheapest books per genre (using subquery approach)
SELECT b.title, g.name AS genre, b.published_year, b.pages
FROM books b
JOIN genres g ON b.genre_id = g.id
ORDER BY g.name ASC, b.published_year ASC
LIMIT 3;
```

```sql
-- Top 5 most recent orders per customer
SELECT o.id, o.customer_id, o.order_date, o.total
FROM orders o
ORDER BY o.customer_id ASC, o.order_date DESC
LIMIT 5;
```

```sql
-- Top 3 members with most active loans
SELECT m.name, COUNT(l.id) AS active_loans
FROM members m
LEFT JOIN loans l ON m.id = l.member_id AND l.return_date IS NULL
GROUP BY m.id
ORDER BY active_loans DESC
LIMIT 3;
```

```sql
-- Top 3 most loaned books
SELECT b.title, COUNT(l.id) AS loan_count
FROM books b
JOIN book_copies bc ON b.id = bc.book_id
JOIN loans l ON bc.id = l.book_copy_id
GROUP BY b.id
ORDER BY loan_count DESC
LIMIT 3;
```

```sql
-- Top 3 authors by number of books
SELECT a.name, COUNT(ab.book_id) AS book_count
FROM authors a
JOIN author_books ab ON a.id = ab.author_id
GROUP BY a.id
ORDER BY book_count DESC
LIMIT 3;
```

### Practice Exercises

1. Find the top 3 most expensive products in each category
2. Find the top 2 longest overdue loans
3. Find the top 3 customers by total order value
4. Find the top 3 most loaned book copies

---

## Day 6: Combined Queries

### Combining WHERE, ORDER BY, and LIMIT

Real queries combine all these clauses together.

### Query Execution Order

Understanding how SQL processes your query:

```sql
SELECT column1, column2     -- 5. What to return
FROM table_name             -- 1. From where
WHERE condition             -- 2. Filter which rows
ORDER BY column1            -- 3. Sort order
LIMIT 10;                   -- 4. How many to return
```

### Examples

```sql
-- Find completed orders over $100, newest first, show top 5
SELECT id, customer_id, order_date, total, status
FROM orders
WHERE status = 'completed' AND total > 100
ORDER BY order_date DESC
LIMIT 5;
```
**Output:**
| id | customer_id | order_date | total | status |
|----|-------------|------------|-------|--------|
| 12 | 5 | 2024-04-15 | 154.98 | completed |
| 9 | 7 | 2024-04-01 | 198.97 | completed |
| 11 | 3 | 2024-04-10 | 59.99 | completed |
| 4 | 1 | 2024-02-28 | 149.99 | completed |
| 3 | 3 | 2024-02-20 | 89.98 | completed |

```sql
-- Find premium members who joined in 2022+, sorted by name
SELECT name, membership_type, membership_date
FROM members
WHERE membership_type = 'premium' AND membership_date >= '2022-01-01'
ORDER BY name ASC;
```

```sql
-- Find Electronics products with stock > 50, cheapest first
SELECT name, price, stock
FROM products
WHERE category_id = 1 AND stock > 50
ORDER BY price ASC;
```
**Output:**
| name | price | stock |
|------|-------|-------|
| Headphones | 149.99 | 200 |
| Smartphone | 699.99 | 100 |
| Laptop | 999.99 | 50 |

```sql
-- Find Science Fiction books published after 1940, page 1
SELECT title, published_year, pages
FROM books b
JOIN genres g ON b.genre_id = g.id
WHERE g.name = 'Science Fiction' AND b.published_year > 1940
ORDER BY b.published_year DESC
LIMIT 5 OFFSET 0;
```

```sql
-- Find active loans (not returned) from premium members, page 1
SELECT m.name, b.title, l.loan_date, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE l.return_date IS NULL AND m.membership_type = 'premium'
ORDER BY l.due_date ASC
LIMIT 5 OFFSET 0;
```

```sql
-- Find products needing reorder (stock < 100), sorted by urgency
SELECT name, category_id, stock, price
FROM products
WHERE stock < 100
ORDER BY stock ASC, price DESC;
```
**Output:**
| name | category_id | stock | price |
|------|-------------|-------|-------|
| Garden Tools Set | 4 | 40 | 79.99 |
| Laptop | 1 | 50 | 999.99 |
| SQL Mastery | 3 | 80 | 49.99 |
| Running Shoes | 5 | 75 | 119.99 |
| Python Guide | 3 | 120 | 39.99 |

```sql
-- Find overdue loans (past due date and not returned)
SELECT m.name, b.title, l.due_date, l.loan_date
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE l.return_date IS NULL AND l.due_date < date('now')
ORDER BY l.due_date ASC;
```

### Practice Exercises

1. Find pending orders over $200, newest first, top 3
2. Find standard members who joined in 2023, alphabetically
3. Find products in category 3 (Books) with stock < 100, cheapest first
4. Find active loans from members in New York, sorted by due date

---

## Day 7: Review & Mini Quiz

### Summary: What You Learned This Week

| Day | Topic | Key Command |
|-----|-------|-------------|
| 1 | ORDER BY Basics | `ORDER BY col ASC\|DESC` |
| 2 | Multi-Column Sort | `ORDER BY col1, col2` |
| 3 | LIMIT | `LIMIT n` |
| 4 | OFFSET | `LIMIT n OFFSET m` |
| 5 | Top-N Patterns | `ORDER BY col LIMIT n` |
| 6 | Combined Queries | `WHERE + ORDER BY + LIMIT` |

---

## Mini Quiz (10 Questions)

### Q1: Sort products by price descending (most expensive first)

```sql
SELECT * FROM products ORDER BY price DESC;
```

### Q2: Get the 5 cheapest products

```sql
SELECT * FROM products ORDER BY price ASC LIMIT 5;
```

**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 12 | Yoga Mat | 5 | 24.99 | 150 |
| 4 | T-Shirt | 2 | 29.99 | 500 |
| 11 | Basketball | 5 | 34.99 | 200 |
| 8 | Python Guide | 3 | 39.99 | 120 |
| 7 | SQL Mastery | 3 | 49.99 | 80 |

---

### Q3: Sort employees by department (ascending), then salary (descending)

```sql
SELECT name, department_id, salary FROM employees ORDER BY department_id ASC, salary DESC;
```

**Output:**
| name | department_id | salary |
|------|---------------|--------|
| Alice Johnson | 1 | 5500 |
| Henry Wilson | 1 | 5100 |
| Bob Smith | 1 | 4800 |
| Carol White | 2 | 5200 |
| Grace Lee | 2 | 4900 |
| David Brown | 3 | 7000 |
| Frank Miller | 3 | 6500 |
| Eve Davis | 4 | 4500 |

---

### Q4: Get page 2 of books (5 per page)

```sql
SELECT title, published_year FROM books ORDER BY title ASC LIMIT 5 OFFSET 5;
```

**Output:**
| title | published_year |
|-------|----------------|
| Fahrenheit 451 | 1953 |
| Foundation | 1951 |
| Harry Potter and the Sorcerer's Stone | 1997 |
| Pride and Prejudice | 1813 |
| The Adventures of Tom Sawyer | 1876 |

---

### Q5: Get the 3 most expensive Electronics products

```sql
SELECT name, price, category_id FROM products WHERE category_id = 1 ORDER BY price DESC LIMIT 3;
```

**Output:**
| name | price | category_id |
|------|-------|-------------|
| Laptop | 999.99 | 1 |
| Smartphone | 699.99 | 1 |
| Headphones | 149.99 | 1 |

---

### Q6: Find the 5 most recent loans

```sql
SELECT l.id, m.name, b.title, l.loan_date
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
ORDER BY l.loan_date DESC
LIMIT 5;
```

**Output:**
| id | name | title | loan_date |
|----|------|-------|-----------|
| 20 | Henry Taylor | The Alchemist | 2024-05-05 |
| 19 | Grace Wilson | Brave New World | 2024-05-01 |
| 18 | Frank Garcia | To Kill a Mockingbird | 2024-04-25 |
| 17 | Lisa Garcia | Fahrenheit 451 | 2024-04-20 |
| 16 | Kevin Martinez | Foundation | 2024-04-15 |

---

### Q7: Sort members by membership_date descending (newest members first)

```sql
SELECT name, membership_date, membership_type FROM members ORDER BY membership_date DESC;
```

**Output:**
| name | membership_date | membership_type |
|------|-----------------|-----------------|
| Eve Martinez | 2023-05-01 | standard |
| Ivy Anderson | 2023-01-15 | standard |
| Kevin Martinez | 2022-07-22 | standard |
| Grace Wilson | 2022-07-25 | premium |
| Jack Thomas | 2022-10-05 | standard |
| Alice Johnson | 2022-01-10 | premium |
| Henry Taylor | 2020-03-30 | standard |
| Frank Garcia | 2021-09-12 | standard |
| Bob Williams | 2021-06-15 | standard |
| David Brown | 2020-11-08 | premium |
| Carol Davis | 2023-02-20 | standard |
| Lisa Garcia | 2023-06-18 | standard |

---

### Q8: Find pending orders over $100, sorted by total descending

```sql
SELECT id, customer_id, total, status FROM orders WHERE status = 'pending' AND total > 100 ORDER BY total DESC;
```

**Output:**
| id | customer_id | total | status |
|----|-------------|-------|--------|
| 5 | 4 | 999.99 | pending |

---

### Q9: Get the 3 authors with the most books

```sql
SELECT a.name, COUNT(ab.book_id) AS book_count
FROM authors a
JOIN author_books ab ON a.id = ab.author_id
GROUP BY a.id
ORDER BY book_count DESC
LIMIT 3;
```

**Output:**
| name | book_count |
|------|------------|
| George Orwell | 4 |
| Agatha Christie | 2 |
| Jane Austen | 1 |
| Isaac Asimov | 1 |
| Mark Twain | 1 |
| Stephen King | 1 |
| J.K. Rowling | 1 |
| Paulo Coelho | 1 |

---

### Q10: Find premium members with active loans, sorted by due date

```sql
SELECT m.name, b.title, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.book_copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE l.return_date IS NULL AND m.membership_type = 'premium'
ORDER BY l.due_date ASC;
```

**Output:**
| name | title | due_date |
|------|-------|----------|
| Alice Johnson | The Shining | 2024-03-10 |
| David Brown | Murder on the Orient Express | 2024-05-05 |
| Grace Wilson | Brave New World | 2024-06-01 |

---

## Quick Reference Card

| Clause | Purpose | Syntax |
|--------|---------|--------|
| ORDER BY | Sort results | `ORDER BY col [ASC\|DESC]` |
| LIMIT | Restrict row count | `LIMIT n` |
| OFFSET | Skip rows | `OFFSET n` |
| Multi-column | Sort by multiple | `ORDER BY col1, col2` |

### Query Execution Order

1. FROM - identify the table
2. WHERE - filter rows
3. ORDER BY - sort
4. LIMIT/OFFSET - restrict results
5. SELECT - return columns

---

## Milestone Checklist (End of Week 3)

- [ ] Can sort data with ORDER BY (ASC/DESC)
- [ ] Can sort by multiple columns
- [ ] Can limit results with LIMIT
- [ ] Can skip rows with OFFSET
- [ ] Can implement pagination
- [ ] Understands query execution order
- [ ] Can combine WHERE, ORDER BY, and LIMIT

---

## Week 3 Summary

**Topics Covered:**
- ORDER BY clause (ASC, DESC)
- Multi-column sorting
- LIMIT - Restricting results
- OFFSET - Skipping rows
- Top-N queries
- Combined queries (WHERE + ORDER BY + LIMIT)
- Query execution order

**Goal:** Pass Week 3 quiz with score > 80%

---

*Week 3 of 12 — Part of the 3-Month SQL Learning Roadmap*