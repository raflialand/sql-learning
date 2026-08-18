# Case 01 — Step 2: Question Decomposition

**Main question:** How is sales performance, and where should we focus next month?

**Step 1 pool (fixed):** metrics — Revenue · Order count · AOV; dimensions — Store · Category · Month.
Rule: sub-questions are built only from this pool (plus product-level drill-downs for the KPI "why"), one metric sliced by one dimension (sometimes two).

---

## Bucket 1 — Overall Trends (level)

| # | Sub-question | Metric × Dimension |
| --- | --- | --- |
| Q1a | What is the chain-wide Revenue trend over time? | Revenue · Month |
| Q1b | How is Revenue split across menu categories? | Revenue · Category |
| Q1c | How is Revenue split across the 3 stores? | Revenue · Store |

*Note:* AOV-by-month level trend deliberately dropped — redundant with the Revenue trend; its payoff is the Bucket 2 growth diagnosis.

---

## Bucket 2 — Growth Rates (% change)

| # | Sub-question | Metric × Dimension |
| --- | --- | --- |
| Q2a | Which store is growing/shrinking Revenue MoM — where should next month's focus go? | Revenue · Store × Month, MoM % change |
| Q2b | For the flagged store: did the change come from order volume or basket size? | AOV vs Order count · Store × Month, MoM % change |

*Note:* "Flag a store" = anomaly detection (MoM change deviating from chain pattern). Q2b fires only for that store — root-cause drill.

---

## Bucket 3 — Performance Measurement (snapshot head-to-head)

| # | Sub-question | Metric × Dimension |
| --- | --- | --- |
| Q3a | Which store earns the most per order (efficiency contest, best vs worst)? | AOV · Store |
| Q3b | Which category has the stronger basket? | AOV · Category |
| Q3c | Which category drives the volume (traffic/quantity side)? | Order count · Category |

*Note:* snapshot only — no time axis, no % change. Q3b + Q3c together surface the "sells more but earns less per sale" contrast.

---

## Bucket 4 — KPI Reporting (the "why")

| # | Sub-question | Metric × Dimension |
| --- | --- | --- |
| Q4a | Which products underperform? | Product Revenue, bottom-decile (~3 of 31); flag zero-sales products |
| Q4b | Are the underperformers cheap, mid, or expensive relative to the menu? | Revenue · unit_price band |
| Q4c | Are the underperformers active or inactive products? | Revenue · is_active |
| Q4d | Are the underperformers bought alone or as add-ons inside bigger orders? | Revenue · basket context |

---

## Locked summary

| Bucket | Questions | Lens |
| --- | --- | --- |
| 1 Overall Trends | 3 | Level split |
| 2 Growth Rates | 2 | % change / anomaly |
| 3 Performance Measurement | 3 | Head-to-head snapshot |
| 4 KPI Reporting | 4 | Why behind a number |
