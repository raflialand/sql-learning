# SQL Mastery

A comprehensive SQL learning path covering essential topics for data engineering and analytics.

---

## Learning Path Overview

```
learning/03-tools/sql-mastery/
├── 01-window-functions/          (Current Module)
│   ├── 01-foundations/
│   ├── 02-ranking-functions/
│   ├── 03-navigation-functions/
│   ├── 04-aggregate-window-functions/
│   ├── 05-practical-patterns/
│   ├── datasets/
│   └── solutions/
├── datasets/                      (Shared datasets for future modules)
└── README.md
```

---

## Module 01: Window Functions

**Status:** In Progress

### What You'll Learn

| Topic | Functions | Production Use |
|-------|-----------|----------------|
| Foundations | `OVER()`, `PARTITION BY` | Essential for all window functions |
| Ranking | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `NTILE()` | Deduplication, leaderboards |
| Navigation | `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()` | Time series analysis, comparisons |
| Aggregates | `SUM()`, `AVG()`, `COUNT()` | Running totals, moving averages |
| Statistics | `CUME_DIST()`, `PERCENT_RANK()` | Percentile analysis |

### Quick Reference: Window Function Syntax

```sql
FUNCTION_NAME(column) OVER (
    PARTITION BY partition_column
    ORDER BY sort_column
    ROWS BETWEEN frame_start AND frame_end
)
```

---

## Module 02: Joins (Coming Soon)

- INNER, LEFT, RIGHT, FULL OUTER joins
- Self-joins
- Multiple join conditions
- Join optimization considerations

---

## Module 03: Subqueries (Coming Soon)

- Scalar subqueries
- Correlated subqueries
- EXISTS / NOT EXISTS
- Common Table Expressions (CTEs)

---

## Module 04: Advanced Aggregations (Coming Soon)

- GROUP BY with HAVING
- GROUPING SETS
- ROLLUP and CUBE
- PIVOT / UNPIVOT

---

## Module 05: Query Optimization (Coming Soon)

- Reading execution plans
- Index utilization
- Join order
- Common performance pitfalls

---

## Dataset

The `sales-records` dataset simulates an e-commerce/retail company with 13 tables:

**Transactional Tables:**
- `customers` — Customer profiles and membership info
- `orders` — Order headers
- `order_items` — Line items per order
- `products` — Product catalog
- `stores` — Physical store locations
- `employees` — Staff records
- `user_events` — Website clickstream data

**Reference Tables:**
- `categories` — Product categories (hierarchical)
- `regions` — Sales territories
- `departments` — Organizational structure
- `job_titles` — Employee roles and salary ranges
- `memberships` — Customer loyalty tiers

**Analytical Tables:**
- `daily_sales` — Pre-aggregated daily metrics

---

## How to Use This Module

1. **Setup Database**
   ```bash
   # For SQLite (VSCode preview)
   sqlite3 datasets/sales-records.db < datasets/sales-records.sql
   
   # For PostgreSQL (recommended for learning)
   psql -d your_database -f datasets/sales-records.sql
   ```

2. **VSCode Setup**
   - Install "SQLite" or "SQL Server" extension
   - Open `datasets/sales-records.db`
   - Browse tables and run queries

3. **Learning Flow**
   - Read lesson files in order (01 → 02 → 03...)
   - Complete exercises at the end of each module
   - Check solutions in `/solutions` folder
   - Build capstone project when all modules complete

---

## Exercise Types

| Type | What You Do |
|------|-------------|
| **Write the Query** | Translate HR request → SQL query |
| **Translate the Query** | Read SQL query → explain in plain English |
| **Debug the Query** | Find and fix bugs in broken queries |

---

## Key Concepts Glossary

| Term | Definition |
|------|------------|
| **Window Function** | A function that operates on a set of rows but returns a single value per row |
| **OVER()** | Clause that defines the window frame for a window function |
| **PARTITION BY** | Divides rows into groups for the window function |
| **ORDER BY** | Orders rows within each partition |
| **Window Frame** | The subset of rows the function operates on |
| **Running Total** | Cumulative sum from first row to current row |
| **Moving Average** | Average of a sliding window of rows |
| **LAG()** | Gets value from the previous row |
| **LEAD()** | Gets value from the next row |

---

## Tips for Learning

1. **Practice daily** — 30 minutes consistent practice beats 4-hour cramming
2. **Use the dataset** — All examples use the provided `sales-records` database
3. **Write queries yourself** — Don't just read; type them out and modify
4. **Translate to English** — Explaining queries in plain language confirms understanding
5. **Debug intentionally broken queries** — Finding errors sharpens diagnostic skills

---

## Database Compatibility

| Database | Window Function Support |
|----------|------------------------|
| PostgreSQL | Full support (recommended) |
| SQLite 3.25+ | Full support |
| MySQL 8.0+ | Full support |
| SQL Server | Full support |
| BigQuery | Full support |
| Snowflake | Full support |

---

## Progress Tracker

- [x] Module 1: Foundations
- [x] Module 2: Ranking Functions
- [x] Module 3: Navigation Functions
- [x] Module 4: Aggregate Window Functions
- [x] Module 5: Practical Patterns
- [ ] Module 6: Joins
- [ ] Module 7: Subqueries & CTEs
- [ ] Module 8: Advanced Aggregations
- [ ] Module 9: Query Optimization

---

## Contributing

This is a personal learning project. Feel free to fork and adapt for your own learning path.

---

## License

Personal learning materials — use freely.
