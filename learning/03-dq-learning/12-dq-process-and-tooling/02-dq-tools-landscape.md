# Lesson 12.2: The DQ Tools Landscape

You've learned to write DQ checks in raw SQL. In industry, those same checks are usually packaged into **tools**. Understanding the landscape helps you map your SQL knowledge onto real tools.

---

## The Three Categories

| Category | Tools | What they do | How it maps to your SQL |
|----------|-------|--------------|-------------------------|
| **Data profiling** | AWS Glue DataBrew, Great Expectations profiling, OpenRefine | Explore and summarize data | Unit 03 patterns |
| **Validation/expectations** | Great Expectations, Soda Core, dbt tests, Soda SQL | Declare rules, validate data, report results | Units 04–09 patterns |
| **Observability** | Monte Carlo, Soda Cloud, Anomalo, Great Expectations Cloud | Continuous monitoring, anomaly detection, alerting | Units 10–11 patterns |

---

## The Big Three You'll Meet

### 1. Great Expectations (GE)
- Python library. You write **expectations** like "column values must not be null" or "column values must be between 1 and 100".
- Generates a **validation report** (pass/fail per expectation) — exactly your scorecard (Unit 11).
- SQL patterns → GE equivalents:

| Your SQL | GE expectation |
|----------|----------------|
| `WHERE email IS NULL` | `expect_column_values_to_not_be_null("email")` |
| `GROUP BY email HAVING COUNT(*) > 1` | `expect_column_values_to_be_unique("email")` |
| `REGEXP` email check | `expect_column_values_to_match_regex("email", "...")` |
| `unit_price > 0` | `expect_column_values_to_be_between("unit_price", min=0)` |

### 2. dbt tests
- dbt is a SQL transformation tool; **tests** are assertions on your models:
  - Built-ins: `not_null`, `unique`, `accepted_values`, `relationships`.
  - Custom: any SQL returning rows when the test fails.
- `relationships` test = your orphan check (Unit 08). `accepted_values` = your domain check (Unit 06). **A dbt test is literally a SQL query that must return zero rows.**

```sql
-- dbt custom test: orders must not reference missing customers
SELECT o.order_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
```

### 3. Soda
- Declarative checks in YAML with SQL under the hood:
```yaml
checks for orders:
  - row_count > 0
  - missing_count(total_amount) = 0
  - invalid_count(status) = 0:
      valid values: ['shipped', 'pending', 'cancelled']
  - freshness(order_date) < 1d
```
- Every one of those is a SQL aggregate you wrote in Units 04–11.

---

## What the Tools Add (that raw SQL doesn't)

| Capability | Value |
|-----------|-------|
| **Declarative syntax** | Rules read like plain English, versionable |
| **Result artifacts** | HTML/JSON validation reports |
| **Scheduling + alerting** | Built-in cron/CI integration, Slack/email |
| **Data lineage** | Know which pipeline step produced bad data |
| **Reference/expectations reuse** | Suite versioning, shared across teams |
| **Observability** | Automatic anomaly detection with history |

---

## Tool vs Raw SQL — When to Use Each

| Situation | Prefer |
|-----------|--------|
| One-off investigation | **Raw SQL** (fast, no setup) |
| Quick ad-hoc profiling | **Raw SQL** |
| Governed, repeatable checks in a pipeline | **Tool** (dbt test / GE / Soda) |
| Automated monitoring & alerting | **Tool** |
| You have no tooling and need something today | **Raw SQL + cron** (Unit 11) |

> **Key message:** the *logic* is identical. A tool is a wrapper around the SQL patterns you've mastered. Learn SQL first (you did), and tools become configuration, not magic.

---

## English Translation (of this lesson)

> "Industry DQ tools — Great Expectations, dbt tests, Soda, observability platforms — are wrappers around the exact SQL patterns I've learned. My null checks are `not_null`, my duplicates are `unique`, my orphans are `relationships`. Tools add declarative syntax, reports, scheduling, and lineage, but the logic is mine. For one-off work I use raw SQL; for governed pipelines I use a tool."

---

## Key Takeaways

1. Tools fall into **profiling, validation, observability** categories.
2. **Great Expectations** = Python expectations ≈ your validation SQL.
3. **dbt tests** = SQL assertions returning zero rows when passing.
4. **Soda** = declarative checks over the same aggregates.
5. **Tools wrap your SQL** — master the SQL, and tools are configuration.

**Coming up next:** Writing a DQ test suite.
