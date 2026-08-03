# Summary: SQL Learning Session

**Date:** 29 June 2026
**Database:** sql-learn-db.db (E-Commerce)
**Status:** Week 4 Day 7 - Quiz COMPLETED ✅ (10/10)

---

## Quiz Results

All 10 answers verified correct:

| # | Concept | Answer Summary |
|---|---------|----------------|
| Q1 | INSERT single row | Full column list with VALUES |
| Q2 | INSERT multiple rows | VALUES (...), (...), (...) |
| Q3 | UPDATE multiple columns | SET col1 = val1, col2 = val2 |
| Q4 | UPDATE with calculation | salary * 110/100 |
| Q5 | UPDATE multiple fields | status and total in one SET |
| Q6 | DELETE with FK | Transaction with child delete first |
| Q7 | DELETE with date | Transaction with date condition |
| Q8 | Transaction + ROLLBACK | Update then rollback to undo |
| Q9 | Transaction + COMMIT | UPDATE then COMMIT |
| Q10 | SELECT arithmetic | price * stock AS 'Stock Value' |

---

## Verified Answers (Reference)

```sql
-- Q1: New employee Sarah Connor
INSERT INTO employees (name, email, department_id, hire_date, salary)
VALUES ('Sarah Connor', 'sarah@hr.com', 3, '2026-06-29', 5500);

-- Q2: 3 new departments
INSERT INTO departments (name, budget) VALUES
    ('Finance', 80000),
    ('Legal', 95000),
    ('Operations', 75000);

-- Q3: Alice Johnson promotion
UPDATE employees SET salary = 6200, email = 'alice.johnson@company.com'
WHERE name = 'Alice Johnson';

-- Q4: Marketing dept 10% raise
UPDATE employees SET salary = salary * 110/100
WHERE department_id = 2;

-- Q5: Order #7 delivered, correct total
UPDATE orders SET status = 'delivered', total = 359.99
WHERE id = 7;

-- Q6: Lisa Garcia left (FK handling)
BEGIN TRANSACTION;
DELETE FROM orders WHERE customer_id = 6;
DELETE FROM customers WHERE name = 'Lisa Garcia';
COMMIT;

-- Q7: Remove pending orders before Jan 2026
BEGIN TRANSACTION;
DELETE FROM orders WHERE status = 'pending' AND order_date < '2026-01-01';
COMMIT;

-- Q8: Undo David Brown's salary change
BEGIN TRANSACTION;
UPDATE employees SET salary = 7500 WHERE name = 'David Brown';
ROLLBACK;

-- Q9: Save IT dept budget change
BEGIN TRANSACTION;
UPDATE departments SET budget = 120000 WHERE name = 'IT';
COMMIT;

-- Q10: Products with stock value
SELECT name, price, stock, price * stock AS 'Stock Value' FROM products;
```

---

## Week 4 Complete!

**Week 4 Topics Covered:**
- Day 1: INSERT single row
- Day 2: INSERT multiple rows
- Day 3: UPDATE basics
- Day 4: UPDATE with WHERE
- Day 5: DELETE basics
- Day 6: Transaction control (COMMIT, ROLLBACK)
- Day 7: Mini Quiz ✅

**Quiz Scores:**
| Week | Score |
|------|-------|
| Week 2 | 9/10 |
| Week 3 | 9.5/10 |
| Week 4 | 10/10 |

---

## 3-Month Roadmap Overview

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅
├── Week 3: Sorting & Limiting ✅
└── Week 4: Data Manipulation (CRUD) ✅ COMPLETE

MONTH 2: INTERMEDIATE
├── Week 5: Table Design & Relationships 🔜 NEXT
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

## Key Takeaways

1. INSERT with all columns: `INSERT INTO table (col1, col2, col3) VALUES (val1, val2, val3)`
2. INSERT multiple rows: `VALUES (...), (...), (...)`
3. UPDATE multiple columns: `SET col1 = val1, col2 = val2 WHERE condition`
4. DELETE with FK constraint: Delete child rows first, then parent rows
5. ON DELETE CASCADE auto-deletes children; default behavior requires manual deletion order
6. Transaction = BEGIN → operations → COMMIT (save) or ROLLBACK (undo)
7. UPDATE can include calculations: `SET salary = salary * 110/100`
8. Q8 trick: To demonstrate ROLLBACK, first make a change then rollback (cannot rollback unchanged data)

---

## Week 5 Module Created! 🎉

**File:** `learning/02-sql-learning/sql-roadmaps/week-5-table-design-and-relationships.md`

### Decisions Made:

| Question | Decision | Reason |
|----------|----------|--------|
| New tables or modifying existing? | **NEW tables** | Simulates real-world growth, safe for practice |
| DROP TABLE timing? | **Included in Week 5** | Listed in roadmap, good to learn with warnings |
| Focus database? | **sql-learn.db only** | Cleaner, more focused learning |

### New Tables Created in Exercises:
- `suppliers` - vendor information
- `shipments` - order fulfillment tracking
- `product_reviews` - customer reviews
- `promotions` - discount codes
- `gift_cards` - gift card tracking
- `stock_movements` - inventory changes
- `employees_backup` - backup of employee data
- `categories_archive` - archived categories

---

## Concepts Clarified Today

### Postal Code Data Type
**A: TEXT, NOT INTEGER**

Postal codes can be alphanumeric internationally:
- USA: `12345` or `12345-6789`
- UK: `SW1A 1AA`
- Netherlands: `1234 AB`

Using INTEGER would reject alphanumeric codes.

### is_primary Flag (0 or 1)
Binary yes/no flag for images:

| Value | Meaning | Example |
|-------|---------|---------|
| `1` | YES - this IS the main image | Product catalog photo |
| `0` | NO - additional image | Back view, detail shots |

Standard convention instead of storing "yes"/"no" as text.

---

## Week 5 Structure (Final)

| Day | Topic | Practice Tables |
|-----|-------|-----------------|
| 1 | CREATE TABLE | suppliers, product_reviews, shipments |
| 2 | Data Types | promotions, gift_cards, stock_movements |
| 3 | Constraints | NOT NULL, UNIQUE, CHECK, DEFAULT |
| 4 | Primary Key | Examining & creating PKs |
| 5 | Foreign Key | Linking shipments → orders, reviews → products |
| 6 | ALTER TABLE | ADD/RENAME columns, DROP TABLE safety |
| 7 | Review + Quiz | 10 questions |

---

## Next Steps

1. ~~Plan Week 5 module~~ ✅ Done
2. **Start Week 5:** Day 1 - CREATE TABLE
   - Create suppliers, product_reviews, shipments tables
   - Practice with HR-style query translations
3. Continue Day 2-7 sequentially
4. Take Week 5 Mini Quiz (target: >80%)

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅
├── Week 3: Sorting & Limiting ✅
└── Week 4: Data Manipulation (CRUD) ✅

MONTH 2: INTERMEDIATE
├── Week 5: Table Design & Relationships 🔜 IN PROGRESS
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

## Week 5 Day 2: Data Types Practice

### Understanding `is_` Prefix Columns

Boolean columns use `is_` prefix to indicate yes/no status:

| Column | Meaning | Values |
|--------|---------|--------|
| `is_active` | Is it active? | 1 = Yes, 0 = No |
| `is_primary` | Is it primary? | 1 = Yes, 0 = No |
| `is_redeemed` | Has it been redeemed? | 1 = Yes, 0 = No |

**Data type for `is_` columns:** INTEGER (SQLite stores booleans as 0/1)

### SQLite Data Types Guide

| Data Type | Use For | Example |
|-----------|---------|---------|
| INTEGER | Whole numbers, booleans | `id`, `quantity`, `is_active` |
| REAL | Decimals | `price`, `discount_percent` |
| TEXT | Alphanumeric text, dates | `name`, `email`, `issue_date` |
| BLOB | Binary data | images, files |

**Important:** SQLite has NO DATE type - dates are stored as TEXT in `'YYYY-MM-DD'` format.

### PRIMARY KEY Placement

```sql
-- Option 1: Inline (most common, cleaner)
gift_card_code TEXT PRIMARY KEY,

-- Option 2: Separate at end
PRIMARY KEY (gift_card_code)
```

### FOREIGN KEY Syntax

```sql
-- Correct
product_id INTEGER REFERENCES products(id),

-- Wrong (typo and placement)
product_id integer refferences products(id),
```

### Corrected Table Definitions

**gift_cards:**
```sql
CREATE TABLE gift_cards (
    gift_card_code TEXT PRIMARY KEY,
    initial_amount REAL,
    current_balance REAL,
    issue_date TEXT,
    expiration_date TEXT,
    recipient_email TEXT,
    is_redeemed INTEGER
);
```

**stock_movements:**
```sql
CREATE TABLE stock_movements (
    movement_id INTEGER PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    quantity_change INTEGER,
    movement_type TEXT,
    movement_date TEXT,
    notes TEXT
);
```

### Key Insights from Day 2

1. Gift card codes are alphanumeric → use TEXT, not INTEGER
2. Date columns → TEXT in SQLite (no DATE type)
3. `is_something` columns → INTEGER (0/1 values)
4. PRIMARY KEY can be inline or separate
5. FOREIGN KEY uses `REFERENCES table(column)`, not `refferences`
6. `movement_type TEXT` - don't put constraints in data type definition

---

## Week 5 Day 3: Constraints Practice

### NOT NULL vs NOT NULL DEFAULT 'unknown'

| Constraint | Behavior |
|------------|----------|
| `NOT NULL` | Must provide value on every INSERT |
| `NOT NULL DEFAULT 'unknown'` | Must provide value OR use default if omitted |

```sql
-- NOT NULL: ERROR if no value given
INSERT INTO t (name) VALUES (DEFAULT);  -- ERROR!

-- NOT NULL DEFAULT 'unknown': uses 'unknown' if no value given
INSERT INTO t (name) VALUES (DEFAULT);  -- OK, name = 'unknown'
```

### CHECK Constraint - Not Just Strings!

CHECK can validate ANY expression that returns TRUE/FALSE:

```sql
-- String ratings
rating TEXT CHECK (rating IN ('A', 'B', 'C', 'D', 'F'))

-- Numbers
price REAL CHECK (price > 0)
quantity INTEGER CHECK (quantity >= 0 AND quantity <= 1000)

-- Patterns
email TEXT CHECK (email LIKE '%@%.%')

-- Calculations
salary REAL CHECK (salary > 0 AND salary < 1000000)
```

### CURRENT_TIMESTAMP

Auto-fills current date and time when a row is inserted:

```sql
created_at TEXT DEFAULT CURRENT_TIMESTAMP
-- Result: "2026-06-29 14:30:00"
```

### Practice Exercises Completed

**Q1: product_reviews** ✅
```sql
CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER REFERENCES products(id),
    customer_id INTEGER REFERENCES customers(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**Q2: employees_audit** ✅
```sql
CREATE TABLE employees_audit (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    old_salary REAL NOT NULL,
    new_salary REAL NOT NULL,
    change_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL
);
```

**Q3: coupon_usage** ✅
```sql
CREATE TABLE coupon_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    coupon_code TEXT NOT NULL,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_id INTEGER NOT NULL REFERENCES orders(id),
    usage_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    discount_amount REAL NOT NULL CHECK (discount_amount > 0)
);
```

**Q4: products CHECK constraint** - Skipped (SQLite ALTER TABLE limitation)

### Errors Fixed

1. Typo: `promary` → `primary`
2. Extra comma after `employee_id,`
3. Wrong FK reference on `old_salary` (removed `REFERENCES employees(salary)`)
4. Missing `TEXT` data type on `change_date`

---

## Key Takeaways (Updated)

1. CHECK constraints accept ANY TRUE/FALSE expression, not just strings
2. `NOT NULL` = must provide value every time
3. `NOT NULL DEFAULT 'value'` = must provide OR fallback to default
4. `CURRENT_TIMESTAMP` auto-fills date+time on INSERT
5. `old_salary` doesn't need FK - just store the old value directly
6. SQLite ALTER TABLE has limitations for adding constraints

---

## Week 5 Progress

| Day | Topic | Status |
|-----|-------|--------|
| 1 | CREATE TABLE | ✅ |
| 2 | Data Types | ✅ |
| 3 | Constraints | ✅ |
| 4 | Primary Key | ✅ |
| 5 | Foreign Key | Pending |
| 6 | ALTER TABLE | Pending |
| 7 | Review + Quiz | Pending |

---

## Week 5 Day 4: Primary Key Practice

### What is a Primary Key?

A Primary Key (PK) is a **unique identifier** for each row in a table.

| Rules | Description |
|-------|-------------|
| UNIQUE | No two rows can have the same PK value |
| NOT NULL | PK cannot be empty |
| One per table | Only 1 PK allowed |
| Immutable | PK value should never change |

### Practice Exercises Completed

**Q2: suppliers table** ✅
```sql
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT DEFAULT 'unknown',
    city TEXT NOT NULL,
    country TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**Q3: product_images table** ✅
```sql
CREATE TABLE product_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL REFERENCES products(id),
    image_url TEXT NOT NULL,
    is_primary INTEGER DEFAULT 1 CHECK (is_primary IN (0, 1)),
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**Q4: What without PRIMARY KEY?** ✅
Without a PRIMARY KEY:
- No unique identifier → duplicate rows possible
- No stable reference → FK relationships break
- Ambiguous targeting → UPDATE/DELETE uncertain

### Key Insights from Day 4

1. **UNIQUE vs PRIMARY KEY**: PRIMARY KEY = 1 per table, UNIQUE = can have multiple
2. **NOT NULL redundancy**: PRIMARY KEY already implies NOT NULL
3. **image_url TEXT**: Store URL/path as TEXT, not BLOB
4. **is_primary CHECK**: Use `CHECK (is_primary IN (0, 1))` to enforce 0 or 1 only

---

## Key Concepts Summary

### Constraint Syntax Order
```sql
-- NOT NULL + REFERENCES
employee_id INTEGER NOT NULL REFERENCES employees(id)

-- NOT NULL + UNIQUE
email TEXT NOT NULL UNIQUE

-- UNIQUE + DEFAULT (problematic if default creates duplicates)
-- BAD: email TEXT UNIQUE DEFAULT 'unknown' -- two rows would conflict!
```

### SQLite Data Types
| Type | Use For |
|------|---------|
| INTEGER | Whole numbers, booleans, PKs, FKs |
| REAL | Decimals (price, budget) |
| TEXT | Strings, dates (YYYY-MM-DD) |
| BLOB | Binary (rarely used) |

### is_ Prefix Columns
| Column | Type | Values |
|--------|------|--------|
| `is_active` | INTEGER | 1 = Yes, 0 = No |
| `is_primary` | INTEGER | 1 = Yes, 0 = No |
| `is_redeemed` | INTEGER | 1 = Yes, 0 = No |

---

## Progress Update

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
└── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships 🔜 Day 4 Complete
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

## Next Steps

1. ~~Week 5 Day 1-4~~ ✅ Done
2. **Week 5 Day 5:** Foreign Key - Linking tables together
3. Week 5 Day 6: ALTER TABLE
4. Week 5 Day 7: Review + Quiz
5. Move to Week 6: JOIN Operations

---

*Happy Learning!*

---

## Week 5 Day 5: Foreign Key Practice

### PRAGMA - Database Configuration

**PRAGMA** is a special SQL command in SQLite (and some other databases) used to query or modify the database engine's internal settings and operational parameters.

| PRAGMA | Purpose |
|--------|---------|
| `PRAGMA foreign_keys = ON;` | Enable/disable foreign key enforcement |
| `PRAGMA table_info(table_name);` | Get column details of a table |
| `PRAGMA index_list(table_name);` | List indexes on a table |

**Important:** SQLite foreign keys are OFF by default for backward compatibility. You must explicitly enable them per connection:

```sql
PRAGMA foreign_keys = ON;
```

### Practice Exercises Completed

**Q1: order_returns table** ✅
```sql
CREATE TABLE order_returns (
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    order_id INTEGER NOT NULL REFERENCES orders(id), 
    product_id INTEGER NOT NULL REFERENCES products(id), 
    customer_id INTEGER NOT NULL REFERENCES customers(id), 
    return_date TEXT DEFAULT CURRENT_TIMESTAMP, 
    reason TEXT NOT NULL,
    refund_amount REAL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'completed'))
);
```
- Fix: Added `DEFAULT 'pending'` for status column

**Q2: supplier_products table (many-to-many)** ✅
```sql
CREATE TABLE supplier_products (
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id), 
    product_id INTEGER NOT NULL REFERENCES products(id), 
    cost_price REAL NOT NULL, 
    contract_date TEXT DEFAULT CURRENT_TIMESTAMP, 
    is_active INTEGER DEFAULT 1 CHECK (is_active IN (0, 1)),
    UNIQUE(supplier_id, product_id)
);
```
- Fix: Changed `supplier_id integer null` → `supplier_id INTEGER NOT NULL`
- Added `UNIQUE(supplier_id, product_id)` to prevent duplicates

**Q3: product_reviews table** ✅
```sql
CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL REFERENCES products(id),
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    rating INTEGER CHECK(rating >= 1 AND rating <= 5),
    review_text TEXT NOT NULL,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);
```
- Fix: `customer_id REFERENCES products(id)` → `customer_id REFERENCES customers(id)`
- Fix: Added `TEXT` data type to `review_text`

**Q4: Demonstrating FK constraint error** ✅
When inserting invalid foreign key data, the database throws an error and rejects the insert:
```
FOREIGN KEY constraint failed
```

### Week 5 Progress (Updated)

| Day | Topic | Status |
|-----|-------|--------|
| 1 | CREATE TABLE | ✅ |
| 2 | Data Types | ✅ |
| 3 | Constraints | ✅ |
| 4 | Primary Key | ✅ |
| 5 | Foreign Key | ✅ |
| 6 | ALTER TABLE | Pending |
| 7 | Review + Quiz | Pending |

---

## Key Takeaways (Final)

1. **PRAGMA** is SQLite's way to configure database settings (like `foreign_keys = ON`)
2. **Foreign keys are OFF by default** - must enable with `PRAGMA foreign_keys = ON;`
3. **Many-to-many relationships** need a junction table with UNIQUE constraint on FK pair
4. **FK constraint error** = trying to reference a non-existent record
5. Always double-check REFERENCES point to the correct table!

---

## Next Steps

1. ~~Week 5 Day 1-5~~ ✅ Done
2. **Week 5 Day 6:** ALTER TABLE - Modifying table structure
3. Week 5 Day 7: Review + Quiz
4. Move to Week 6: JOIN Operations

---

*Session saved - Rest well! 🎉*

---

## Week 5 Day 6: ALTER TABLE Practice

### ALTER TABLE vs UPDATE vs DELETE

| Aspect | ALTER TABLE | UPDATE | DELETE |
|--------|-------------|--------|--------|
| **Type** | DDL (Data Definition) | DML (Data Manipulation) | DML (Data Manipulation) |
| **What it changes** | **Structure** (schema) | **Data** in rows | **Data** - removes rows |
| **Scope** | Table definition | Column values within rows | Entire rows |
| **Reversible** | Manual restore needed | Can rollback (within transaction) | Can rollback (within transaction) |

### Key Distinction

- **ALTER TABLE** = "Change how the table looks/is defined"
- **UPDATE** = "Change what data is stored in rows"
- **DELETE** = "Remove rows entirely"

Think of it like a spreadsheet:
- **ALTER TABLE** = Add/remove columns, rename the sheet
- **UPDATE** = Edit values in cells
- **DELETE** = Remove entire rows (horizontal lines)

### Practice Exercises Completed

**Q1: products last_updated** ✅
```sql
ALTER TABLE products ADD last_updated TEXT DEFAULT 'unknown';
```
Note: Added `DEFAULT 'unknown'` because existing rows need a value for the new NOT NULL column.

**Q2: orders notes** ✅
```sql
ALTER TABLE orders ADD notes TEXT DEFAULT 'unknown';
```
Same reason - existing rows need default value.

**Q3: rename stock column** ✅
```sql
ALTER TABLE products RENAME stock TO stock_quantity;
```

**Q4: customers_backup table** ✅
```sql
CREATE TABLE customers_backup (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE DEFAULT 'unknown',
    city TEXT DEFAULT 'unknown',
    join_date TEXT NOT NULL
);

DROP TABLE IF EXISTS customers_backup;
```

### Important: DDL Auto-Commits!

`CREATE TABLE` and `DROP TABLE` are **DDL** commands. In SQLite, DDL commands **auto-commit** immediately - they don't wait for the transaction.

```sql
-- This WON'T work as intended:
BEGIN TRANSACTION;
CREATE TABLE customers_backup (...);
ROLLBACK;  -- The CREATE already committed!

-- DROP TABLE behavior:
DROP TABLE IF EXISTS customers_backup;  -- Safe, only drops if exists
```

### Week 5 Progress (Final)

| Day | Topic | Status |
|-----|-------|--------|
| 1 | CREATE TABLE | ✅ |
| 2 | Data Types | ✅ |
| 3 | Constraints | ✅ |
| 4 | Primary Key | ✅ |
| 5 | Foreign Key | ✅ |
| 6 | ALTER TABLE | ✅ |
| 7 | Review + Quiz | ⏳ Next |

---

## Key Takeaways (Updated)

1. **ALTER TABLE** changes table STRUCTURE (DDL), UPDATE/DELETE changes DATA (DML)
2. When adding columns with NOT NULL to existing tables, must provide DEFAULT
3. `DROP TABLE` auto-commits in SQLite - cannot ROLLBACK
4. `DROP TABLE IF EXISTS` is safe - won't error if table doesn't exist
5. `ALTER TABLE RENAME` renames the column, not the data

---

## Next Steps

1. ~~Week 5 Day 1-6~~ ✅ Done
2. **Week 5 Day 7:** Review + Quiz (10 questions)
3. Move to Week 6: JOIN Operations

---

*Session saved - Rest well! 🎉*