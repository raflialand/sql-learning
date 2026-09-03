# Business Case: Omnichannel Sales Performance & Loyalty Optimization

**Module**: Data-to-Insight Pipeline
**Dataset**: `data/02-bookstore/` (SQLite: `bookstore.db`)
**Difficulty**: Intermediate–Advanced
**Estimated Time**: 3–5 hours (across all stages)

---

## Business Context

**PageTurner Books** is a mid-size bookstore chain operating 8 physical retail locations alongside an online storefront. Over the past two years (September 2024 – August 2026), the company has accumulated rich transactional data across orders, inventory, customers, reviews, and promotional campaigns.

Senior leadership has called an urgent strategy review. The company has been growing top-line revenue, but margins are under pressure from rising shipping costs, inventory carrying costs, and a declining repeat-purchase rate among certain customer segments. The leadership team needs a **data-driven diagnostic** to understand *what is working*, *what is not*, and *where to invest next*.

### Key Stakeholders

| Stakeholder | Interest |
|-------------|----------|
| **VP of Retail Operations** | Store-level performance, staffing efficiency, inventory turns |
| **VP of E-Commerce** | Online conversion, shipping cost management, digital marketing ROI |
| **Head of Marketing** | Promotion effectiveness, customer acquisition vs retention, segment health |
| **CFO** | Margin analysis, revenue decomposition, cost optimization |
| **Inventory Manager** | Stock-out frequency, reorder optimization, slow-mover identification |

---

## Main Business Question

> **"How is PageTurner Books performing across its omnichannel operations, and which levers — store locations, customer segments, product categories, or promotional strategies — should leadership prioritize to improve profitability and customer loyalty over the next 12 months?"**

This question is intentionally open-ended. It spans multiple business dimensions and requires the analyst to decompose it into actionable sub-questions.

### Suggested Sub-Questions (Decomposition Guide)

The analyst should explore these dimensions (not exhaustive):

1. **Revenue Health**: What is the total revenue trend over the 2-year period? Is there seasonality? MoM and YoY growth rates?
2. **Channel Mix**: How do physical stores compare to online orders in terms of revenue, order volume, AOV (Average Order Value), and margin?
3. **Store Performance**: Which stores are top/bottom performers? Is there a correlation between store size (sq. ft.) and revenue?
4. **Customer Segmentation**: How do loyalty tiers and customer segments differ in CLV (Customer Lifetime Value), repeat rate, and order frequency?
5. **Category Analysis**: Which book categories drive the most revenue? Which have the highest margin? Are there "long tail" categories that are underperforming?
6. **Promotional ROI**: How effective are promotions? Which codes drive incremental revenue vs. simply discounting existing demand?
7. **Inventory Efficiency**: Are there chronic stock-outs or overstock situations? What is the inventory turnover rate by category and store?
8. **Review & Quality Signals**: Do highly-reviewed books sell better? Is there a correlation between review sentiment and repeat purchases?

---

## Dataset Limitation Notes

| Limitation | Detail | Impact on Analysis |
|------------|--------|--------------------|
| **Date range** | Sep 2024 – Aug 2026 (24 months) | YoY comparisons are possible for the overlapping 12 months (Sep 2024–Aug 2025 vs Sep 2025–Aug 2026). Full 2-year trend analysis is supported. |
| **Data quality issues** | ~5-10% NULLs, case inconsistency, whitespace, wrong data types, date format variation | Data cleaning must precede analysis. Some columns (e.g., `order_status`, `payment_method`) require standardization before grouping. |
| **No cost/margin data** | `books` has `price` and `list_price` but no COGS | True margin analysis requires assumption: use `list_price - price` as a proxy for publisher discount, or treat `price` as the cost to PageTurner. |
| **No online/offline channel flag** | Orders link to `store_id` (nullable) but there is no explicit `channel` column | Online orders likely have `store_id IS NULL`. The analyst must infer channel from this field. |
| **Promotions not linked to orders** | `promotions` table has `code` but `orders` has no `promo_code` foreign key | Promotion effectiveness can only be inferred from timing overlaps or `order_items.discount` > 0 patterns, not directly joined. |
| **Shipping cost variability** | `shipping.shipping_cost` exists but no order-level "fulfillment channel" flag | Shipping cost analysis requires careful interpretation. |

---

## Scaffolding Hints

### Suggested Metrics

| Metric | Definition | Tables Involved |
|--------|------------|-----------------|
| **Total Revenue** | `SUM(total_amount)` per period | `orders` |
| **AOV (Average Order Value)** | `AVG(total_amount)` per customer/segment/channel | `orders` |
| **Order Volume** | `COUNT(DISTINCT order_id)` per period | `orders` |
| **Revenue by Category** | Join `order_items` → `books` → `categories`, sum `line_total` | `order_items`, `books`, `categories` |
| **Revenue by Store** | Group `orders` by `store_id` (null = online) | `orders`, `stores` |
| **Repeat Purchase Rate** | % of customers with > 1 order in period | `orders`, `customers` |
| **CLV (Customer Lifetime Value)** | Total spend per customer over full period | `orders`, `customers` |
| **Inventory Turnover** | Units sold / average inventory level | `order_items`, `inventory` |
| **Stock-out Frequency** | Count of `inventory.quantity = 0` snapshots | `inventory` |
| **Review Correlation** | Average rating of top-selling vs bottom-selling books | `reviews`, `order_items`, `books` |
| **Promotional Uplift** | Compare AOV of discounted vs non-discounted orders | `order_items`, `orders` |
| **Shipping Cost Ratio** | `shipping_cost / total_amount` per order | `shipping`, `orders` |

### Suggested Dimensions

| Dimension | Column | Table |
|-----------|--------|-------|
| Time period | `order_date` (month, quarter, year) | `orders` |
| Channel | `store_id` (NULL = online) | `orders` |
| Store location | `city`, `state` | `stores` |
| Customer segment | `customer_segment` | `customers` |
| Book category | `name` (via `category_id`) | `categories` → `books` |
| Promotion | `discount` > 0 flag | `order_items` |
| Order status | `order_status` | `orders` |

---

## How to Work This Case

### Step 1 — Data Exploration & Cleaning
Before any analysis, explore the raw data:
- Run `SELECT * FROM orders LIMIT 20` to understand column formats
- Identify NULLs: `SELECT COUNT(*) FROM orders WHERE order_status IS NULL`
- Standardize statuses: `SELECT DISTINCT order_status FROM orders` — note case inconsistencies
- Check date formats: `SELECT order_date FROM orders LIMIT 50`

**Tip**: Use CTEs to create a cleaned staging layer before aggregating. For example:
```sql
WITH cleaned_orders AS (
    SELECT *,
           TRIM(UPPER(order_status)) AS status_clean,
           /* date parsing logic */
    FROM orders
)
```

### Step 2 — Metric Computation
Build your core metric queries. Start with the simplest (total revenue by month) and progressively add dimensions (by store, by category, by segment).

### Step 3 — Comparative Analysis
Compare metrics across dimensions:
- Store vs Online (AOV, volume, shipping cost)
- Top vs Bottom stores (revenue, inventory efficiency)
- High-value vs Low-value customer segments (repeat rate, CLV)
- Promoted vs Non-promoted orders (AOV, margin impact)

### Step 4 — Insight Synthesis
For each comparison, identify:
- **Trend**: Is the metric improving or declining?
- **Fluctuation**: Are there seasonal spikes or anomalies?
- **Anomaly**: Any sudden changes that break the pattern?
- **Root Cause**: What business factor explains the pattern?
- **Recommendation**: What action should leadership take?

### Step 5 — Stakeholder Deliverable
Prepare a summary that answers the main business question with 3–5 key findings, each supported by data. Structure as:
1. Executive summary (1 paragraph)
2. Key finding #1 + supporting metric
3. Key finding #2 + supporting metric
4. Key finding #3 + supporting metric
5. Recommended actions (prioritized)

---

## Success Criteria

A successful analysis will:
- ✅ Produce at least 5 distinct metrics across 3+ dimensions
- ✅ Identify a clear top-performing and bottom-performing segment/store/category
- ✅ Quantify the impact of promotions on AOV (even if directional)
- ✅ Surface at least 1 actionable inventory or operational recommendation
- ✅ Handle data quality issues cleanly (no raw NULLs or case-inconsistent groupings in final output)
