# Summary: SQL Learning Session

**Date:** 23 June 2026
**Database:** sql-learn-db.db (E-Commerce) + library-db.db (Library)
**Status:** Week 3 - Days 1-4 Complete ✅

---

## Day 6: LIKE Pattern Matching

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
| `'A%'` | Starts with A |
| `'%A'` | Ends with A |
| `'%A%'` | Contains A anywhere |
| `'_o%'` | Second character is o |
| `'%oo%'` | Contains "oo" anywhere |

### Examples Practiced

```sql
-- Products starting with G
SELECT * FROM products WHERE name LIKE 'G%';

-- Products containing 'Mat'
SELECT * FROM products WHERE name LIKE '%Mat%';

-- Employees with 'e' as second letter
SELECT * FROM employees WHERE name LIKE '_e%';
```

### Real-Life LIKE Examples

| Scenario | Query |
|----------|-------|
| Find company emails | `WHERE email LIKE '%@company.com'` |
| Phone area codes | `WHERE phone LIKE '212-%'` |
| File types | `WHERE filename LIKE '%.jpg'` |
| Product codes | `WHERE sku LIKE 'ELEC-%'` |

---

## Day 7: IS NULL / IS NOT NULL

### Understanding NULL

NULL represents **missing or unknown data**. It's not:
- Not zero (0)
- Not an empty string ('')
- Not the word "NULL"

**Important:** You cannot use `= NULL` to check for NULL. You must use `IS NULL` or `IS NOT NULL`.

### Examples

```sql
-- Find missing emails
SELECT * FROM customers WHERE email IS NULL;

-- Find customers who have provided email
SELECT * FROM customers WHERE email IS NOT NULL;
```

### Why Special Operators?

If you asked 100 people "What is your favorite movie?" and 30 didn't answer, those 30 have NULL responses. Each person didn't provide an answer for a different reason — NULL just means "we don't know."

### How NULL Appears in Results

```
| name          | email              | phone      |
|---------------|--------------------|------------|
| Alice Johnson | alice@library.com | 555-1001   |
| Bob Williams  | NULL              | 555-1002   |
| Carol Davis   | carol@email.com   | NULL       |
```

- NULL appears as **blank/empty** in the column
- It's a concept of "missing/unknown", not the text "NULL"

---

## New Practice Database: Library System

### Why Library Database?

Created to practice NULL queries since current e-commerce database has no NULL data.

### Tables (9 total)

| Table | Purpose |
|-------|---------|
| genres | Book categories |
| publishers | Book publishers |
| authors | Book creators |
| books | Book catalog |
| author_books | Links authors to books (many-to-many) |
| book_copies | Physical copies of books |
| members | Library members |
| loans | Borrowing records |
| fines | Late fees |

### Relationships

```
genres ← books → publishers
authors ← author_books → books
books → book_copies → loans → fines
members ← loans
```

### NULL Data Included

- 4 authors without email
- 3 publishers without website/phone
- 4 members without phone
- 4 members without email
- 2 members without address
- 4 book copies without condition
- 8 loans not returned yet (return_date = NULL)
- 4 fines unpaid (paid_date = NULL)

---

## Day 7 - NULL Operators Reference

### Basic Operators

| Operator | Purpose | Example |
|----------|---------|---------|
| `IS NULL` | Find missing data | `WHERE email IS NULL` |
| `IS NOT NULL` | Find existing data | `WHERE phone IS NOT NULL` |

### SQLite Shorthand Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `IFNULL(col, default)` | Replace NULL with default | `IFNULL(phone, 'No phone')` |
| `COALESCE(a, b, c, ...)` | Return first non-NULL | `COALESCE(phone, email, 'No contact')` |

### Common Patterns

| Task | Query |
|------|-------|
| Find incomplete records | `WHERE email IS NULL OR phone IS NULL` |
| Find complete records | `WHERE email IS NOT NULL AND phone IS NOT NULL` |
| Show default for NULL | `SELECT IFNULL(phone, 'Unknown')` |

### Common Mistakes

| Wrong | Correct |
|-------|---------|
| `WHERE phone = NULL` | `WHERE phone IS NULL` |
| `WHERE phone <> NULL` | `WHERE phone IS NOT NULL` |

---

## Week 2 Mini Quiz Results

**Score: 9/10** ✅

| Q | Topic | Result |
|---|-------|--------|
| 1 | Find pending orders | ✅ |
| 2 | Products over $500 | ✅ |
| 3 | Completed orders under $100 | ❌ Forgot quotes |
| 4 | Customers from multiple cities | ✅ |
| 5 | Price BETWEEN $30-$100 | ✅ |
| 6 | Names starting with 'G' | ✅ |
| 7 | Employees NOT in dept 3 | ✅ |
| 8 | Totals between $100-$300 | ✅ |
| 9 | Names containing 'oo' | ✅ |
| 10 | Electronics over $200 | ✅ |

### Mistake Analysis

**Q3:** `WHERE status = completed` — forgot single quotes around text value.

**Remember:**
- **Text/strings** → single quotes: `'completed'`, `'New York'`
- **Numbers** → no quotes: `price > 500`, `total < 100`

---

## Week 2 Key Takeaways

1. **WHERE** filters data based on conditions
2. Text values use single quotes: `status = 'completed'`
3. Numbers do not use quotes: `price > 100`
4. **AND** requires ALL conditions to be TRUE
5. **OR** requires AT LEAST ONE condition to be TRUE
6. **NOT** reverses the condition
7. Use parentheses to control operator precedence (NOT → AND → OR)
8. **IN** matches any value in a list (shorthand for OR)
9. **BETWEEN** filters within inclusive range
10. **LIKE** pattern matching: `%` = any chars, `_` = one char
11. **NULL** = missing/unknown data (not text "NULL")
12. Always use `IS NULL` / `IS NOT NULL`, never `= NULL`

---

## Next Steps

1. ~~Complete Week 2~~ ✅ Done
2. ~~Week 3 Days 1-2~~ ✅ Done
3. **Week 3 Day 5:** Top-N Patterns
4. **Week 3 Day 6:** Combined Queries
5. **Week 3 Day 7:** Review & Mini Quiz

---

## Week 3: Sorting & Limiting (Days 1-2)

### Day 1: ORDER BY Basics

**What it does:** Sorts query results by one or more columns in ascending or descending order.

```sql
-- Ascending (default) - cheapest first
SELECT name, price FROM products ORDER BY price ASC;

-- Descending - most expensive first
SELECT name, price FROM products ORDER BY price DESC;
```

### Day 2: Multi-Column Sorting

**What it does:** Sort by multiple columns in sequence. First column is primary sort, second breaks ties.

```sql
-- Sort by department, then by salary within each department
SELECT name, department_id, salary 
FROM employees 
ORDER BY department_id ASC, salary DESC;
```

---

## Week 3 Key Takeaways

1. **ORDER BY** sorts results — ASC (default) = A→Z, 0→9; DESC = Z→A, 9→0
2. **Multi-column sort:** First column primary, second breaks ties, third breaks further ties
3. **LIMIT** restricts number of rows returned (show only top X)
4. **LIMIT + ORDER BY** = get top N results (e.g., top 3 most expensive)

---

## Day 3: LIMIT Operator

### What is LIMIT?

Tells SQL "show me only X number of rows from the top." Prevents overwhelming results and speeds up queries.

### Real-World Uses

- Dashboards: "Show top 5 customers by revenue"
- Pagination: Blog pages (1-10, 11-20, 21-30)
- Leaderboards: "Top 10 players by score"
- Preview data: Quick sample before running expensive queries

### Syntax

```sql
SELECT * FROM products LIMIT 5;
SELECT * FROM products ORDER BY price DESC LIMIT 3;
```

### Exercises Completed

**Easy:**
- First 5 products ✅
- First 5 customers ✅

**Medium:**
- 3 most expensive products ✅
- 3 cheapest products ✅
- 2 newest orders ✅
- 3 highest-paid employees ✅
- 4 newest customers ✅

**Medium (LIMIT + WHERE + ORDER BY):**
- 3 cheapest Electronics products ✅
- 2 most expensive pending orders ✅
- 3 most expensive Clothing products ✅
- 2 oldest employees (by hire date) ✅
- First 3 completed orders ✅

---

## Next Steps

1. ~~Complete Week 2~~ ✅ Done
2. ~~Week 3 Days 1-2~~ ✅ Done
3. ~~Week 3 Day 3: LIMIT~~ ✅ Done
4. ~~Week 3 Day 4: OFFSET~~ ✅ Done
5. **Week 3 Day 5:** Top-N Patterns
6. **Week 3 Day 6:** Combined Queries
7. **Week 3 Day 7:** Review & Mini Quiz

---

## Day 4: OFFSET Operator

### What is OFFSET?

OFFSET tells SQL to **skip the first X rows** before returning results. It's used for **pagination** - showing data in chunks/pages.

### Key Insight: OFFSET Always Skips From BEGINNING

```
OFFSET 3 = Skip first 3 rows from the ENTIRE dataset, then take data
```

### Common Misconception

❌ Wrong: "OFFSET skips within the results"
✅ Correct: "OFFSET skips from the very beginning of the data"

### OFFSET Without LIMIT (Risky!)

```sql
-- Skips first 5, returns ALL remaining rows (dangerous!)
SELECT * FROM products ORDER BY id OFFSET 5;
```

### OFFSET + LIMIT (Safe Pagination)

```sql
-- Page 1: Skip 0, take 5
SELECT * FROM products ORDER BY id LIMIT 5 OFFSET 0;

-- Page 2: Skip 5, take 5
SELECT * FROM products ORDER BY id LIMIT 5 OFFSET 5;

-- Page 3: Skip 10, take 5
SELECT * FROM products ORDER BY id LIMIT 5 OFFSET 10;
```

### OFFSET Formula

```
OFFSET = (page - 1) * items_per_page
```

| Page | Items Per Page | OFFSET |
|------|---------------|--------|
| 1 | 5 | 0 |
| 2 | 5 | 5 |
| 3 | 5 | 10 |

### OFFSET 0 Means...

OFFSET 0 = Skip nothing (same as not writing OFFSET at all)

```sql
-- These are identical:
SELECT * FROM products ORDER BY id LIMIT 5 OFFSET 0;
SELECT * FROM products ORDER BY id LIMIT 5;
```

### Exercises Completed

**Pagination Basics:**
- Employees: 3 per page, page 2 → `LIMIT 3 OFFSET 3` ✅
- Orders: 4 per page, page 3 → `LIMIT 4 OFFSET 8` ✅

**Advanced Scenarios (sql-learn-db.db):**
- Electronics products page 1 (2 per page) ✅
- Pending orders page 2 (2 per page) ✅
- Top 3 highest-paid employees ✅
- Employees 4-6 by salary (page 2 of highest earners) ✅
- 3 most expensive Clothing products ✅
- Completed orders by date page 1 (3 per page) ✅

**Advanced Scenarios (library-db.db):**
- Science Fiction books page 1 (3 per page) ✅
- Premium members page 1 (2 per page) ✅
- Unreturned loans page 1 (4 per page) ✅
- 3 oldest books by published_year ✅
- Books 4-6 by page count ✅
- Unpaid fines page 1 (3 per page) ✅

---

## 3-Month Roadmap Overview

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅
├── Week 3: Sorting & Limiting ← In Progress (Days 1-4 done)
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

*Happy Learning!*
