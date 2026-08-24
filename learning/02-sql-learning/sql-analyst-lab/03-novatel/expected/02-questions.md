# Case 03 — Sub-Questions Mapped to the 4 Buckets

Main question → sub-questions. One SQL query per sub-question (metric × dimension).

| Bucket | Sub-question | Metric × Dimension | Query |
| --- | --- | --- | --- |
| **Overall Trends** | How does billed revenue split across plans? | Revenue × plan | Q1 |
| **Overall Trends** | What is the monthly revenue + subscriber base shape? | Revenue + active subs × month | Q2 |
| **Growth Rates** | How did revenue and ARPU move MoM (Dec → Jan)? | Revenue + ARPU growth × month | Q3 |
| **Performance Measurement** | Which plans monetize best? | ARPU × plan | Q4 |
| **Performance Measurement** | Where does the base concentrate by region? | Active subs + revenue × region | Q5 |
| **KPI Reporting** | *Why* is revenue leaking — unpaid/overdue bills by plan? | Leak (unpaid/overdue) × plan | Q6 |
| **KPI Reporting** | *Why* do subscribers churn — by plan and reason? | Churn count × plan × reason | Q7 |
| **KPI Reporting** | Do heavy users over-consume their plan (data usage tier drill-down)? | Avg data usage × usage tier × plan | Q8 |

Q1–Q2 level, Q3 change (MoM only — no YoY), Q4–Q5 segment comparison, Q6–Q8 the "why" + one dimension dug deeper (usage tier).
