# Week 1: Introduction & Basic Queries
## SQL Learning Roadmap - Month 1

```
Duration: 7 Days
Level: Beginner
Time Commitment: 1-2 hours daily
Goal: Master basic data retrieval with SELECT
```

---

## Learning Objectives

By the end of Week 1, you will be able to:

- [ ] Explain what SQL is and its purpose
- [ ] Differentiate between RDBMS and NoSQL
- [ ] Write basic SELECT queries
- [ ] Filter columns and use aliases
- [ ] Perform arithmetic operations in SQL
- [ ] Use DISTINCT to remove duplicates
- [ ] Understand basic data types in SQL

---

## Quick Reference

### SQL Command Types

| Type | Purpose | Examples |
|------|---------|----------|
| **DDL** (Data Definition Language) | Define/manage table structure | CREATE, ALTER, DROP |
| **DML** (Data Manipulation Language) | Manipulate data | INSERT, UPDATE, DELETE |
| **DQL** (Data Query Language) | Retrieve data | SELECT |
| **DCL** (Data Control Language) | Access control | GRANT, REVOKE |
| **TCL** (Transaction Control Language) | Manage transactions | COMMIT, ROLLBACK |

> **Focus this week:** DQL (SELECT queries)

---

## Day 1: Database Concepts

### What is a Database?

A **database** is an organized collection of data stored electronically. Think of it like:

- A **digital filing cabinet** with folders (tables) containing records (rows)
- An **Excel spreadsheet** but more powerful and structured
- A **library** where data is systematically arranged for easy retrieval

### Key Terms Explained

| Term | Simple Explanation | Analogy |
|------|-------------------|---------|
| **Database** | Electronic system that stores data | The filing cabinet |
| **Table** | A collection of related data in rows and columns | A spreadsheet tab |
| **Row** | A single record/entry | One row in Excel |
| **Column** | A specific attribute (field) | A column header |
| **Cell** | The intersection of row and column | One box in Excel |
| **Primary Key** | Unique identifier for each row | Employee ID number |

### RDBMS vs NoSQL

**RDBMS (Relational Database Management System):**

- Stores data in **tables with relationships**
- Uses **SQL** for querying
- Data is structured with fixed schemas
- Examples: SQLite, MySQL, PostgreSQL, SQL Server

```
Customers Table                    Orders Table
┌────┬─────────┬──────────────┐    ┌────┬─────────┬────────┐
│ ID │  Name   │    Email     │    │ ID │ Cust_ID │ Total  │
├────┼─────────┼──────────────┤    ├────┼─────────┼────────┤
│ 1  │ John    │ john@e.com   │    │101 │    1    │ 150.00 │
│ 2  │ Jane    │ jane@e.com   │    │102 │    2    │  75.00 │
└────┴─────────┴──────────────┘    └────┴─────────┴────────┘
         ↑                               ↑
    Related via ID                   Related via Cust_ID
```

**NoSQL (Not Only SQL):**

- Stores data in various formats: documents, key-value pairs, graphs
- More flexible schema
- Examples: MongoDB, Redis, Cassandra

### Why SQL Matters

1. **Universal** - Used by almost every company with data
2. **In-demand** - Top skill for data analysts, developers, data scientists
3. **Standardized** - Works across different database systems
4. **Powerful** - Can retrieve complex data in single queries

### Your Task for Day 1

- [ ] Research: Write a 5-sentence summary comparing RDBMS to NoSQL
- [ ] Install SQLite if not already installed
- [ ] Verify installation: `sqlite3 --version`

---

## Day 2: SELECT Basics

### The SELECT Statement

`SELECT` is how you ask the database for information. It's the most used SQL command.

### Syntax

```sql
SELECT column_name FROM table_name;
```

### The Wildcard (*)

The asterisk `*` means "all columns". Use it when you want everything from a table.

```sql
SELECT * FROM table_name;
```

### Your First Queries

Let's start with a simple database. Assume we have an `employees` table:

```
employees table:
┌────┬───────────┬─────────┬─────────────────┬──────────┐
│ id │ first_name│last_name│     email       │ salary   │
├────┼───────────┼─────────┼─────────────────┼──────────┤
│ 1  │ John      │ Doe     │ john@company.com│ 50000    │
│ 2  │ Jane      │ Smith   │ jane@company.com│ 60000    │
│ 3  │ Bob       │ Johnson │ bob@company.com │ 55000    │
└────┴───────────┴─────────┴─────────────────┴──────────┘
```

### Examples

```sql
-- Get ALL data from employees
SELECT * FROM employees;

-- Get all data from products table
SELECT * FROM products;

-- Get all data from orders table
SELECT * FROM orders;
```

### Understanding Query Structure

Every SELECT query has these parts:

```sql
SELECT      -- What columns you want
*           -- All columns (or list specific ones)
FROM        -- Which table
employees;  -- The table name
;           -- Statement ends with semicolon
```

### Practice Exercises

```sql
-- Exercise 2.1: Get all data from employees table
SELECT * FROM employees;

-- Exercise 2.2: Get all data from products table
SELECT * FROM products;

-- Exercise 2.3: Get all data from customers table
SELECT * FROM customers;

-- Exercise 2.4: Get all data from orders table
SELECT * FROM orders;
```

### Check Your Understanding

- [ ] Can you explain what `SELECT *` does?
- [ ] Can you write a basic SELECT query?
- [ ] Do you know why the semicolon is important?

---

## Day 3: Column Selection

### Selecting Specific Columns

Instead of getting all columns with `*`, specify exactly which columns you need.

### Why Specify Columns?

1. **Faster** - Less data to retrieve
2. **Clearer** - Easier to read output
3. **Safer** - Don't expose unnecessary data
4. **Efficient** - Uses less memory

### Syntax

```sql
SELECT column1, column2, column3 FROM table_name;
```

### Examples

```sql
-- Get only name and email from customers
SELECT first_name, last_name, email FROM customers;

-- Get order details without sensitive info
SELECT order_id, order_date, total FROM orders;

-- Get product info for a catalog
SELECT product_name, price, quantity FROM products;
```

### Multiple Columns

Separate column names with commas:

```sql
-- Correct
SELECT first_name, last_name, email FROM employees;

-- Incorrect (missing comma)
SELECT first_name last_name, email FROM employees;
```

### Practice Exercises

```sql
-- Exercise 3.1: Select specific columns from employees
SELECT first_name, last_name, salary FROM employees;

-- Exercise 3.2: Select product details for a catalog
SELECT product_name, price, category FROM products;

-- Exercise 3.3: Create a customer contact list
SELECT customer_name, email, phone FROM customers;

-- Exercise 3.4: Get order summary
SELECT order_id, order_date, status, total FROM orders;
```

### Check Your Understanding

- [ ] Can you select specific columns?
- [ ] Do you know how to separate column names?
- [ ] Can you explain why specifying columns is better?

---

## Day 4: Aliases (AS)

### What Are Aliases?

Aliases give columns a temporary nickname in your output. The actual table column names don't change - only how they appear in results.

### Syntax

```sql
SELECT column_name AS 'Nickname' FROM table_name;
```

### Why Use Aliases?

1. **Better readability** - "First Name" instead of "first_name"
2. **Clearer output** - "Annual Salary" instead of "salary * 12"
3. **Professional reports** - Clean column headers

### Examples

```sql
-- Simple alias
SELECT first_name AS 'First Name', 
       last_name AS 'Last Name'
FROM employees;

-- Alias with calculation
SELECT first_name AS 'First Name',
       last_name AS 'Last Name',
       salary * 12 AS 'Annual Salary'
FROM employees;
```

### Output Comparison

**Without Alias:**
```
first_name  | last_name  | salary * 12
John        | Doe        | 60000
```

**With Alias:**
```
First Name  | Last Name  | Annual Salary
John        | Doe        | 60000
```

### Alias Rules

- Single quotes are optional but recommended for readability
- Aliases can contain spaces when quoted
- Aliases only affect the output, not the actual data

### Practice Exercises

```sql
-- Exercise 4.1: Rename columns for readability
SELECT product_name AS 'Product',
       price AS 'Price',
       quantity AS 'Stock'
FROM products;

-- Exercise 4.2: Create clean customer list
SELECT customer_name AS 'Customer Name',
       email AS 'Email Address'
FROM customers;

-- Exercise 4.3: Calculate and rename
SELECT order_id AS 'Order Number',
       total AS 'Order Total'
FROM orders;

-- Exercise 4.4: Multiple aliases with calculation
SELECT product_name AS 'Product',
       price AS 'Unit Price',
       quantity AS 'Units In Stock',
       price * quantity AS 'Total Inventory Value'
FROM products;
```

### Check Your Understanding

- [ ] Can you use the AS keyword for aliases?
- [ ] Can you combine aliases with calculations?
- [ ] Do you understand aliases only affect output?

---

## Day 5: Arithmetic in SQL

### SQL Can Do Math!

SQL supports basic arithmetic operations directly in queries.

### Operators

| Operator | Operation | Example |
|----------|-----------|---------|
| `+` | Addition | `salary + 1000` |
| `-` | Subtraction | `price - discount` |
| `*` | Multiplication | `price * quantity` |
| `/` | Division | `total / quantity` |

### Examples

```sql
-- Calculate total value of products in inventory
SELECT product_name, price, quantity, 
       price * quantity AS 'Total Value'
FROM products;

-- Add a bonus to salaries
SELECT first_name, last_name, salary, 
       salary + 1000 AS 'Salary With Bonus'
FROM employees;

-- Apply a 10% discount
SELECT product_name, price, 
       price * 0.9 AS 'Discounted Price'
FROM products;

-- Calculate price per unit
SELECT order_id, total, quantity,
       total / quantity AS 'Price Per Unit'
FROM orders;
```

### Order of Operations

SQL follows standard math order:
1. Parentheses `()`
2. Division `/` and Multiplication `*`
3. Addition `+` and Subtraction `-`

```sql
-- Calculates: (price * quantity) - discount
SELECT product_name, price, quantity, 
       (price * quantity) - 10 AS 'After Discount'
FROM products;
```

### Practice Exercises

```sql
-- Exercise 5.1: Calculate order totals
SELECT order_id, 
       quantity, 
       unit_price, 
       quantity * unit_price AS 'Subtotal'
FROM order_items;

-- Exercise 5.2: Calculate annual salaries
SELECT first_name, 
       last_name, 
       salary, 
       salary * 12 AS 'Annual Salary'
FROM employees;

-- Exercise 5.3: Apply percentage discounts
SELECT product_name, 
       price, 
       price * 0.85 AS '15% Off Price'
FROM products;

-- Exercise 5.4: Calculate revenue
SELECT product_name,
       units_sold,
       price_per_unit,
       units_sold * price_per_unit AS 'Total Revenue'
FROM sales;

-- Exercise 5.5: Complex calculation
SELECT product_name,
       price,
       quantity,
       (price * quantity) * 1.08 AS 'Total With Tax'
FROM products;
```

### Check Your Understanding

- [ ] Can you perform arithmetic operations in SELECT?
- [ ] Do you understand the order of operations?
- [ ] Can you combine arithmetic with aliases?

---

## Day 6: DISTINCT

### What Is DISTINCT?

`DISTINCT` removes duplicate values from your results, showing only unique values.

### Why Use DISTINCT?

Imagine you have 100 products but only 5 categories. Without DISTINCT:

```
category
---------
Electronics
Clothing
Electronics
Electronics
Clothing
... (100 rows)
```

With DISTINCT:

```
category
---------
Electronics
Clothing
```

### Syntax

```sql
SELECT DISTINCT column_name FROM table_name;
```

### Examples

```sql
-- Find all unique departments
SELECT DISTINCT department FROM employees;

-- Find all unique categories
SELECT DISTINCT category FROM products;

-- Find all unique countries where we have customers
SELECT DISTINCT country FROM customers;
```

### DISTINCT With Multiple Columns

When you use DISTINCT with multiple columns, it returns unique combinations:

```sql
-- Unique department-status combinations
SELECT DISTINCT department, status FROM employees;
```

### Common Use Cases

1. **List all categories** without repetition
2. **Find unique values** in a column
3. **Count unique items** (combine with COUNT)

```sql
-- Count unique customers who placed orders
SELECT COUNT(DISTINCT customer_id) FROM orders;
```

### Practice Exercises

```sql
-- Exercise 6.1: List all unique departments
SELECT DISTINCT department FROM employees;

-- Exercise 6.2: Find all unique product categories
SELECT DISTINCT category FROM products;

-- Exercise 6.3: Find all unique order statuses
SELECT DISTINCT status FROM orders;

-- Exercise 6.4: Unique combinations
SELECT DISTINCT category, brand FROM products;

-- Exercise 6.5: Count unique values
SELECT COUNT(DISTINCT customer_id) AS 'Unique Customers' FROM orders;
```

### Check Your Understanding

- [ ] Can you use DISTINCT to remove duplicates?
- [ ] Do you understand how DISTINCT works with multiple columns?
- [ ] Can you combine DISTINCT with COUNT?

---

## Day 7: Review & Mini Quiz

### Summary: What You Learned This Week

| Day | Topic | Key Command |
|-----|-------|-------------|
| 1 | Database Concepts | Understanding RDBMS |
| 2 | SELECT Basics | `SELECT * FROM table` |
| 3 | Column Selection | `SELECT col1, col2 FROM table` |
| 4 | Aliases | `SELECT col AS 'Name' FROM table` |
| 5 | Arithmetic | `SELECT price * quantity FROM table` |
| 6 | DISTINCT | `SELECT DISTINCT col FROM table` |

### Practice Database Setup

Run this script to create your practice database:

```sql
-- Create employees table
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    department TEXT,
    salary DECIMAL(10,2)
);

-- Insert sample data
INSERT INTO employees VALUES
(1, 'John', 'Doe', 'john@company.com', 'Sales', 5000),
(2, 'Jane', 'Smith', 'jane@company.com', 'IT', 6000),
(3, 'Bob', 'Johnson', 'bob@company.com', 'Sales', 5500),
(4, 'Alice', 'Williams', 'alice@company.com', 'HR', 4500),
(5, 'Charlie', 'Brown', 'charlie@company.com', 'IT', 6500),
(6, 'Diana', 'Davis', 'diana@company.com', 'Marketing', 5200),
(7, 'Edward', 'Miller', 'edward@company.com', 'Sales', 5800),
(8, 'Fiona', 'Wilson', 'fiona@company.com', 'IT', 6200);

-- Create products table
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    price DECIMAL(10,2),
    quantity INTEGER
);

-- Insert sample data
INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 999.99, 10),
(2, 'Mouse', 'Electronics', 29.99, 50),
(3, 'Keyboard', 'Electronics', 79.99, 30),
(4, 'T-Shirt', 'Clothing', 19.99, 100),
(5, 'Jeans', 'Clothing', 39.99, 75),
(6, 'Jacket', 'Clothing', 59.99, 40),
(7, 'Headphones', 'Electronics', 149.99, 25),
(8, 'Sneakers', 'Clothing', 79.99, 60);
```

### Mini Quiz

Test your knowledge with these questions:

**Q1:** What does `SELECT *` mean?
- a) Select all columns
- b) Select the first row
- c) Select the last row

**Q2:** How do you rename a column in the output?
- a) `RENAME column AS 'Name'`
- b) `SELECT column AS 'Name'`
- c) `ALTER column AS 'Name'`

**Q3:** What does `DISTINCT` do?
- a) Sorts data
- b) Removes duplicates
- c) Filters data

**Q4:** Calculate: `10 + 5 * 2` = ?
- a) 30
- b) 20
- c) 15

**Q5:** Which is the correct syntax for aliases?
- a) `SELECT column 'Name' FROM table`
- b) `SELECT column AS 'Name' FROM table`
- c) `SELECT column FROM 'Name' AS table`

### Quiz Answers

| Q1 | Q2 | Q3 | Q4 | Q5 |
|----|----|----|----|----|
| a  | b  | b  | a  | b  |

### Self-Assessment Checklist

Before moving to Week 2, verify you can:

- [ ] Explain what SQL is and its purpose
- [ ] Write basic SELECT queries
- [ ] Filter columns and use aliases
- [ ] Perform arithmetic operations
- [ ] Use DISTINCT to remove duplicates
- [ ] Understand data types in SQL

### If You Struggled With Something

Review these concepts:
- Day 2: Watch SQL SELECT basics video
- Day 3: Practice selecting specific columns
- Day 4: Re-read alias section with examples
- Day 5: Review arithmetic operator precedence
- Day 6: Think of DISTINCT as "unique values only"

### Next Week Preview

**Week 2: Filtering with WHERE**
- Filter data using conditions
- Comparison operators (=, <>, <, >, <=, >=)
- Logical operators (AND, OR, NOT)
- Pattern matching with LIKE

---

## Practice Exercises (All Combined)

```sql
-- Challenge 1: Basic SELECT
-- Select all columns from employees
SELECT * FROM employees;

-- Challenge 2: Column Selection
-- Select first name, last name, and salary from employees
SELECT first_name, last_name, salary FROM employees;

-- Challenge 3: Aliases
-- Rename columns for a report
SELECT first_name AS 'First Name',
       last_name AS 'Last Name',
       salary AS 'Monthly Salary',
       salary * 12 AS 'Annual Salary'
FROM employees;

-- Challenge 4: Arithmetic
-- Calculate total value of inventory per product
SELECT product_name,
       price,
       quantity,
       price * quantity AS 'Total Value'
FROM products;

-- Challenge 5: DISTINCT
-- List all unique departments
SELECT DISTINCT department FROM employees;

-- Challenge 6: Combined
-- Calculate annual salary and remove duplicates
SELECT DISTINCT salary * 12 AS 'Annual Salary'
FROM employees;

-- Challenge 7: Complex Query
-- Create a product report with calculated values
SELECT product_name AS 'Product',
       category AS 'Category',
       price AS 'Unit Price',
       quantity AS 'Stock',
       price * quantity AS 'Inventory Value'
FROM products;

-- Challenge 8: DISTINCT with multiple columns
-- Find unique department-status combinations
SELECT DISTINCT department, status FROM employees;

-- Challenge 9: Multiple calculations
-- Calculate revenue with tax
SELECT product_name,
       price,
       quantity,
       price * quantity AS 'Subtotal',
       (price * quantity) * 1.10 AS 'With Tax'
FROM products;

-- Challenge 10: Your own query
-- Write a query to get employee contact list with annual salary
SELECT first_name || ' ' || last_name AS 'Full Name',
       email AS 'Email',
       salary * 12 AS 'Annual Salary'
FROM employees;
```

---

## Key Takeaways

1. **SELECT** is how you retrieve data from databases
2. Use **`*`** to select all columns, or list specific ones
3. **Aliases (AS)** make output more readable
4. SQL can perform **arithmetic** directly in queries
5. **DISTINCT** removes duplicate values from results

---

## Milestone Checkpoint

At the end of Week 1, you should have achieved:

- [ ] Can explain what SQL is and its purpose
- [ ] Can write basic SELECT queries
- [ ] Can filter columns and use aliases
- [ ] Understands data types in SQL

**Congratulations!** You've completed Week 1 of SQL Fundamentals.

---

*Week 1 Complete - Ready for Week 2: Filtering with WHERE*
