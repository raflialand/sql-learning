# Lesson 2.4: Prioritizing DQ Dimensions

You cannot check all 6 dimensions at maximum strictness for every field — it is expensive and noisy. **Prioritize** by matching dimensions to the domain and the stakes.

---

## Dimension Priority by Business Domain

| Domain | What breaks first | Priority dimensions |
|--------|-------------------|---------------------|
| **Finance** | Wrong money numbers | Accuracy > Completeness > Uniqueness |
| **Operations / Supply Chain** | Wrong action taken | Timeliness > Completeness > Validity |
| **Marketing / CRM** | Wasted spend on bad targets | Validity > Completeness > Uniqueness |
| **Compliance / Legal** | Fines for bad records | Completeness > Accuracy > Consistency |
| **Analytics / ML** | Biased or broken models | Consistency > Completeness > Validity |

These are *starting points*, not rules. The real priority always comes from the specific use case.

---

## The 80/20 of DQ Checks

Most business pain comes from a handful of high-value fields and dimensions. A useful heuristic:

- **20% of fields** (the money fields, the identity fields, the action fields) carry **80% of the risk**.
- Identify the **critical fields** first: `total_amount`, `status`, `email`, `order_date`, `customer_id`, `sku`, `qty`, `unit_price`, `total_price`.
- Put your strictest checks on those fields. Lighter checks everywhere else.

---

## Example: Prioritizing for `orders` (finance)

Finance depends on `orders`. The priority is:

1. **Accuracy** — `total_amount` must equal the sum of its items (this is the money).
2. **Completeness** — `total_amount` must never be NULL.
3. **Validity** — `status` must be in the allowed set (this drives ops, but still matters).
4. **Timeliness** — `order_date` must not be in the future (a future-dated order lands in the wrong reporting period).
5. **Consistency** — no orphan `customer_id` (a join to customers drops revenue detail).

We will actually run *these exact checks* in Units 07, 04, 06, 09, and 08. Notice the order matches the priority.

---

## The Priority Matrix

Use this when you need to decide what to check *first*:

| Priority | Dimension | When it dominates |
|----------|-----------|-------------------|
| P1 | **Accuracy** | Money, measurement, master data |
| P1 | **Timeliness** | Live operations, dashboards, SLAs |
| P2 | **Completeness** | Regulatory, required fields, reporting |
| P2 | **Validity** | Any system with strict input formats |
| P3 | **Uniqueness** | Identity/master data, dedup, LTV |
| P3 | **Consistency** | Multi-system pipelines, joins |

> Remember: severity is set with the business. Your priority matrix just tells you *where to look first*, not what to ignore forever.

---

## English Translation (of this lesson)

> "I can't check everything to the max, so I prioritize. Each business domain has dimensions that break first — finance needs accuracy, ops needs timeliness, marketing needs valid targets. I focus my strictest checks on the 20% of fields that carry 80% of the risk, and I use a priority matrix to decide what to check first."

---

## Key Takeaways

1. Match **dimensions to domains** (finance→accuracy, ops→timeliness, marketing→validity).
2. Focus strict checks on the **critical 20% of fields**.
3. Use a **priority matrix** (P1→P3) to sequence your work.
4. Priorities come from the use case — the business confirms, you measure.

**Coming up next:** The stakeholder questions checklist.
