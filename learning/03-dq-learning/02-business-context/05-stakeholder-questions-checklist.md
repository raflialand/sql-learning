# Lesson 2.5: The Stakeholder Questions Checklist

Before auditing *any* dataset, run this checklist with the data owner / steward. It is the fastest way to turn "vague business need" into "testable rules."

---

## The Checklist (copy-paste into your notes)

### 1. Purpose & Consumers
- [ ] Who consumes this data? List them (teams, reports, models).
- [ ] What is the single most important decision this data supports?
- [ ] Is any consumer **regulatory or compliance** related?

### 2. Field-Level Semantics
- [ ] For each critical field: what does "valid" mean? (format, allowed values)
- [ ] Which fields are **required** (must never be NULL / empty)?
- [ ] Which field is the **natural/business key** (the true unique identifier)?
- [ ] Are there fields whose values depend on other fields? (e.g., `total = qty × price`)

### 3. Business Rules
- [ ] What value sets are allowed? (e.g., status: shipped/pending/cancelled)
- [ ] What ranges are acceptable? (e.g., `unit_price > 0`, `qty > 0`)
- [ ] Are there cross-table rules? (e.g., every order belongs to an existing customer)
- [ ] Are there cross-field rules? (e.g., `order_date` cannot be after `ship_date`)

### 4. Freshness & Timing
- [ ] How fresh must the data be for each consumer? (hourly, daily, weekly)
- [ ] What is the expected load window? (data must arrive by X)
- [ ] Is `order_date` ever allowed to be in the future? (usually no)

### 5. Severity & Ownership
- [ ] What is the **worst consequence** of this data being wrong?
- [ ] Who decides severity? (usually the data owner)
- [ ] Who is accountable for fixing root causes?

---

## A Realistic Stakeholder Interview (example)

**You:** "Who uses the orders data?"

**Owner:** "Finance uses it for monthly revenue; ops uses it to track shipments."

**You:** "Which fields are must-never-be-empty?"

**Owner:** "total_amount — we can't book revenue without it."

**You:** "What statuses are allowed?"

**Owner:** "shipped, pending, cancelled. Anything else is a mistake."

**You:** "Should order_date ever be in the future?"

**Owner:** "No — that means a bad feed from the store system."

Three answers → three rule cards. The interview *is* the DQ design process.

---

## Red Flags to Probe Further

| Stakeholder says... | You should ask... |
|---------------------|-------------------|
| "Just make sure the data is clean" | "Which field worries you most, and what does clean mean for it?" |
| "All fields are required" | "Even the optional ones like notes?" (probe for the real key fields) |
| "That can't happen" | "What's the worst case if it does?" (gauge severity) |
| "We'll fix it later" | "Later costs 10× more — can we capture the rule now at least?" |

---

## Your Deliverable After the Interview

A short **data expectations sheet** you keep next to the dataset:

```
Dataset: orders
Critical fields : total_amount, status, order_date, customer_id
Required        : total_amount, customer_id, order_date
Key             : order_id (business key: customer_id + order_date + amount)
Allowed values  : status ∈ {shipped, pending, cancelled}
Ranges          : total_amount ≥ 0; order_date ≤ today
Cross-table     : customer_id must exist in customers
Cross-field     : total_amount = Σ(qty × unit_price) from order_items
Freshness       : daily by 06:00
Severity        : HIGH — CFO revenue reporting
```

This sheet is the input to every rule you write in Units 04–10.

---

## English Translation (of this lesson)

> "Before I touch the data, I interview the owner with a fixed checklist: who consumes this, what's valid, what's required, what's the business key, what rules and ranges apply, how fresh it must be, and how severe a break is. The answers become a data expectations sheet that drives every check I write."

---

## Key Takeaways

1. The **stakeholder checklist** converts vague needs into testable rules.
2. Always identify the **business key**, **required fields**, **allowed values**, **ranges**, and **freshness**.
3. **Probe red flags** — vague "clean" answers hide the real priorities.
4. End every interview with a written **data expectations sheet**.

**Coming up next:** Unit 02 exercises (business-context case study).
