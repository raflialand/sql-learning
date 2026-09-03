# Case 03 — Questions (decomposed from the main question)

**Main question:** Is the subscriber base healthy, and where is revenue leaking?

---

## Bucket 1 — Overall Trends

Evaluating level, patterns, segmentation, and summary stats.

| # | Sub-question | Metric × Dimension | Why it serves the main question |
|---|-------------|---------------------|--------------------------------|
| Q1 | What is the total billed revenue per month? | Revenue (billed) × Month | Baseline revenue trend — the top line across the two billing cycles. |
| Q2 | What is the payment collection rate per month? | Collection rate × Month | Baseline collection health — what % of billed revenue is actually collected. |
| Q3 | How many active subscribers are billed per month? | Active subscribers × Month | Base size trend — whether the paying subscriber pool is stable or shrinking. |

---

## Bucket 2 — Growth Rates

MoM % change as a metric itself (Dec → Jan only; NO YoY).

| # | Sub-question | Metric × Dimension | Why it serves the main question |
|---|-------------|---------------------|--------------------------------|
| Q4 | How did billed revenue change MoM? | Revenue (billed) × Month | Whether the top line is growing or contracting between cycles. |
| Q5 | How did the payment collection rate change MoM? | Collection rate × Month | Whether leakage is worsening or improving — the trajectory of the leak. |

---

## Bucket 3 — Performance Measurement

Head-to-head comparison between segments.

| # | Sub-question | Metric × Dimension | Why it serves the main question |
|---|-------------|---------------------|--------------------------------|
| Q6 | Which plans generate the most billed revenue? | Revenue (billed) × Plan | Product segmentation — which plans are the revenue engines. |
| Q7 | Which regions have the highest billed revenue? | Revenue (billed) × Region | Geographic segmentation — where revenue concentrates. |
| Q8 | Which plans have the worst payment collection rates? | Collection rate × Plan | Product leakage — which plans have the most unpaid/overdue bills. |
| Q9 | Which regions have the highest churn counts? | Churn count × Region | Geographic retention — where subscribers are leaving. |

---

## Bucket 4 — KPI Reporting

Not just reporting the static number, but explaining *why* it is at that level (dig one dimension deeper).

| # | Sub-question | Metric × Dimension | Why it serves the main question |
|---|-------------|---------------------|--------------------------------|
| Q10 | Why is revenue leaking? → What is the unpaid/overdue share by plan? | Unpaid/Overdue share × Plan | Drives into the "why" of leakage — which plans have the worst collection problems. |
| Q11 | Why are subscribers churning? → What are the churn reasons by region? | Churn reason × Region | Drives into the "why" of churn — whether it's price, coverage, service, or external. |
| Q12 | Why is ARPU changing? → How does ARPU compare across plans? | ARPU × Plan | Explains whether revenue movement is driven by plan mix or subscriber count. |

---

## Coverage check

**Metrics used:** Revenue (billed), Collection rate, Active subscribers, Churn count, Unpaid/Overdue share, Churn reason, ARPU — all from the Stage 1 scope pool. ✅  
**Dimensions used:** Month, Plan, Region — all from the Stage 1 scope pool. ✅  
**No orphan scoped metric/dimension:** every metric and dimension in the scope appears in at least one sub-question. ✅  
**No out-of-scope metric/dimension:** no metric or dimension appears that wasn't in the Stage 1 scope. ✅  
**No forbidden comparison:** all time comparisons are MoM (Dec → Jan). No YoY. ✅  
**No duplicate sub-question:** each (metric × dimension × bucket) is unique. ✅  
**Every sub-question serves the main question:** each maps to either "subscriber base health" or "revenue leaking". ✅
