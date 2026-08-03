# Summary: SQL Learning Session

**Date:** 17 June 2026
**Database:** sql-learn.db (SQLite)

---

## 1. Database Structure

We explored an **E-Commerce database** with 7 tables:

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `departments` | Company departments | id, name, budget |
| `employees` | Staff information | id, name, department_id FK, salary |
| `customers` | Customer data | id, name, email, city |
| `categories` | Product categories | id, name |
| `products` | Product catalog | id, name, category_id FK, price, stock |
| `orders` | Customer orders | id, customer_id FK, order_date, status |
| `order_items` | Order line items | id, order_id FK, product_id FK, quantity |

---

## 2. Relationships (ERD)

```
departments (1) ─────< employees (N)
customers (1) ─────< orders (N)
orders (1) ─────< order_items (N)
order_items (N) >──── products (1)
products (N) >──── categories (1)
```

**Key Relationships:**
- **1:N** - One department has many employees
- **1:N** - One customer places many orders
- **1:N** - One order contains many items
- **N:1** - Each item references one product
- **N:1** - Each product belongs to one category

---

## 3. File Types: `.sql` vs `.db`

| File | Type | Description |
|------|------|-------------|
| `sql-learn-db.sql` | Text/SQL Script | CREATE TABLE + INSERT statements (source code) |
| `sql-learn.db` | Binary/SQLite Database | Actual database with data |

The `.sql` file is the **recipe**, the `.db` file is the **dish**.

---

## 4. How to Query Multiple Tables

### CROSS JOIN
```sql
SELECT * FROM customers, employees;
-- Returns ALL combinations (not practical)
```

### INNER JOIN (Recommended)
```sql
SELECT c.name, o.order_date, o.total
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;
```

### UNION (Combine Results)
```sql
SELECT name, email FROM customers
UNION
SELECT name, email FROM employees;
```

---

## 5. Querying the Same Table Multiple Times

When you want to select from 2 tables without a direct relationship:

**Option 1:** Use UNION (no relationship needed)
```sql
SELECT name, email FROM customers
UNION
SELECT name, email FROM employees;
```

**Option 2:** Use INNER JOIN (requires relationship)
```sql
SELECT c.name, o.order_date
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;
```

---

## 6. Folder Organization

```
SQL-DUMMY/
├── databases/       # Database files (.db, .sql)
├── docs/            # Documentation (ERD, guides)
├── exercises/       # Practice SQL files
├── notes/           # Learning summaries
└── roadmaps/        # Learning plans
```

**Note:** Keep `.sql` and `.db` files in `databases/` folder. The `.sql` file is the backup/source of the `.db`.

---

## 7. Week 1 Learning Progress

### Completed Days:
- **Day 1:** Database Concepts (RDBMS vs NoSQL)
- **Day 2:** SELECT Basics (`SELECT * FROM table`)
- **Day 3:** Column Selection (`SELECT col1, col2 FROM table`)
- **Day 4:** Aliases (`SELECT col AS 'Name' FROM table`)
- **Day 5:** Arithmetic in SQL
- **Day 6:** DISTINCT - Remove duplicate values

### Day 6: DISTINCT (LEARNED)

**What is DISTINCT?**
- Removes duplicate values from query results
- Shows only unique values

**Syntax:**
```sql
SELECT DISTINCT column_name FROM table_name;
```

**DISTINCT with Single Column:**
```sql
SELECT DISTINCT city FROM customers;
-- Hasil: New York, Los Angeles, Chicago, Houston, Phoenix (5 kota unik)
```

**DISTINCT with Multiple Columns:**
```sql
SELECT DISTINCT department_id, status FROM employees;
-- Hasil: kombinasi unik dari kedua kolom
```

**Important Notes:**
- DISTINCT with multiple columns = unique **combinations** of those columns
- If all values in selected columns are unique, DISTINCT has no effect
- JOIN is NOT part of DISTINCT - JOIN is for Week 2+ (combining tables)

**Examples from sql-learn-db.sql:**
```sql
-- Cek kota unik pelanggan
SELECT DISTINCT city FROM customers;

-- Cek status order unik
SELECT DISTINCT status FROM orders;

-- Cek departemen unik
SELECT DISTINCT department_id FROM employees;
```

### Day 5: Arithmetic in SQL (PRACTICED)

**Operators:**
| Operator | Operation |
|----------|-----------|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |

**Order of Operations:**
1. `()` parentheses
2. `*` `/` multiplication/division
3. `+` `-` addition/subtraction

**Practiced Queries:**

1. Total inventori:
```sql
SELECT name, price, stock, price * stock AS 'Total Inventory Value'
FROM products;
```

2. Gaji tahunan:
```sql
SELECT name, salary, salary * 12 AS 'Annual Salary'
FROM employees;
```

3. Subtotal order items:
```sql
SELECT order_id, product_id, quantity, price,
       quantity * price AS 'Subtotal'
FROM order_items;
```

4. Bonus employee:
```sql
SELECT name, salary, salary * 0.10 AS 'Bonus',
       salary + (salary * 0.10) AS 'Total With Bonus'
FROM employees;
```

5. Diskon produk:
```sql
SELECT name, price, price * 0.85 AS 'After 15% Discount'
FROM products;
```

---

## 8. Key Takeaways

1. **Always check schema first** with `.tables` and `.schema` commands
2. **Understand relationships** before writing JOINs
3. **CROSS JOIN** = all combinations (avoid unless needed)
4. **INNER JOIN** = only matching rows
5. **UNION** = combine similar data from different tables
6. **Foreign Keys** connect tables: `department_id` → `departments(id)`
7. **Arithmetic** can be combined with aliases for readable output

---

## Next Steps

1. **Day 7:** Review & Mini Quiz
2. Practice **Week 1** concepts: SELECT, Aliases, Arithmetic, DISTINCT
3. Move to **Week 2: Filtering with WHERE** after completing Week 1
4. **JOINs** will be covered in Week 2 or later (not in Week 1)
5. Progress through: Order By → Limit → Aggregate → Group By → Subqueries
6. Review `exercises/` folder for practice problems

---

*Happy Learning!*
