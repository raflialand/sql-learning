# Summary: SQL Learning Session

**Date:** 25 June 2026
**Database:** sql-learn-db.db (E-Commerce) + library-db.db (Library)
**Status:** Week 3 - Day 7 Complete ✅

---

## Week 3 Day 7: Mini Quiz

### Quiz Structure

**Part 1: E-Commerce Database (sql-learn-db.db)**

| Q | Question | Key Concepts |
|---|----------|-------------|
| 1 | Top 3 highest-paid employees | `ORDER BY salary DESC LIMIT 3` |
| 2 | Employees in Sales department | `WHERE department_id = 1` |
| 3 | Employees hired before 2022 | `WHERE hire_date < '2022-01-01'` |
| 4 | 5 most recently joined customers | `ORDER BY join_date DESC LIMIT 5` |
| 5 | Customers in New York or Los Angeles | `WHERE city IN ('New York', 'Los Angeles')` |

**Part 2: Library Database (library-db.db)**

| Q | Question | Key Concepts |
|---|----------|-------------|
| 6 | 3 longest-standing members | `ORDER BY membership_date ASC LIMIT 3` |
| 7 | Authors without email | `WHERE email IS NULL` |
| 8 | 5 shortest books | `ORDER BY pages ASC LIMIT 5` |
| 9 | Books published between 1950-2000 | `BETWEEN 1950 AND 2000` (INTEGER) |
| 10 | Premium members | `WHERE membership_type = 'premium'` |

**Score: 9.5/10** ✅

---

## Bonus Round: More Complex Questions

### E-Commerce Database

| Q | Question | Key Concepts |
|---|----------|-------------|
| 1 | Electronics/Clothing $50-$500, expensive first | `IN (1,2)`, `BETWEEN`, `ORDER BY price DESC` |
| 2 | Products with 'Shirt' or 'Shoe' in name | `LIKE '%Shirt%' OR LIKE '%Shoe%'` |
| 3 | IT/HR employees earning >= $5000 | `IN (3,4)`, `>=`, `ORDER BY salary DESC` |
| 4 | 3 cheapest products with stock >= 100 | `stock >= 100`, `ORDER BY price ASC LIMIT 3` |
| 5 | Non-Chicago customers joined in 2023 | `NOT IN`, `BETWEEN '2022-12-31' AND '2024-01-01'` |

### Library Database

| Q | Question | Key Concepts |
|---|----------|-------------|
| 6 | Sci-Fi/Mystery books before 1980 | `IN (3,4)`, `< 1980`, `ORDER BY published_year ASC` |
| 7 | Members with incomplete profiles | `email IS NULL OR phone IS NULL` |
| 8 | 3 longest books from Penguin Random House | `publisher_id = 1`, `ORDER BY pages DESC LIMIT 3` |
| 9 | Books 1930-1960 with >300 pages | `BETWEEN 1930 AND 1960`, `pages > 300` |
| 10 | Standard members joined 2022-2023 | `BETWEEN`, `membership_type = 'standard'` |

**Bonus Score: 9.5/10**

---

## Key Learning: BETWEEN Inclusive Behavior

### What I Learned Today

**BETWEEN is inclusive on both ends:**

```sql
-- These are equivalent:
price BETWEEN 50 AND 100
price >= 50 AND price <= 100
```

| BETWEEN | Includes Start | Includes End |
|---------|---------------|--------------|
| `BETWEEN 50 AND 100` | 50 ✅ | 100 ✅ |
| `BETWEEN '2022-01-01' AND '2023-12-31'` | Jan 1, 2022 ✅ | Dec 31, 2023 ✅ |

**NOT BETWEEN** gives values outside the range.

---

## 3-Month Roadmap Overview

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅
├── Week 3: Sorting & Limiting ✅
└── Week 4: Data Manipulation (CRUD) ← Next Up

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

## Progress Summary

| Week | Topic | Quiz Score |
|------|-------|------------|
| Week 1 | Introduction & Basic Queries | - |
| Week 2 | Filtering with WHERE | 9/10 |
| Week 3 | Sorting & Limiting | 9.5/10 |

**Total Progress:** 21 of 84 days (25%)

---

## Next Steps

1. ~~Complete Week 3~~ ✅ Done
2. ~~Week 3 Mini Quiz~~ ✅ Done (9.5/10)
3. ~~Bonus Questions~~ ✅ Done (9.5/10)
4. **Week 4:** Data Manipulation (INSERT, UPDATE, DELETE)
5. Create, Read, Update, Delete data in databases

---

## Key Takeaways

1. **BETWEEN is inclusive** - includes both endpoint values
2. **Query execution order:** WHERE → ORDER BY → LIMIT
3. **Multiple conditions** can be combined with AND/OR
4. **LIKE with %** matches any characters (zero or more)
5. **IS NULL** checks for missing data (never use `= NULL`)

---

*Happy Learning!*
