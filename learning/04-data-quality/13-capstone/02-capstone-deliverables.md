# Capstone 13.2: Deliverables — Guided Build Steps

Follow these steps in order. **Do not skip Step 1 — the whole point of this module is business context first.**

---

## Step 1 — Business Context (write this before any query)

Answer these in a short document:

1. **Who consumes each table?** (copy the consumer table from the scenario)
2. **Which fields matter most** per table, and which dimension is dominant?
3. **What are the hard requirements?** (completeness %, allowed statuses, no future dates, etc.)
4. **What would break** if each field were wrong? (tie to the consumer's stakes)

> Then translate these into a **data expectations sheet** per table (Unit 02 format). Your checks must match this sheet exactly.

---

## Step 2 — Profile the Data

Run the profiling patterns from Unit 03 for every table:
- Row counts (all tables, `UNION ALL`)
- NULL rates (all required columns)
- Column stats (products prices/weights, order amounts)
- Frequency distributions (order status, customer state, product category, address country, order currency)
- Cardinality (customer email/phone, product sku)

**Record:** for each profile anomaly, note *which dimension* it hints at.

---

## Step 3 — Findings (run the checks)

For each table, run checks across the relevant dimensions. Use the SQL patterns from Units 04–10. For every finding record:

```
Table     : <table>
Field     : <field>
Dimension : <which of 6>
Finding   : <what's wrong, with counts>
SQL       : <the check that found it>
Impact    : <who it hurts and how>
```

Cover **at least**:
- customers: completeness (email/phone/signup), uniqueness (emails, name+phone), validity (email format, state), accuracy (vs master email/state)
- products: validity (price, weight), uniqueness (sku), consistency (lifecycle: discontinued vs active), accuracy (price/weight vs master)
- addresses: uniqueness (duplicate address), consistency (country naming)
- orders: completeness (total_amount, ship_city, status), validity (status domain), timeliness (future dates), consistency (orphan customer), accuracy (order total vs items)
- order_items: validity (qty), accuracy (total = qty×price), consistency (orphans, currency vs order)
- daily_sales: completeness (NULL metrics), anomaly detection (spike/dip/shift)

---

## Step 4 — Scorecard

Build the per-dimension scorecard (Unit 11). For each table × dimension:

| Table | Dimension | Rule | Metric | Threshold | Status |
|-------|-----------|------|--------|-----------|--------|

Then compute an **overall score** (rules passed / total rules).

---

## Step 5 — Remediation Plan

For the top defects, write:

| Priority | Defect | Fix (SQL) | Root cause | Prevention |
|----------|--------|-----------|------------|------------|
| P1 | ... | ... | ... | ... |

- **Order by severity** (Finance/Exec issues first).
- **Fix = cleanup SQL** (UPDATE/DELETE with care — flag, don't hard-delete).
- **Root cause** = where does the defect originate? (entry form, bad feed, missing FK)
- **Prevention** = which rule to add to the catalog (Unit 11) so it never recurs?

---

## Report Template

```markdown
# Data Quality Audit — <date>

## 1. Business Context
<expectations sheet per table>

## 2. Profile Report
<table of row counts, NULL rates, stats, frequencies>

## 3. Findings
<findings table + SQL>

## 4. Scorecard
<table + overall score>

## 5. Remediation Plan
<prioritized plan>

## Appendix: All SQL used
```

---

## Final Check

- [ ] Business context written first
- [ ] All 6 dimensions covered
- [ ] All defects from `dq_dataset_schema.md` found
- [ ] Scorecard complete with overall score
- [ ] Remediation prioritized by severity with prevention
