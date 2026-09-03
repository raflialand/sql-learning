# Case 03 — Scope (before touching data)

**Main question:** Is the subscriber base healthy, and where is revenue leaking?

## Northstar metrics (~3) — learner-derived

| # | Metric | Definition | Why it matters |
| --- | --- | --- | --- |
| M1 | **Revenue (billed)** | `SUM(amount)` from `billing` grouped by `bill_date` month | The top line — how much the business bills each cycle. The primary revenue health indicator. |
| M2 | **Payment collection rate** | `COUNT(bills WHERE status='Paid') / COUNT(*) × 100` per month | The inverse of leakage — what percentage of billed revenue actually gets collected. Direct measure of revenue health. |
| M3 | **Active subscriber base** | `COUNT(DISTINCT sub_id)` from `billing` (per month) | The engine of recurring revenue — whether the paying base is growing or shrinking. |

### Derived (secondary) metrics used by the KPI "why"

- **Unpaid/Overdue share:** billing rows with `status IN ('Unpaid','Overdue')` — the direct revenue leak signal.
- **Churn count:** `COUNT(*)` from `churn` (427 records) — the base shrink driver.
- **ARPU (average revenue per user):** `Revenue ÷ Active subscribers` per month — whether revenue moves because the base grows or because each user pays more.

## Dimensions (~3) — learner-derived

| # | Dimension | Values | Why it matters |
| --- | --- | --- | --- |
| D1 | **Plan** | Starter, Standard, Plus, Premium, Family, Unlimited Max | Product segmentation — which plans generate or leak revenue. Different price points ($20–$120) mean different revenue impact per subscriber. |
| D2 | **Region** | Northeast, Southeast, Midwest, Southwest, West | Geographic health — where churn concentrates, where revenue leakage is worst. |
| D3 | **Month** | 2025-12, 2026-01 (MoM only — dataset limitation) | The only trend axis available. Two-point comparison: Dec → Jan. |

### KPI "why" dimension (dig one layer deeper)

- **Usage tier** — buckets of avg monthly data_mb per subscriber (low/medium/high/excessive) to explain whether revenue health aligns with consumption. Are high-usage subscribers paying their fair share? Are low-usage subscribers churning?
- **Ticket category** — from `tickets` (Billing/Technical/Network/Account/Device) to explain churn/revenue-leak root causes. Billing tickets may correlate with payment issues; Network tickets may correlate with coverage-driven churn.

## Definitions fixed here

- **Revenue (billed):** `billing.amount` grouped by `bill_date` month. Billing has exactly two months — MoM only.
- **Payment collection rate:** `COUNT(billing WHERE status='Paid') / COUNT(*) × 100` per `bill_date` month.
- **Active subscribers (per-month):** distinct `sub_id` with a bill in that month (not the subscriber table's status field, which is a snapshot).
- **Revenue leak:** `billing.status IN ('Unpaid','Overdue')` — money billed but not collected.
- **MoM growth:** `(Jan − Dec) / Dec × 100`. NO YoY — the dataset has only two billing months (stated in `case.md`).
- **ARPU:** billed revenue ÷ active subscribers for the same `bill_date` month.

## Hard constraints

1. **MoM-only:** No YoY comparisons. All time-series analysis is limited to Dec-2025 → Jan-2026.
2. **Read-only datasets:** Do not modify source data.
3. **Floor, not cap:** 3 metrics + 3 dimensions is the minimum starting point. Add more only if a specific sub-question demands it.
