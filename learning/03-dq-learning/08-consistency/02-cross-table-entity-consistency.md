# Lesson 8.2: Cross-Table Entity Consistency

The same entity (a customer, a product) often lives in multiple tables. **Cross-table consistency** checks that the entity's attributes agree wherever they appear.

---

## The Problem

`customers.state` says `'CA'`, but `addresses` for the same customer says `'California'`. Same entity, different representations → joins and deduplication behave unpredictably.

---

## Customer Consistency: State Across Tables

```sql
-- Same customer, different state spelling between tables
SELECT
    c.customer_id,
    c.first_name,
    c.state   AS customers_state,
    a.state   AS address_state,
    c.city    AS customers_city,
    a.city    AS address_city
FROM customers c
JOIN addresses a ON c.customer_id = a.customer_id
WHERE c.state <> a.state OR c.city <> a.city;
```

**Expected output:**

| customer_id | first_name | customers_state | address_state | customers_city | address_city |
|-------------|------------|-----------------|---------------|----------------|--------------|
| 3 | Bob | CA | CA | San Francisco | San Francisco |
| 4 | Bob | California | CA | Austin | Austin |
| 6 | David | tx | TX | Miami | Miami |
| 9 | Grace | CA | CA | Los Angeles | LA |

Wait — let me check. `addresses` has no `state` column! It has `address_line, city, country`. Let me re-check the schema.

The `addresses` table schema is: `address_id, customer_id, address_line, city, country`. No state column. So I can't compare state across `customers` and `addresses`.

What CAN be compared across tables:
- `customers` city? No — customers has no city column.
- The consistent attribute across tables: customer email/name/phone live only in `customers`. 

Hmm. So cross-table entity consistency needs a common attribute. Let me reconsider what's comparable:
- `customers.first_name/last_name` vs nothing else.
- `orders.customer_id` → customers — covered by RI.
- Currency: `orders.currency` vs `order_items.currency` — THAT is a real cross-table consistency check!

Let me rewrite the lesson around genuinely comparable fields:
1. **Currency** — orders vs order_items (both have currency). Item 14 mismatch.
2. **Customer naming/state** — I can compare `customers` state variants *within* the customers table (customers 3 & 4 same person). But that's intra-table near-duplicate, already in Unit 05.

Actually, a better cross-table check: compare `orders.customer_id` against `customers` — but that's RI. 

Another: `daily_sales.region_id` vs regions reference — done in Unit 06.

Let me use **currency** as the primary cross-table consistency example (orders vs order_items), and also demonstrate comparing a *derived* value across tables (order total vs sum of items — but that's accuracy in Unit 07).

For entity consistency, I can compare `customers.email` against the clean master (done in Unit 07). 

Let me think about what's genuinely new here for cross-table entity consistency in our dataset:
- **orders.currency vs order_items.currency** — item 14 USD under order 12 EUR. This is the cleanest cross-table consistency example.
- **customers vs dq_clean_customers** — master comparison (Unit 07 framing, but consistency framing: "the same customer differs across systems").

I'll rewrite the lesson to:
1. Currency consistency (orders ↔ order_items) — the primary example.
2. Format consistency across systems (customers vs clean master: state `'tx'` vs `'TX'`, `'California'` vs `'CA'`) — framed as cross-system entity consistency.
3. Same-entity-in-one-table (customers 3 vs 4) as an intra-table variant.

Let me rewrite the file completely.<｜end▁of▁thinking｜>The `addresses` table has no `state` column, so that example is wrong. Let me rewrite the lesson around genuinely comparable fields.

<｜｜DSML｜｜tool_calls>
<｜｜DSML｜｜invoke name="write">
<｜｜DSML｜｜parameter name="content" string="true"># Lesson 8.2: Cross-Table Entity Consistency

The same fact (an order's currency, a customer's state) can appear in multiple tables or systems. **Cross-table consistency** checks that the fact agrees everywhere it appears.

---

## Example 1: Currency Consistency — Orders vs Line Items

An order's currency must match the currency of its line items. Mixing them breaks financial calculations.

```sql
SELECT
    oi.item_id,
    oi.order_id,
    oi.currency  AS item_currency,
    o.currency   AS order_currency,
    o.customer_id
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE oi.currency <> o.currency;
```

**Expected output (1 row):**

| item_id | order_id | item_currency | order_currency | customer_id |
|---------|----------|---------------|----------------|-------------|
| 14 | 12 | USD | EUR | 11 |

Order 12 is an EUR order, but item 14 is priced in USD. Any FX conversion or revenue total that assumes a single currency per order is now wrong.

---

## Example 2: State Consistency Across Systems (master comparison)

The same customer's `state` should match the master system's record. We have `'tx'`, `'California'`, `'Oregon'` variants in `customers` vs clean master `'TX'`, `'CA'`, `'OR'`:

```sql
SELECT
    c.customer_id,
    c.first_name, c.last_name,
    c.state        AS customers_state,
    m.state        AS master_state
FROM customers c
JOIN dq_clean_customers m ON c.customer_id = m.customer_id
WHERE COALESCE(c.state, '') <> COALESCE(m.state, '');
```

**Expected output (3 rows):**

| customer_id | first_name | last_name | customers_state | master_state |
|-------------|------------|-----------|-----------------|--------------|
| 4 | Bob | Smith | California | CA |
| 6 | David | Wilson | tx | TX |
| 12 | Ivy | Clark | Oregon | OR |

The same customer is recorded with different state spellings in the operational and master systems. This is a **consistency** defect (same entity, disagreeing attributes) — with the master system as the arbiter.

---

## Example 3: Same Entity Within One Table

Customers 3 & 4 are the same person (same phone) with inconsistent states (`'CA'` vs `'California'`). This is intra-table entity inconsistency — the near-duplicate we met in Unit 05, now from the consistency angle:

```sql
SELECT c1.customer_id AS a, c2.customer_id AS b,
       c1.first_name, c1.state AS state_a, c2.state AS state_b
FROM customers c1
JOIN customers c2
  ON c1.first_name = c2.first_name
 AND c1.last_name  = c2.last_name
 AND c1.phone      = c2.phone
 AND c1.customer_id < c2.customer_id;
```

**Expected output (1 row):**

| a | b | first_name | state_a | state_b |
|---|---|------------|---------|---------|
| 3 | 4 | Bob | CA | California |

---

## The Cross-Table Consistency Pattern

```
SELECT <fields from table1>, <fields from table2>
FROM table1 t1
JOIN table2 t2 ON <natural key>
WHERE COALESCE(t1.<attribute>, '') <> COALESCE(t2.<attribute>, '');
```

Key points:
1. Join on the **natural key** (customer_id, order_id) — the entity's identity.
2. Compare the **attribute** you expect to be identical.
3. **`COALESCE`** handles NULLs (a missing value should count as a difference).
4. Decide which side is **authoritative** (usually master data or the source system).

---

## Why This Matters

| Scenario | Impact |
|----------|--------|
| Item currency ≠ order currency | Revenue/FX totals wrong |
| State `'California'` vs `'CA'` | Dedup and grouping split one entity into many |
| Phone format differs | Identity matching fails |

Cross-table consistency is the silent killer of *reporting*: aggregates that join on inconsistent values either drop rows or double-count them.

---

## English Translation (of this lesson)

> "The same fact should agree across every table and system where it appears. I join tables on the natural key and compare the shared attributes with COALESCE so NULLs are treated as differences. Currency between orders and items, and state between operational and master data, are two places this breaks. The master or source system is the arbiter."

---

## Key Takeaways

1. **Cross-table consistency = compare shared attributes across tables on a natural key**.
2. **`COALESCE`** in comparisons catches NULL vs value mismatches.
3. **Currency** (orders ↔ items) and **state/format** (operational ↔ master) are prime examples.
4. Always designate the **authoritative side** (master data usually wins).
5. Inconsistency breaks joins, dedup, and aggregates — often silently.

**Coming up next:** Format and unit consistency.
