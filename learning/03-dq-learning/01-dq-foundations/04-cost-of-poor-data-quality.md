# Lesson 1.4: The Cost of Poor Data Quality

Why should a business spend money on data quality? Because poor data quality **costs money in a measurable way**. This lesson builds your business justification skills — a DQ engineer who cannot argue for resources gets no resources.

---

## The Five Cost Categories

| Cost | Mechanism | Example |
|------|-----------|---------|
| **1. Rework** | Time spent finding and fixing bad data | Analysts spend 40% of their week cleaning data instead of analyzing |
| **2. Wrong decisions** | Decisions made on bad numbers | Budget allocated based on revenue missing 8% of orders |
| **3. Wasted spend** | Money spent on the wrong target | Campaign mailed to 40,000 duplicate profiles |
| **4. Compliance & legal** | Fines and penalties for bad filings | GDPR fine for incorrect personal data |
| **5. Lost trust** | Consumers stop believing the data | Teams keep their own spreadsheets instead of the warehouse |

---

## Quantifying the "bottom line" of a defect

A powerful DQ skill is translating a data defect into money. Let's do it for a defect in our own dataset.

**Scenario:** In `orders`, some orders have a NULL `total_amount`. Suppose finance uses `orders.total_amount` to compute monthly revenue.

```sql
-- How much revenue is unmeasurable because the total is NULL?
SELECT COUNT(*) AS null_amount_orders,
       COUNT(*) * 59.00 AS estimated_lost_tracking   -- 59.00 = avg order value
FROM orders
WHERE total_amount IS NULL;
```

**Business translation:** "We cannot count the value of these orders in our books. If the average order is ~$59, that is an unmeasured amount flowing through the company — finance understates revenue, forecasts are off, and we cannot audit these transactions."

Now you can argue: *"Fix the NULL-total issue and finance gets auditable revenue for ~X orders per month."*

---

## The Quality-Cost Curve (prevention beats correction)

```
Cost per defect
      │
   High│           ● fix after customer impact
      │         ●   fix after delivery
      │       ●      fix during development
   Low │ ●  prevent at design time
      └──────────────────────────────► pipeline stage
```

The earlier a defect is caught, the cheaper it is. This is the *economic* argument for **automated, early, and monitored** checks rather than one-off cleanup.

---

## A 10× Rule of Thumb

Industry rule of thumb: the cost of correcting a data defect **multiplies by ~10× at each downstream stage**:

| Stage | Relative cost |
|-------|---------------|
| At the source system (design) | 1× |
| During extraction/transform | 10× |
| After loading into the warehouse | 100× |
| After being consumed by a report/model | 1,000× |
| After causing a real-world action | 10,000× |

So a defect we catch in SQL *before* the dashboard is 1,000× cheaper than discovering it after a wrong business action.

---

## The DQ Engineer's Pitch (template)

When asked "why invest in data quality?", you should be able to say:

1. **Quantify a concrete defect** (e.g., "we can't measure $X of monthly revenue").
2. **Name the downstream risk** (wrong forecasts, compliance, wasted spend).
3. **Point to prevention economics** (catch it in the pipeline, not at the report).
4. **Propose measurement first** (profile + scorecard), *then* remediation.

> Notice how step 1 forces you back to *business context* — you can't quantify impact until you know how the data is used.

---

## English Translation (of this lesson)

> "Bad data costs money five ways: rework, wrong decisions, wasted spend, fines, and lost trust. I can translate any defect into dollars by asking how the data is used downstream. Fixing defects early is dramatically cheaper than fixing them late, so automated checks are an investment, not an expense."

---

## Key Takeaways

1. Poor data quality costs money through **rework, bad decisions, waste, fines, and lost trust**.
2. **Translate defects to dollars** — it is your strongest argument for DQ investment.
3. The **10× rule** explains why early automated checks pay off.
4. Always frame DQ work as **measurable risk reduction**, not a nice-to-have.

**Coming up next:** exercises for Unit 01.
