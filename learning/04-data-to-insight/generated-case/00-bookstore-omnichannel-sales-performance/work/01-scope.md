# Stage 1 — Scope

**Case**: 00-bookstore-omnichannel-sales-performance
**Date**: 2026-09-03

---

## 1. Northstar Metrics

| # | Metric | Definition | Source Tables | Notes |
|---|--------|------------|---------------|-------|
| M1 | **Total Revenue** | `SUM(total_amount)` per period | `orders` | Primary top-line measure. Includes tax. |
| M2 | **Average Order Value (AOV)** | `AVG(total_amount)` per period/segment | `orders` | Measures transaction value. Sensitive to channel mix. |
| M3 | **Order Volume** | `COUNT(DISTINCT order_id)` per period | `orders` | Transaction count. Baseline for growth rates. |
| M4 | **Repeat Purchase Rate** | `% of customers with > 1 order in period` | `orders` | Directly addresses the "customer loyalty" lever. |
| M5 | **Inventory Turnover** | `Units sold / avg inventory level` | `order_items`, `inventory` | Addresses "profitability" via carrying cost efficiency. |

**Why 5 metrics (above floor):** The main question explicitly spans profitability *and* customer loyalty. Revenue/AOV/Volume cover profitability; Repeat Rate covers loyalty; Inventory Turnover covers operational efficiency — each maps to a distinct stakeholder interest.

---

## 2. Dimensions

| # | Dimension | Column / Derivation | Source Tables | Notes |
|---|-----------|---------------------|---------------|-------|
| D1 | **Time Period** | `order_date` → month, quarter, year | `orders` | Enables trend and seasonality analysis. |
| D2 | **Channel** | `store_id` IS NULL → "Online", else "In-Store" | `orders` | Inferred (L4). Must state assumption. |
| D3 | **Customer Segment** | `customer_segment` | `customers` | Direct column. Enables segment-level diagnosis. |
| D4 | **Book Category** | `categories.name` via `books.category_id` | `order_items`, `books`, `categories` | Product-level analysis. Hierarchical (parent_category_id). |
| D5 | **Store Location** | `stores.city`, `stores.state` | `orders`, `stores` | Enables top/bottom store comparison. |

**Why 5 dimensions (above floor):** The main question names 4 specific levers (store locations, customer segments, product categories, promotional strategies). Time period is mandatory for trend analysis. Promotional strategy is handled via `order_items.discount > 0` flag at query time, not as a standalone dimension.

---

## 3. Definitions Fixed Here

| Term | Definition Used | Alternative (Rejected) | Rationale |
|------|----------------|----------------------|-----------|
| **Revenue** | `SUM(orders.total_amount)` — includes tax | `SUM(order_items.line_total)` — excludes tax | `total_amount` is the order-level truth; tax is part of what the customer pays. |
| **Online Channel** | `orders.store_id IS NULL` | Separate channel column (doesn't exist) | Only available inference method (L4). |
| **Repeat Customer** | Customer with ≥ 2 orders in the analysis period | ≥ 1 order in prior period + ≥ 1 in current (cohort-based) | Cohort-based is more rigorous but requires explicit cohort framing; simpler definition suffices for scope. |
| **Inventory Turnover** | `SUM(order_items.quantity)` / `AVG(inventory.quantity)` | `SUM(quantity) / (beginning + ending) / 2` | Avg inventory is simpler; beginning/ending split requires temporal inventory snapshots which may not exist. |
| **AOV** | `AVG(orders.total_amount)` | Weighted average across items | Standard definition; item-level weighting is uncommon at this stage. |

---

## 4. Scope Boundaries

### In Scope
- Revenue trends (monthly, quarterly, yearly) over 24 months
- Channel comparison (Online vs In-Store) on Revenue, AOV, Order Volume
- Customer Segment analysis on Repeat Rate and Revenue contribution
- Book Category analysis on Revenue and Inventory Turnover
- Store-level performance ranking (top/bottom)
- MoM and YoY growth rates (allowed per L1)

### Out of Scope (Limitation-Driven)
- **True margin analysis** — no COGS data (L3). Proxy discount spread (`list_price - price`) may appear in queries but will not be framed as "margin."
- **Causal promotional ROI** — no FK from promotions to orders (L5). Discount-associated lift only.
- **Shipping cost optimization** — shipping data exists but no fulfillment channel flag (L6). Directional only.

### Out of Scope (Choice)
- Employee/staffing analysis (not relevant to the main question)
- Publisher-level analysis (too granular for this case)
- Individual book-level analysis (use categories instead)

---

## 5. Scope Complete — Ready for Checkpoint

Scope defines 5 metrics × 5 dimensions. Downstream stages will decompose these into specific sub-questions (Stage 2). Ready for progress-evaluator verification.
