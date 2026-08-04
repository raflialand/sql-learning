# Summary: SQL Learning Session

**Date:** 24 June 2026
**Database:** library-db.db (Library)
**Status:** Week 3 - Day 6 Complete ✅

---

## Day 6: Combined Queries (WHERE + ORDER BY + LIMIT)

### The 3-Clause Formula

```sql
SELECT columns
FROM table
WHERE condition(s)    -- Filter first
ORDER BY column(s)    -- Then sort
LIMIT n;               -- Finally, limit results
```

### Why Combine Them?

- `WHERE` filters to only the rows you care about
- `ORDER BY` sorts those filtered results
- `LIMIT` shows only top/bottom N

---

## Day 5: Top-N Patterns

### What is Top-N?

Top-N queries retrieve the **top (or bottom) N records** from a sorted result. This is one of the most common patterns in real-world applications.

### The Formula

**Top-N = ORDER BY + LIMIT**

| What You Want | Formula |
|---------------|---------|
| Best/Highest/Largest N | `ORDER BY col DESC LIMIT N` |
| Worst/Lowest/Smallest N | `ORDER BY col ASC LIMIT N` |

### Memory Trick

| Direction | Use When |
|-----------|----------|
| **DESC** | Largest/Biggest/Highest first |
| **ASC** | Smallest/Lowest/Cheapest first |

### Real-Life Examples

| Real Life | SQL Query |
|-----------|-----------|
| Top 3 richest people | `ORDER BY wealth DESC LIMIT 3` |
| 3 cheapest houses | `ORDER BY price ASC LIMIT 3` |
| Top 5 fastest cars | `ORDER BY speed DESC LIMIT 5` |

---

## Table Aliases Explained

### What Are Aliases?

Aliases are **nicknames for table names** that you define in the FROM or JOIN clause.

```sql
-- Without alias (long):
SELECT books.title, genres.name
FROM books
JOIN genres ON books.genre_id = genres.id

-- With alias (short):
SELECT b.title, g.name
FROM books b
JOIN genres g ON b.genre_id = g.id
```

### Common Alias Patterns

| Table | Common Alias |
|-------|-------------|
| books | b, bo, boo |
| book_copies | bc, bco |
| genres | g, ge, gen |
| members | m, me, mem |
| loans | l, lo, loa |

### Key Rules

1. **You choose the alias** - can be any letter(s) you want
2. **First letter convention** - common but not required
3. **Must use alias after defining it** - once you write `books b`, use `b.title`, not `books.title`
4. **Aliases essential when joining** - when multiple tables have same column names (like `id`)

### When Are Aliases Useful?

| Situation | Need Alias? |
|-----------|-------------|
| Only 1 table in query | No |
| Multiple tables/joins | Yes |
| Same table used twice | Yes |
| Column names unique across tables | Optional |

---

## Exercises Completed (Library Database)

### Easy Exercises
1. 3 oldest books (by published_year ASC) ✅
2. 3 newest books (by published_year DESC) ✅
3. 3 longest books (by pages DESC) ✅
4. 3 shortest books (by pages ASC) ✅

### Medium Exercises
5. 3 most recently joined members ✅
6. 3 earliest joined members ✅
7. 3 highest fines ✅

### Challenge Exercise
8. 3 largest UNPAID fines (WHERE + ORDER BY + LIMIT) ✅

**Note:** JOIN-based exercises deferred to Week 6 (not yet learned)

---

## Day 6 Exercises Completed (Library Database)

### Exercises
1. **Oldest Premium Members** - `WHERE membership_type='premium', ORDER BY membership_date ASC, LIMIT 5` ✅
2. **Longest Fiction Books** - `WHERE genre_id=1, ORDER BY pages DESC, LIMIT 3` ✅
3. **Earliest Unreturned Loans** - `WHERE return_date IS NULL, ORDER BY loan_date ASC, LIMIT 5` ✅
4. **Most Recently Published Books** - `ORDER BY published_year DESC, LIMIT 3` ✅

### Key Concepts Practiced
- Combining WHERE + ORDER BY + LIMIT in sequence
- Using IS NULL to find missing values
- ASC for ascending (oldest/shortest/earliest)
- DESC for descending (newest/longest/latest)

---

## Key Insights

### Why "Top-N Formula" Has a Name

1. **Common problem pattern** - humans naturally think in rankings ("top 3", "bottom 5")
2. **Faster communication** - developers say "Top-N query" instead of "ORDER BY + LIMIT query"
3. **Named for humans, not SQL** - SQL doesn't treat it differently

### Bottom Line

There's **no SQL magic** in "Top-N" - it's just:
```sql
ORDER BY column [DESC|ASC] LIMIT N
```

It exists because "find the best/worst X of something" is **extremely common in real life and programming**.

---

## 3-Month Roadmap Overview

```
MONTH 1: FUNDAMENTALS
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅
├── Week 3: Sorting & Limiting ← In Progress (Days 1-6 done)
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

## Next Steps

1. ~~Complete Week 3 Day 1-4~~ ✅ Done
2. ~~Week 3 Day 5: Top-N Patterns~~ ✅ Done
3. ~~Week 3 Day 6: Combined Queries~~ ✅ Done
4. **Week 3 Day 7:** Review & Mini Quiz
5. Move to **Week 4: Data Manipulation (CRUD)**

---

*Happy Learning!*
