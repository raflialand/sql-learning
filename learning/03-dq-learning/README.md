# Data Quality Engineer — SQL Learning Module

A self-paced, modular path from **beginner → advanced Data Quality Engineer**, built entirely around **MySQL 8.0** SQL practice. You learn the *what* and *why* of data quality, then do real checks against a purpose-built **dirty dataset** seeded with intentional defects.

> **Philosophy:** Business context comes first. You cannot judge whether data is "good" until you know what decisions it supports. Every unit in this module is grounded in that idea.

---

## Learning Path

```
Foundations → Business Context → Profiling → 6 DQ Dimensions → Anomaly Detection → Reporting → Process/Tooling → Capstone
```

| Phase | Units | Skill level |
|-------|-------|-------------|
| Conceptual foundation | 01, 02 | Beginner (mostly reading) |
| Profiling skill | 03 | Beginner SQL |
| Dimension-by-dimension SQL | 04–09 | Intermediate |
| Advanced analytics | 10 | Intermediate → Advanced |
| Reporting & monitoring | 11 | Advanced |
| Process, tooling, governance | 12 | Advanced (conceptual) |
| Integration | 13 | Advanced (capstone) |

The workflow taught throughout:

> **understand business → understand data (profile) → define rules → measure → remediate → monitor**

---

## Prerequisites

- **MySQL 8.0** installed and running (Windows: `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`).
- Comfort with basic `SELECT`, `WHERE`, `GROUP BY`, `JOIN`. If you are new to SQL, finish Month 1–2 of the [3-month SQL roadmap](../02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md) first.
- Optionally MySQL Workbench for a GUI.

---

## Setup

1. **Verify MySQL**
   ```bash
   mysql --version
   # Expected: Ver 8.0.x
   ```

2. **Connect as root**
   ```bash
   mysql -u root -p
   ```

3. **Load the dirty dataset**
   ```sql
   SOURCE learning/03-dq-learning/datasets/dq_dataset.sql;
   ```

4. **Load the clean reference dataset** (needed for Unit 07 Accuracy)
   ```sql
   SOURCE learning/03-dq-learning/datasets/dq_dataset_clean.sql;
   ```

5. **Sanity check**
   ```sql
   SELECT 'customers' AS tbl, COUNT(*) AS rows FROM customers
   UNION ALL SELECT 'products', COUNT(*) FROM products
   UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
   UNION ALL SELECT 'orders', COUNT(*) FROM orders
   UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
   UNION ALL SELECT 'daily_sales', COUNT(*) FROM daily_sales;
   ```
   Expected: customers **15**, products **12**, addresses **12**, orders **15**, order_items **20**, daily_sales **184**.

> The reference date for all timeliness exercises is **2026-08-03** — any date after it is "in the future".

---

## Folder Structure

```
learning/03-dq-learning/
├── README.md                    # This file
├── datasets/
│   ├── dq_dataset.sql           # Dirty dataset (schema + seeded defects)
│   ├── dq_dataset_clean.sql     # Clean "master data" reference
│   └── dq_dataset_schema.md     # Table map + documented defects per table
├── 01-dq-foundations/           # What is Data Quality
├── 02-business-context/         # Why context comes before checks
├── 03-data-profiling/           # Row counts, stats, distributions, NULL rates
├── 04-completeness/             # Missing / NULL analysis
├── 05-uniqueness/               # Duplicate detection & dedup
├── 06-validity/                 # Format, domain, range, reference checks
├── 07-accuracy/                 # Cross-field, master-data, business rules
├── 08-consistency/              # Orphans, cross-table, format/unit consistency
├── 09-timeliness/               # Freshness, batch windows, future dates
├── 10-anomaly-detection/        # z-score, IQR, shift & spike detection
├── 11-dq-monitoring-and-reporting/  # Scorecards, rule catalogs, alerting
├── 12-dq-process-and-tooling/   # Governance, contracts, tools landscape
├── 13-capstone/                 # Full DQ audit of the dirty dataset
└── solutions/                   # Executable solution SQL per unit
```

---

## How Each Unit Works

1. Read the lesson files **in order** (`01-…` → `02-…`).
2. Run every example query in MySQL.
3. Complete the `exercises.md` at the end of the unit.
4. Check your answers in `solutions/` (file `solution_<unit>_<exercise>.sql`).
5. Tick the **self-assessment checkpoint** at the end of each exercises file.

Exercises come in three flavors (mirroring the `sql-mastery` conventions):

- **Write the Query** — translate a business request into SQL.
- **Translate the Query** — explain a given SQL query in plain English.
- **Debug the Query** — find and fix intentionally broken queries.

---

## Unit Map

| Unit | Focus | Key SQL |
|------|-------|---------|
| 01 | What is data quality, 6 dimensions, roles, lifecycle | — |
| 02 | Business context, requirements → rules, stakeholder questions | — |
| 03 | Data profiling | `COUNT`, `COUNT(DISTINCT)`, `MIN/MAX/AVG/STDDEV`, `GROUP BY` |
| 04 | Completeness | `IS NULL`, `COUNT/COUNT(*)`, ratios |
| 05 | Uniqueness | `GROUP BY ... HAVING`, `ROW_NUMBER() OVER`, `LOWER/TRIM` |
| 06 | Validity | `REGEXP`, `CASE`, ranges, FK lookups |
| 07 | Accuracy | joins, `qty*price=total`, master-data diff |
| 08 | Consistency | `LEFT JOIN ... IS NULL`, cross-table diff, `UPPER` |
| 09 | Timeliness | `CURDATE()`, `DATEDIFF`, `MAX(date)`, batch windows |
| 10 | Anomaly detection | `STDDEV_POP`, z-score, percentiles, `LAG()`, moving avg |
| 11 | Monitoring & reporting | scorecard views, threshold queries, alert views |
| 12 | Process & tooling | conceptual (Great Expectations, dbt tests, Soda) |
| 13 | Capstone | everything combined into a written audit |

---

## Tips for Success

1. **Write, don't just read.** Type every query and run it.
2. **Predict before you run.** Guess the output, then check.
3. **Use the defect map.** `dq_dataset_schema.md` lists every planted defect — use it to verify your checks catch them all.
4. **Translate to English.** If you can explain a query in plain language, you understand it.
5. **Fix forward.** After detecting a defect, write the SQL to find it *and* the SQL to clean it.

---

## Relationship to the 3-Month SQL Roadmap

The `learning-progress` skill tracks this module as a **13-unit** track registered in `learning/00-notes/tracks.md`. The module is **MySQL-native and self-paced**; treat it as a focused specialization after you have solid SQL fundamentals.
