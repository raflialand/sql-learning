# Case 03 — Context: NovaTel Telecom

**Date:** 1 September 2026  
**Source:** `case.md` + `datasets/03-advanced/README.md`

---

## Business Context

**NovaTel** is a mobile telecom carrier with 4,500 subscribers across 6 plans (Starter $20 → Unlimited Max $120). Subscribers pick a plan, receive a monthly bill, pay it, and consume data/voice/SMS each month. Some open support tickets, and some churn (cancel).

**Main question:** Is the subscriber base healthy, and where is revenue leaking?

This mixes growth/retention (subscriber base health) with collections (revenue leaking).

---

## Dataset Structure (7 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `plans` | 6 | Subscription plans (plan_id, plan_name, monthly_fee, data_gb, voice_min) |
| `subscribers` | 4,500 | Customer accounts (sub_id, plan_id, region, signup_date, status) |
| `billing` | 7,996 | Monthly bills (bill_id, sub_id, bill_date, amount, status) |
| `payments` | 6,588 | Bill payments (pay_id, sub_id, bill_id, pay_date, amount, method) |
| `usage_logs` | 7,418 | Monthly data/voice/SMS usage (log_id, sub_id, log_date, data_mb, voice_min, sms) |
| `tickets` | 3,800 | Support tickets (ticket_id, sub_id, created_date, resolved_date, category, status) |
| `churn` | 427 | Subscribers who cancelled (churn_id, sub_id, churn_date, reason) |

## Key Data Notes

- **Subscriber status:** Active (3,709), Suspended (364), Cancelled (427)
- **Billing cycles:** 2 months only — Dec 2025 (4,287 bills) and Jan 2026 (3,709 bills)
- **Bill statuses:** Paid (6,588), Unpaid (765), Overdue (643)
- **216 subscribers** were billed but never paid
- **Usage:** one log per active subscriber per billing month; ~30 GB/month typical; some exceed plan allowance
- **Tickets:** 1,149 tickets have resolved_date = NULL (still open)
- **Churn reasons:** Price, Coverage, Service Quality, Moving, Competitor Offer, Other

## CRITICAL LIMITATION

**Billing spans ONLY two months: 2025-12-01 and 2026-01-01. There is NO YoY comparison possible — only MoM (Dec-2025 → Jan-2026).**

This applies to all time-series analysis. Usage logs also span 2025-12 to 2026-01.

---

## Implications for Analysis

1. **MoM-only constraint:** All time comparisons must be Dec → Jan. No YoY claims allowed.
2. **Revenue leakage indicators:** Unpaid (765) + Overdue (643) = 1,408 bills not paid = ~17.6% of total 7,996 bills.
3. **Churn is snapshot, not trend:** 427 churned subscribers with dates, but only 2 months of billing means we can't do churn trend analysis beyond a single count.
4. **Usage vs plan:** Can compare actual usage against plan allowance to find over/under-utilization.
5. **Ticket resolution gap:** 1,149 unresolved tickets is a service quality signal that may correlate with churn.
