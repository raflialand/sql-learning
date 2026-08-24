# Case 02 — Sub-Questions Mapped to the 4 Buckets

Main question → sub-questions. One SQL query per sub-question (metric × dimension).

The bucket mapping is **partially open** — decide where each sub-question fits before reading the mapping below. Suggested answers:

| Bucket | Sub-question | Metric × Dimension | Query |
| --- | --- | --- | --- |
| **Overall Trends** | How has GMV trended month by month? | GMV + order count × month | Q1 |
| **Overall Trends** | Which categories generate the most GMV? | GMV × category | Q2 |
| **Growth Rates** | What is the MoM growth pattern? | GMV growth % × month | Q3 |
| **Growth Rates** | How does Jan-2026 compare with Jan-2025 (YoY)? | GMV + order count × month (Jan vs Jan) | Q4 |
| **Performance Measurement** | Which countries perform best on GMV and AOV? | GMV + AOV × country | Q5 |
| **Performance Measurement** | How does repeat purchase rate differ by country? | Repeat rate × country | Q6 |
| **KPI Reporting** | *Why* do payments fail — which methods leak? | Failure rate × payment method | Q7 |
| **KPI Reporting** | Where should we invest next (vendor/segment drill-down)? | GMV × vendor country × top category | Q8 |

Q1–Q2 level, Q3–Q4 change, Q5–Q6 segment comparison, Q7–Q8 the "why" + decision.
