# Lesson 11.2: The DQ Rule Catalog and Thresholds

A DQ program without a **rule catalog** is a pile of ad-hoc queries. The catalog turns your checks into a governed, repeatable, versionable asset — the "source of truth" for what you measure and why.

---

## The Rule Catalog Table

Store every rule in a database table:

```sql
CREATE TABLE dq_rule_catalog (
    rule_id     VARCHAR(20) PRIMARY KEY,
    dataset     VARCHAR(50) NOT NULL,
    dimension   VARCHAR(20) NOT NULL,
    rule_name   VARCHAR(200) NOT NULL,
    rule_sql    TEXT NOT NULL,          -- returns the VIOLATIONS
    threshold   DECIMAL(10,2) NOT NULL, -- max allowed violations
    severity    VARCHAR(10) NOT NULL,   -- HIGH / MEDIUM / LOW
    owner       VARCHAR(100),
    active      TINYINT DEFAULT 1
);

INSERT INTO dq_rule_catalog VALUES
('DQ-CUST-001', 'customers', 'Completeness',
 'email must not be NULL or empty',
 'SELECT customer_id FROM customers WHERE email IS NULL OR TRIM(email) = ''''',
 0, 'HIGH', 'Marketing Steward', 1),
('DQ-CUST-002', 'customers', 'Uniqueness',
 'no duplicate emails',
 'SELECT email FROM customers WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1',
 0, 'HIGH', 'Marketing Steward', 1),
('DQ-ORD-001', 'orders', 'Timeliness',
 'no future order dates',
 'SELECT order_id FROM orders WHERE order_date > CURDATE()',
 0, 'HIGH', 'Finance Steward', 1);
```

> **Note the escaping:** a single quote inside a string literal is written as `''`. Writing rule SQL as TEXT means you need a runner (app/script) to execute it — which is exactly what DQ tools do.

---

## The Rule Execution Pattern

A **DQ runner** iterates the catalog, executes each `rule_sql`, and records violations:

```sql
-- Step 1: run each rule and count violations
SELECT rule_id, COUNT(*) AS violations
FROM ( <rule_sql from catalog> ) v
```

Which, for DQ-CUST-001, is:

```sql
SELECT 'DQ-CUST-001' AS rule_id, COUNT(*) AS violations
FROM (SELECT customer_id FROM customers WHERE email IS NULL OR TRIM(email) = '') v;
```

**Expected output:**

| rule_id | violations |
|---------|------------|
| DQ-CUST-001 | 2 |

---

## Thresholds & Severity

| Level | Threshold meaning | Alerting |
|-------|-------------------|----------|
| **HIGH** | `violations = 0` (hard requirement) | Immediate, page someone |
| **MEDIUM** | `violations ≤ N` (soft limit) | Daily report |
| **LOW** | `violations % ≤ X` (trend indicator) | Weekly report |

```sql
-- Check a rule against its threshold
SELECT
    r.rule_id, r.rule_name, r.severity, r.threshold,
    v.violations,
    CASE WHEN v.violations <= r.threshold THEN 'PASS' ELSE 'FAIL' END AS status
FROM dq_rule_catalog r
JOIN (
    SELECT 'DQ-CUST-001' AS rule_id, 2 AS violations
) v ON r.rule_id = v.rule_id;
```

---

## The History / Results Table

Monitoring requires storing results over time:

```sql
CREATE TABLE dq_check_results (
    check_id     INT AUTO_INCREMENT PRIMARY KEY,
    run_date     DATE NOT NULL,
    rule_id      VARCHAR(20) NOT NULL,
    violations   INT NOT NULL,
    status       VARCHAR(10) NOT NULL
);

-- Example: record today's result
INSERT INTO dq_check_results (run_date, rule_id, violations, status)
VALUES (CURDATE(), 'DQ-CUST-001', 2, 'FAIL');
```

Then trends are a simple query:

```sql
-- Trend: violations of the email rule over the last 7 runs
SELECT run_date, violations, status
FROM dq_check_results
WHERE rule_id = 'DQ-CUST-001'
ORDER BY run_date DESC
LIMIT 7;
```

---

## The DQ Catalog + Scorecard + History = Monitoring Loop

```
dq_rule_catalog (what to check)
        │
        ▼
run each rule → violations
        │
        ├──► dq_check_results (history)
        │
        ▼
scorecard (status per rule)  ──►  dashboard / alerts
```

---

## Best Practices for the Catalog

1. **Version it** — the catalog lives with your code (a schema file), not just in the DB.
2. **Own every rule** — each row has an `owner` (the steward).
3. **Link rules to requirements** — reference the Unit 02 expectations sheet.
4. **Never delete, deactivate** — keep history for auditability.
5. **Document thresholds** — who set them and why.

---

## English Translation (of this lesson)

> "A rule catalog is a table of every DQ rule: its SQL, threshold, severity, and owner. A runner executes each rule's SQL, records violations in a history table, and compares against thresholds. This gives me a repeatable, versionable monitoring loop: catalog → run → history → scorecard. Thresholds and severity decide alerting."

---

## Key Takeaways

1. **Rule catalog** = dataset, dimension, SQL, threshold, severity, owner.
2. A **runner** executes catalog SQL and **counts violations**.
3. **History table** enables trend monitoring over time.
4. **Severity + threshold** decide how to alert (page/daily/weekly).
5. Catalog + results + scorecard = the complete monitoring loop.

**Coming up next:** Scheduling and alerting basics.
