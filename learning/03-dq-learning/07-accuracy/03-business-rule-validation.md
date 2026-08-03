# Lesson 7.3: Business-Rule Validation

Beyond arithmetic and master data, accuracy includes **business rules** — the domain-specific logic that says what a correct record looks like. These rules come straight from the Unit 02 expectations sheet.

---

## Business Rules in Our Dataset

| Rule | Statement | Type |
|------|-----------|------|
| Price plausibility | `unit_price` must be > 0 (inventories can't be negative) | Range |
| Weight plausibility | `weight_kg` must be within plausible bounds | Range |
| Product lifecycle | an inactive product should have a discontinuation date | Cross-field |
| Order amount | an order total must match its items | Cross-field |

---

## Rule: Product Lifecycle Consistency

A product that is `is_active = 0` should have a `discontinued_at` date (and vice-versa):

```sql
SELECT product_id, sku, product_name, is_active, discontinued_at
FROM products
WHERE (is_active = 0 AND discontinued_at IS NULL)
   OR (is_active = 1 AND discontinued_at IS NOT NULL AND discontinued_at <= CURRENT_DATE);
```

**Expected output:**

| product_id | sku | product_name | is_active | discontinued_at |
|------------|-----|--------------|-----------|-----------------|
| 6 | SKU-1005 | Coffee Maker | 1 | 2025-01-01 |

Product 6 is marked `is_active = 1` but was discontinued in January 2025 — the catalog still sells a product that should have been retired. This is a *business-rule* accuracy violation (the two fields contradict the intended lifecycle logic).

---

## Rule: Price vs Weight Plausibility

Some business rules combine two fields — e.g., a chair cannot weigh 150 kg:

```sql
SELECT product_id, sku, product_name, unit_price, weight_kg
FROM products
WHERE unit_price <= 0
   OR weight_kg < 0.1 OR weight_kg > 50;
```

**Expected output (3 rows):**

| product_id | sku | product_name | unit_price | weight_kg |
|------------|-----|--------------|------------|-----------|
| 3 | SKU-1002 | USB-C Cable | -5.00 | 0.05 |
| 4 | SKU-1003 | Desk Lamp | 0.00 | 1.20 |
| 5 | SKU-1004 | Office Chair | 199.99 | 150.00 |

This check encodes *domain knowledge* from the business ("chairs weigh between 5-20 kg") into a query.

---

## Rule: Currency Logic in Order Items

A business rule could state: "line item currency must match the parent order currency." That's a consistency/accuracy business rule across two tables:

```sql
SELECT oi.item_id, oi.order_id, oi.currency AS item_currency, o.currency AS order_currency
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.currency <> o.currency;
```

**Expected output (1 row):**

| item_id | order_id | item_currency | order_currency |
|---------|----------|---------------|----------------|
| 14 | 12 | USD | EUR |

Item 14 is priced in USD under an EUR order — mixing currencies breaks finance calculations.

---

## The Business-Rule Validation Checklist

When writing a business-rule check, always ask (from Unit 02):

1. **What rule** does the business state for these fields?
2. **Which tables/fields** does it span?
3. **What's the expected relationship** (equality, ordering, membership, bounds)?
4. **How should NULLs behave** in this rule?
5. **What threshold** triggers an alert?

---

## Building a Combined Accuracy Scorecard

Business rules can be combined into a single violations view:

```sql
SELECT
    COUNT(*) AS total_products,
    SUM(unit_price <= 0 OR weight_kg < 0.1 OR weight_kg > 50) AS rule_violations,
    ROUND(SUM(unit_price <= 0 OR weight_kg < 0.1 OR weight_kg > 50) * 100.0 / COUNT(*), 1) AS violation_pct
FROM products;
```

**Expected output:**

| total_products | rule_violations | violation_pct |
|----------------|-----------------|---------------|
| 12 | 3 | 25.0 |

---

## English Translation (of this lesson)

> "Business-rule validation encodes domain logic as queries: active products shouldn't be discontinued, weights must be plausible, item currency must match the order. Every rule comes from the business expectations sheet. I combine rules into violation counts and percentages for a quick accuracy score."

---

## Key Takeaways

1. **Business rules** translate domain knowledge into SQL conditions.
2. Rules can span **single fields, multiple fields, or multiple tables**.
3. Always encode the rule from the **business expectations sheet** (Unit 02).
4. Combined checks produce **violation counts/percentages** for scorecards.
5. Accuracy = cross-field + master-data + business-rule checks working together.

---

## Unit 07 Exercises → practice accuracy checks.

Move on to `exercises.md`.
