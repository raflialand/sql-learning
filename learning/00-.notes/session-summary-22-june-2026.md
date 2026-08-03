# Summary: SQL Learning Session

**Date:** 22 June 2026
**Database:** sql-learn.db (SQLite)
**Status:** Week 2, Day 5 Complete

---

## 1. Week 2 Progress

### Days Completed

| Day | Topic | Status |
|-----|-------|--------|
| 1 | WHERE Clause Fundamentals | ✅ Completed |
| 2 | Comparison Operators | ✅ Completed |
| 3 | Logical Operators (AND, OR, NOT) | ✅ Completed |
| 4 | IN Operator | ✅ Completed |
| 5 | BETWEEN Operator | ✅ Completed |
| 6 | LIKE Pattern Matching | ⏳ Pending |
| 7 | IS NULL / IS NOT NULL + Mini Quiz | ⏳ Pending |

---

## 2. Day 1: WHERE Clause Fundamentals

### What is WHERE?

The WHERE clause filters data based on specified conditions. Only rows that meet the condition are returned.

### Syntax

```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

### Key Concepts Learned

- WHERE filters rows that match a specific condition
- Think of it like a filter on a spreadsheet
- Only rows where condition is TRUE are returned

### Examples Practiced

```sql
-- Filter orders by status
SELECT * FROM orders WHERE status = 'completed';

-- Filter products by category
SELECT * FROM products WHERE category_id = 1;

-- Filter employees by department
SELECT * FROM employees WHERE department_id = 3;
```

---

## 3. Day 2: Comparison Operators

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

### Examples Practiced

```sql
-- Products priced over $100
SELECT * FROM products WHERE price > 100;

-- Employees with salary under $5000
SELECT * FROM employees WHERE salary < 5000;

-- Employees with salary $5500 or more
SELECT * FROM employees WHERE salary >= 5500;

-- Orders that are NOT cancelled
SELECT * FROM orders WHERE status <> 'cancelled';
```

### Practice Exercises Completed

1. Find products with stock less than 100
2. Find employees hired before 2022
3. Find orders with total >= 500
4. Find products priced exactly $29.99

---

## 4. Day 3: Logical Operators (AND, OR, NOT)

### What are Logical Operators?

Words/symbols that connect conditions to create more specific filters.

### AND Operator

Both conditions must be TRUE to include the row.

```sql
SELECT * FROM orders WHERE status = 'completed' AND total > 500;
```

### OR Operator

At least one condition must be TRUE to include the row.

```sql
SELECT * FROM products WHERE category_id = 1 OR category_id = 2;
```

### NOT Operator

Reverses the condition (TRUE becomes FALSE, FALSE becomes TRUE).

```sql
SELECT * FROM products WHERE NOT category_id = 1;
```

### Combining Operators

Use parentheses to control evaluation order. Precedence: NOT → AND → OR.

```sql
-- Completed orders with total between 100 and 500
SELECT * FROM orders WHERE status = 'completed' AND total >= 100 AND total <= 500;
```

### Practice Exercises Completed

1. Find completed orders over $100
2. Find products in category 1 OR category 3
3. Find products NOT in category 2
4. Find orders that are either pending AND over $500, or cancelled

---

## 5. Day 4: IN Operator

### What is IN?

A cleaner way to check if a value matches ANY value in a list. Shorthand for multiple OR conditions.

### IN vs OR

```sql
-- Long way with OR
SELECT * FROM customers WHERE city = 'New York' OR city = 'Los Angeles' OR city = 'Chicago';

-- Short way with IN
SELECT * FROM customers WHERE city IN ('New York', 'Los Angeles', 'Chicago');
```

### Examples Practiced

```sql
-- Products in categories 1, 2, or 3
SELECT * FROM products WHERE category_id IN (1, 2, 3);

-- Employees in departments 1 or 2
SELECT * FROM employees WHERE department_id IN (1, 2);

-- Orders with status pending or shipped
SELECT * FROM orders WHERE status IN ('pending', 'shipped');
```

### Practice Exercises Completed (Standard)

1. Find customers from cities 'Phoenix' or 'Houston'
2. Find products with category_id 1, 2, or 4
3. Find orders with status 'pending', 'shipped', or 'cancelled'
4. Find employees in departments 3 or 4

### Practice Exercises Completed (Advanced)

1. Find products in categories 1, 2, or 3 that cost more than $100
2. Find employees in departments 2 and 4 who earn less than $5000
3. Find completed orders with totals over $200 that are NOT from customers 1, 2, or 3
4. Find products in categories 1, 2, or 4 with stock less than 200
5. Find employees in departments 1 or 3 who were hired before 2022
6. Find customers from cities 'New York', 'Los Angeles', or 'Chicago' whose name contains a space
7. Find products NOT in categories 1, 3, or 5
8. Find orders with status 'pending' OR 'shipped' that have totals under $1000
9. Find employees in departments 1, 2, or 4 whose salary is NOT between $4500 and $5500
10. Find products in category 2 OR category 4 with stock greater than 100

---

## 6. Day 5: BETWEEN Operator

### What is BETWEEN?

A convenient way to filter for values within a range. The range is always **inclusive** (includes both endpoints).

### Key Insight

```sql
price BETWEEN 50 AND 200
-- is equivalent to:
price >= 50 AND price <= 200
```

### Examples Practiced

```sql
-- Products priced between $50 and $150
SELECT * FROM products WHERE price BETWEEN 50 AND 150;

-- Orders with total between $100 and $500
SELECT * FROM orders WHERE total BETWEEN 100 AND 500;

-- Employees hired in 2022
SELECT * FROM employees WHERE hire_date BETWEEN '2022-01-01' AND '2022-12-31';

-- Products NOT in price range
SELECT * FROM products WHERE price NOT BETWEEN 30 AND 100;
```

### Practice Exercises Completed (Advanced)

1. Completed orders $100-300 in Q1 2024
2. Employees hired 2020-2023 with salary < $5000
3. Products in cats 1/2/3 with stock NOT between 50-200
4. Customers from NY/LA/Chicago who joined Jan-Jun 2023
5. Orders with precedence demonstration (with/without parentheses)
6. Category 1 OR 5 products with price $100-1000
7. Employees in depts 1/2 salary $4500-6000 OR dept 3 any salary

### Errors Caught and Corrected

- **Exercise #3:** Initially showed products IN the range instead of NOT IN. Corrected to show T-Shirt and Jeans (stock 500 and 300).
- **Exercise #5:** Precedence issue — `OR` has lower precedence than `AND`. Without parentheses, only shipped orders get filtered by total range, not completed orders.

---

## 7. Week 2 Key Takeaways (So Far)

1. **WHERE** filters data based on conditions
2. Comparison operators (`=`, `<>`, `<`, `>`, `<=`, `>=`) compare values
3. Text values use single quotes: `status = 'completed'`
4. Numbers do not use quotes: `price > 100`
5. `<>` and `!=` both mean "not equals"
6. **AND** requires ALL conditions to be TRUE
7. **OR** requires AT LEAST ONE condition to be TRUE
8. **NOT** reverses the condition
9. Use parentheses to control operator precedence (NOT → AND → OR)
10. **IN** matches any value in a list (shorthand for OR)
11. **BETWEEN** filters within inclusive range — equivalent to `>= AND <=`
12. **NOT BETWEEN** means outside the range — `< OR >`
13. Critical thinking: Question your own answers and verify with actual queries

---

## 8. Next Steps

1. ~~Learn BETWEEN operator~~ ✅ Done
2. ~~Practice advanced BETWEEN exercises~~ ✅ Done
3. **Day 6:** Learn LIKE Pattern Matching (wildcards: % and _)
4. **Day 7:** IS NULL / IS NOT NULL + Mini Quiz
5. Take Mini Quiz at end of Week 2
6. Move to Week 3: Sorting & Limiting

---

## 9. 3-Month Roadmap Overview

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ← Current (Day 5/7)
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

*Happy Learning!*
