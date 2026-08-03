# Summary: SQL Learning Session

**Date:** 30 June 2026
**Database:** sql-learn-db-week6.db
**Status:** Week 6 Day 3 Complete - RIGHT JOIN & Multiple JOINs

---

## Week 5 Day 7: Quiz Completed

### Quiz Results - PERFECT 10/10!

| Question | Topic | Result |
|----------|-------|--------|
| Q1 | CREATE TABLE suppliers | ✅ |
| Q2 | product price data type (REAL) | ✅ |
| Q3 | ratings table with CHECK constraint | ✅ |
| Q4 | ALTER TABLE orders FK to customers | ✅ |
| Q5 | PRIMARY KEY rules | ✅ |
| Q6 | ALTER TABLE ADD phone column | ✅ |
| Q7 | product_reviews table | ✅ |
| Q8 | DEFAULT CURRENT_TIMESTAMP | ✅ |
| Q9 | shipments table with FKs | ✅ |
| Q10 | Why use foreign keys | ✅ |

---

## Key Corrections Learned

1. **Q4 - SQLite ALTER TABLE with FK:**
   ```sql
   ALTER TABLE orders ADD COLUMN customer_id INTEGER REFERENCES customers(id);
   ```

2. **Q3 - CHECK constraint in CREATE TABLE** (not separate ALTER)

3. **Q8 - CURRENT_TIMESTAMP:** Auto-fills current date+time when row is INSERTed

---

## Week 5 Complete!

**Topics Mastered:**
- Day 1: CREATE TABLE
- Day 2: Data Types (INTEGER, REAL, TEXT, BLOB)
- Day 3: Constraints (NOT NULL, UNIQUE, CHECK, DEFAULT)
- Day 4: Primary Key
- Day 5: Foreign Key + PRAGMA foreign_keys = ON
- Day 6: ALTER TABLE (ADD, RENAME, DROP)
- Day 7: Quiz ✅

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
└── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations 🔄 Day 1/7
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Next Steps

1. ~~Week 5 Quiz~~ ✅ DONE (10/10!)
2. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
3. **Week 6 Day 2: LEFT JOIN** - Next session
   - LEFT JOIN - All left + matched right
   - Finding NULLs (rows with no match)
   - LEFT JOIN with aggregation

---

*Rest well! Week 6 Day 2 awaits you! 🎉*

---

## Week 6 Day 1: INNER JOIN - Completed

### Concepts Learned

1. **INNER JOIN Syntax**
   - Combines rows from two tables based on matching column
   - Only returns rows with matches in BOTH tables

2. **Table Aliases**
   - `FROM orders o` - "o" is alias for orders table
   - `INNER JOIN customers c` - "c" is alias for customers table
   - Shorthand for writing queries

3. **ON Clause**
   - Specifies how tables are related
   - `ON o.customer_id = c.id` means match orders.customer_id with customers.id

4. **WHERE vs AND in JOIN**
   - WHERE: Filter AFTER join (recommended for readability)
   - AND in ON: Filter DURING join (needed for LEFT JOIN right-table filters)
   - For INNER JOIN: Both work, WHERE is cleaner

5. **Why `oi.price` not `p.price`?**
   - `oi.price` stores price at time of purchase (historical accuracy)
   - `p.price` is current catalog price (may change)

### Exercises Completed (4/4)

| # | Description | Status |
|---|-------------|--------|
| 1 | Orders with 'completed' status + customer name | ✅ |
| 2 | Products in 'Electronics' category via JOIN | ✅ |
| 3 | Employees in 'Sales' department with hire dates | ✅ |
| 4 | Order items for order_id = 6 | ✅ |

### Example Queries Practiced

```sql
-- INNER JOIN: Orders with customer names
SELECT o.id, c.name AS customer_name, o.total, o.status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed';

-- INNER JOIN with filter in ON clause
SELECT p.id, p.name AS Product, c.name AS Category
FROM categories c
INNER JOIN products p ON p.category_id = c.id AND c.name = 'Electronics';

-- Order items with product details
SELECT p.name AS product, oi.quantity, oi.price
FROM products p
INNER JOIN order_items oi ON oi.product_id = p.id
WHERE oi.order_id = 6;
```

### Key Takeaways

1. INNER JOIN returns only matching rows from BOTH tables
2. Table aliases (`o`, `c`, `p`) make queries shorter and cleaner
3. ON clause defines relationships; WHERE defines filters
4. Use WHERE for filtering (cleaner), AND in ON only when LEFT JOIN requires it
5. `oi.price` (transaction price) vs `p.price` (current price) - historical accuracy matters

---

*Week 6 Day 1 Complete! Rest well! 🎉*

---

## Week 6 Day 2: LEFT JOIN - Completed

### Concepts Learned

1. **LEFT JOIN Core Concept**
   - Returns ALL rows from LEFT table, matched rows from RIGHT
   - NULL values for RIGHT columns when no match exists
   - FROM table = base (always appears), LEFT JOIN = append data

2. **LEFT JOIN vs INNER JOIN**
   - INNER JOIN: Only rows with matches in BOTH tables
   - LEFT JOIN: ALL left rows, matched right or NULL

3. **Order of Columns in SELECT**
   - Does NOT affect results
   - Only affects output format/display
   - Can mix columns from any table freely

4. **Which Table Goes Where**
   - FROM = master/primary table (all rows must appear)
   - LEFT JOIN = optional data (may be NULL)

5. **Finding Non-Matching Rows**
   - Add `WHERE right_table.column IS NULL`
   - Finds LEFT rows with no match in RIGHT

6. **RIGHT JOIN is Unnecessary**
   - Can always swap table positions and use LEFT JOIN
   - RIGHT JOIN exists only for convenience/legacy

7. **LEFT JOIN with Aggregation**
   - `COUNT(column)` ignores NULLs
   - `SUM()` returns NULL if all rows are NULL
   - Use `COALESCE(SUM(), 0)` to handle NULL sums

### SQL Aggregate Functions Review

| Function | Description |
|----------|-------------|
| COUNT() | Count rows |
| SUM() | Sum values |
| AVG() | Average value |
| MIN() | Minimum value |
| MAX() | Maximum value |

### Exercises Completed (5/5)

| # | Description | Status |
|---|-------------|--------|
| 1 | Count orders per customer (including 0) | ✅ |
| 2 | Products with reviews (including NULL) | ✅ |
| 3 | Customers with NO orders (WHERE IS NULL) | ✅ Initially missed WHERE clause |
| 4 | Employees per department | ✅ |
| 5 | Promotions used in orders | ✅ |

### Example Queries Practiced

```sql
-- Count orders per customer (including 0)
SELECT c.id, c.name, COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name;

-- Customers with NO orders
SELECT c.id, c.name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL;

-- Employees per department
SELECT d.id, d.name, COUNT(e.department_id) AS total_member
FROM departments d
LEFT JOIN employees e ON e.department_id = d.id
GROUP BY d.id, d.name;

-- COUNT vs COUNT(*) with LEFT JOIN
COUNT(column)  -- Ignores NULLs
COUNT(*)       -- Counts all rows including NULLs
```

### Key Takeaways

1. LEFT JOIN = ALL left rows + matched right or NULL
2. Position matters: FROM = base, LEFT JOIN = optional
3. Column order in SELECT doesn't affect query results
4. RIGHT JOIN is redundant (swap tables + use LEFT JOIN)
5. To find non-matching rows: `WHERE column IS NULL`
6. COUNT(column) ignores NULLs, COUNT(*) includes them
7. SUM with potential NULLs: use `COALESCE(SUM(), 0)`

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
├── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations 🔄 Day 2/7 COMPLETE ✅
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Next Steps

1. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
2. ~~Week 6 Day 2: LEFT JOIN~~ ✅ DONE
3. **Week 6 Day 3: RIGHT JOIN** - Next session
   - RIGHT JOIN (all right + matched left)
   - Converting RIGHT to LEFT JOIN
   - When RIGHT JOIN might be useful

---

*Week 6 Day 2 Complete! Great progress! 🎉*

---

## Week 6 Day 3: RIGHT JOIN & Multiple Table JOINs - Completed

### Concepts Learned

1. **RIGHT JOIN Core Concept**
   - Returns ALL rows from RIGHT table, matched LEFT or NULL
   - Opposite of LEFT JOIN
   - Rarely needed since LEFT JOIN can always substitute

2. **RIGHT JOIN vs LEFT JOIN**
   - RIGHT JOIN: All RIGHT rows, NULL on unmatched LEFT
   - LEFT JOIN: All LEFT rows, NULL on unmatched RIGHT
   - Just swap table positions to convert

3. **Multiple Table JOINs**
   - Chain JOINs together: `FROM t1 JOIN t2 ON ... JOIN t3 ON ... JOIN t4 ON ...`
   - Each JOIN builds on the previous result
   - Use table aliases (t1, t2, t3) for readability

4. **JOIN Direction Matters**
   - `FROM orders LEFT JOIN shipments` = all orders appear
   - `FROM shipments LEFT JOIN orders` = all shipments appear
   - The base table (FROM) determines what appears

### Exercises Completed (5/5)

| # | Description | Status |
|---|-------------|--------|
| 1 | Orders without shipments (LEFT JOIN + IS NULL) | ✅ |
| 2 | Products with average rating (GROUP BY required) | ✅ |
| 3 | Customers with unredeemed gift cards | ✅ |
| 4 | Products reviewed but never ordered | ✅ Fixed JOIN to order_items |
| 5 | All promotions with orders (corrected LEFT JOIN direction) | ✅ |

### Common Errors Fixed

1. **Exercise 1:** Used INNER JOIN instead of LEFT JOIN for finding non-matches
2. **Exercise 2:** Forgot GROUP BY - `AVG()` requires grouping non-aggregated columns
3. **Exercise 3:** WHERE on LEFT JOIN column filtered out NULLs (implicit INNER JOIN)
4. **Exercise 4:** Joined `pr.product_id = o.id` instead of `oi.product_id = p.id`
5. **Exercise 5:** Started FROM orders instead of FROM promotions

### Example Queries Practiced

```sql
-- Orders without shipments (LEFT JOIN + IS NULL)
SELECT o.id, o.customer_id, c.name
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
LEFT JOIN shipments s ON s.order_id = o.id
WHERE s.id IS NULL;

-- Products with average rating (GROUP BY required!)
SELECT p.id, p.name, avg(pr.rating)
FROM products p
LEFT JOIN product_reviews pr ON pr.product_id = p.id
GROUP BY p.id, p.name;

-- Multiple table JOINs (orders → customers → employees)
SELECT o.order_id, c.customer_name, e.employee_name, o.total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
INNER JOIN employees e ON o.employee_id = e.id
WHERE o.total > 100;

-- RIGHT JOIN (all right + matched left)
SELECT o.id, c.name
FROM shipments s
RIGHT JOIN orders o ON o.id = s.order_id
INNER JOIN customers c ON c.id = o.customer_id;

-- All promotions with orders (correct direction)
SELECT pro.id, pro.code, o.id AS order_id
FROM promotions pro
LEFT JOIN orders o ON o.promotion_id = pro.id;
```

### Key Takeaways

1. RIGHT JOIN returns ALL right rows + matched left or NULL
2. RIGHT JOIN is redundant - swap tables and use LEFT JOIN instead
3. Multiple JOINs chain together, each building on previous result
4. LEFT JOIN + IS NULL = find non-matching rows
5. GROUP BY required when mixing aggregate functions with non-aggregated columns
6. JOIN direction matters: base table in FROM, optional data in LEFT JOIN
7. For order_items, join on `oi.product_id = p.id`, NOT `pr.product_id = o.id`

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
├── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations 🔄 Day 3/7 COMPLETE ✅
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Next Steps

1. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
2. ~~Week 6 Day 2: LEFT JOIN~~ ✅ DONE
3. ~~Week 6 Day 3: RIGHT JOIN & Multiple JOINs~~ ✅ DONE
4. **Week 6 Day 4: CROSS JOIN & Self JOIN** - Next session
   - CROSS JOIN - Cartesian product (all combinations)
   - Self JOIN - Table joined to itself
   - Employee-manager relationships

---

*Week 6 Day 3 Complete! Rest well! 🎉*

---

## Week 6 Day 4: CROSS JOIN & Self JOIN - In Progress

### Concepts Learned

**1. CROSS JOIN (Cartesian Product)**

- Returns ALL possible combinations of rows from both tables
- No ON clause needed (no relationship required)
- Formula: Table A rows × Table B rows = total rows

**2. CROSS JOIN Real-Life Examples**

| Use Case | Example |
|----------|---------|
| Scheduling matrix | All doctors × all time slots |
| Size × Color variants | Every size combined with every color |
| Shipping options | Every warehouse × every carrier |
| Test data generation | Generate sample datasets |
| Finding missing combinations | Who hasn't done which shift? |

**3. Self JOIN (Self-Referential Relationship)**

- Table joined to ITSELF using aliases
- Uses `manager_id` column that references `employees(id)`
- Useful for hierarchical data

**4. How Self JOIN Query Works (Employee-Manager)**

```sql
SELECT e.id, e.name AS employee, m.id AS manager_id, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
```

**How it works step by step:**
- `e` = every employee row (the person we want info about)
- `m` = looking for their manager (same table, but as "another copy")
- `ON e.manager_id = m.id` = match where employee's manager_id = manager's id
- Example: Bob Smith (manager_id=1) matches Alice Johnson (id=1)
- Example: Alice (manager_id=NULL) has no manager → NULL result

**5. Understanding `e1.id < e2.id` (Avoiding Duplicate Pairs)**

For finding colleagues in the same department:

```sql
SELECT e1.name AS employee, e1.department_id, e2.name AS colleague
FROM employees e1
LEFT JOIN employees e2 ON e1.department_id = e2.department_id
WHERE e1.id < e2.id
```

**What `e1.id < e2.id` does:**
- NOT about who is "above" or "below"
- Just a tie-breaking rule to avoid duplicate pairs
- `<` keeps only one direction (smaller ID claims the relationship)
- `>` reverses which employee "owns" the pair, but same result

| WHERE clause | Result |
|-------------|--------|
| `e1.id < e2.id` | 3 rows, unique pairs (Alice claims Bob, Alice claims Henry, Bob claims Henry) |
| `e1.id > e2.id` | 3 rows, reversed (Bob claims Alice, Henry claims Alice, Henry claims Bob) |
| `e1.id < e2.id OR e1.id > e2.id` | 6 rows (same as `e1.id != e2.id`) - duplicates! |

**Key insight:** No data is lost - just different "view" of the same relationships.

**6. Real-World Insight: Data Engineering Truth**

- Knowing SQL syntax ≠ knowing what data is needed
- Most time spent on: gathering requirements, meetings, understanding business needs
- SQL syntax is easy; figuring out the RIGHT question to ask is hard
- Always clarify: "What does success look like?" before writing queries

---

### Examples Practiced

```sql
-- CROSS JOIN: All products × all active suppliers
SELECT p.name AS product, p.price, s.name AS supplier, s.rating
FROM products p
CROSS JOIN suppliers s
WHERE s.is_active = 1
ORDER BY p.name, s.rating DESC;

-- Self JOIN: Employee-Manager hierarchy
SELECT e.id, e.name AS employee, e.salary, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
ORDER BY m.name, e.name;

-- Self JOIN: Colleagues in same department (avoiding duplicates)
SELECT e1.name AS employee, e1.department_id, e2.name AS colleague
FROM employees e1
LEFT JOIN employees e2 ON e1.department_id = e2.department_id
WHERE e1.id < e2.id
ORDER BY e1.department_id, e1.name;
```

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
├── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations 🔄 Day 4/7 IN PROGRESS
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Next Steps

1. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
2. ~~Week 6 Day 2: LEFT JOIN~~ ✅ DONE
3. ~~Week 6 Day 3: RIGHT JOIN & Multiple JOINs~~ ✅ DONE
4. ~~Week 6 Day 4: CROSS JOIN & Self JOIN~~ ✅ DONE (up to Example 4)
5. **Week 6 Day 4: Example 5** - CROSS JOIN for report matrix (NEXT SESSION)
   - Monthly sales summary with CASE expressions
   - CROSS JOIN with aggregation
6. **Week 6 Day 4: Practice Exercises** - After Example 5
   - All combinations of customers × promotion codes
   - Find employees who are managers (have direct reports)
   - Products with all order statuses as columns
   - Management chain for specific employee
   - Price comparison matrix: products vs suppliers

---

*Week 6 Day 4 (partial) Complete! Rest well! 🎉*
