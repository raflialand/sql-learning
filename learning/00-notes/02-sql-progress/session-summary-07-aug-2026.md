# Summary: SQL Fundamentals Learning Session

**Date:** 7 August 2026
**Track:** SQL Fundamentals
**Status:** Week 7 Day 2 — HAVING concepts learned, exercises pending

---

## Week 7: Aggregation & GROUP BY — Started

Resumed from Week 6 (complete). Began Week 7 Aggregation module using `data/sql-learn.db`.

### Day 1: MIN/MAX — Finding Extreme Values ✅

- Aggregate functions recap: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` squash N rows into 1.
- `MIN`/`MAX` work on any comparable type: numbers, dates, and **text** (alphabetical).
- Aggregates skip NULLs automatically.
- **Key rule:** aggregate functions (`MAX`, `MIN`, ...) are ILLEGAL in `WHERE` — they run AFTER WHERE in execution order (FROM → WHERE → GROUP BY → SELECT → HAVING/ORDER BY).

### Day 2: HAVING — Filtering Aggregated Data ✅ Concepts Learned

- `HAVING` filters **groups** after `GROUP BY` — can use aggregates (`COUNT`, `SUM`, `AVG`)
- `WHERE` filters **rows** before grouping — cannot use aggregates
- Execution order: `FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY`
- SQLite allows aliases in HAVING; standard SQL requires repeating the expression
- Common pitfalls: alias in HAVING, column not in GROUP BY, mixing aggregate + non-aggregate

---

## Week 7 Day 1 Practice Exercises — All 5 Completed

### Q1: Highest/lowest rated product reviews (rating score)
- Interpreted as **average rating per product** (SUM unfair due to unequal review counts; MIN/MAX too coarse on a 1-5 scale).
- Used `AVG(pr.rating)` + `GROUP BY`, `LEFT JOIN`, `WHERE pr.rating IS NOT NULL`.
- Result: Headphones & SQL Mastery (5.0), T-Shirt & Running Shoes (4.0).

### Q2: Most expensive product in each category
- `GROUP BY c.name, p.name` returned ALL products — must group only by category.
- Correct: **`ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY p.price DESC)`** in a **CTE**, outer `WHERE rn = 1`.
- Generalizes to "top N per group" via `rn <= 3`.

### Q3: Earliest and latest shipment delivery dates
- **Caught column trap:** question says *delivery* dates → `delivery_date`, NOT `shipment_date`. Two shipments had NULL delivery dates; MIN/MAX skip NULLs.
- `SELECT MIN(delivery_date), MAX(delivery_date) FROM shipments;` → 2024-01-18 / 2024-03-19.

### Q4: Employees with longest/shortest tenure
- Learned: `WHERE hire_date = MAX(hire_date)` → `misuse of aggregate function MAX()`.
- Fix: **correlated subqueries** — `WHERE hire_date = (SELECT MIN(hire_date) FROM employees) OR hire_date = (SELECT MAX(hire_date) FROM employees)`.
- Used `CASE` to label 'Highest Tenure' / 'Lowest Tenure' (highest tenure = OLDEST hire = MIN date).

### Q5: First and last product alphabetically per category
- Initial attempt found GLOBAL min/max, not per-category.
- Correct: `ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY p.name ASC)` AND `ROW_NUMBER() OVER (... ORDER BY p.name DESC)`; filter `first_rank = 1 OR last_rank = 1`.
- Single-product category (Home & Garden) satisfies both conditions — CASE picks first match.

---

## Bonus: SQLite → MySQL Migration

- Wrote `script/sqlite-to-mysql.py` (stdlib Python) → generates `data/sql-learn-mysql.sql`.
- Full dataset of `data/sql-learn.db` (12 tables, 97 rows) converted: `AUTOINCREMENT`→`AUTO_INCREMENT`, `REAL`→`DECIMAL(10,2)`, `TEXT`→`VARCHAR(255)`/`TEXT`, dates→`DATE`, `CURRENT_TIMESTAMP`→`DATETIME DEFAULT CURRENT_TIMESTAMP`, `is_*`→`TINYINT(1)`.
- Learned `SET FOREIGN_KEY_CHECKS=0/1` (disable during import, re-enable after).
- Noted: `data/sql-learn-db.sql` is a STALE 7-table seed; `data/sql-learn.db` is the evolved 12-table Week 6-7 dataset. Roadmap weeks use different DBs (sql-learn-db.sql weeks 1-5, sql-learn.db weeks 6-7, library-db.db week 3, sales-records.db for SQL Mastery).

---

## Key Takeaways

1. `WHERE col = MAX(col)` is always wrong — wrap aggregate in a subquery (correlated subquery pattern).
2. `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)` = "rank within each group"; solve top/bottom/first/last per group with it.
3. Always verify WHICH column a question means (delivery_date vs shipment_date; MIN date = longest tenure).
4. Single backticks around `table.column` (`` `p.name` ``) = one identifier "p.name" → errors in MySQL; use `p.name` or `` `p`.`name` ``.
5. Average rating is the standard "rating score" metric (not SUM — volume bias; not MIN/MAX — too coarse).

---

## Next Steps

1. ~~Week 7 Day 2: HAVING~~ ✅ Learned (concepts saved)
2. **Week 7 Day 2: HAVING Practice** — 5 exercises on `data/sql-learn.db`
3. Day 3: Multiple Aggregations & COUNT(DISTINCT).
4. Day 4: Aggregating across JOINs + date functions (strftime).
5. Week 7 Mini Quiz (target > 80%).
6. Optionally import `data/sql-learn-mysql.sql` into local MySQL and practice on it.

---

*Happy Learning!*

---

## Week 7 Day 2: HAVING — Filtering Aggregated Data

### What HAVING Does

`WHERE` filters **rows** before grouping. `HAVING` filters **groups** after grouping. You cannot use aggregate functions like `COUNT()`, `SUM()`, `AVG()` inside `WHERE` — that's where `HAVING` comes in.

```sql
-- Filter groups after aggregation
SELECT department_id, COUNT(*) AS headcount, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 3;
```

### Execution Order (Critical to Memorize)

```
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

| Clause | What it sees | Can use aggregates? |
|--------|-------------|-------------------|
| WHERE | Raw rows | No |
| GROUP BY | Groups forming | No |
| HAVING | Completed groups | Yes |
| SELECT | Final result | Yes (but aliases not in WHERE/HAVING) |

### WHERE vs HAVING — When to Use Which

| Situation | Use | Example |
|-----------|-----|---------|
| Filter individual rows | `WHERE` | Only employees in dept 3 |
| Filter after grouping | `HAVING` | Only departments with >3 employees |
| Both together | `WHERE` first, then `HAVING` | Dept 3 employees → groups with avg > 5000 |

```sql
-- WHERE + HAVING combo
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
WHERE hire_date > '2020-01-01'      -- filter rows FIRST
GROUP BY department_id
HAVING AVG(salary) > 5000;          -- filter groups SECOND
```

### Common Pitfalls

1. **Alias in HAVING** — SQLite allows `HAVING avg_salary > 5000`, but standard SQL (MySQL, Postgres) requires repeating the expression: `HAVING AVG(salary) > 5000`.
2. **Column must be in GROUP BY** — Every non-aggregate column in `SELECT` must appear in `GROUP BY` or SQL errors.
3. **Can't mix aggregate + non-aggregate** — `HAVING MAX(salary) > 5000 AND department_id = 3` fails. Filter `department_id` in `WHERE` instead.

### Why This Matters (Real-World Insight)

Most business questions are "find groups that satisfy a condition" — top customers, underperforming departments, products ordered frequently. Without HAVING, you'd have to compute everything, export results, and filter externally. HAVING lets the database do it in one query.

---

*Happy Learning!*
