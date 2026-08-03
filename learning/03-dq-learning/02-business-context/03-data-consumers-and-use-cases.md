# Lesson 2.3: Data Consumers and Use Cases

Every dataset exists because *someone* consumes it. Knowing who consumes it — and for what decision — tells you the quality bar that matters.

---

## The Consumer Map

For each table in our dataset, the consumers are different, so the priorities are different:

| Table | Primary consumer | Use case | Dominant dimension |
|-------|------------------|----------|--------------------|
| `customers` | Marketing | Campaign segmentation | Completeness, Validity |
| `customers` | Finance | Customer lifetime value | Uniqueness, Accuracy |
| `products` | Commerce | Product catalog | Validity, Uniqueness |
| `orders` | Finance | Revenue reporting | Accuracy, Completeness |
| `orders` | Ops | Fulfillment status | Validity, Timeliness |
| `order_items` | Finance | Revenue detail | Accuracy |
| `addresses` | Logistics | Shipping | Completeness, Consistency |
| `daily_sales` | Executives | KPI dashboard | Timeliness, Completeness |

Notice: **one table, multiple consumers, conflicting priorities.** `orders` must satisfy both Finance (accuracy of amounts) and Ops (validity of status). Your rule catalog must cover *all* consumers, not the loudest one.

---

## Consumer Severity Levels

A framework for prioritizing:

| Consumer level | Data stakes | Example |
|----------------|-------------|---------|
| **Regulatory / compliance** | Fines, legal exposure | Tax filings, patient records |
| **Executive decision-making** | Wrong strategy | CFO revenue report |
| **Operational execution** | Wrong action taken | Shipping to wrong address |
| **Analytical / planning** | Misleading insights | Marketing segmentation |
| **Nice-to-have** | Minor annoyance | Internal hobby reports |

The higher the stakes, the stricter the thresholds you set (Unit 11) and the faster the alerting.

---

## Use Case → Specific Check (examples)

Take two consumers of `customers`:

**Marketing (campaign emails):**
```sql
-- Find every customer marketing cannot reach
SELECT customer_id, email
FROM customers
WHERE email IS NULL
   OR email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
```

**Finance (customer lifetime value):**
```sql
-- Find duplicate customer profiles (would inflate LTV and split history)
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

Same table. Different consumers. Different checks. **This is business context in action.**

---

## The Downstream Impact Chain

When profiling, always think one step downstream:

```
data → transform → warehouse → report/model → DECISION
         ↑                                   ↑
   defects introduced          defects amplified
```

- A defect in source data (e.g., NULL email) flows into every downstream report.
- A defect can also be **introduced** by a transform (e.g., a bad join duplicates rows) or **amplified** (e.g., a NULL in one column becomes a NULL in a calculated metric).
- A DQ engineer checks both the *source* and the *output* of the pipeline.

**Practical takeaway:** when you check `orders`, also check the aggregates that Finance actually reads:

```sql
SELECT YEAR(order_date) AS yr, COUNT(*) AS orders, SUM(total_amount) AS revenue
FROM orders
GROUP BY YEAR(order_date);
```

If revenue is understated because totals are NULL or wrong, the CFO's report is wrong. Your checks exist to catch that.

---

## English Translation (of this lesson)

> "Every table has consumers who depend on it for specific decisions. I map each table to its consumers, rank their stakes, and write checks tailored to each consumer's dominant dimensions. I always think about what happens one step downstream — the report or model — because that's where a defect causes real damage."

---

## Key Takeaways

1. **One table, many consumers** — with different, sometimes conflicting quality priorities.
2. Rank consumers by **stakes** (regulatory > executive > operational > analytical > nice-to-have).
3. Tailor checks to each consumer's **dominant dimension**.
4. Always follow the **downstream chain** — check what the report/model actually reads.

**Coming up next:** Prioritizing DQ dimensions per domain.
