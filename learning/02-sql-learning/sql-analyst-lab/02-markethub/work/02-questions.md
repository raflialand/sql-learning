# Case 02 — Stage 2: Question Decomposition

**Main question:** How is the marketplace performing, and which vendor/segment should we invest in next?

**Stage 1 pool (fixed):** metrics — GMV · Order count · AOV · Repeat purchase rate; dimensions — Vendor · Country · Category · Month.
Rule: sub-questions are built only from this pool (plus product / payment / shipment drill-downs for the KPI "why"), one metric sliced by one dimension (sometimes two). No sub-question requests a forbidden comparison — this dataset spans 2025-01 → 2026-01, so **both MoM and YoY are supported**.

---

## Bucket 1 — Overall Trends (level)

| # | Sub-question | Metric × Dimension | Why it answers |
| --- | --- | --- | --- |
| Q1 | What is the marketplace GMV trend over time? | GMV · Month | Headline "how are we performing" — level arc across 13 months. |
| Q2 | How is GMV distributed across vendors? | GMV · Vendor | Size ranking — which sellers carry the top line today. |
| Q3 | How is GMV distributed across categories? | GMV · Category | Catalog mix — which product lines drive GMV. |
| Q4 | How is GMV distributed across buyer countries? | GMV · Country | Geography — where the buyers (and growth) come from. |

*Note:* Level splits only, no time axis on Q2–Q4 and no % change. Q1 is the only time-series level question here.

---

## Bucket 2 — Growth Rates (% change)

| # | Sub-question | Metric × Dimension | Why it answers |
| --- | --- | --- | --- |
| Q5 | Is the marketplace growing, and is there a repeating rhythm? | GMV · Month, MoM % + YoY % | Performance over time — % change lens; YoY supported only here (13-month span). |
| Q6 | Which vendor is growing vs shrinking — who has momentum? | GMV · Vendor × Month, MoM % + YoY % | Vendor *trajectory* — the forward-looking "invest next" signal that size (Q2) cannot give. |

*Note:* Growth bucket uses the % change lens on the same dimensions as the level splits — the metric becomes the change, not the level. Q5 is chain-level rhythm; Q6 is per-vendor momentum (`PARTITION BY vendor_id`, same window pattern as Case 01's Q2a). YoY (Jan-2026 vs Jan-2025) is the seasonality test that Case 01 could not run.

---

## Bucket 3 — Performance Measurement (snapshot head-to-head)

| # | Sub-question | Metric × Dimension | Why it answers |
| --- | --- | --- | --- |
| Q7 | Which vendor has the strongest basket? | AOV · Vendor | Basket efficiency — separates "bigger orders" from "more orders". |
| Q8 | Which vendor has the most loyal buyers? | Repeat purchase rate · Vendor | Loyalty — the signal that says *invest here*, not another sales level. |

*Note:* snapshot only — no time axis, no % change. Q7 + Q8 together answer "who is performing best *per buyer*", which GMV-level splits (Q2) cannot.

---

## Bucket 4 — KPI Reporting (the "why")

| # | Sub-question | Metric × Dimension | Why it answers |
| --- | --- | --- | --- |
| Q9 | Which vendor underperforms, and why? | Bottom-vendor drill → product/category mix, fulfillment health (shipments), payment health (Failed/Refunded) | The "why" behind a flagged number — one layer deeper, so the invest/divest call is evidence-based. |

*Note:* Q9 anchors on the flagged bottom vendor from Q2 (GMV · Vendor) and drills one dimension deeper: category/product mix, shipment status, and payment status. Each drill reuses a KPI-reporting lens, not another level split.

---

## Locked summary

| Bucket | Questions | Lens |
| --- | --- | --- |
| 1 Overall Trends | 4 | Level split |
| 2 Growth Rates | 2 | % change (MoM + YoY) |
| 3 Performance Measurement | 2 | Head-to-head snapshot |
| 4 KPI Reporting | 1 | Why behind a number |
| **Total** | **9** | |
