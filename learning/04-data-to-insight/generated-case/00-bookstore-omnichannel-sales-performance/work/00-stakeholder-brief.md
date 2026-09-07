# Stage 0 — Stakeholder Brief

**Case**: 00-bookstore-omnichannel-sales-performance
**Date**: 2026-09-07

---

## 1. Business Context Summary

PageTurner Books is a mid-size bookstore chain with 8 physical stores and an online storefront, operating over 24 months (Sep 2024 – Aug 2026). Revenue is growing but margins are squeezed by rising shipping costs, inventory carrying costs, and declining repeat purchases in some segments. Leadership needs a data-driven diagnostic to decide where to invest next. The main question is: **"How is PageTurner performing across omnichannel operations, and which levers — store locations, customer segments, product categories, or promotional strategies — should leadership prioritize to improve profitability and customer loyalty?"**

---

## 2. Stakeholder Priorities

| Priority | Stakeholder | What they need | Why it matters |
|----------|-------------|----------------|----------------|
| 1 (highest) | CFO | Revenue decomposition + cost optimization | Margins are under pressure — leadership needs to know where revenue is coming from and where costs are eating it |
| 2 | VP of Retail Operations | Store-level performance + inventory turns | 8 stores with varying performance — need to identify top/bottom and optimize inventory |
| 3 | Head of Marketing | Customer segment health + promotion effectiveness | Declining repeat rate is a red flag — need to understand which segments are churning and whether promotions actually drive loyalty |
| 4 | VP of E-Commerce | Online vs in-store comparison + shipping costs | Online channel is newer and less understood — need to quantify its contribution and cost profile |
| 5 (lowest) | Inventory Manager | Stock-out frequency + slow-movers | Operational — supports the other priorities but is not the primary decision driver |

---

## 3. Assumptions

1. **Channel inference**: Online orders = `store_id IS NULL`. This is not explicit in the data — must be stated as an assumption in every channel-based finding.
2. **Promotions are indirect**: No FK from promotions to orders. Effectiveness can only be inferred from `order_items.discount > 0` or timing overlaps — not causal.
3. **No true margin**: No COGS data. `list_price - price` is a proxy for publisher discount, not PageTurner's margin. Any "margin" language must be caveated.
4. **Revenue includes tax**: Using `orders.total_amount` which includes tax. This is consistent across channels and segments, so comparisons are valid even if the absolute number is inflated.
5. **Data quality is a prerequisite**: ~5-10% NULLs, case inconsistency, wrong data types. Cleaning (Stage 3) must happen before any metric is computed. Scope assumes cleaned data.

---

## 4. Questions I'd Ask the Stakeholder

If I could sit down with the leadership team, I'd ask:

1. **"What does 'invest next' mean — revenue growth, profitability, or customer retention?"** The main question says "improve profitability and customer loyalty" but these can conflict (e.g., discounting boosts volume but hurts margin). Which takes precedence?
2. **"Is the online channel a growth engine or a cost center?"** The VP of E-Commerce and CFO may have different views. Knowing the strategic intent changes whether we optimize for volume or margin online.
3. **"Which customer segments are declining in repeat purchases?"** The case mentions "declining repeat-purchase rate among certain segments" — which ones? This would help me focus the analysis instead of slicing all segments equally.
4. **"Are there specific stores at risk of closure?"** If leadership is already considering cutting underperforming stores, the analysis should focus on diagnosing *why* they're underperforming, not just ranking them.
5. **"What's the time horizon for the investment decision?"** The question says "next 12 months" but the data covers 24 months. Should we weight recent months more heavily, or treat the full history equally?

---

## 5. Success Criteria

A good analysis will:

1. **Name the #1 lever** — not just report metrics, but explicitly recommend which lever (store locations, customer segments, categories, or promotions) leadership should prioritize, with a data-backed reason.
2. **Quantify the gap** — show the difference between top and bottom performers (e.g., "top store generates 3× the revenue of bottom store") so the investment decision has scale context.
3. **Handle the data limitations honestly** — every channel comparison, promotion analysis, and margin proxy must state its assumption. No false precision.
4. **Surface at least 1 unexpected finding** — something leadership doesn't already know. That's the value of the analysis over intuition.
5. **Be actionable** — recommendations should be specific enough to act on (e.g., "invest in Store X because..." not "consider improving store performance").

---

## 6. If I Were the Stakeholder...

- **The one thing I need from this analysis is**: A clear, prioritized list of which lever to pull first — not a dashboard of every metric.
- **The decision I'm trying to make is**: Where to allocate a有限 budget across stores, marketing, or e-commerce to improve both profitability and loyalty simultaneously.
- **The risk of a wrong answer is**: Investing in the wrong lever (e.g., boosting promotions when the real problem is store experience) and wasting a year of budget with no margin improvement.
- **What I don't care about**: Comprehensive metric reporting. I have analysts for that. I need the synthesis — the "so what" and "now what."

---

## 7. Case-Specific Questions

Given the dataset quirks, these deserve stakeholder attention:

1. **Channel inference reliability**: "How confident are we that `store_id IS NULL` accurately captures all online orders? Could some in-store orders also have NULL store_id (e.g., phone orders)?"
2. **Promotion tracking gap**: "The promotions table isn't linked to orders. Is there a business reason for this, or is it a data collection gap we should fix?"
3. **Data quality scope**: "The dataset has ~5-10% dirty data. Should we flag affected records for investigation, or just clean and move on?"
