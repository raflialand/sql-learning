# Query Analysis Report

- **Inspector**: `query-inspector`
- **Source**: `script/01-sql/query-inspector-smoke-test.txt`
- **Date**: 2026-08-03

## Stated Business Requirement

> show the top 3 highest-paid employees per department

## Analyzed Query

```sql
select
    e.id,
    e.name as employee_name,
    e.salary,
    d.name as department
from employees e
inner join departments d
    on e.department_id = d.id
order by e.salary desc
limit 3;
```

## Findings Summary

| # | Severity | Classification | Issue |
| - | -------- | -------------- | ----- |
| 1 | High | Business-alignment | `ORDER BY e.salary DESC LIMIT 3` returns the **top 3 employees overall**, not **top 3 per department** |
| 2 | High | Query-logic | No partition/grouping on department exists, so per-department ranking is impossible in this shape |
| 3 | Medium | Business-alignment | No strategy for ties: equal salaries can arbitrarily drop a valid "top 3" member |

The SQL itself is syntactically valid and semantically consistent — the columns resolve, the join is correct, and the ordering is well-formed. The core defect is that the query answers a **different question** than the one asked.

## Mismatch Details

### Mismatch 1 — Global top-3 instead of per-department top-3

**Classification**: Business-alignment (high)

The requirement asks for the top 3 highest-paid employees **in each department**. A global `ORDER BY e.salary DESC LIMIT 3` only ever returns a single global top-3 list. If all three best-paid employees work in one department, the other departments are completely absent from the result.

**Current behavior**:
```
+------+---------------+--------+------------+
| id   | employee_name | salary | department |
+------+---------------+--------+------------+
| ...  | ...           | 150000 | Sales      |   <- global top 1
| ...  | ...           | 145000 | Sales      |   <- global top 2
| ...  | ...           | 140000 | Sales      |   <- global top 3 (Sales dominates)
+------+---------------+--------+------------+
```

**Recommended fix**: rank employees within each department using a window function, then filter to the top 3 per partition.

```sql
-- Recommended query 1: window function (ROW_NUMBER)
with ranked as (
    select
        e.id,
        e.name as employee_name,
        e.salary,
        d.name as department,
        row_number() over (
            partition by e.department_id
            order by e.salary desc
        ) as rn
    from employees e
    inner join departments d
        on e.department_id = d.id
)
select
    id,
    employee_name,
    salary,
    department
from ranked
where rn <= 3
order by department, salary desc;
```

**Change rationale relative to the submitted query**:
- Added `with ranked as (...)`: wraps the base select so the ranking result can be filtered.
- Added `row_number() over (partition by e.department_id order by e.salary desc)`: assigns a rank per department, which the original lacked entirely.
- Replaced `limit 3` with `where rn <= 3`: the filter now applies **within each department partition** instead of the whole result set.
- Added `order by department, salary desc`: groups the output by department with highest salary first, matching the "per department" requirement.

**Alternative (no window functions)**: correlated subquery counting higher earners in the same department.

```sql
-- Recommended query 2: correlated subquery (portable to older SQL dialects)
select
    e.id,
    e.name as employee_name,
    e.salary,
    d.name as department
from employees e
inner join departments d
    on e.department_id = d.id
where (
    select count(*)
    from employees e2
    where e2.department_id = e.department_id
      and e2.salary > e.salary
) < 3
order by d.name, e.salary desc;
```

**Change rationale**: replaces the global `ORDER BY ... LIMIT 3` with a per-department filter that counts how many employees in the same department earn more; keep only rows with fewer than 3 such employees.

### Mismatch 2 — No grouping / partition mechanism present

**Classification**: Query-logic (high)

A query that wants "top N per group" must group (or partition) rows. The submitted query has no `GROUP BY`, no `PARTITION BY`, and no correlated subquery — there is no construct anywhere that would allow per-department ranking. This is not a syntax error; it is a structural/logical gap. Mismatch 1's recommended queries both address it by introducing a ranking/filtering mechanism keyed on `department_id`.

### Mismatch 3 — Tie handling not defined

**Classification**: Business-alignment (medium)

With `ROW_NUMBER`, if two employees in the same department have identical salaries at the boundary of the top 3, one is arbitrarily excluded. Decide the intended semantics:

- `DENSE_RANK()` — include all employees tied at rank 3 (may return more than 3 rows per department).
- `RANK()` — include all ties at any rank.
- `ROW_NUMBER()` — exactly 3 rows per department, deterministic if a stable tiebreaker is added.

```sql
-- Recommended query 3: deterministic ROW_NUMBER with salary tiebreaker
with ranked as (
    select
        e.id,
        e.name as employee_name,
        e.salary,
        d.name as department,
        row_number() over (
            partition by e.department_id
            order by e.salary desc, e.name asc
        ) as rn
    from employees e
    inner join departments d
        on e.department_id = d.id
)
select
    id,
    employee_name,
    salary,
    department
from ranked
where rn <= 3
order by department, salary desc;
```

**Change rationale**: added `e.name asc` as a secondary `ORDER BY` key inside the window so the outcome is deterministic when salaries tie. If ties should be kept rather than broken, swap `row_number()` for `dense_rank()`.

## Notes on what is correct

- `select` columns, aliases, and case conventions are clean.
- `inner join departments d on e.department_id = d.id` is correct and appropriate — employees without a department are excluded, which is acceptable for a per-department report.
- `order by e.salary desc` orders by salary descending; the intent is right, only the scope (`limit 3`) is wrong.

## Verdict

**Not acceptable as submitted.** The query executes successfully but returns the global top-3 employees instead of the top 3 per department — a business-alignment failure. Adopt Recommended query 1 (or 2 for older SQL versions), and explicitly decide tie-handling semantics per Mismatch 3.
