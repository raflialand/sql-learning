# Comprehensive SQL Learning Roadmap
## 3-Month Journey from Scratch to Proficiency

```
Start Date: Juni 2026
End Date: September 2026
Level: Beginner to Intermediate/Advanced
Time Commitment: 1-2 hours daily
```

---

## Table of Contents

1. [Prerequisites & Setup](#prerequisites--setup)
2. [Month 1: SQL Fundamentals](#month-1-sql-fundamentals)
3. [Month 2: Intermediate SQL](#month-2-intermediate-sql)
4. [Month 3: Advanced SQL](#month-3-advanced-sql)
5. [Weekly Schedule Overview](#weekly-schedule-overview)
6. [Project Milestones](#project-milestones)
7. [Resources & References](#resources--references)

---

## Prerequisites & Setup

### Required Tools

| Tool | Purpose | Download |
|------|---------|----------|
| SQLite3 | Database engine for practice | Pre-installed or sqlite.org |
| VSCode | Text editor with terminal | code.visualstudio.com |
| DB Browser for SQLite | GUI tool (optional) | sqlitebrowser.org |

### Environment Verification

```bash
# Verify SQLite installation
sqlite3 --version

# Expected output: 3.x.x (2026)
```

### Recommended VSCode Extensions

- **SQLite Viewer** - View SQLite databases visually
- **mysql** - MySQL syntax highlighting (if using MySQL later)
- **mssql** - SQL Server syntax support

---

## Month 1: SQL Fundamentals

> **Goal:** Master basic data retrieval, manipulation, and table management

### Week 1: Introduction & Basic Queries

#### Topics Covered
- What is a database?
- What is SQL and why it matters
- Types of SQL commands (DDL, DML, DQL, DCL, TCL)
- Your first SELECT query
- Understanding the SELECT statement structure

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | Database concepts | Research: RDBMS vs NoSQL |
| 2 | SELECT basics | `SELECT * FROM customers` |
| 3 | Column selection | Select specific columns |
| 4 | Aliases (AS) | Rename columns in output |
| 5 | Arithmetic in SQL | Basic calculations |
| 6 | DISTINCT | Remove duplicate values |
| 7 | **Review + Mini Quiz** | Create your practice database |

#### Exercises

```sql
-- Exercise 1.1: Your first query
SELECT * FROM employees;

-- Exercise 1.2: Select specific columns
SELECT first_name, last_name, email FROM employees;

-- Exercise 1.3: Use aliases
SELECT first_name AS 'First Name', 
       last_name AS 'Last Name',
       salary * 12 AS 'Annual Salary'
FROM employees;

-- Exercise 1.4: Remove duplicates
SELECT DISTINCT department FROM employees;

-- Exercise 1.5: Arithmetic operations
SELECT product_name, price, quantity, price * quantity AS 'Total Value'
FROM products;
```

#### Milestone Checkpoint
- [ ] Can explain what SQL is and its purpose
- [ ] Can write basic SELECT queries
- [ ] Can filter columns and use aliases
- [ ] Understands data types in SQL

---

### Week 2: Filtering with WHERE

#### Topics Covered
- WHERE clause fundamentals
- Comparison operators (=, <>, <, >, <=, >=)
- Logical operators (AND, OR, NOT)
- IN operator for multiple values
- BETWEEN operator for ranges
- LIKE operator for pattern matching
- IS NULL and IS NOT NULL

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | WHERE basics | Filter by single condition |
| 2 | Comparison operators | Numeric comparisons |
| 3 | AND, OR, NOT | Multiple conditions |
| 4 | IN operator | Filter with lists |
| 5 | BETWEEN operator | Range filtering |
| 6 | LIKE patterns | Wildcard matching |
| 7 | **Review + Mini Quiz** | 10 filtering challenges |

#### Exercises

```sql
-- Exercise 2.1: Basic WHERE
SELECT * FROM products WHERE category = 'Electronics';

-- Exercise 2.2: Multiple conditions
SELECT * FROM orders 
WHERE status = 'Shipped' AND total > 100;

-- Exercise 2.3: IN operator
SELECT * FROM customers 
WHERE country IN ('USA', 'UK', 'Canada');

-- Exercise 2.4: BETWEEN operator
SELECT * FROM products 
WHERE price BETWEEN 50 AND 200;

-- Exercise 2.5: LIKE patterns
-- % = any characters, _ = single character
SELECT * FROM customers WHERE name LIKE 'A%';
SELECT * FROM customers WHERE email LIKE '%@gmail.com';
SELECT * FROM products WHERE sku LIKE 'ELE-_';

-- Exercise 2.6: NULL handling
SELECT * FROM orders WHERE shipped_date IS NULL;
```

#### Milestone Checkpoint
- [ ] Can filter data using WHERE
- [ ] Can combine multiple conditions
- [ ] Can use IN, BETWEEN, LIKE effectively
- [ ] Can handle NULL values

---

### Week 3: Sorting & Limiting Results

#### Topics Covered
- ORDER BY clause (ASC, DESC)
- Multi-column sorting
- LIMIT and OFFSET
- Top-N queries
- Understanding query execution order

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | ORDER BY basics | Sort ascending/descending |
| 2 | Multi-column sort | Sort by multiple columns |
| 3 | LIMIT | Restrict number of results |
| 4 | OFFSET | Skip rows pagination |
| 5 | Top-N patterns | First/last N records |
| 6 | Combined queries | WHERE + ORDER BY + LIMIT |
| 7 | **Review + Mini Quiz** | 10 sorting challenges |

#### Exercises

```sql
-- Exercise 3.1: Basic sorting
SELECT * FROM products ORDER BY price ASC;
SELECT * FROM products ORDER BY price DESC;

-- Exercise 3.2: Multi-column sort
SELECT * FROM employees 
ORDER BY department ASC, salary DESC;

-- Exercise 3.3: LIMIT results
SELECT * FROM products ORDER BY price DESC LIMIT 5;

-- Exercise 3.4: OFFSET for pagination
SELECT * FROM products ORDER BY id LIMIT 10 OFFSET 0;  -- Page 1
SELECT * FROM products ORDER BY id LIMIT 10 OFFSET 10; -- Page 2

-- Exercise 3.5: Top 3 expensive products per category
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) as rn
    FROM products
) WHERE rn <= 3;
```

#### Milestone Checkpoint
- [ ] Can sort data with ORDER BY
- [ ] Can limit and offset results
- [ ] Understands query execution order
- [ ] Can implement pagination

---

### Week 4: Data Manipulation (DML)

#### Topics Covered
- INSERT INTO - Adding data
- UPDATE - Modifying data
- DELETE - Removing data
- TRUNCATE vs DELETE
- Transaction basics (COMMIT, ROLLBACK)
- Understanding Primary Keys

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | INSERT single row | Add data to table |
| 2 | INSERT multiple rows | Batch insert |
| 3 | UPDATE basics | Modify existing data |
| 4 | UPDATE with WHERE | Conditional updates |
| 5 | DELETE basics | Remove rows |
| 6 | Transaction control | COMMIT, ROLLBACK |
| 7 | **Review + Mini Quiz** | CRUD operations practice |

#### Exercises

```sql
-- Exercise 4.1: Insert single row
INSERT INTO customers (name, email, city) 
VALUES ('John Doe', 'john@email.com', 'New York');

-- Exercise 4.2: Insert multiple rows
INSERT INTO products (name, price, category) VALUES
    ('Product A', 29.99, 'Electronics'),
    ('Product B', 49.99, 'Electronics'),
    ('Product C', 19.99, 'Clothing');

-- Exercise 4.3: Update with conditions
UPDATE products 
SET price = price * 0.9 
WHERE category = 'Electronics' AND price > 100;

-- Exercise 4.4: Update multiple columns
UPDATE employees 
SET department = 'Sales', 
    salary = salary * 1.05 
WHERE employee_id = 101;

-- Exercise 4.5: Delete with WHERE
DELETE FROM orders 
WHERE status = 'Cancelled' AND order_date < '2026-01-01';

-- Exercise 4.6: Transaction example
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- If both succeed:
COMMIT;
-- If error occurs:
-- ROLLBACK;
```

#### Milestone Checkpoint
- [ ] Can insert, update, delete data
- [ ] Understands transaction control
- [ ] Knows the difference between TRUNCATE and DELETE
- [ ] Can recover from failed transactions

---

## Month 2: Intermediate SQL

> **Goal:** Master table relationships, aggregations, and subqueries

### Week 5: Table Design & Relationships

#### Topics Covered
- CREATE TABLE syntax
- Data types deep dive
- Constraints (NOT NULL, UNIQUE, CHECK, DEFAULT)
- Primary Keys and Foreign Keys
- ALTER TABLE (add, modify, drop columns)
- DROP TABLE

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | CREATE TABLE | Design first table |
| 2 | Data types | Choose appropriate types |
| 3 | Constraints | Add constraints to tables |
| 4 | Primary Key | Define and use PK |
| 5 | Foreign Key | Create relationships |
| 6 | ALTER TABLE | Modify table structure |
| 7 | **Review + Mini Quiz** | Design a small database |

#### Exercises

```sql
-- Exercise 5.1: Create complete table
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    hire_date DATE,
    salary DECIMAL(10,2) CHECK (salary > 0),
    department_id INTEGER,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Exercise 5.2: Add constraints to existing table
ALTER TABLE products 
ADD COLUMN sku TEXT UNIQUE;

-- Exercise 5.3: Create related tables
CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    budget DECIMAL(15,2)
);

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    department_id INTEGER,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Exercise 5.4: Modify table
ALTER TABLE employees ADD COLUMN phone TEXT;
ALTER TABLE employees DROP COLUMN phone;
ALTER TABLE employees MODIFY COLUMN name TEXT(100);
```

#### Milestone Checkpoint
- [ ] Can design normalized tables
- [ ] Understands and can apply constraints
- [ ] Can create Primary and Foreign Keys
- [ ] Can modify table structure

---

### Week 6: JOIN Operations

#### Topics Covered
- INNER JOIN
- LEFT (OUTER) JOIN
- RIGHT (OUTER) JOIN
- FULL OUTER JOIN
- CROSS JOIN
- Self JOIN
- Multiple JOINs in one query
- JOIN with filtering and sorting

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | INNER JOIN | Matched rows only |
| 2 | LEFT JOIN | All left + matched right |
| 3 | RIGHT JOIN | All right + matched left |
| 4 | FULL OUTER JOIN | All rows from both |
| 5 | Self JOIN | Table referencing itself |
| 6 | Multiple JOINs | Complex queries |
| 7 | **Review + Mini Quiz** | 10 JOIN challenges |

#### Exercises

```sql
-- Exercise 6.1: Basic INNER JOIN
SELECT orders.order_id, customers.customer_name, orders.total
FROM orders
INNER JOIN customers ON orders.customer_id = customers.id;

-- Exercise 6.2: LEFT JOIN
SELECT customers.customer_name, orders.order_id, orders.total
FROM customers
LEFT JOIN orders ON customers.id = orders.customer_id;

-- Exercise 6.3: Multiple JOINs
SELECT 
    o.order_id,
    c.customer_name,
    e.employee_name,
    o.total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN employees e ON o.employee_id = e.id
WHERE o.total > 100
ORDER BY o.total DESC;

-- Exercise 6.4: Self JOIN (employee-manager)
SELECT 
    e.employee_name AS Employee,
    m.employee_name AS Manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;

-- Exercise 6.5: LEFT JOIN with NULL check
SELECT 
    c.customer_name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.order_id IS NULL;  -- Customers who never ordered
```

#### Milestone Checkpoint
- [ ] Can write all types of JOINs
- [ ] Can chain multiple JOINs
- [ ] Understands when to use each JOIN type
- [ ] Can debug JOIN issues

---

### Week 7: Aggregation & GROUP BY

#### Topics Covered
- COUNT, SUM, AVG, MIN, MAX
- GROUP BY clause
- HAVING clause
- DISTINCT with aggregation
- Multiple aggregations
- Aggregating across relationships
- Date functions in aggregation

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | Basic aggregations | COUNT, SUM, AVG |
| 2 | MIN, MAX | Find extremes |
| 3 | GROUP BY | Group data |
| 4 | HAVING | Filter grouped data |
| 5 | Multiple groupings | Multi-level aggregation |
| 6 | Date aggregation | Group by time periods |
| 7 | **Review + Mini Quiz** | 10 aggregation challenges |

#### Exercises

```sql
-- Exercise 7.1: Basic aggregations
SELECT 
    COUNT(*) AS total_orders,
    SUM(total) AS total_revenue,
    AVG(total) AS average_order,
    MIN(total) AS smallest_order,
    MAX(total) AS largest_order
FROM orders;

-- Exercise 7.2: GROUP BY
SELECT 
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department;

-- Exercise 7.3: HAVING (filter after grouping)
SELECT 
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 5;

-- Exercise 7.4: Date aggregation
SELECT 
    strftime('%Y', order_date) AS year,
    strftime('%m', order_date) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
GROUP BY year, month
ORDER BY year, month;

-- Exercise 7.5: Complex aggregation with JOIN
SELECT 
    c.category_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM categories c
INNER JOIN products p ON c.id = p.category_id
INNER JOIN order_items oi ON p.id = oi.product_id
GROUP BY c.category_name
HAVING total_revenue > 10000
ORDER BY total_revenue DESC;
```

#### Milestone Checkpoint
- [ ] Can use all aggregate functions
- [ ] Understands GROUP BY vs WHERE
- [ ] Can filter with HAVING
- [ ] Can write complex aggregated queries

---

### Week 8: Subqueries

#### Topics Covered
- Subquery in WHERE
- Subquery in FROM (derived tables)
- Subquery in SELECT
- Correlated subqueries
- EXISTS and NOT EXISTS
- Common Table Expressions (CTE)
- Comparison with JOINs

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | Subquery basics | Query inside query |
| 2 | WHERE subqueries | Filter with subquery results |
| 3 | SELECT subqueries | Add calculated columns |
| 4 | FROM subqueries | Derived tables |
| 5 | Correlated subqueries | Row-dependent subqueries |
| 6 | CTE (WITH) | Simplify complex queries |
| 7 | **Review + Mini Quiz** | 10 subquery challenges |

#### Exercises

```sql
-- Exercise 8.1: Subquery in WHERE
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Exercise 8.2: Subquery with IN
SELECT customer_name
FROM customers
WHERE id IN (
    SELECT customer_id 
    FROM orders 
    WHERE total > 500
);

-- Exercise 8.3: Subquery in SELECT
SELECT 
    p.product_name,
    p.price,
    (SELECT COUNT(*) FROM order_items WHERE product_id = p.id) AS times_ordered
FROM products p;

-- Exercise 8.4: Derived table (subquery in FROM)
SELECT category_name, avg_price
FROM (
    SELECT 
        c.name AS category_name,
        AVG(p.price) AS avg_price
    FROM categories c
    INNER JOIN products p ON c.id = p.category_id
    GROUP BY c.name
) AS category_stats
WHERE avg_price > 50;

-- Exercise 8.5: Correlated subquery
SELECT 
    e.employee_name,
    e.salary,
    (SELECT AVG(salary) FROM employees WHERE department = e.department) AS dept_avg
FROM employees e;

-- Exercise 8.6: CTE (Common Table Expression)
WITH high_value_orders AS (
    SELECT customer_id, SUM(total) AS total_spent
    FROM orders
    GROUP BY customer_id
    HAVING SUM(total) > 1000
)
SELECT 
    c.customer_name,
    h.total_spent
FROM customers c
INNER JOIN high_value_orders h ON c.id = h.customer_id
ORDER BY h.total_spent DESC;
```

#### Milestone Checkpoint
- [ ] Can write subqueries in all clauses
- [ ] Understands correlated vs non-correlated subqueries
- [ ] Can rewrite subqueries as JOINs and vice versa
- [ ] Can use CTEs for readability

---

## Month 3: Advanced SQL

> **Goal:** Master advanced features, optimization, and real-world application

### Week 9: Advanced Filtering & CASE

#### Topics Covered
- CASE WHEN (conditional logic)
- COALESCE and NULL handling
- IIF function (SQL Server)
- DECODE function (Oracle)
- Complex conditional aggregation
- Pattern matching enhancements

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | CASE basics | Simple CASE expressions |
| 2 | CASE in WHERE | Conditional filtering |
| 3 | CASE in SELECT | Calculated columns |
| 4 | CASE with aggregation | Conditional sums |
| 5 | COALESCE/NVL | Handle NULLs |
| 6 | Complex CASE | Multi-condition logic |
| 7 | **Review + Mini Quiz** | 10 CASE challenges |

#### Exercises

```sql
-- Exercise 9.1: Basic CASE
SELECT 
    product_name,
    price,
    CASE 
        WHEN price < 50 THEN 'Budget'
        WHEN price BETWEEN 50 AND 100 THEN 'Mid-range'
        WHEN price > 100 THEN 'Premium'
    END AS price_category
FROM products;

-- Exercise 9.2: CASE with aggregation
SELECT 
    SUM(CASE WHEN status = 'Completed' THEN total ELSE 0 END) AS completed_revenue,
    SUM(CASE WHEN status = 'Pending' THEN total ELSE 0 END) AS pending_revenue,
    SUM(CASE WHEN status = 'Cancelled' THEN total ELSE 0 END) AS cancelled_revenue
FROM orders;

-- Exercise 9.3: COALESCE for NULL handling
SELECT 
    customer_name,
    COALESCE(phone, email, 'No contact') AS contact_info
FROM customers;

-- Exercise 9.4: Complex CASE with dates
SELECT 
    order_id,
    order_date,
    shipped_date,
    CASE 
        WHEN shipped_date IS NULL THEN 'Not Shipped'
        WHEN shipped_date <= order_date + 3 THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status
FROM orders;

-- Exercise 9.5: IIF (Access/SQL Server)
SELECT 
    product_name,
    IIF(stock > 0, 'In Stock', 'Out of Stock') AS availability
FROM products;
```

#### Milestone Checkpoint
- [ ] Can write CASE expressions in all clauses
- [ ] Understands conditional aggregation
- [ ] Can handle NULLs with COALESCE
- [ ] Can implement complex business logic

---

### Week 10: Views & Indexes

#### Topics Covered
- CREATE VIEW
- Modifying through VIEWs
- DROP VIEW
- Understanding indexes
- CREATE INDEX
- Composite indexes
- Index optimization
- When to use/not use indexes

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | Creating views | Virtual tables |
| 2 | Querying views | SELECT from views |
| 3 | Updating views | INSERT/UPDATE through views |
| 4 | Dropping views | Cleanup |
| 5 | Index basics | How indexes work |
| 6 | Creating indexes | Performance optimization |
| 7 | **Review + Mini Quiz** | View and index challenges |

#### Exercises

```sql
-- Exercise 10.1: Create simple view
CREATE VIEW active_customers AS
SELECT customer_name, email, phone
FROM customers
WHERE status = 'Active';

-- Exercise 10.2: Create complex view
CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total,
    (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) AS item_count
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;

-- Exercise 10.3: Query from view
SELECT * FROM order_summary WHERE total > 100;

-- Exercise 10.4: Create index
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);

-- Exercise 10.5: Composite index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Exercise 10.6: Index analysis
-- Check query plan (SQLite)
EXPLAIN QUERY PLAN SELECT * FROM orders WHERE customer_id = 1;
```

#### Milestone Checkpoint
- [ ] Can create and use views
- [ ] Understands view limitations
- [ ] Can create appropriate indexes
- [ ] Knows when indexes help and when they don't

---

### Week 11: Advanced JOINs & Set Operations

#### Topics Covered
- Multiple JOIN types in one query
- UNION, UNION ALL
- INTERSECT
- EXCEPT/MINUS
- CROSS JOIN applications
- Complex query building

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | Complex JOINs | Multiple table joins |
| 2 | UNION basics | Combine result sets |
| 3 | UNION ALL | Keep duplicates |
| 4 | INTERSECT | Common records |
| 5 | EXCEPT | Difference between sets |
| 6 | CROSS JOIN | Cartesian product |
| 7 | **Review + Mini Quiz** | 10 advanced query challenges |

#### Exercises

```sql
-- Exercise 11.1: Multiple JOINs
SELECT 
    a.account_name,
    b.balance,
    t.transaction_type,
    t.amount
FROM accounts a
INNER JOIN transactions t ON a.id = t.account_id
INNER JOIN transaction_types t ON t.id = t.type_id
WHERE t.transaction_date > '2026-01-01';

-- Exercise 11.2: UNION
SELECT customer_name, email FROM customers WHERE status = 'Active'
UNION
SELECT supplier_name, email FROM suppliers WHERE active = 1;

-- Exercise 11.3: UNION ALL (keeps duplicates)
SELECT category FROM products
UNION ALL
SELECT category FROM archived_products;

-- Exercise 11.4: INTERSECT - products in both stores
SELECT product_name FROM store_a
INTERSECT
SELECT product_name FROM store_b;

-- Exercise 11.5: EXCEPT - products only in store A
SELECT product_name FROM store_a
EXCEPT
SELECT product_name FROM store_b;

-- Exercise 11.6: CROSS JOIN (all combinations)
SELECT s.size, c.color FROM sizes s CROSS JOIN colors c;
```

#### Milestone Checkpoint
- [ ] Can combine multiple JOIN types
- [ ] Understands set operations
- [ ] Can use UNION/INTERSECT/EXCEPT
- [ ] Knows when to use CROSS JOIN

---

### Week 12: Performance & Best Practices

#### Topics Covered
- Query optimization principles
- EXPLAIN and query plans
- Index optimization
- Writing efficient WHERE clauses
- Avoiding N+1 queries
- SQL formatting conventions
- Security best practices
- SQL coding standards

#### Daily Breakdown

| Day | Topic | Exercise |
|-----|-------|----------|
| 1 | Query optimization | Reading EXPLAIN |
| 2 | Index optimization | Index design |
| 3 | Efficient WHERE | Avoid function on indexed columns |
| 4 | Query patterns | Common anti-patterns |
| 5 | SQL formatting | Readable SQL code |
| 6 | Security | SQL injection prevention |
| 7 | **Final Project** | Complete application |

#### Exercises

```sql
-- Exercise 12.1: EXPLAIN query plan
EXPLAIN QUERY PLAN 
SELECT * FROM orders WHERE customer_id = 1;

-- Exercise 12.2: Good vs Bad indexing
-- BAD: Function on column prevents index use
SELECT * FROM orders WHERE LOWER(email) = 'test@email.com';
-- GOOD: Direct comparison
SELECT * FROM orders WHERE email = 'test@email.com';

-- Exercise 12.3: Covering index
CREATE INDEX idx_products_covering ON products(category_id, price, product_name);

-- Exercise 12.4: Avoid SELECT *
-- BAD
SELECT * FROM orders WHERE order_id = 1;
-- GOOD
SELECT order_id, order_date, total FROM orders WHERE order_id = 1;

-- Exercise 12.5: SQL injection prevention
-- Use parameterized queries in application code
-- BAD (never do this in real apps):
-- "SELECT * FROM users WHERE name = '" + user_input + "'"
-- GOOD:
-- "SELECT * FROM users WHERE name = ?"
```

#### Milestone Checkpoint
- [ ] Can read and analyze query plans
- [ ] Understands optimization principles
- [ ] Follows SQL best practices
- [ ] Can write secure SQL code

---

## Weekly Schedule Overview

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries
├── Week 2: Filtering with WHERE
├── Week 3: Sorting & Limiting
└── Week 4: Data Manipulation (CRUD)

MONTH 2: INTERMEDIATE
├── Week 5: Table Design & Relationships
├── Week 6: JOIN Operations
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Project Milestones

### Project 1: Personal Budget Tracker (End of Week 4)
- Tables: accounts, categories, transactions
- Features: CRUD operations, basic reports

### Project 2: Mini E-Commerce Database (End of Week 8)
- Tables: customers, products, orders, order_items
- Features: JOINs, aggregations, revenue reports

### Project 3: Complete Inventory System (End of Week 12)
- Tables: All from Project 2 + suppliers, warehouses, employees
- Features: Complex queries, views, performance optimization

---

## Resources & References

### Documentation
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [W3Schools SQL Tutorial](https://www.w3schools.com/sql/)
- [SQLZoo](https://sqlzoo.net/)

### Practice Platforms
- [LeetCode SQL](https://leetcode.com/problemset/database/)
- [HackerRank SQL](https://www.hackerrank.com/domains/sql)
- [SQLFiddle](http://sqlfiddle.com/)

### Books (Optional)
- "SQL QuickStart Guide" - Walter Shields
- "Learning SQL" - Alan Beaulieu
- "SQL Performance Explained" - Markus Winand

---

## Progress Tracking

### Month 1 Completion Checklist
- [ ] Week 1 Quiz passed (score > 80%)
- [ ] Week 2 Quiz passed (score > 80%)
- [ ] Week 3 Quiz passed (score > 80%)
- [ ] Week 4 Quiz passed (score > 80%)
- [ ] Project 1 completed

### Month 2 Completion Checklist
- [ ] Week 5 Quiz passed (score > 80%)
- [ ] Week 6 Quiz passed (score > 80%)
- [ ] Week 7 Quiz passed (score > 80%)
- [ ] Week 8 Quiz passed (score > 80%)
- [ ] Project 2 completed

### Month 3 Completion Checklist
- [ ] Week 9 Quiz passed (score > 80%)
- [ ] Week 10 Quiz passed (score > 80%)
- [ ] Week 11 Quiz passed (score > 80%)
- [ ] Week 12 Quiz passed (score > 80%)
- [ ] Project 3 completed

---

## Tips for Success

1. **Practice Daily** - Even 30 minutes helps
2. **Don't Just Read** - Type and execute every example
3. **Solve Real Problems** - Apply concepts to your own data
4. **Ask Questions** - When stuck, seek help
5. **Review Weekly** - Recap what you learned
6. **Build Projects** - Apply knowledge in real scenarios
7. **Join Communities** - SQL learning groups

---

*Last Updated: Juni 2026*
*Created by: SQL Learning Assistant*
