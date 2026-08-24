# Case 03 — Scope (before touching data)

**Main question:** Is the subscriber base healthy, and where is revenue leaking?

## Northstar metrics (~3) — learner-derived

| # | Metric | Definition | Why it matters |
| --- | --- | --- | --- |
| M1 | **Revenue (billed)** | `SUM(amount)` from `billing` per month (`bill_date`) | The money the business bills — the top line for a subscription company. |
| M2 | **Active subscribers** | `COUNT(DISTINCT sub_id)` from `subscribers WHERE status = 'Active'` (and per-month from billing/usage) | Base health — the pool that generates recurring revenue. |
| M3 | **ARPU (average revenue per user)** | `Revenue ÷ Active subscribers` for the same month | Monetization intensity; whether revenue moves because the base grows or because each user pays more. |

### Derived (secondary) metrics used by the KPI "why"

- **Unpaid/Overdue share:** billing rows with `status IN ('Unpaid','Overdue')` — the direct revenue leak.
- **Churn:** `COUNT(*)` from `churn` (427 records) — the base shrink driver.
- **Avg data usage:** `AVG(data_mb)` from `usage_logs` — consumption health (are subscribers using what they pay for?).

## Dimensions (~3) — learner-derived

| # | Dimension | Values | Why it matters |
| --- | --- | --- | --- |
| D1 | **Plan** | `Starter`/`Standard`/`Plus`/`Premium`/`Family`/`Unlimited Max` | Product segmentation — which plans generate/leak revenue. |
| D2 | **Region (state)** | Northeast, Southeast, Midwest, Southwest, West | Geographic health and where churn concentrates. |
| D3 | **Month** | `2025-12`, `2026-01` (MoM only — dataset limitation) | The only trend axis available. |

### KPI "why" dimension (dig one layer deeper)

- **Usage tier** — buckets of `avg monthly data_mb` per subscriber (e.g. low/medium/high/excessive) to explain whether revenue health aligns with consumption.
- **Ticket category** — from `tickets` (Billing/Technical/Network/Account/Device) to explain churn/revenue-leak root causes.

## Definitions fixed here

- **Revenue (billed):** `billing.amount` grouped by `bill_date` month. Billing has exactly two months — MoM only.
- **ARPU:** billed revenue ÷ active subscribers for the same `bill_date` month.
- **Active subscribers:** `subscribers.status = 'Active'` (3,709 at the end of the window); per-month base = distinct subscribers with a bill in that month.
- **Revenue leak:** `billing.status IN ('Unpaid','Overdue')` — money billed but not collected.
- **MoM growth:** `(Jan − Dec) / Dec × 100`. NO YoY — the dataset has only two billing months (stated in `case.md`).
