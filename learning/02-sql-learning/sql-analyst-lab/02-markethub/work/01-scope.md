# Case 02 — Scope (before touching data)

**Main question:** How is the marketplace performing, and which vendor/segment should we invest in next?

## Northstar metrics

| # | Metric | Definition | Why it matters |
| --- | --- | --- | --- |
| M1 | **GMV (Gross Merchandise Value)** | `SUM(total_amount)` from `orders` where `status IN ('Completed','Shipped')` (fulfilled sales; Cancelled + Pending excluded) | The headline marketplace sales number. |
| M2 | **Order count** | `COUNT(*)` of fulfilled orders (same Completed + Shipped set) | Volume of transactions; separates "more orders" from "bigger orders". |
| M3 | **AOV** | `GMV ÷ Order count` (same grouping scope) | Basket size; the value lever vs. the volume lever. |
| M4 | **Repeat purchase rate** | customers with ≥2 fulfilled orders ÷ customers with ≥1 fulfilled order | Buyer loyalty — the "invest next" growth signal. |

> Floor is ~3; M4 is added because the main question explicitly asks *which segment to invest next*, and loyalty is the metric that signals a segment worth investing in.

## Dimensions

| # | Dimension | Values | Why it matters |
| --- | --- | --- | --- |
| D1 | **Vendor** | `vendors.vendor_id` (14 vendors) | The literal "which vendor should we invest in next". |
| D2 | **Country** | `customers.country` (buyer geography) | Segment-level performance; where growth comes from. |
| D3 | **Category** | `categories` top-level parent (8 parents, 16 subcategories) | Catalog mix — which lines drive GMV. |
| D4 | **Month** | `2025-01` … `2026-01` (`TO_CHAR(order_date,'YYYY-MM')`) | Trends + MoM/YoY (both supported this dataset). |

> Payment method is a known quirk dimension (517 no-payment orders, Failed/Refunded statuses) but is **not** a core scope dimension here — it earns a slot only if a KPI "why" sub-question needs it.

## Definitions fixed here

- **GMV (Gross Merchandise Value):** `orders.total_amount` for `status IN ('Completed','Shipped')`. Cancelled and Pending orders are excluded — Cancelled have no payment/shipment and Pending are not yet realized sales. (Note: `total_amount` = sum of its `order_items` per the dataset README.)
- **Order count:** `COUNT(*)` of the same Completed + Shipped set.
- **AOV:** total GMV ÷ total fulfilled order count, computed within the same grouping scope.
- **Repeat purchase rate:** (`COUNT(DISTINCT customer_id)` with ≥2 fulfilled orders ÷ `COUNT(DISTINCT customer_id)` with ≥1 fulfilled order) **× 100**, expressed as a percentage.
- **"Underperforming vendor/segment" (KPI Reporting bucket):** a vendor whose GMV ranks in the bottom of the vendor set — we investigate *why* (units sold, category mix, fulfillment/payment health) rather than just report the number.
