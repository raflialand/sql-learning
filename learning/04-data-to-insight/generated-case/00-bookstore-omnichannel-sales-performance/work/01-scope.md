# Stage 1 — Scope (v2: stakeholder-brief-aligned)

**Case**: 00-bookstore-omnichannel-sales-performance
**Date**: 2026-09-07
**Stakeholder brief**: `00-stakeholder-brief.md`

---

## 1. Northstar Metrics

| # | Metric | Definition | Source Tables | Traces to Brief |
|---|--------|------------|---------------|-----------------|
| M1 | **Total Revenue** | `SUM(total_amount)` per period | `orders` | CFO priority #1: revenue decomposition. Success criteria #1: name the #1 lever. |
| M2 | **Average Order Value (AOV)** | `AVG(total_amount)` per period/segment | `orders` | CFO priority #1: revenue decomposition. Stakeholder question: "Is online a cost center?" AOV comparison answers this. |
| M3 | **Order Volume** | `COUNT(DISTINCT order_id)` per period | `orders` | CFO priority #1: baseline for growth rates. VP Retail: store-level volume ranking. |
| M4 | **Repeat Purchase Rate** | `% of customers with ≥2 orders in period` | `orders` | Head of Marketing priority #3: customer segment health. Main question explicitly mentions "customer loyalty." Stakeholder Q3: "Which segments are declining?" |

**Why 4 metrics (above floor):** The brief's stakeholder priorities rank CFO (revenue + cost) as #1 and Marketing (customer health) as #2. Revenue/AOV/Volume cover the CFO's decomposition need; Repeat Rate covers Marketing's loyalty concern. Inventory Turnover (from old scope) is dropped — it maps to Inventory Manager (priority #5) and requires `inventory` table which has data quality issues. If the KPI "why" sub-question needs it, it can be added then.

---

## 2. Dimensions

| # | Dimension | Column / Derivation | Source Tables | Traces to Brief |
|---|-----------|---------------------|---------------|-----------------|
| D1 | **Time Period** | `order_date` → month | `orders` | All stakeholders need trends. Success criteria #5: actionable recommendations need temporal context. |
| D2 | **Channel** | `store_id IS NULL` → "Online", else "In-Store" | `orders` | VP E-Commerce priority #4. Stakeholder Q2: "Is online a growth engine or cost center?" Assumption stated in brief. |
| D3 | **Customer Segment** | `customer_segment` | `customers` | Head of Marketing priority #3. Stakeholder Q3: "Which segments are declining?" Main question names customer segments as a lever. |
| D4 | **Book Category** | `categories.name` via `books.category_id` | `order_items`, `books`, `categories` | Main question names product categories as a lever. Success criteria #2: quantify gap between top/bottom categories. |
| D5 | **Store Location** | `stores.city`, `stores.state` | `orders`, `stores` | VP Retail priority #2. Main question names store locations as a lever. Success criteria #2: identify top/bottom stores. |

**Why 5 dimensions (above floor):** The main question explicitly names 4 levers (store locations, customer segments, product categories, promotions). Time period is mandatory for trends. Promotional strategy is handled via `order_items.discount > 0` flag at query time (not a standalone dimension) — per brief assumption #2, promotions are indirect and cannot be a core scope dimension.

---

## 3. Definitions Fixed Here

| Term | Definition Used | Alternative (Rejected) | Traces to Brief |
|------|----------------|----------------------|-----------------|
| **Revenue** | `SUM(orders.total_amount)` — includes tax | `SUM(order_items.line_total)` — excludes tax | Brief assumption #4: revenue includes tax; consistent across channels so comparisons are valid. |
| **Online Channel** | `orders.store_id IS NULL` | Separate channel column (doesn't exist) | Brief assumption #1: channel inference required; must state assumption. |
| **Repeat Customer** | Customer with ≥ 2 orders in the analysis period | Cohort-based (prior + current period) | Brief assumption: simpler definition suffices for scope; cohort analysis can be a deeper drill-down. |
| **AOV** | `AVG(orders.total_amount)` | Weighted average across items | Standard definition; brief success criteria #2: quantifying gap needs a simple, defensible metric. |
| **"Underperforming"** | Bottom quartile by revenue | Bottom 1 or bottom 3 | Brief success criteria #2: quantify the gap — quartile gives scale context without being overly restrictive. |

---

## 4. Scope Boundaries

### In Scope
- Revenue trends (monthly) over 24 months — traces to CFO priority #1, all stakeholders
- Channel comparison (Online vs In-Store) on Revenue, AOV, Order Volume — traces to VP E-Commerce priority #4, stakeholder Q2
- Customer Segment analysis on Repeat Rate and Revenue contribution — traces to Head of Marketing priority #3, stakeholder Q3
- Book Category analysis on Revenue — traces to main question lever, success criteria #2
- Store-level performance ranking (top/bottom by revenue) — traces to VP Retail priority #2, success criteria #2
- MoM and YoY growth rates — allowed per dataset limitation (24-month range supports both)

### Out of Scope (Limitation-Driven)
- **True margin analysis** — no COGS data (brief assumption #3). `list_price - price` is a proxy only; no true margin claims.
- **Promotional ROI** — no FK from promotions to orders (brief assumption #2). Discount-associated lift only, not causal.
- **Shipping cost optimization** — no fulfillment channel flag. Directional only.
- **Inventory Turnover** — dropped from scope (brief decision: maps to priority #5, data quality issues in inventory table). Can be added as a KPI drill-down if needed.

### Out of Scope (Choice)
- Employee/staffing analysis (not relevant to main question)
- Publisher-level analysis (too granular)
- Individual book-level analysis (use categories instead)
- Review/sentiment analysis (not named as a lever in main question)

---

## 5. Scope Complete — Ready for Checkpoint

Scope defines 4 metrics × 5 dimensions. Every metric and dimension traces to a stakeholder priority, assumption, or success criterion in `00-stakeholder-brief.md`. Downstream stages will decompose these into specific sub-questions (Stage 2). Ready for progress-evaluator verification.
