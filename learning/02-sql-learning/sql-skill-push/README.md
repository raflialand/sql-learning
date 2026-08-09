# SQL Skill Push — Practice-by-Solving Module

Sharpen your SQL by **solving challenges**, not by reading theory. Each challenge is a real business question with an **expected result** (sample rows + total row count) that your query must reproduce exactly.

## Structure

```
sql-skill-push/
├── 01-beginner/      20 challenges   coffee shop chain   (SELECT, WHERE, ORDER BY, GROUP BY, aggregates)
├── 02-intermediate/  20 challenges   e-commerce          (JOINs, HAVING, subqueries, CTEs, CASE, basic windows)
├── 03-advanced/      20 challenges   telecom carrier     (window funcs, correlated subs, recursive CTE, set ops, pivots, cohorts)
├── datasets/         one business-profiled dataset per level (MySQL .sql + SQLite .db)
└── _tools/           generator + verification helper
```

Each `challenges.md` contains 20 numbered questions. Solutions are in the matching `solutions/` folder (`solution_01.sql` … `solution_20.sql`).

## Datasets & business context

Each level uses its own dataset so questions have meaningful answers. Read the dataset README first to understand the business:

| Level | Dataset | Business | Row counts |
| --- | --- | --- | --- |
| Beginner | `datasets/01-beginner/retail.db` | Brew & Co. coffee shop (3 stores) | 1,200 orders, 4 tables |
| Intermediate | `datasets/02-intermediate/ecommerce.db` | MarketHub marketplace | 2,800 orders, 8 tables |
| Advanced | `datasets/03-advanced/telecom.db` | NovaTel telecom carrier | 4,500 subscribers, 7 tables |

Each dataset ships in two formats:
- **`.sql`** — MySQL 8.x DDL + INSERT, for loading into MySQL.
- **`.db`** — SQLite copy, for practice in DB Browser for SQLite / `sqlite3` CLI.

## Requirements

- **MySQL 8.x** for the `.sql` datasets (needed for window functions, CTEs, INTERSECT/EXCEPT in advanced solutions).
- **SQLite 3.25+** if you practice on the `.db` files instead.

## How to use

1. Pick a level and open `challenges.md`.
2. Read the dataset README for that level (business context + data notes).
3. Write your query, run it against the dataset, and compare your output with the **expected result** shown under each question (first rows + total count).
4. If stuck, check the matching `solutions/solution_XX.sql`.

### Running a query

SQLite:
```bash
sqlite3 datasets/01-beginner/retail.db < 01-beginner/solutions/solution_05.sql
```

MySQL (after loading the dataset):
```bash
mysql -u user -p < datasets/02-intermediate/ecommerce.sql   # one-time load
mysql -u user -p ecommerce -e "SELECT ..."
```

Helper (any level):
```bash
python _tools/run_query.py datasets/01-beginner/retail.db 01-beginner/solutions/solution_05.sql
```

## Expected results

Every expected result is **verified** — the solutions were actually executed against the SQLite copies to capture the shown rows and counts. `(12 rows total; 6 shown)` means the query returns 12 rows and only the first 6 are printed.

**Note on dialect:** questions and solutions are authored for MySQL 8.x. Where the SQLite verification copy uses a different function name (e.g. `strftime` vs `DATE_FORMAT`, `julianday` vs `DATEDIFF`), the hint calls it out. Row content is identical across both.

## Progress tracking

Session notes for this module live in `learning/00-notes/04-sql-push/`. Track your progress there (e.g. `Beginner Q1–Q12 ✅`).
