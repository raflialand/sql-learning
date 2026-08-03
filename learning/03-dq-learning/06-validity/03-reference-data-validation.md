# Lesson 6.3: Reference-Data Validation

Some "valid" values are defined by **reference data** — a separate, authoritative table of allowed values. Validating against reference data is a JOIN-based validity check: does this value exist in the reference table?

---

## The Reference-Data Concept

Reference tables are the source of truth for allowed values:

- `regions` defines the allowed `region_id` values → `daily_sales.region_id` must exist there.
- A `categories` table defines allowed product categories → `products.category` must match.
- A `status` table defines allowed order statuses.

Our `dq_learning` database has a small reference: the `daily_sales` regions (`RGN001`, `RGN002`) are self-declared. For a real reference-data check, we compare against an authoritative table.

---

## The Reference-Data Check Pattern

```sql
-- Any daily_sales rows whose region_id has no matching reference?
SELECT DISTINCT ds.region_id
FROM daily_sales ds
LEFT JOIN (
    SELECT 'RGN001' AS region_id UNION ALL SELECT 'RGN002'
) ref ON ds.region_id = ref.region_id
WHERE ref.region_id IS NULL;
```

**Expected output:** no rows — every region is valid.

The pattern:

```
FROM <data table> d
LEFT JOIN <reference table> r ON d.<fk> = r.<pk>
WHERE r.<pk> IS NULL;     -- ← rows with no reference = invalid
```

---

## Cross-Table Reference Check: Categories

Reference data can also be derived from another *master* table. Product categories should come from a known set:

```sql
-- Products whose category isn't in the reference set
SELECT product_id, product_name, category
FROM products
WHERE category NOT IN ('Electronics', 'Home & Office', 'Furniture',
                       'Appliances', 'Stationery', 'Office')
   OR category IS NULL;
```

**Expected output (1 row):**

| product_id | product_name | category |
|------------|--------------|----------|
| 8 | Pen | NULL |

---

## The General Reference-Validation Pattern (memorize)

For any `child.col` that must reference `parent.pk`:

```sql
-- Orphan detection = reference validation
SELECT child.id, child.col
FROM child
LEFT JOIN parent ON child.col = parent.pk
WHERE parent.pk IS NULL;
```

This is *also* the consistency/orphan check from Unit 08 — validity (allowed value) and consistency (referential integrity) are two views of the same join. **The dimension you call it depends on whether you think of it as "invalid value" or "broken relationship".**

---

## Using a Real Reference Table

A production-grade approach creates an actual reference table:

```sql
CREATE TEMPORARY TABLE ref_status (
    status VARCHAR(20) PRIMARY KEY
);
INSERT INTO ref_status VALUES ('shipped'), ('pending'), ('cancelled');

-- Validate orders against reference data
SELECT o.order_id, o.status
FROM orders o
LEFT JOIN ref_status s ON o.status = s.status
WHERE s.status IS NULL;
```

**Expected output (4 rows — including NULL):**

| order_id | status |
|----------|--------|
| 4 | NULL |
| 8 | Shipped |
| 9 | SHIPPED |
| 10 | shippd |

> **Note the difference from Lesson 6.2:** the `LEFT JOIN` reference check DOES catch the NULL status (because a NULL key never joins), whereas `NOT IN` skipped it. Reference-data validation is generally more robust — another reason DQ tooling prefers lookup-based checks.

---

## Reference Checks in Practice (tools)

This is exactly what DQ tools automate:

| Tool | Reference check |
|------|-----------------|
| Great Expectations | `expect_column_values_to_be_in_set` |
| dbt test | `relationships:` (references to another model) |
| Soda | `values in (...)` or lookup queries |

Under the hood, they all build the **LEFT JOIN ... IS NULL** you just learned.

---

## English Translation (of this lesson)

> "Reference data defines the allowed values. I validate against it with LEFT JOIN and WHERE <ref> IS NULL — values with no matching reference are invalid. This pattern is also called orphan detection; it's more robust than NOT IN because it catches NULLs too. DQ tools automate exactly this logic."

---

## Key Takeaways

1. **Reference validation = `LEFT JOIN <reference> ... WHERE ref IS NULL`**.
2. Reference tables can be real tables, temporary tables, or derived allowed sets.
3. Reference checks **catch NULLs** that `NOT IN` silently skips.
4. Reference validation and **orphan detection are the same join** — validity vs consistency framing.
5. Tools (Great Expectations, dbt, Soda) automate this exact pattern.

---

## Unit 06 Exercises → practice validity checks.

Move on to `exercises.md`.
