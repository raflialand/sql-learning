# Week 2: Filtering with WHERE — Complete Plan

**Database:** `sql-learn-db.sql` (E-Commerce Learning Database)
**Tables:** `departments`, `employees`, `customers`, `categories`, `products`, `orders`, `order_items`
**Duration:** 7 days, 1-2 hours/day

---

## Database Schema Reference

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
```

---

## Sample Data Summary

**Departments:** Sales, Marketing, IT, HR

**Employees (8):** Alice Johnson, Bob Smith, Carol White, David Brown, Eve Davis, Frank Miller, Grace Lee, Henry Wilson

**Customers (8):** John Doe, Jane Smith, Mike Johnson, Sarah Brown, Tom Wilson, Lisa Garcia, Kevin Martinez, Amy Taylor

**Categories (5):** Electronics, Clothing, Books, Home & Garden, Sports

**Products (12):** Laptop ($999.99), Smartphone ($699.99), Headphones ($149.99), T-Shirt ($29.99), Jeans ($59.99), Jacket ($89.99), SQL Mastery ($49.99), Python Guide ($39.99), Garden Tools Set ($79.99), Running Shoes ($119.99), Basketball ($34.99), Yoga Mat ($24.99)

**Orders (12):** Mix of completed, pending, shipped, and cancelled statuses

---

## Day 1: WHERE Clause Fundamentals

**Concept:** Show only rows that match a condition

### What is WHERE?

The WHERE clause tells SQL to return only rows that meet a specific condition. Think of it like a filter on a spreadsheet or search results.

**Syntax:**
```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

### Examples

```sql
SELECT * FROM orders WHERE status = 'completed';
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 1 | 1 | 2024-01-15 | completed | 1049.98 |
| 2 | 2 | 2024-01-18 | completed | 749.98 |
| 3 | 3 | 2024-02-20 | completed | 89.98 |
| 4 | 1 | 2024-02-28 | completed | 149.99 |
| 7 | 2 | 2024-03-15 | completed | 49.99 |
| 9 | 7 | 2024-04-01 | completed | 198.97 |
| 11 | 3 | 2024-04-10 | completed | 59.99 |
| 12 | 5 | 2024-04-15 | completed | 154.98 |

```sql
SELECT * FROM products WHERE category_id = 1;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |
| 3 | Headphones | 1 | 149.99 | 200 |

```sql
SELECT * FROM employees WHERE department_id = 3;
```
**Output:**
| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 4 | David Brown | david@company.com | 3 | 2020-11-05 | 7000 |
| 6 | Frank Miller | frank@company.com | 3 | 2021-02-14 | 6500 |

### Practice Exercises

1. Find all orders with status 'shipped'
2. Find all products in category 2 (Clothing)
3. Find all employees in department 1 (Sales)

---

## Day 2: Comparison Operators

**Concept:** Compare values using mathematical symbols

### What are Comparison Operators?

Symbols that compare two values, just like in basic math. They always return TRUE or FALSE.

### Operator Reference

| Operator | Meaning |
|----------|---------|
| `=` | equals |
| `<>` or `!=` | not equals |
| `>` | greater than |
| `<` | less than |
| `>=` | greater than or equal |
| `<=` | less than or equal |

### Examples

```sql
SELECT * FROM products WHERE price > 100;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |
| 3 | Headphones | 1 | 149.99 | 200 |
| 5 | Jeans | 2 | 59.99 | 300 |
| 6 | Jacket | 2 | 89.99 | 150 |
| 9 | Garden Tools Set | 4 | 79.99 | 40 |
| 10 | Running Shoes | 5 | 119.99 | 75 |

```sql
SELECT * FROM employees WHERE salary < 5000;
```
**Output:**
| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 2 | Bob Smith | bob@company.com | 1 | 2021-06-20 | 4800 |
| 5 | Eve Davis | eve@company.com | 4 | 2022-08-30 | 4500 |
| 7 | Grace Lee | grace@company.com | 2 | 2023-01-20 | 4900 |

```sql
SELECT * FROM employees WHERE salary >= 5500;
```
**Output:**
| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 1 | Alice Johnson | alice@company.com | 1 | 2022-01-15 | 5500 |
| 4 | David Brown | david@company.com | 3 | 2020-11-05 | 7000 |
| 6 | Frank Miller | frank@company.com | 3 | 2021-02-14 | 6500 |

```sql
SELECT * FROM orders WHERE status <> 'cancelled';
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 1 | 1 | 2024-01-15 | completed | 1049.98 |
| 2 | 2 | 2024-01-18 | completed | 749.98 |
| 3 | 3 | 2024-02-20 | completed | 89.98 |
| 4 | 1 | 2024-02-28 | completed | 149.99 |
| 5 | 4 | 2024-03-05 | pending | 999.99 |
| 6 | 5 | 2024-03-10 | shipped | 179.98 |
| 7 | 2 | 2024-03-15 | completed | 49.99 |
| 9 | 7 | 2024-04-01 | completed | 198.97 |
| 10 | 8 | 2024-04-05 | shipped | 89.98 |
| 11 | 3 | 2024-04-10 | completed | 59.99 |
| 12 | 5 | 2024-04-15 | completed | 154.98 |

### Practice Exercises

1. Find products with stock less than 100
2. Find employees hired before 2022 (hire_date < '2022-01-01')
3. Find orders with total greater than or equal to 500
4. Find products priced exactly $29.99

---

## Day 3: Logical Operators (AND, OR, NOT)

**Concept:** Combine multiple conditions

### What are Logical Operators?

Words/symbols that connect conditions. They let you create more specific filters.

### AND Operator

Both conditions must be TRUE.

```sql
SELECT * FROM orders WHERE status = 'completed' AND total > 500;
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 1 | 1 | 2024-01-15 | completed | 1049.98 |
| 2 | 2 | 2024-01-18 | completed | 749.98 |

### OR Operator

At least one condition must be TRUE.

```sql
SELECT * FROM products WHERE category_id = 1 OR category_id = 2;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |
| 3 | Headphones | 1 | 149.99 | 200 |
| 4 | T-Shirt | 2 | 29.99 | 500 |
| 5 | Jeans | 2 | 59.99 | 300 |
| 6 | Jacket | 2 | 89.99 | 150 |

### NOT Operator

Reverses the condition (TRUE becomes FALSE, FALSE becomes TRUE).

```sql
SELECT * FROM products WHERE NOT category_id = 1;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 4 | T-Shirt | 2 | 29.99 | 500 |
| 5 | Jeans | 2 | 59.99 | 300 |
| 6 | Jacket | 2 | 89.99 | 150 |
| 7 | SQL Mastery | 3 | 49.99 | 80 |
| 8 | Python Guide | 3 | 39.99 | 120 |
| 9 | Garden Tools Set | 4 | 79.99 | 40 |
| 10 | Running Shoes | 5 | 119.99 | 75 |
| 11 | Basketball | 5 | 34.99 | 200 |
| 12 | Yoga Mat | 5 | 24.99 | 150 |

### Combining Operators

You can mix AND, OR, and NOT. Use parentheses to be explicit.

```sql
SELECT * FROM orders WHERE status = 'completed' AND total >= 100 AND total <= 500;
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 4 | 1 | 2024-02-28 | completed | 149.99 |
| 9 | 7 | 2024-04-01 | completed | 198.97 |
| 12 | 5 | 2024-04-15 | completed | 154.98 |

### Operator Precedence

SQL processes operators in this order: **NOT → AND → OR**

```sql
-- Without parentheses, this might surprise you:
SELECT * FROM orders WHERE status = 'completed' OR total > 100 AND total < 200;

-- Safer with parentheses:
SELECT * FROM orders WHERE status = 'completed' OR (total > 100 AND total < 200);
```

### Practice Exercises

1. Find completed orders over $100
2. Find products in category 1 OR category 3
3. Find products NOT in category 2
4. Find orders that are either pending AND over $500, or cancelled

---

## Day 4: IN Operator

**Concept:** Match any value in a list

### What is IN?

A cleaner way to check if a value matches ANY value in a list. It's shorthand for multiple OR conditions.

### IN vs OR

The long way with OR:
```sql
SELECT * FROM customers WHERE city = 'New York' OR city = 'Los Angeles' OR city = 'Chicago';
```

The short way with IN:
```sql
SELECT * FROM customers WHERE city IN ('New York', 'Los Angeles', 'Chicago');
```

Both return the same result, but IN is easier to read and type.

### Examples

```sql
SELECT * FROM customers WHERE city IN ('New York', 'Los Angeles', 'Chicago');
```
**Output:**
| id | name | email | city | join_date |
|----|------|-------|------|-----------|
| 1 | John Doe | john.doe@email.com | New York | 2023-01-10 |
| 2 | Jane Smith | jane.smith@email.com | Los Angeles | 2023-02-15 |
| 3 | Mike Johnson | mike.j@email.com | Chicago | 2023-03-20 |
| 4 | Sarah Brown | sarah.b@email.com | New York | 2023-04-05 |
| 7 | Kevin Martinez | kevin.m@email.com | Chicago | 2023-07-22 |
| 8 | Amy Taylor | amy.t@email.com | Los Angeles | 2023-08-30 |

```sql
SELECT * FROM products WHERE category_id IN (1, 3, 5);
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |
| 3 | Headphones | 1 | 149.99 | 200 |
| 7 | SQL Mastery | 3 | 49.99 | 80 |
| 8 | Python Guide | 3 | 39.99 | 120 |
| 10 | Running Shoes | 5 | 119.99 | 75 |
| 11 | Basketball | 5 | 34.99 | 200 |
| 12 | Yoga Mat | 5 | 24.99 | 150 |

```sql
SELECT * FROM employees WHERE department_id IN (1, 2);
```
**Output:**
| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 1 | Alice Johnson | alice@company.com | 1 | 2022-01-15 | 5500 |
| 2 | Bob Smith | bob@company.com | 1 | 2021-06-20 | 4800 |
| 3 | Carol White | carol@company.com | 2 | 2023-03-10 | 5200 |
| 7 | Grace Lee | grace@company.com | 2 | 2023-01-20 | 4900 |
| 8 | Henry Wilson | henry@company.com | 1 | 2022-07-08 | 5100 |

### Practice Exercises

1. Find customers from cities 'Phoenix' or 'Houston'
2. Find products with category_id 1, 2, or 4
3. Find orders with status 'pending', 'shipped', or 'cancelled'
4. Find employees in departments 3 or 4

---

## Day 5: BETWEEN Operator

**Concept:** Match values within a range

### What is BETWEEN?

A convenient way to filter for values within a range. The range is always inclusive (includes both endpoints).

```sql
price BETWEEN 50 AND 200
-- is equivalent to:
price >= 50 AND price <= 200
```

### Examples

```sql
SELECT * FROM products WHERE price BETWEEN 50 AND 150;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 3 | Headphones | 1 | 149.99 | 200 |
| 5 | Jeans | 2 | 59.99 | 300 |
| 6 | Jacket | 2 | 89.99 | 150 |
| 9 | Garden Tools Set | 4 | 79.99 | 40 |
| 10 | Running Shoes | 5 | 119.99 | 75 |

```sql
SELECT * FROM orders WHERE total BETWEEN 100 AND 500;
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 4 | 1 | 2024-02-28 | completed | 149.99 |
| 6 | 5 | 2024-03-10 | shipped | 179.98 |
| 9 | 7 | 2024-04-01 | completed | 198.97 |
| 12 | 5 | 2024-04-15 | completed | 154.98 |

```sql
SELECT * FROM employees WHERE hire_date BETWEEN '2022-01-01' AND '2022-12-31';
```
**Output:**
| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 1 | Alice Johnson | alice@company.com | 1 | 2022-01-15 | 5500 |
| 5 | Eve Davis | eve@company.com | 4 | 2022-08-30 | 4500 |
| 8 | Henry Wilson | henry@company.com | 1 | 2022-07-08 | 5100 |

### BETWEEN with NOT

```sql
SELECT * FROM products WHERE price NOT BETWEEN 30 AND 100;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |
| 3 | Headphones | 1 | 149.99 | 200 |
| 10 | Running Shoes | 5 | 119.99 | 75 |

### Practice Exercises

1. Find products with stock between 100 and 300
2. Find employees with salary between 4000 and 6000
3. Find orders placed in January 2024 (between '2024-01-01' and '2024-01-31')
4. Find products NOT priced between $50 and $100

---

## Day 6: LIKE Pattern Matching

**Concept:** Match text against patterns

### What is LIKE?

Used for searching text when you don't know the exact value. Uses wildcards to match patterns.

### Wildcards

| Wildcard | Meaning |
|----------|---------|
| `%` | Any characters (zero or more) |
| `_` | Exactly one character |

### Common Patterns

| Pattern | Matches |
|---------|---------|
| `'A%'` | Starts with A (Apple, Avocado, A) |
| `'%A'` | Ends with A (Pizza, Honda, A) |
| `'%A%'` | Contains A anywhere (Banana, Apple, A) |
| `'_o%'` | Second character is o (Bob, Dog, Office) |
| `'%oo%'` | Contains "oo" anywhere (Book, Wood, Good) |

### Examples

```sql
SELECT * FROM products WHERE name LIKE 'S%';
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 2 | Smartphone | 1 | 699.99 | 100 |
| 7 | SQL Mastery | 3 | 49.99 | 80 |
| 10 | Running Shoes | 5 | 119.99 | 75 |

```sql
SELECT * FROM products WHERE name LIKE '%oo%';
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 10 | Running Shoes | 5 | 119.99 | 75 |
| 11 | Basketball | 5 | 34.99 | 200 |

```sql
SELECT * FROM employees WHERE name LIKE '_o%';
```
**Output:**
| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 2 | Bob Smith | bob@company.com | 1 | 2021-06-20 | 4800 |
| 8 | Henry Wilson | henry@company.com | 1 | 2022-07-08 | 5100 |

```sql
SELECT * FROM products WHERE name LIKE '%Guide';
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 8 | Python Guide | 3 | 39.99 | 120 |

```sql
SELECT * FROM customers WHERE email LIKE '%@%';
```
**Output:**
| id | name | email | city | join_date |
|----|------|-------|------|-----------|
| 1 | John Doe | john.doe@email.com | New York | 2023-01-10 |
| 2 | Jane Smith | jane.smith@email.com | Los Angeles | 2023-02-15 |
| 3 | Mike Johnson | mike.j@email.com | Chicago | 2023-03-20 |
| 4 | Sarah Brown | sarah.b@email.com | New York | 2023-04-05 |
| 5 | Tom Wilson | tom.w@email.com | Houston | 2023-05-12 |
| 6 | Lisa Garcia | lisa.g@email.com | Phoenix | 2023-06-18 |
| 7 | Kevin Martinez | kevin.m@email.com | Chicago | 2023-07-22 |
| 8 | Amy Taylor | amy.t@email.com | Los Angeles | 2023-08-30 |

### Practice Exercises

1. Find products starting with 'G'
2. Find customers whose name starts with 'J'
3. Find products containing 'Mat' (like Yoga Mat)
4. Find employees whose name has 'e' as the second letter
5. Find products ending with 'Set'

---

## Day 7: IS NULL / IS NOT NULL + Mini Quiz

### Understanding NULL

NULL represents missing or unknown data. It's not:
- Not zero (0)
- Not an empty string ('')
- Not the word "NULL"

**Important:** You cannot use `= NULL` to check for NULL. You must use `IS NULL` or `IS NOT NULL`.

### Examples

```sql
-- Find missing emails (would return rows if any NULL emails existed)
SELECT * FROM customers WHERE email IS NULL;

-- Find customers who have provided email
SELECT * FROM customers WHERE email IS NOT NULL;
```

Since this database has no NULL values in any column, these queries would return empty results.

### Why Special Operators?

Think of it this way: if you asked 100 people "What is your favorite movie?" and 30 people didn't answer, those 30 have NULL responses. You can't say their NULL answer equals another person's NULL answer - each person simply didn't provide an answer for a different reason.

---

## Mini Quiz (10 Questions)

### Q1: Find all pending orders

```sql
SELECT * FROM orders WHERE status = 'pending';
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 5 | 4 | 2024-03-05 | pending | 999.99 |

---

### Q2: Find products priced over $500

```sql
SELECT * FROM products WHERE price > 500;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |

---

### Q3: Find completed orders under $100

```sql
SELECT * FROM orders WHERE status = 'completed' AND total < 100;
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 3 | 3 | 2024-02-20 | completed | 89.98 |
| 7 | 2 | 2024-03-15 | completed | 49.99 |
| 11 | 3 | 2024-04-10 | completed | 59.99 |

---

### Q4: Find customers from New York, Los Angeles, or Chicago

```sql
SELECT * FROM customers WHERE city IN ('New York', 'Los Angeles', 'Chicago');
```
**Output:**
| id | name | email | city | join_date |
|----|------|-------|------|-----------|
| 1 | John Doe | john.doe@email.com | New York | 2023-01-10 |
| 2 | Jane Smith | jane.smith@email.com | Los Angeles | 2023-02-15 |
| 3 | Mike Johnson | mike.j@email.com | Chicago | 2023-03-20 |
| 4 | Sarah Brown | sarah.b@email.com | New York | 2023-04-05 |
| 7 | Kevin Martinez | kevin.m@email.com | Chicago | 2023-07-22 |
| 8 | Amy Taylor | amy.t@email.com | Los Angeles | 2023-08-30 |

---

### Q5: Find products priced between $30 and $100

```sql
SELECT * FROM products WHERE price BETWEEN 30 AND 100;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 3 | Headphones | 1 | 149.99 | 200 |
| 4 | T-Shirt | 2 | 29.99 | 500 |
| 5 | Jeans | 2 | 59.99 | 300 |
| 6 | Jacket | 2 | 89.99 | 150 |
| 7 | SQL Mastery | 3 | 49.99 | 80 |
| 8 | Python Guide | 3 | 39.99 | 120 |
| 9 | Garden Tools Set | 4 | 79.99 | 40 |
| 10 | Running Shoes | 5 | 119.99 | 75 |
| 11 | Basketball | 5 | 34.99 | 200 |

---

### Q6: Find products whose name starts with 'G'

```sql
SELECT * FROM products WHERE name LIKE 'G%';
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 9 | Garden Tools Set | 4 | 79.99 | 40 |

---

### Q7: Find employees NOT in the IT department (department_id = 3)

```sql
SELECT * FROM employees WHERE department_id <> 3;
```
**Output:**
| id | name | email | department_id | hire_date | salary |
|----|------|-------|---------------|-----------|--------|
| 1 | Alice Johnson | alice@company.com | 1 | 2022-01-15 | 5500 |
| 2 | Bob Smith | bob@company.com | 1 | 2021-06-20 | 4800 |
| 3 | Carol White | carol@company.com | 2 | 2023-03-10 | 5200 |
| 5 | Eve Davis | eve@company.com | 4 | 2022-08-30 | 4500 |
| 7 | Grace Lee | grace@company.com | 2 | 2023-01-20 | 4900 |
| 8 | Henry Wilson | henry@company.com | 1 | 2022-07-08 | 5100 |

---

### Q8: Find orders with totals between $100 and $300

```sql
SELECT * FROM orders WHERE total BETWEEN 100 AND 300;
```
**Output:**
| id | customer_id | order_date | status | total |
|----|-------------|------------|--------|-------|
| 4 | 1 | 2024-02-28 | completed | 149.99 |
| 6 | 5 | 2024-03-10 | shipped | 179.98 |
| 9 | 7 | 2024-04-01 | completed | 198.97 |
| 12 | 5 | 2024-04-15 | completed | 154.98 |

---

### Q9: Find products containing 'oo' in the name

```sql
SELECT * FROM products WHERE name LIKE '%oo%';
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 10 | Running Shoes | 5 | 119.99 | 75 |
| 11 | Basketball | 5 | 34.99 | 200 |

---

### Q10: Find Electronics products (category 1) priced over $200

```sql
SELECT * FROM products WHERE category_id = 1 AND price > 200;
```
**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |

---

## Quick Reference Card

| Operator | Use When | Example |
|----------|----------|---------|
| `=` | Exact match | `city = 'Japan'` |
| `<>` or `!=` | Not equal | `status <> 'Cancelled'` |
| `>` `<` `>=` `<=` | Number comparisons | `price > 100` |
| AND | All conditions must be true | `price > 50 AND stock > 0` |
| OR | Any condition can be true | `city = 'A' OR city = 'B'` |
| NOT | Reverses the condition | `NOT category = 1` |
| IN | Matches list of values | `country IN ('USA','UK','FR')` |
| BETWEEN | Within a range | `price BETWEEN 50 AND 100` |
| LIKE | Pattern matching | `name LIKE 'A%'` |
| IS NULL | Value is missing | `phone IS NULL` |
| IS NOT NULL | Value exists | `phone IS NOT NULL` |

---

## Milestone Checklist (End of Week 2)

- [ ] Can filter data using WHERE
- [ ] Can combine multiple conditions with AND/OR/NOT
- [ ] Can use IN, BETWEEN, LIKE effectively
- [ ] Can handle NULL values with IS NULL / IS NOT NULL

---

## Week 2 Summary

**Topics Covered:**
- WHERE clause fundamentals
- Comparison operators (=, <>, <, >, <=, >=)
- Logical operators (AND, OR, NOT)
- IN operator for multiple values
- BETWEEN operator for ranges
- LIKE operator for pattern matching
- IS NULL and IS NOT NULL

**Goal:** Pass Week 2 quiz with score > 80%

---

*Week 2 of 12 — Part of the 3-Month SQL Learning Roadmap*
