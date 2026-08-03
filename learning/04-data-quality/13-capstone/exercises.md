# Exercises: Unit 13 — Capstone (Guided Steps)

The capstone is a multi-step audit. These exercises break it into checkable pieces. **Complete them in order.** When done, you'll have assembled the full audit report.

---

## Part A: Business Context (Step 1)

### Exercise 13.1 — Expectations sheet: customers

Write the data expectations sheet for `customers` for the **marketing** use case (required fields, key, allowed values, freshness, severity).

### Exercise 13.2 — Expectations sheet: orders

Write the expectations sheet for `orders` for the **finance** use case.

---

## Part B: Profiling (Step 2)

### Exercise 13.3 — Row count survey

Write the `UNION ALL` row-count survey for all 6 tables.

### Exercise 13.4 — Frequency of order status

Write the status frequency query and state the dimensions it hints at.

### Exercise 13.5 — Frequency of customer state

Write the state frequency query. Which consistency defect does it reveal?

---

## Part C: Findings (Step 3)

### Exercise 13.6 — Completeness findings

Write queries that find: (a) customers missing email, (b) orders missing total_amount, (c) daily_sales rows with NULL total_revenue. Record each as a finding (table/field/dimension/count/impact).

### Exercise 13.7 — Uniqueness findings

Write queries for: (a) duplicate customer emails, (b) duplicate SKUs, (c) duplicate addresses. Record findings.

### Exercise 13.8 — Validity findings

Write queries for: (a) invalid emails, (b) invalid prices, (c) invalid order statuses. Record findings.

### Exercise 13.9 — Accuracy findings

Write queries for: (a) item total mismatch, (b) order total vs items, (c) product price vs master. Record findings.

### Exercise 13.10 — Consistency findings

Write queries for: (a) orphan orders, (b) orphan items, (c) currency mismatch, (d) state vs master. Record findings.

### Exercise 13.11 — Timeliness findings

Write queries for: (a) future-dated orders, (b) expired-but-active products. Record findings.

### Exercise 13.12 — Anomaly findings

Write queries for: (a) z-score > 2 in daily_sales, (b) week-over-week spike > 50%. Record findings.

---

## Part D: Scorecard (Step 4)

### Exercise 13.13 — Customers scorecard

Build a scorecard for `customers` covering completeness (email), uniqueness (email), validity (email format, state). Compute overall score.

**Expected:** email completeness 86.7 (FAIL, ≥99), dupes 2 (FAIL, 0), invalid emails 2 (FAIL, 0), non-standard states 3 (FAIL, 0) → score 0%.

### Exercise 13.14 — Orders scorecard

Build a scorecard for `orders`: total_amount completeness (100%), no future dates (0), status domain (0), orphan customers (0). Compute overall score.

**Expected:** 93.3 (FAIL, ≥100), 1 future (FAIL, 0), 4 invalid statuses (FAIL, 0), 1 orphan (FAIL, 0) → 0%.

---

## Part E: Remediation (Step 5)

### Exercise 13.15 — Prioritized remediation

Pick the **top 5 defects** by business severity and fill the remediation table (priority, defect, fix SQL, root cause, prevention).

### Exercise 13.16 — The one-line pitch

Write the 2-3 sentence pitch you'd give the CFO to fund fixing the top defect (use the cost-framing from Unit 01).

---

## Self-Assessment Checkpoint (final)

- [ ] I wrote business context BEFORE queries
- [ ] I profiled every table
- [ ] I found and labeled defects across all 6 dimensions
- [ ] My checks match `dq_dataset_schema.md`'s defect map
- [ ] I built a scorecard with per-dimension status + overall score
- [ ] I wrote a prioritized remediation plan with prevention

**Congratulations — you've completed the Data Quality Engineer module.**
