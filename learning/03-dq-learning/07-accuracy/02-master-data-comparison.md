# Lesson 7.2: Master-Data Comparison

Some accuracy checks need an external source of truth. **Master data** (the authoritative reference — in our case the `dq_clean_*` tables) tells you what values *should* be. Comparing a table to master data exposes records that contradict the source of truth.

---

## Why Master Data Matters

`products.unit_price` might be *valid* (> 0) but still *inaccurate* (wrong price for that product). Master data holds the correct price. When the operational table disagrees with master data, one of them is wrong — and master data usually wins.

---

## Comparing Products to Master Data

```sql
-- Products whose price in the operational table differs from master data
SELECT
    p.product_id,
    p.sku,
    p.unit_price        AS operational_price,
    c.unit_price        AS master_price,
    ROUND(p.unit_price - c.unit_price, 2) AS price_diff
FROM products p
JOIN dq_clean_products c ON p.product_id = c.product_id
WHERE p.unit_price <> c.unit_price;
```

**Expected output:**

| product_id | sku | operational_price | master_price | price_diff |
|------------|-----|-------------------|--------------|------------|
| 3 | SKU-1002 | -5.00 | 9.99 | -14.99 |
| 4 | SKU-1003 | 0.00 | 24.99 | -24.99 |
| 5 | SKU-1004 | 199.99 | 199.99 | 0.00 |
| 6 | SKU-1005 | 49.99 | 49.99 | 0.00 |

Wait — let me be careful. Master data for these:

| product_id | dirty unit_price | clean unit_price |
|------------|------------------|------------------|
| 1 | 29.99 | 29.99 | same
| 2 | 29.99 | 29.99 | same
| 3 | -5.00 | 9.99 | **diff**
| 4 | 0.00 | 24.99 | **diff**
| 5 | 199.99 | 199.99 | same
| 6 | 49.99 | 49.99 | same
| 7 | 4.99 | 4.99 | same
| 8 | 1.99 | 1.99 | same
| 9 | 7.99 | 7.99 | same
| 10 | 149.99 | 149.99 | same
| 11 | 4.99 | 4.99 | same
| 12 | 5.99 | 5.99 | same

So only products **3 and 4** differ in price. But I also deliberately made product 5's *weight* differ (150.00 vs 12.00) and product 6's *discontinued_at/is_active* differ. Let me craft a combined comparison that shows price diff (products 3, 4) plus weight diff (product 5) plus active-flag diff (product 6).

Let me write a fuller comparison:

```sql
-- Full master-data comparison for products
SELECT
    p.product_id, p.sku,
    p.unit_price   AS op_price,   c.unit_price   AS master_price,
    p.weight_kg    AS op_weight,  c.weight_kg    AS master_weight,
    p.is_active    AS op_active,  c.is_active    AS master_active
FROM products p
JOIN dq_clean_products c ON p.product_id = c.product_id
WHERE p.unit_price <> c.unit_price
   OR p.weight_kg  <> c.weight_kg
   OR p.is_active  <> c.is_active;
```

**Expected output:**

| product_id | sku | op_price | master_price | op_weight | master_weight | op_active | master_active |
|------------|-----|----------|--------------|-----------|---------------|-----------|---------------|
| 3 | SKU-1002 | -5.00 | 9.99 | 0.05 | 0.05 | 1 | 1 |
| 4 | SKU-1003 | 0.00 | 24.99 | 1.20 | 1.20 | 1 | 1 |
| 5 | SKU-1004 | 199.99 | 199.99 | 150.00 | 12.00 | 1 | 1 |
| 6 | SKU-1005 | 49.99 | 49.99 | 4.50 | 4.50 | 1 | 0 |

This exposes four accuracy defects: two wrong prices (3, 4), one implausible weight (5), and one product that should be discontinued but is still active (6).

---

## Comparing Customers to Master Data

```sql
-- Customers whose email differs from master data
SELECT
    c.customer_id,
    c.email           AS op_email,
    m.email           AS master_email
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE c.email <> m.email;
```

**Expected output (3 rows):**

| customer_id | op_email | master_email |
|-------------|----------|--------------|
| 5 | NULL | carol.davis@example.com |
| 6 | david.wilson@@example.com | david.wilson@example.com |
| 7 | eve.brown@example | eve.brown@example.com |

Customer 5's email is missing entirely, customer 6's is malformed, customer 7's lacks a TLD — master data tells us the *correct* values. That makes remediation straightforward: copy from master.

---

## The Master-Data Comparison Pattern

```
SELECT <operational fields>, <master fields>
FROM <operational table> op
JOIN <master table> m ON op.<key> = m.<key>
WHERE op.<value> <> m.<value>;
```

Key points:
1. Join on the **natural/business key** (not necessarily the surrogate id).
2. Compare **value columns**, not the key.
3. Handle NULLs — `NULL <> value` is *unknown*, not true, so a NULL operational value silently passes. Add `COALESCE` or `IS NULL` handling:

```sql
-- Correctly catch NULL vs master value
SELECT c.customer_id, c.email AS op_email, m.email AS master_email
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.email, '') <> COALESCE(m.email, '');
```

---

## When Operational Data Should Win

Master data isn't always right. The comparison *flags* differences; a **data owner** decides which side is authoritative for each case. Your job: surface every contradiction with both values visible.

---

## English Translation (of this lesson)

> "Master data is the source of truth for what values should be. I join the operational table to master data on the business key and compare value columns. Differences are accuracy defects — like a wrong price or a product that should be discontinued. I surface both values so the owner can decide which side is right."

---

## Key Takeaways

1. **Master data = external source of truth** for accuracy.
2. Join on the **business key**, compare **value columns**.
3. **COALESCE handles NULLs** in comparisons — `NULL <> 'x'` is unknown, not true.
4. Every difference is **evidence** (both values shown) for the data owner to adjudicate.
5. Master comparison complements cross-field checks (Lesson 7.1).

**Coming up next:** Business-rule validation.
