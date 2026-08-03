# Lesson 8.1: Referential Integrity — Orphan Detection

**Consistency** answers: *do records agree with each other?* The most basic consistency check is **referential integrity**: every child reference must point to an existing parent. A reference to a nonexistent parent is an **orphan**.

---

## The Orphan Check Pattern

The universal pattern is a `LEFT JOIN` followed by an `IS NULL` on the parent key:

```sql
-- Orders whose customer does not exist
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
```

**Expected output (1 row):**

| order_id | customer_id |
|----------|-------------|
| 3 | 99 |

Order 3 references customer 99, but no such customer exists. This is an **orphan order** — it will silently disappear from any INNER JOIN to `customers`, understating per-customer analytics.

---

## Orphaned Order Items (product side)

```sql
-- Line items whose product does not exist
SELECT oi.item_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
```

**Expected output (1 row):**

| item_id | product_id |
|---------|------------|
| 4 | 99 |

---

## Orphaned Order Items (order side)

```sql
-- Line items whose parent order does not exist
SELECT oi.item_id, oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
```

**Expected output (1 row):**

| item_id | order_id |
|---------|----------|
| 20 | 999 |

---

## The Full Referential Integrity Report

All orphans in one query:

```sql
SELECT 'orders.customer_id' AS relation, o.order_id AS child_id, o.customer_id AS fk_value
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'order_items.product_id', oi.item_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
UNION ALL
SELECT 'order_items.order_id', oi.item_id, oi.order_id
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
```

**Expected output (3 rows):**

| relation | child_id | fk_value |
|----------|----------|----------|
| orders.customer_id | 3 | 99 |
| order_items.product_id | 4 | 99 |
| order_items.order_id | 20 | 999 |

---

## Why Orphans Matter (business impact)

| Orphan | Impact |
|--------|--------|
| Order → customer 99 | Revenue drops out of per-customer reports; impossible to attribute |
| Item → product 99 | Revenue detail unattributable to any product |
| Item → order 999 | An item belonging to no order — can't be reconciled |

**This is a silent data killer:** `INNER JOIN` drops orphans without error, so reports look *fine* but are wrong.

---

## Orphans Across All Tables — the Anti-Join

A useful trick for finding rows in table A that have no match in table B:

```sql
-- Customers that have no orders at all (valid — some customers don't buy)
SELECT c.customer_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

**Expected output:** customers 15 (Kevin) has no orders — this is *expected* for this dataset, not a defect. Referential integrity checks protect the *direction* the business cares about (children must have parents), not the reverse.

---

## Referential Integrity & Constraints

Real production databases enforce referential integrity with **FOREIGN KEY** constraints:

```sql
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
```

But FKs only protect *future* inserts — they don't fix existing orphans, and many legacy/staging schemas have no FKs at all. **Your SQL check is what audits existing data.**

---

## English Translation (of this lesson)

> "Consistency means records agree with each other. The core consistency check is referential integrity: every child must reference an existing parent. I use LEFT JOIN + IS NULL to find orphans. Orphans are dangerous because INNER JOIN silently drops them — reports look fine but are wrong. Foreign keys prevent new orphans; my queries find existing ones."

---

## Key Takeaways

1. **Orphan pattern = `LEFT JOIN ... WHERE parent IS NULL`**.
2. Check every **child → parent** relationship in your schema.
3. Orphans are **silently dropped by INNER JOIN** — the danger is invisible.
4. **FK constraints** prevent future orphans; **queries** find existing ones.
5. Not every anti-join result is a defect — some orphans are legitimate (e.g., customers without orders).

**Coming up next:** Cross-table entity consistency.
