# Summary: SQL Learning Session

**Date:** 26 June 2026
**Database:** sql-learn-db.db (E-Commerce)
**Status:** Week 4 - Day 6 Complete (Transactions)

---

## Week 4 Day 1-5: Data Manipulation (DML)

### INSERT Single Row

**INSERT Syntax:**
```sql
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...);
```

**Key Rules:**
| Rule | Explanation |
|------|-------------|
| Column order | Values must match column order |
| Data types | Values must match column data types |
| Strings | Use single quotes around text values |
| Numbers | No quotes needed |
| Dates | Use 'YYYY-MM-DD' format |

### NULL Value Handling in INSERT

**Option 1: Omit the column**
```sql
INSERT INTO customers (name, email)
VALUES ('John', 'john@email.com');
```

**Option 2: Explicitly use NULL keyword**
```sql
INSERT INTO customers (name, email, phone)
VALUES ('John', 'john@email.com', NULL);
```

### INTEGER PRIMARY KEY Behavior

- **Unique identifier** - each row gets a unique number (1, 2, 3...)
- **Auto-increment** - SQLite automatically generates the next number
- **Cannot INSERT into it** - SQLite auto-generates, specifying will cause error

### UPDATE vs INSERT

| Operation | SQL Command | Purpose |
|-----------|-------------|---------|
| Add new row | `INSERT INTO` | New data |
| Change existing data | `UPDATE SET` | Fill in or modify data |

### DELETE Basics

```sql
DELETE FROM table_name WHERE condition;
```

**Important:** Always include WHERE or you'll delete ALL rows!

---

## Week 4 Day 6: Transactions

### What are Transactions?

Transaction = a group of database operations that must ALL succeed or ALL fail together

### Why Transactions Matter

Bank Transfer Analogy:
```
Step 1: Subtract $100 from Account A
Step 2: Add $100 to Account B
```
Without transactions, if Step 2 fails, your $100 disappears!

### SQL Transaction Commands

| Command | Meaning |
|---------|---------|
| `BEGIN` | Start grouping operations |
| `COMMIT` | "Save all changes" - make them permanent |
| `ROLLBACK` | "Undo everything" - cancel all changes |

### Example

```sql
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

### What Happens If You Forget COMMIT?

| Database | Behavior |
|----------|----------|
| SQLite | Auto-ROLLBACK when connection closes |
| MySQL/PostgreSQL | Depends on autocommit setting |

**The Danger: LOCKS**
- Rows are locked during an open transaction
- Other users cannot access those rows
- Always COMMIT or ROLLBACK to release locks

### How to Check Data Before Commit

```sql
-- CEK dulu sebelum DELETE
SELECT * FROM customers WHERE id = 1;

-- Begin transaction, then delete
BEGIN TRANSACTION;
DELETE FROM customers WHERE id = 1;

-- Verify the result
SELECT * FROM customers WHERE id = 1;

-- If wrong, rollback
ROLLBACK;
-- If correct, commit
COMMIT;
```

### If You Made a Mistake After COMMIT

```sql
-- Already committed wrong data? Fix with new transaction:
BEGIN TRANSACTION;
UPDATE customers SET balance = 1000 WHERE id = 1;
COMMIT;
```

### Practice Exercise Completed

**Q4: Add a new author and a new book for that author, then commit**
```sql
BEGIN TRANSACTION;
INSERT INTO authors (name, email, phone, bio, nationality)
VALUES ('New Author', 'new.author@email.com', '555-1234', 'A new author bio', 'American');
INSERT INTO books (title, genre_id, publisher_id, isbn, published_year, pages, edition)
VALUES ('New Book Title', 1, 1, '978-0143039530', 2026, 300, '1st');
COMMIT;
```

---

## 3-Month Roadmap Overview

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅
├── Week 3: Sorting & Limiting ✅
├── Week 4: Data Manipulation (CRUD) 🔄 (Day 6 complete)
└── ...

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
| Week 4 | Data Manipulation (DML) | In progress |

**Total Progress:** 33 of 84 days (39%)

---

## Key Takeaways

1. **INSERT adds rows** (new records), **UPDATE modifies existing data**
2. **INTEGER PRIMARY KEY is auto-generated** - cannot insert into it
3. **NULL in INSERT** - omit column or use NULL keyword
4. **Always specify column names** in INSERT - clearer and safer
5. **UPDATE/DELETE require WHERE** - without it, affects ALL rows
6. **BETWEEN is inclusive** on both ends (remember from Week 3)
7. **Transaction = BEGIN + operations + COMMIT/ROLLBACK**
8. **Before COMMIT: changes visible to you, locked for others**
9. **Forgotten COMMIT in SQLite = auto-ROLLBACK (safe)**
10. **Wrong after COMMIT = fix with new transaction, cannot undo directly**

---

## Next Steps

1. ~~Complete INSERT fundamentals~~ ✅ Done
2. ~~Practice UPDATE operations~~ ✅ Done
3. ~~DELETE basics~~ ✅ Done
4. ~~Week 4 Day 6: Transaction Control (COMMIT, ROLLBACK)~~ ✅ Done
5. **Week 4 Day 7:** Review + Mini Quiz
6. **Week 5:** Table Design & Relationships

---

*Happy Learning!*
