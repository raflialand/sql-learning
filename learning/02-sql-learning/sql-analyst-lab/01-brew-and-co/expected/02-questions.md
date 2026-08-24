# Case 01 — Sub-Questions Mapped to the 4 Buckets

Main question → sub-questions. One SQL query per sub-question (metric × dimension).

| Bucket | Sub-question | Metric × Dimension | Query |
| --- | --- | --- | --- |
| **Overall Trends** | What does the sales trend look like month by month? | Revenue + order count + AOV × month | Q1 |
| **Overall Trends** | How does each store contribute to total revenue? | Revenue + order count × store | Q2 |
| **Overall Trends** | Which menu category drives revenue? | Revenue + order count × category | Q3 |
| **Growth Rates** | Which months grew or shrank (MoM)? | Revenue growth % × month | Q4 |
| **Performance Measurement** | Do stores have different category mixes (segment comparison)? | Revenue × store × category | Q5 |
| **KPI Reporting** | *Why* are the bottom products underperforming? | Revenue KPI × product + why (units, price, active) | Q6 |

Note: Q1–Q3 give the "what" (level), Q4 gives the "change", Q5 compares segments, Q6 digs the "why" one dimension deeper.
