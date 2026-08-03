# Exercises: Unit 12 — DQ Process & Tooling

*Conceptual unit — mostly writing and mapping, light SQL.*

---

## Part A: Process & Contracts

### Exercise 12.1 — Governance vocabulary

Define in one sentence each: Data Owner, Data Steward, Data Contract, Data Governance Council.

### Exercise 12.2 — Write a data contract

Write a data contract for the `customers` table. Include: producer/consumer, required fields, allowed values, key, SLAs (completeness %, freshness), and owner.

### Exercise 12.3 — Contract → SQL

Pick three requirements from your contract in 12.2 and write the exact SQL check that enforces each.

### Exercise 12.4 — Who decides?

For each situation, say who decides (owner, steward, or council):
1. Email completeness threshold raised from 95% to 99%.
2. Whether a disputed duplicate customer is really the same person.
3. A new cross-department rule that conflicts with an existing policy.

---

## Part B: Tooling

### Exercise 12.5 — Map SQL → tools

Fill the table (write the dbt/GE equivalent):

| Your SQL | GE expectation | dbt test |
|----------|----------------|----------|
| `WHERE email IS NULL` | | |
| `GROUP BY email HAVING COUNT(*) > 1` | | |
| `NOT REGEXP email pattern` | | |
| `LEFT JOIN ... IS NULL` (orphan) | | |

### Exercise 12.6 — Tool vs SQL decision

For each scenario, say "raw SQL" or "tool" and justify:
1. A one-off check to see why last night's orders look weird.
2. A governed completeness check that must run on every nightly pipeline.
3. Monitoring the daily_sales spike with automated alerts.

### Exercise 12.7 — Translate a dbt test

The dbt test below is the standard `relationships` test. Write the equivalent raw SQL you'd run in MySQL:

```sql
-- dbt: relationships: fk=product_id to ref('products'), field=product_id
SELECT *
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
```

(What should it return for our dataset?)

---

## Part C: Writing a Test Suite

### Exercise 12.8 — The suite principle

State the "zero rows = pass" principle in your own words. Why does returning *offending rows* matter (vs only a count)?

### Exercise 12.9 — Products test suite

Write a single-query (UNION ALL) test suite for `products` with at least 4 tests:
1. completeness: product_name not NULL
2. uniqueness: no duplicate SKUs
3. validity: unit_price > 0
4. validity: weight within 0.1..50
5. consistency: no active product with past discontinuation date

**Expected failure counts:** 1 (NULL category is not tested here), dup SKUs 2, price 2, weight 1, lifecycle 1.

### Exercise 12.10 — From suite to catalog

Take test `PROD-001` from 12.9 and write its row in the `dq_rule_catalog` format (rule_id, dataset, dimension, rule_name, rule_sql, threshold, severity, owner).

---

## Self-Assessment Checkpoint

- [ ] I can explain governance roles (owner, steward, council)
- [ ] I can write a data contract from a business brief
- [ ] I can map contract requirements to SQL rules
- [ ] I can translate my SQL checks to GE expectations and dbt tests
- [ ] I know when to use raw SQL vs a tool
- [ ] I can write a complete test suite and a rule-catalog entry

**Ready to continue?** Move to **Unit 13 — Capstone**.
