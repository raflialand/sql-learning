# Case 02 — Scope (before touching data)

**Main question:** How is the marketplace performing, and which vendor/segment should we invest in next?

## Northstar metrics (~3)

| # | Metric | Definition | Why it matters |
| --- | --- | --- | --- |
| M1 | **GMV (gross merchandise value)** | `SUM(total_amount)` from `orders` — we count **Completed + Shipped** orders as revenue-generating (Cancelled and Pending are excluded from GMV; see note below) | The headline marketplace volume. |
| M2 | **AOV (average order value)** | `GMV ÷ order count` for the same order scope | Basket size; reveals whether growth comes from more buyers or bigger baskets. |
| M3 | **Repeat purchase rate** | **Fixed definition (see below):** `customers with ≥ 2 Completed or Shipped orders ÷ customers with ≥ 1 Completed or Shipped order`, over the full order history | Loyalty health — the strongest "which segment to invest in" signal. |

### Fixed definitions (must be consistent across all queries)

- **"Order" scope for GMV/AOV:** `status IN ('Completed','Shipped')`. Cancelled orders returned no money; Pending orders are not yet real. This scope SHALL be used consistently.
- **Repeat purchase rate — FIXED here:** a buyer is a "repeat" customer if they have **≥ 2 orders in the `Completed`/`Shipped` scope** (any date in the full history). The rate = repeat customers ÷ customers with **≥ 1 order** in that scope. No windowing, no recency filter — simplest consistent definition that matches the dataset.

## Dimensions (~3–4)

| # | Dimension | Values | Why it matters |
| --- | --- | --- | --- |
| D1 | **Month** | `2025-01` … `2026-01` via `strftime('%Y-%m', order_date)` | Trends + MoM + YoY. |
| D2 | **Country** | 7 buyer countries (e.g. USA, Canada, Germany) | Geographic segment for investment. |
| D3 | **Category** | 8 top-level categories (e.g. Electronics, Clothing) | Product segment for investment. |
| D4 | **Payment method** | `Card`, `PayPal`, `Bank Transfer`, `COD` | Payment health KPI (failed attempts). |

## Definitions fixed here

- **GMV** = sum of `total_amount` for `Completed`/`Shipped` orders (dataset note: `total_amount` always equals line-item sum).
- **AOV** = GMV ÷ order count (same scope).
- **Repeat purchase rate** = buyers with ≥2 orders ÷ buyers with ≥1 order (scope: Completed/Shipped).
- **Payment failure "why"** (KPI Reporting): failure rate = `Failed` payments ÷ all payment attempts, then sliced by method to explain which method leaks.
