# Case 01 — Scope (before touching data)

**Main question:** How is sales performance, and where should we focus next month?

## Northstar metrics (~3)

| # | Metric | Definition | Why it matters |
| --- | --- | --- | --- |
| M1 | **Revenue** | `SUM(total_amount)` from `orders` (equals line-item sum per dataset note) | The headline sales number. |
| M2 | **Order count** | `COUNT(*)` from `orders` | Volume of transactions; revenue alone hides whether growth comes from more orders or bigger orders. |
| M3 | **Average order value (AOV)** | `Revenue ÷ Order count` | Basket size; tells us whether customers spend more per visit. |

## Dimensions (~3)

| # | Dimension | Values | Why it matters |
| --- | --- | --- | --- |
| D1 | **Store** | `BRW001` (Manhattan), `BRW002` (Brooklyn), `BRW003` (Queens) | Location performance → where to focus next month. |
| D2 | **Category** | `Beverage`, `Food`, `Merchandise` | Menu mix → which products drive revenue. |
| D3 | **Month** | `2025-01` … `2026-01` (use `strftime('%Y-%m', order_date)`) | Seasonality + trends → next-month focus. |

## Definitions fixed here

- **Revenue:** `orders.total_amount` (the dataset guarantees it equals `SUM(quantity × unit_price)` per order; either source is valid, we use the ready-made column for simplicity).
- **AOV:** total revenue ÷ total orders for the same grouping scope.
- **"Underperforming product"** (KPI Reporting bucket): product whose revenue ranks in the bottom decile — we investigate *why* (units sold, price, active flag) rather than just reporting the number.
