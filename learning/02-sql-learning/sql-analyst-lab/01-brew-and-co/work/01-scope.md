# Case 01 — Scope (before touching data)

**Main question:** How is sales performance, and where should we focus next month?

## Northstar metrics (~3)

| # | Metric | Definition | Why it matters |
| --- | --- | --- | --- |
| M1 | Revenue | `SUM(total_amount)` from orders | Headline sales number |
| M2 | Order count | `COUNT(*)` from orders | Volume lever — revenue = count × AOV |
| M3 | AOV | Revenue ÷ Order count | Basket size / value lever |

## Dimensions (~3)

| # | Dimension | Values | Why it matters |
| --- | --- | --- | --- |
| D1 | Store | BRW001 / BRW002 / BRW003 | Literal "where" → resource focus next month |
| D2 | Category | Beverage / Food / Merchandise | Menu mix lever |
| D3 | Month | 2025-01 … 2026-01 | Trends + next-month focus |

## Definitions fixed here

- Revenue: `orders.total_amount` (guaranteed to equal line-item sum).
- AOV: total revenue ÷ total orders for the same grouping scope.
- "Underperforming product": a product in the bottom decile (lowest ~10%) of product revenue.
