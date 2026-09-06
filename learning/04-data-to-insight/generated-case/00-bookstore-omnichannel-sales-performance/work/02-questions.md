# Stage 2 — Sub-Questions Mapped to the 4 Buckets

**Case**: 00-bookstore-omnichannel-sales-performance
**Date**: 2026-09-06

---

Main question → sub-questions. One SQL query per sub-question (metric × dimension).

| # | Bucket | Sub-question | Metric × Dimension | Lens |
|---|--------|--------------|---------------------|------|
| Q1 | Overall Trends | How does total revenue distribute across channels (Online vs In-Store) over the 24-month period? | Revenue × Channel | Level |
| Q2 | Overall Trends | What is the monthly revenue and order volume trend across the full period? | Revenue + Order Volume × Month | Level |
| Q3 | Overall Trends | Which customer segments contribute the most to total revenue? | Revenue × Customer Segment | Level |
| Q4 | Growth Rates | How did revenue grow MoM across the 24 months? | Revenue MoM × Month | % change |
| Q5 | Growth Rates | How did order volume and AOV change MoM? | Order Volume + AOV MoM × Month | % change |
| Q6 | Growth Rates | What is the YoY revenue growth — Sep 2024–Aug 2025 vs Sep 2025–Aug 2026? | Revenue YoY × Year | % change |
| Q7 | Performance Measurement | How do Online vs In-Store channels compare on AOV and order volume? | AOV + Order Volume × Channel | Head-to-head |
| Q8 | Performance Measurement | Which customer segments have the highest and lowest AOV? | AOV × Customer Segment | Head-to-head |
| Q9 | Performance Measurement | Which stores are top and bottom performers by revenue? | Revenue × Store Location | Head-to-head |
| Q10 | KPI Reporting | *Why* does repeat purchase rate vary — which segments have the lowest loyalty? | Repeat Rate × Customer Segment | Why |
| Q11 | KPI Reporting | *Why* does inventory turnover differ — which categories are slow movers? | Inventory Turnover × Book Category | Why |
| Q12 | KPI Reporting | *Why* is revenue concentrated — which categories drive the most revenue? | Revenue × Book Category | Why |

---

## Coverage Check

### Metrics consumed

| Metric | Sub-questions | Covered? |
|--------|---------------|----------|
| M1 — Total Revenue | Q1, Q2, Q3, Q4, Q6, Q9, Q12 | Yes |
| M2 — AOV | Q5, Q7, Q8 | Yes |
| M3 — Order Volume | Q2, Q5, Q7 | Yes |
| M4 — Repeat Purchase Rate | Q10 | Yes |
| M5 — Inventory Turnover | Q11 | Yes |

### Dimensions consumed

| Dimension | Sub-questions | Covered? |
|-----------|---------------|----------|
| D1 — Time Period | Q2, Q4, Q5, Q6 | Yes |
| D2 — Channel | Q1, Q7 | Yes |
| D3 — Customer Segment | Q3, Q8, Q10 | Yes |
| D4 — Book Category | Q11, Q12 | Yes |
| D5 — Store Location | Q9 | Yes |

### Bucket distribution

| Bucket | Count | Sub-questions |
|--------|-------|---------------|
| Overall Trends | 3 | Q1, Q2, Q3 |
| Growth Rates | 3 | Q4, Q5, Q6 |
| Performance Measurement | 3 | Q7, Q8, Q9 |
| KPI Reporting | 3 | Q10, Q11, Q12 |

### No duplicates

Every sub-question is unique — one metric × one dimension per query. No metric or dimension is queried in the same bucket with the same lens.

### Serves main question

- Q1–Q2 establish the revenue baseline → answers "How is PageTurner performing?"
- Q3, Q10 identify which customer segments matter → answers "customer segments" lever
- Q4–Q6 quantify growth trajectory → answers "where to invest"
- Q7–Q9 compare channels, segments, stores → answers "store locations" and "channel" levers
- Q11–Q12 diagnose category-level drivers → answers "product categories" lever

---

## Notes

- **Discount flag** (`order_items.discount > 0`) handled ad-hoc in queries that need it — not a standalone dimension per scope.
- **Channel inference** (L4): `store_id IS NULL` = Online. All channel queries note this assumption.
- **YoY allowed** per L1 — 24-month range supports Sep 2024–Aug 2025 vs Sep 2025–Aug 2026.
- **No true margin** (L3) — inventory turnover and revenue analysis only; no margin claims.

---

## Ready for Checkpoint

12 sub-questions across 4 buckets. All 5 metrics consumed. All 5 dimensions consumed. No duplicates. Every question serves the main business question.
