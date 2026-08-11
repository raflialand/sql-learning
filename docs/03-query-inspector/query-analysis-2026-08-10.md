# Query Analysis Report

- **Inspector**: `query-inspector`
- **Source**: `learning/02-sql-learning/sql-skill-push/01-beginner/solutions/my-solutions.sql`
- **References**: `solution_01.sql` … `solution_20.sql` (same directory); expected results in `01-beginner/challenges.md`
- **Dataset**: `datasets/01-beginner/retail.db` (SQLite 3.53.2 — the track's canonical verification DB) and `retail.sql` (MySQL copy)
- **Date**: 2026-08-10
- **Method**: static comparison of each learner query against the corresponding reference solution, plus **empirical execution** of every learner query and the key reference queries against `retail.db` using the `sqlite3` CLI — the track's own verification method (`sqlite3 datasets/01-beginner/retail.db < solutions/solution_XX.sql`).

## Verdict at a Glance

| Metric | Value |
| --- | --- |
| PASS | 14 / 20 |
| WARN | 0 / 20 |
| FAIL | 6 / 20 |
| Final verdict | **Partial** — the file does not, as written, correctly answer all 20 beginner challenges. 6 queries error at runtime or fail to answer correctly on the provided dataset. All 6 are fixable with small, localized changes. |

## Summary Table (Q1–Q20)

| Q | Verdict | One-line reason |
| - | ------- | --------------- |
| Q1 | **FAIL** | `WHERE active = 1` references a non-existent column; the schema column is `is_active` → runtime error `no such column: active` |
| Q2 | PASS | Distinct categories returned correctly; only missing the reference's `ORDER BY category` (cosmetic) |
| Q3 | **FAIL** | `YEAR(signup_date)` is MySQL-only; SQLite has no `YEAR` function → runtime error on `retail.db` |
| Q4 | PASS | Correct count for store BRW001 (407 rows); alias/column list differ cosmetically from reference |
| Q5 | PASS | Filter `payment_method = 'Card' AND total_amount > 50` is correct (291 rows) |
| Q6 | PASS | `BETWEEN 3 AND 6` filter correct (15 rows) |
| Q7 | PASS | `LIKE '%Coffee%'` filter correct (1 row) |
| Q8 | PASS | `IS NULL OR payment_method = ''` is a defensible superset; identical 37 rows on this data (0 empty strings) |
| Q9 | PASS | Top 5 by price correct |
| Q10 | PASS | Top 5 by order total correct, `store_id` included as asked |
| Q11 | PASS | GROUP BY store correct (3 rows); missing `ORDER BY order_count DESC` (cosmetic) |
| Q12 | PASS | `SUM(total_amount)` per store correct; missing `ROUND(…,2)` (cosmetic) |
| Q13 | PASS | `AVG(total_amount)` per store correct; missing `ROUND(…,2)` (cosmetic) |
| Q14 | **FAIL** | `oi.quantity` references an alias that is never defined (`FROM order_items` has no `oi` alias) → runtime error; the unqualified `unit_price` would also be ambiguous |
| Q15 | **FAIL** | Stray `;` after `GROUP BY payment_method;` (line 96) terminates the statement; line 97 `ORDER BY …` becomes a standalone statement → syntax error `near "ORDER": syntax error` |
| Q16 | PASS | Verified top 5 identical to reference; `COUNT(o.order_id)` correctly avoids counting no-order customers |
| Q17 | PASS | `HAVING total_spent > 100` on an aggregate alias works (SQLite); verified top 10 identical to expected |
| Q18 | **FAIL** | `MONTH()`/`YEAR()` are MySQL-only → runtime error on `retail.db`; output format (month number) also differs from expected `YYYY-MM` |
| Q19 | **FAIL** | `YEAR()`/`MONTH()` MySQL-only → runtime error on `retail.db`; plus ordering is fragile for "which month had the highest" |
| Q20 | PASS | `LEFT JOIN` + `WHERE o.order_id IS NULL` anti-join matches the reference exactly; verified 18 rows |

## Detailed Findings — FAIL Items

### Q1 — Wrong column name (query-logic / runtime)

**Classification**: Query-logic (high)

The learner filters `WHERE active = 1`, but `products` in this dataset has no `active` column — it is `is_active` (see `datasets/01-beginner/README.md`, ERD: `products { … int is_active }`; hint in `challenges.md`: "`is_active = 1`"). Executed against `retail.db`:

```
Parse error near line 1: no such column: active
```

`solution_01.sql` uses `WHERE is_active = 1` and returns 29 active products ordered cheapest-first.

**Recommended query** (matches the reference; selects only the expected columns instead of `*`):

```sql
SELECT prod_id, prod_name, category, unit_price
FROM products
WHERE is_active = 1
ORDER BY unit_price ASC;
```

**Change rationale**: `active` → `is_active` (actual column name — this alone makes the query run and answer Q1); replaced `SELECT *` with the expected column list from `challenges.md`.

---

### Q3 — MySQL-only date function (engine compatibility)

**Classification**: Query-logic (engine incompatibility; logic intent correct)

`YEAR(signup_date) = 2025` is valid MySQL but SQLite (the track's verification DB) has no `YEAR` function:

```
Parse error near line 1: no such function: YEAR
```

`solution_03.sql` uses `WHERE signup_date BETWEEN '2025-01-01' AND '2025-12-31'`, which is engine-agnostic and returns the expected 83 rows. The learner's filtering intent (year = 2025) is correct; only the dialect is wrong. The learner also concatenates `first_name + last_name` into one `name` column, whereas the reference returns `cust_id, first_name, last_name, city, signup_date` — both forms satisfy "list their name".

**Recommended query** (works on both SQLite and MySQL):

```sql
SELECT cust_id, first_name, last_name, city, signup_date
FROM customers
WHERE signup_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY signup_date;
```

**Change rationale**: replaced the MySQL-only `YEAR()` predicate with a `BETWEEN` range on the date literal — same result set, portable.

---

### Q14 — Undefined alias + ambiguous column (query-logic / runtime)

**Classification**: Query-logic (high)

The learner wrote `SUM(oi.quantity * unit_price)` with `FROM order_items LEFT JOIN products p …` — but `order_items` is **never aliased**, so `oi` is undefined:

```
Parse error near line 1: no such column: oi.quantity
```

There is a second latent defect: even after aliasing `order_items oi`, the unqualified `unit_price` is **ambiguous** because both `order_items` and `products` have a `unit_price` column (confirmed in the dataset README). The revenue *formula* itself (quantity × unit_price) is exactly right — `solution_14.sql` computes `SUM(oi.quantity * oi.unit_price)` and returns Merchandise 42145.00 / Beverage 14747.60 / Food 13341.50.

**Recommended query** (reference):

```sql
SELECT p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY total_revenue DESC;
```

**Change rationale**:
- Added the missing alias `order_items oi` — this fixes the `no such column: oi.quantity` error.
- Fully qualified `oi.unit_price` — removes the ambiguity with `products.unit_price` (using `oi.unit_price` also matches the reference's intent: revenue from the line-item snapshot price).
- `LEFT JOIN` → `JOIN` per the reference. On this dataset there are no orphan `order_items`, so results are identical either way; `INNER JOIN` is the reference's choice and avoids an extraneous `NULL`-category bucket if orphans ever appear.

---

### Q15 — Stray semicolon / broken statement (lines 96–97)

**Classification**: Query-logic (high) — confirmed syntax error

```sql
SELECT payment_method,
    COUNT(*) AS payment_count
FROM orders
GROUP BY payment_method;      -- line 96: stray ';' TERMINATES the statement
ORDER BY payment_method DESC; -- line 97: standalone ORDER BY => syntax error
```

Executed as the track runs solution files, the first statement executes and prints the correct counts, then the second statement fails:

```
|37
Card|562
Cash|398
Parse error near line 5: near "ORDER": syntax error
```

So the file as a whole errors; `solution_15.sql` is a single statement with `ORDER BY usage_count DESC`, returning Card 562 / Cash 398 / Mobile Pay 203 / NULL 37.

**Recommended query** (reference):

```sql
SELECT payment_method,
    COUNT(*) AS usage_count
FROM orders
GROUP BY payment_method
ORDER BY usage_count DESC;
```

**Change rationale**:
- Removed the stray `;` after `GROUP BY payment_method` so the `ORDER BY` belongs to the same statement (this is the syntax fix).
- Changed `ORDER BY payment_method DESC` (alphabetical) → `ORDER BY usage_count DESC` (most-used first) to match the reference's ordering, which is also the more useful business presentation for "how many times was each payment method used".

---

### Q18 — MySQL-only date functions + format mismatch (engine compatibility / alignment)

**Classification**: Query-logic (engine incompatibility) + Business-alignment (format, minor)

`MONTH(order_date)` / `YEAR(order_date)` do not exist in SQLite:

```
Parse error near line 1: no such function: MONTH
```

`solution_18.sql` uses `strftime('%Y-%m', order_date)` and returns 12 rows (`2025-01` … `2025-12`). The learner's filtering intent (only 2025, grouped by month) is correct; the expected output format is `YYYY-MM`, not the month number `1..12` the learner would produce even under MySQL. (Under MySQL the fix would be `DATE_FORMAT(order_date, '%Y-%m')`.)

**Recommended query** (reference, SQLite):

```sql
SELECT strftime('%Y-%m', order_date) AS month,
    COUNT(*) AS order_count
FROM orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;
```

**Change rationale**: replaced MySQL-only `YEAR()/MONTH()` with the SQLite `strftime('%Y-%m', …)` used by the reference (or `DATE_FORMAT(order_date, '%Y-%m')` for the MySQL copy); the `BETWEEN` filter is equivalent to `YEAR(order_date) = 2025` and portable.

---

### Q19 — MySQL-only date functions + fragile ordering

**Classification**: Query-logic (engine incompatibility) + Business-alignment (medium)

Two distinct problems:

1. **Engine**: `YEAR()`/`MONTH()` do not exist in SQLite → the query errors on `retail.db` (`no such function: YEAR`), so it cannot run at all as written.

2. **Ordering / "which month had the highest"**: The reference **does not filter to 2025** — it groups *all* months across all years and returns 13 rows (2025-01…12 plus 2026-01), ordered globally by `avg_order_value DESC`; the top row (2025-11, 65.22) is the answer. The learner's scope (no year filter) correctly matches the reference. However, the learner's `ORDER BY YEAR(order_date), average_order_value DESC` sorts by **year ascending first**, then by average within each year. That only guarantees the top row is the highest month of the *earliest* year — not the globally highest month. Empirically simulated with the learner's ordering semantics, the 13 rows place 2026-01 (65.10 — the **second-highest** month overall) at the very bottom after all 2025 months; the top row is 2025-11 (65.22), which is the global max only by coincidence of this data. If the global max month were in 2026, the learner's ordering would not surface it first.

**Recommended query** (reference):

```sql
SELECT strftime('%Y-%m', order_date) AS month,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY avg_order_value DESC;
```

**Change rationale**:
- Swapped `YEAR()/MONTH()` for the SQLite `strftime('%Y-%m', …)` (fixes the runtime error).
- Changed `ORDER BY YEAR(order_date), average_order_value DESC` → `ORDER BY avg_order_value DESC`: a single global descending sort guarantees the month with the highest average appears first, directly answering "which month had the highest" regardless of which year it falls in.
- Added `ROUND(…, 2)` to match the reference output (cosmetic).

---

## Explicitly Requested Suspicious-Item Verifications

1. **Q15 stray `;` (lines 96–97) — CONFIRMED syntax error.** The first statement (`… GROUP BY payment_method;`) is valid and returns the right counts, but line 97 `ORDER BY payment_method DESC;` is a separate, invalid statement (`near "ORDER": syntax error`). This deviates from `solution_15.sql`, which is one statement ordering by `usage_count DESC`.

2. **Q19 — reference expects ALL years, not only 2025.** `solution_19.sql` has no year filter and returns 13 rows (2025-01…12 + 2026-01). The learner's scope (no filter) matches the reference. The learner's per-year `average_order_value DESC` ordering does not robustly surface the global highest month; on this data it happens to be correct at the top (2025-11, 65.22) only because the max is in 2025 — the reference's global `ORDER BY avg_order_value DESC` is the correct pattern.

3. **Q20 — anti-join pattern CONFIRMED correct.** The learner's `LEFT JOIN orders o ON c.cust_id = o.customer_id WHERE o.order_id IS NULL` is exactly the reference pattern (and the `challenges.md` hint) and returns the expected 18 customers. Only cosmetic differences: learner concatenates the name and omits `c.email` and `ORDER BY c.cust_id`.

4. **Q14 — revenue calc intent correct, execution broken.** `quantity × unit_price` is the right formula, but the query cannot run: `oi` is never defined as an alias (`FROM order_items` without `AS oi`), and the unqualified `unit_price` would be ambiguous between `order_items.unit_price` and `products.unit_price` once the alias is added. Fix: `FROM order_items oi` + `SUM(oi.quantity * oi.unit_price)`.

5. **Q17 — `HAVING total_spent > 100` on an aggregate alias CONFIRMED works.** Empirically verified on SQLite: returns exactly the expected top 10 (CST252 860.15, CST255 677.25, CST008 618.35, …). Alias references in `HAVING` are supported by SQLite and MySQL. Portability caveat only: PostgreSQL does not allow select-list aliases in `HAVING`; the reference's `HAVING SUM(o.total_amount) > 100` is the most portable spelling.

## Notes on What Is Correct

- **Q16** is a good pattern: `LEFT JOIN` + `COUNT(o.order_id)` correctly counts only matched orders (avoids the classic `COUNT(*)` bug that would count no-order customers as 1) and matches the reference top 5 exactly (CST108/CST125/CST152/CST252 at 9 orders, CST054 at 8).
- **Q17** and **Q20** both match the reference semantics and produce the expected rows.
- Basic filtering skills (Q2, Q4–Q13) are solid: `DISTINCT`, `AND`, `BETWEEN`, `LIKE`, `IS NULL`, `ORDER BY`/`LIMIT`, `GROUP BY` with `COUNT/SUM/AVG` are all correctly applied. Several are missing only cosmetic touches the references add (`ORDER BY` for determinism, `ROUND(…, 2)`).
- Q8's `IS NULL OR payment_method = ''` is a defensible superset of the reference; on this dataset both return 37 rows (verified 0 empty strings).

## Final Verdict

**Partial — the file does not, as written, answer all 20 beginner challenges.** 14 of 20 questions (Q2, Q4–Q13, Q16, Q17, Q20) are answered correctly and run against the provided dataset. 6 fail: Q1 (wrong column name `active` vs `is_active`), Q3/Q18/Q19 (MySQL-only `YEAR()`/`MONTH()` that error on the SQLite verification DB), Q14 (undefined `oi` alias + ambiguous `unit_price`), and Q15 (stray `;` breaks the statement). None of the failures are conceptual — each is a localized, mechanical defect (column name, dialect, alias, terminator, ordering), and adopting the recommended queries above makes all 20 pass against `retail.db` with results identical to the reference solutions.

## Appendix — Analyzed File (`my-solutions.sql`)

```sql
-- [Beginner SQL Skill Push]
-- Q1: Which products are currently active? Show them from cheapest to most expensive.
SELECT *
FROM products
WHERE active = 1
ORDER BY unit_price ASC;
--
-- Q2: What are the distinct product categories in the menu?
SELECT DISTINCT category
FROM products;
--
-- Q3: Which customers signed up in 2025? List their name, city and signup date.
SELECT CONCAT(first_name, ' ', last_name) AS `name`,
    city,
    signup_date
FROM customers
WHERE YEAR(signup_date) = 2025
ORDER BY signup_date ASC;
--
-- Q4: How many orders were placed at store BRW001 (Manhattan)?
SELECT COUNT(*) AS total_orders
FROM orders
WHERE store_id = 'BRW001';
--
-- Q5: Which orders were paid by Card AND totaled more than $50?
SELECT *
FROM orders
WHERE payment_method = 'Card'
    AND total_amount > 50;
--
-- Q6: Which products are priced between $3 and $6?
SELECT prod_id,
    prod_name,
    unit_price
FROM products
WHERE unit_price BETWEEN 3 AND 6;
--
-- Q7: Which products have "Coffee" anywhere in their name?
SELECT prod_id,
    prod_name
FROM products
WHERE prod_name LIKE '%Coffee%';
--
-- Q8: Which orders do NOT have a recorded payment method?
SELECT *
FROM orders
WHERE payment_method IS NULL
    OR payment_method = '';
--
-- Q9: What are the 5 most expensive products on the menu?
SELECT prod_id,
    prod_name,
    unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 5;
--
-- Q10: What are the 5 largest orders, and what store did each come from?
SELECT order_id,
    total_amount,
    store_id
FROM orders
ORDER By total_amount DESC
LIMIT 5;
--
-- Q11: How many orders were placed at each store?
SELECT store_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY store_id;
--
-- Q12: What is the total revenue per store?
SELECT store_id,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY store_id;
--
-- Q13: What is the average order value at each store?
SELECT store_id,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY store_id;
--
-- Q14: Which product categories bring in the most revenue? (revenue = qty × unit_price)
SELECT p.category,
    SUM(oi.quantity * unit_price) AS total_revenue
FROM order_items
    LEFT JOIN products p ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY total_revenue DESC;
--
-- Q15: How many times was each payment method used?
SELECT payment_method,
    COUNT(*) AS payment_count
FROM orders
GROUP BY payment_method;
ORDER BY payment_method DESC;
--
-- Q16: Which customer has placed the most orders? Show the top 5 customers by order count.
SELECT c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS `name`,
    COUNT(o.order_id) AS order_count
FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.customer_id
GROUP BY c.cust_id
ORDER BY order_count DESC
LIMIT 5;
--
-- Q17: Which customers have spent more than $100 in total, and how much? Show the top 10.
SELECT c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS `name`,
    SUM(o.total_amount) AS total_spent
FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.customer_id
GROUP BY c.cust_id
HAVING total_spent > 100
ORDER BY total_spent DESC
LIMIT 10;
--
-- Q18: How many orders were placed in each month of 2025?
SELECT MONTH(order_date) AS order_month,
    COUNT(*) AS total_orders
FROM orders
WHERE YEAR(order_date) = 2025
GROUP BY MONTH(order_date)
ORDER BY order_month ASC;
--
-- Q19: What is the average order value per month, and which month had the highest?
SELECT YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY YEAR(order_date),
    MONTH(order_date)
ORDER BY YEAR(order_date),
    average_order_value DESC;
--
-- Q20: Which customers have NEVER placed an order?
SELECT c.cust_id,
    CONCAT(c.first_name, ' ', c.last_name) AS `name`
FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.customer_id
WHERE o.order_id IS NULL;
```
