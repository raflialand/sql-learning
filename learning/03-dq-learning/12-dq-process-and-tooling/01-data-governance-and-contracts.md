# Lesson 12.1: Data Governance and Contracts

Good data quality doesn't survive on good queries alone — it needs **governance**: who decides the rules, who owns the data, and how the rules are agreed and enforced. This lesson is conceptual (no SQL), but it's what separates a "query writer" from a **DQ engineer**.

---

## What Data Governance Is

Governance = **decision rights and accountability** for data. It answers:

- Who decides what "good" means for this dataset?
- Who is accountable when it's wrong?
- Who approves changes to rules and thresholds?
- How do we document and communicate these decisions?

| Term | Meaning |
|------|---------|
| **Data Owner** | Senior person accountable for a dataset's quality and budget |
| **Data Steward** | Daily owner of a domain's rules and quality |
| **Data Governance Council** | Cross-functional body that resolves conflicts and sets policy |

---

## The Governance Pillars That Protect Quality

| Pillar | What it does |
|--------|--------------|
| **Policies** | Written rules ("personal data must be masked", "financial data needs 100% completeness") |
| **Standards** | Format conventions (dates as `YYYY-MM-DD`, states as 2-letter codes) |
| **Roles** | Who owns what (stewards, owners, engineers) |
| **Process** | How changes are proposed, approved, reviewed |

---

## Data Contracts — the Modern DQ Tool

A **data contract** is a formal, versioned agreement between a data producer and a data consumer:

```
DATA CONTRACT: orders (producer: Order Service → consumer: Finance)
Version 3.2   |   Owner: Finance Steward   |   SLA: daily by 06:00

SCHEMA
  order_id      INT         REQUIRED, UNIQUE
  customer_id   INT         REQUIRED (exists in customers)
  order_date    DATE        REQUIRED, <= today
  total_amount  DECIMAL(10,2)  REQUIRED, >= 0
  status        VARCHAR(20)   IN ('shipped','pending','cancelled')
  currency      VARCHAR(3)    = 'USD'

METRICS / SLAs
  completeness:  total_amount 100% | order_date 100%
  freshness:     max(order_date) <= today, loaded by 06:00
  volume:        daily row count within +-20% of 7-day average
```

**Every requirement in the contract is exactly a rule you already know how to write in SQL.** The contract is the *agreement*; your checks are the *enforcement*.

---

## How Contracts Help

1. **Clarity** — producers and consumers agree on expectations *before* data flows.
2. **Breaks fast** — a pipeline that violates the contract fails its checks at the source, not at the dashboard.
3. **Versioning** — schema changes are explicit and reviewed.
4. **Ownership** — every field has an accountable owner.

---

## Contract Violation = Your Alert

When the `orders` contract says "no future order dates", the query you wrote in Unit 09 *is* the contract check:

```sql
-- Contract check: order_date <= today
SELECT order_id, order_date
FROM orders
WHERE order_date > CURDATE();
```

The only difference: in a governed system, this query is **named, scheduled, thresholded, and owned** — because it lives in the contract.

---

## English Translation (of this lesson)

> "Governance gives data quality decision rights and accountability: owners, stewards, policies, and standards. The modern way to formalize expectations is a data contract — a versioned agreement between producer and consumer listing required fields, formats, and SLAs. Every line of a contract maps to a SQL rule I already know. My checks enforce the contract."

---

## Key Takeaways

1. **Governance = decision rights + accountability** for data.
2. Roles: **owner** (accountable), **steward** (daily rules), **council** (policy).
3. **Data contracts** formalize producer-consumer expectations (schema, SLA, metrics).
4. Every contract requirement = a **SQL rule you know how to write**.
5. Contract violations are exactly the alerts you build in Unit 11.

**Coming up next:** The DQ tools landscape.
