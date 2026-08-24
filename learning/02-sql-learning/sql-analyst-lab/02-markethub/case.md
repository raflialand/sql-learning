# Case 02 — MarketHub Marketplace

**Module:** SQL Analyst Lab · **Dataset:** `sql-skill-push/datasets/02-intermediate/ecommerce.db` (read-only, reused)
**Dataset README + ERD:** `sql-skill-push/datasets/02-intermediate/README.md` — read this first: business context (multi-vendor marketplace, 8 tables: categories/vendors/products/customers/orders/order_items/payments/shipments), join hints, and data quirks (order statuses Completed/Shipped/Pending/Cancelled, 517 orders with no payment row, payments statuses Paid/Failed/Refunded).

## Main question

> **How is the marketplace performing, and which vendor/segment should we invest in next?**

"Marketplace performance" is broad: it spans GMV, basket size, buyer loyalty, and payment health — and "invest next" forces you to pick a segment, not just report levels.

## How to work this case

1. Draft your own `01-scope.md` and `02-questions.md` in `work/` first (metrics/dimensions are still suggested, but the bucket mapping is **partially open** — decide which sub-questions belong where).
2. Write your queries in `work/`, run them against `ecommerce.db`, and compare with `expected/03-results.md`.
3. Check the model answer in `expected/` only after your own attempt.

## Scaffolding

Medium scaffolding: metrics (GMV, AOV, repeat purchase rate) and dimensions (country, category, month, payment method) are suggested, but you decide the full bucket-to-sub-question mapping. Case 01 showed you the pattern; now you apply it with less hand-holding.

## Dataset limitation note

Unlike Case 03 (telecom, MoM only), this dataset spans **2025-01-01 → 2026-01-31**, so both MoM **and YoY** comparisons are supported (e.g. Jan-2025 vs Jan-2026). Use them.
