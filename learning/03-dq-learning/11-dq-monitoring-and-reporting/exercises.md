# Exercises: Unit 11 — DQ Monitoring & Reporting

*All exercises run against `dq_learning`.*

---

## Part A: Write the Query

### Exercise 11.1 — Customers scorecard

Write a scorecard query for `customers` with these three rules:
1. Completeness: email ≥ 99% (threshold)
2. Uniqueness: 0 duplicate emails
3. Validity: 0 invalid-format emails

Each row: dimension, rule, metric, threshold, PASS/FAIL.

**Expected:** all FAIL (86.7% / 2 dupes / 2 invalid).

### Exercise 11.2 — Overall score

Extend 11.1 (use just the first two rules) to add total_rules, passed, failed, and overall_score.

**Expected:** total 2, passed 0, failed 2, score 0.

### Exercise 11.3 — Multi-dataset scorecard

Write a scorecard for:
- customers.email completeness (≥99%)
- orders.total_amount completeness (100%)
- products.unit_price validity (>0 for all, threshold 100%)

**Expected:** 3 FAIL rows.

### Exercise 11.4 — Alert query (no GROUP BY + HAVING)

Write an alert query that returns one row only when email completeness < 99%.

**Expected:** 1 row (86.7%).

### Exercise 11.5 — Rule catalog table

Write the `CREATE TABLE dq_rule_catalog` statement and insert at least 3 rules (customers email completeness, customers email uniqueness, orders future-date).

### Exercise 11.6 — History table

Write `CREATE TABLE dq_check_results` and insert two historical results for rule `DQ-CUST-001` (one PASS, one FAIL on different dates).

### Exercise 11.7 — Trend query

Write a query returning the last 7 runs of `DQ-CUST-001` from `dq_check_results`, ordered newest first.

---

## Part B: Translate the Query

### Exercise 11.8

Explain how this returns a row only when something is wrong:

```sql
SELECT 'email_completeness' AS alert,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS actual
FROM customers
HAVING actual < 99;
```

### Exercise 11.9

Explain the purpose of `NOT EXISTS` here:

```sql
INSERT INTO dq_alerts (alert_date, alert_name, detail)
SELECT NOW(), 'email_completeness', 'below 99%'
FROM customers
HAVING ROUND(COUNT(email) * 100.0 / COUNT(*), 1) < 99
  AND NOT EXISTS (
      SELECT 1 FROM dq_alerts
      WHERE alert_name = 'email_completeness' AND status = 'OPEN'
  );
```

---

## Part C: Debug the Query

### Exercise 11.10 — Buggy alert (always fires)

**Intended purpose:** alert only when email completeness < 99%.

```sql
SELECT 'email_completeness' AS alert, COUNT(email) AS cnt
FROM customers
WHERE COUNT(email) < 99;
```

**Bug:** `WHERE` can't use aggregates — must use `HAVING`. Fix it.

### Exercise 11.11 — Buggy alert (never fires)

**Intended purpose:** alert when completeness < 99%.

```sql
SELECT 'email_completeness' AS alert,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS actual
FROM customers
WHERE actual < 99;
```

**Bug:** `actual` is an alias of an aggregate — can't be used in `WHERE` (not yet computed) and aliases aren't allowed there anyway. Fix with `HAVING actual < 99`.

### Exercise 11.12 — Buggy scorecard status

**Intended purpose:** PASS when violations are 0.

```sql
SELECT rule_name, violations,
       CASE WHEN violations = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM (SELECT 'no dup emails' AS rule_name, COUNT(*) AS violations
      FROM customers
      WHERE email IN (SELECT email FROM customers GROUP BY email HAVING COUNT(*) > 1)) v;
```

**Bug (conceptual):** `email IN (dupes)` counts the *duplicate rows*, so the "violations" number is inflated and the status logic is misleading. Rewrite to count duplicate *groups* instead of rows (e.g., `SELECT COUNT(*) FROM (SELECT email FROM customers GROUP BY email HAVING COUNT(*) > 1) g`).

---

## Self-Assessment Checkpoint

- [ ] I can build a per-dimension scorecard query
- [ ] I can compute an overall score (% rules passed)
- [ ] I can write multi-dataset scorecards
- [ ] I can write aggregate alert queries using `HAVING`
- [ ] I can design a rule catalog and results/history tables
- [ ] I understand the scheduling + alerting loop (cron/Airflow → checks → alerts → delivery)

**Ready to continue?** Move to **Unit 12 — DQ Process & Tooling** (conceptual).
