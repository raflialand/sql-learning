# Capstone 13.1: The Scenario — Full DQ Audit

You are a **Data Quality Engineer** hired by the fictional e-commerce company that owns the `dq_learning` dataset. Your first assignment: **a complete data quality audit** of the operational database, delivered as a written report.

---

## The Business Context (read this first — it drives everything)

**Company:** you sell electronics and office supplies online across two sales regions (RGN001, RGN002).

**Key consumers and their stakes:**

| Consumer | Uses | Critical fields | Hard requirement |
|----------|------|-----------------|------------------|
| **Finance** | Monthly revenue reporting | `orders.total_amount`, `order_items.*` | total_amount must be 100% present & match items |
| **Marketing** | Email campaigns | `customers.email` | ≥ 99% present, valid format, no duplicates |
| **Ops** | Fulfillment | `orders.status`, `ship_city` | status in {shipped, pending, cancelled}; no future dates |
| **Executives** | Daily KPI dashboard | `daily_sales.*` | no NULL metrics, no unexplained spikes/shifts |
| **Logistics** | Shipping | `addresses.city/country` | complete, consistent country naming |

**Reference date: 2026-08-03.** (Anything after that is "in the future".)

---

## Your Deliverables

1. **Business-context section** — written BEFORE any query (Step 1).
2. **Profile report** — shape of every table (Step 2).
3. **Findings** — defects found, each labeled by dimension, with the SQL that found it (Step 3).
4. **Scorecard** — per-dimension PASS/FAIL per table with an overall score (Step 4).
5. **Remediation plan** — what to fix, in what order, and how to prevent recurrence (Step 5).

---

## The Master Data Reference

`dq_dataset_clean.sql` provides `dq_clean_*` tables (correct prices, emails, states, weights). Use them to confirm suspected accuracy defects. **Master data wins** unless you document otherwise.

---

## Grading Checklist (how you know you're done)

- [ ] Business context written *first*, tied to specific consumers
- [ ] Every dimension (6) covered with at least one check per table where relevant
- [ ] Every defect in `dq_dataset_schema.md` found by at least one check
- [ ] Scorecard has per-dimension status + overall score
- [ ] Remediation plan ordered by severity, with prevention measures
- [ ] All SQL executed and verified against `dq_learning`

---

## Suggested Structure (Steps 1–5)

Use `02-capstone-deliverables.md` to write your report, or create your own document. The steps are detailed next.
