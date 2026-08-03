# Exercises: Unit 02 — Business Context

*The goal of this unit is to practice translating business needs into DQ expectations BEFORE writing checks.*

---

## Part A: Case Study — The Marketing Email Campaign

**Business brief:** Marketing wants to run a $50,000 email campaign to all active customers. Success depends on emails actually being delivered.

### Exercise 2.1 — The interview

Using the stakeholder checklist (Lesson 2.5), write the 5-6 questions you would ask the marketing owner, and the *likely* answers for this scenario.

### Exercise 2.2 — The expectations sheet

Fill in this expectations sheet for the `customers` table, for the *marketing* use case:

```
Dataset:
Critical fields :
Required        :
Key             :
Allowed values  :
Ranges          :
Cross-table     :
Cross-field     :
Freshness       :
Severity        :
```

### Exercise 2.3 — Rule → SQL

Translate these marketing expectations into SQL (against `customers` in `dq_learning`):

1. Every customer must have a non-NULL email.
2. Every email must be well-formed (contains `@`, a domain, and a TLD).
3. No two customers may share an email.

Write the three queries and run them. How many rows does each return?

### Exercise 2.4 — Priority call

If you could only fix **one** of the three issues above this week, which would it be and why? Base your answer on business impact, not ease.

---

## Part B: Different Consumers, Different Checks

### Exercise 2.5 — Finance vs Marketing

The same `customers` table is also used by Finance for **customer lifetime value** (LTV).

1. Which dimension becomes *most important* now, and why?
2. Write the SQL check that identifies duplicate customer profiles **by email**.
3. Why might Finance care about customer 3 vs 4 (`'bob.smith@example.com'` vs `'bob@example.com'`, same phone)? What check would you add to catch this?

### Exercise 2.6 — Translate the query

Explain in plain English what this query does and which consumer it serves:

```sql
SELECT state, COUNT(*) AS cnt
FROM customers
WHERE email IS NULL
GROUP BY state
ORDER BY cnt DESC;
```

---

## Part C: Ambiguity Hunting

### Exercise 2.7 — The ambiguous requirement

The owner says: *"Make sure the orders data is unique."*

1. List **three** different ways to interpret "unique" for `orders`.
2. Write the SQL for each interpretation.
3. Which interpretation is the *business key* for orders? Why do the other two fail the "so what?" test?

### Exercise 2.8 — The "so what?" test

For each rule below, decide keep or drop, and justify:

| Rule | Keep? | Why |
|------|-------|-----|
| `customers.signup_date` must not be NULL | | |
| `order_items.total_price` must equal `qty × unit_price` | | |
| `products.product_name` must not contain the letter `z` | | |
| `daily_sales.total_revenue` must not be NULL | | |
| `addresses.address_line` must not contain a `#` | | |

---

## Self-Assessment Checkpoint

- [ ] I can explain why business context comes before DQ checks
- [ ] I can run the stakeholder checklist from memory
- [ ] I can produce a data expectations sheet for any given table/use case
- [ ] I can translate an expectations sheet into SQL rules
- [ ] I can prioritize dimensions and rules by business impact
- [ ] I can hunt down ambiguous requirements and apply the "so what?" test

**Ready to continue?** Move to **Unit 03 — Data Profiling** (your first big SQL skill).
