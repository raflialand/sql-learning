# Lesson 2.1: Why Business Context Comes First

This is the most important lesson in the entire module. Read it twice.

---

## The Trap of "Checking Everything"

A beginner DQ engineer sees a table and wants to check *everything*:

- All columns NOT NULL?
- All columns unique?
- All values in a valid format?

That is a waste of effort. It produces a mountain of findings, 90% of which nobody cares about, while the 10% that *would* hurt the business go unnoticed — because the checks weren't aligned with how the data is actually used.

**The alternative:** understand the business first. Then every check you write answers a question someone actually cares about.

---

## Data Quality Is Use-Case Relative (revisited)

From Unit 01: data is good or bad *relative to a purpose*. That means:

| Dataset | Used for | Quality that matters most |
|---------|----------|---------------------------|
| `customers.email` | Marketing campaigns | **Validity** (format) + **Completeness** (no NULLs) |
| `orders.total_amount` | CFO revenue reports | **Accuracy** + **Completeness** |
| `orders.status` | Ops fulfillment | **Validity** (correct enum) + **Timeliness** |
| `daily_sales` | Executive dashboard | **Completeness** + **Consistency** + **Timeliness** |

Same table, different use case → different priorities. **The use case tells you which dimensions to check first.**

---

## The Business-First Workflow

Before opening MySQL, answer these questions:

```
1. WHO consumes this data?          → the analysts, the CFO, the ops team, the ML model?
2. WHAT decisions does it drive?    → revenue reporting? shipping? marketing spend?
3. WHAT would go wrong if it were bad? → wrong forecast? late delivery? compliance fine?
4. WHICH fields matter most?        → not all columns matter equally
5. WHAT does "good" mean for them?  → formats, ranges, required-ness, expected freshness
6. HOW will we measure it?          → pass/fail rule with a threshold
```

> The last question — "how will we measure it?" — is where your SQL begins. Everything before it is the *business context* that makes the SQL meaningful.

---

## Worked Example: `orders` in our dataset

Let's walk through the six questions for the `orders` table.

**1. Who consumes it?** Finance (revenue reporting), Ops (fulfillment), Analytics (dashboards).

**2. What decisions?** Monthly revenue figures go to the CFO. Ops uses status to prioritize shipments.

**3. What goes wrong?** A NULL `total_amount` hides revenue (finance understates). A bad status `'shippd'` confuses ops automation.

**4. Which fields matter most?** `total_amount` (finance), `status` (ops), `order_date` (reporting periods).

**5. What does "good" mean?**
- `total_amount` must never be NULL and must equal the sum of its items.
- `status` must be one of `shipped | pending | cancelled` (exact).
- `order_date` must not be in the future.

**6. How will we measure it?**
```sql
-- DQ rule 1: completeness of total_amount
SELECT COUNT(*) AS bad_rows
FROM orders
WHERE total_amount IS NULL;
```
```sql
-- DQ rule 2: validity of status
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status
HAVING status NOT IN ('shipped', 'pending', 'cancelled');
```

Both checks are *tiny* — but each one maps to a real business consequence. That is the point.

---

## Context Also Sets Priorities

When a defect is found, context decides severity:

| Defect | Business context | Severity |
|--------|------------------|----------|
| Customer email NULL | Customer can't be reached for a $1M campaign | **High** |
| Customer email NULL | Customer never re-contacted (static archive) | **Low** |
| 3% of order totals NULL | Finance needs auditable monthly revenue | **High** |
| Address country `'US'` vs `'USA'` | No system uses country for decisions | **Low** |

Same defect, different context → different priority. This is why the *steward/owner* (business) decides severity, and you (engineer) measure it.

---

## English Translation (of this lesson)

> "I don't check everything — I check what the business actually depends on. Before writing any SQL, I ask who consumes the data, what decisions it drives, what breaks if it's bad, which fields matter, and what good looks like. Then my checks are small, focused, and tied to real consequences."

---

## Key Takeaways

1. **Check what matters, not everything** — business context selects your checks.
2. The **6 questions** (who / what / what breaks / which fields / what's good / how to measure) are your pre-SQL ritual.
3. The same table has **different DQ priorities** per use case.
4. **Severity is a business call**, not an engineering call — you provide the measurement.

**Coming up next:** Reading business requirements.
