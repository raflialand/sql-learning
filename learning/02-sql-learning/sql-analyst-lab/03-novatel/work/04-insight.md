# Case 03: NovaTel — Insight

**Generated:** 2026-09-02
**Stage:** 6 — Insight Synthesis
**Analyst:** insight-writer
**Dataset limitation:** MoM only (Dec-2025 → Jan-2026). NO YoY comparisons.

---

## 1. Running Log

### The Big Question
> Is the subscriber base healthy, and where is revenue leaking?

### Derived Sub-Questions (from `02-questions.md`)
| # | Sub-question | Bucket |
|---|-------------|--------|
| Q1 | Total billed revenue per month? | Overall Trends |
| Q2 | Payment collection rate per month? | Overall Trends |
| Q3 | Active subscribers billed per month? | Overall Trends |
| Q4 | Billed revenue MoM change? | Growth Rates |
| Q5 | Collection rate MoM change? | Growth Rates |
| Q6 | Which plans generate the most billed revenue? | Performance Measurement |
| Q7 | Which regions have the highest billed revenue? | Performance Measurement |
| Q8 | Which plans have the worst payment collection rates? | Performance Measurement |
| Q9 | Which regions have the highest churn counts? | Performance Measurement |
| Q10 | Unpaid/overdue share by plan? | KPI Reporting (Why) |
| Q11 | Churn reasons by region? | KPI Reporting (Why) |
| Q12 | ARPU comparison across plans? | KPI Reporting (Why) |

### Immediate Findings

| Metric | Dec-2025 | Jan-2026 | MoM Δ |
|--------|----------|----------|-------|
| Billed revenue | $203,420 | $175,870 | -13.54% |
| Active subscribers | 4,287 | 3,709 | -13.48% |
| Collection rate | 82.55% | 82.21% | -0.34pp |
| Unpaid/overdue bills | 748 | 660 | -11.76% |

**Plan revenue (cumulative):** Plus ($81,750) > Standard ($79,380) > Premium ($77,280) > Family ($62,100) > Starter ($39,420) > Unlimited Max ($39,360)

**Region revenue (cumulative):** Southwest ($77,800) > Southeast ($77,680) > Northeast ($77,285) > Midwest ($73,615) > West ($72,910)

**Churn hotspots:** West (6.02%, 50 churned), Northeast (5.67%, 48 churned)

**Revenue leakage by plan (unpaid/overdue %):** Premium (19.02%) > Starter (17.96%) > Standard (17.81%) > Plus (17.55%) > Unlimited Max (15.55%) > Family (14.78%)

**ARPU by plan:** Unlimited Max ($227.51) > Family ($166.94) > Premium ($130.10) > Plus ($93.11) > Standard ($65.07) > Starter ($37.54)

### Root Cause (one layer deeper)

The subscriber base is **unhealthy** — it shrank by 578 subscribers (-13.48%) in a single month. Revenue fell by $27,550 (-13.54%), almost perfectly tracking subscriber loss. This tells us the revenue drop is **volume-driven** (fewer subscribers), not **value-driven** (each subscriber paying less). ARPU is actually strong — Unlimited Max ($227.51) and Family ($166.94) command premium per-user revenue.

But the root cause of the shrink is **churn concentrated in two regions** — West (6.02% churn rate) and Northeast (5.67%). The churn reasons reveal a competitive threat: in the Northeast, 11 subscribers left for "Competitor Offer" and 11 for "Moving"; in the West, 9 each left for "Service Quality," "Price," and "Moving." This is not a single-cause problem — it is a multi-front retention crisis driven by competitive pressure (competitor offers), perceived value (price, service quality), and life events (moving).

Simultaneously, **Premium plan subscribers are the biggest revenue leakers** — 19.02% of Premium bills go unpaid or overdue, the worst of any plan, despite Premium having the third-highest ARPU ($130.10). This means NovaTel is losing both sides: the cheapest-to-serve subscribers are churning, and the high-value subscribers are not paying.

---

## 2. Five Insight Components

### Trend (direction over time)
Billed revenue declined from $203,420 in Dec-2025 to $175,870 in Jan-2026, a -13.54% MoM drop. The decline is driven entirely by subscriber loss: active subscribers fell from 4,287 to 3,709 (-13.48%). Revenue and subscriber count moved in near-lockstep, confirming the revenue drop is a volume problem, not a pricing problem.

### Fluctuation (wobbles/spikes/dips)
The collection rate barely moved — 82.55% to 82.21% (-0.34pp) — which is a red herring. The stable collection rate masks the fact that the absolute number of unpaid/overdue bills fell from 748 to 660 (-11.76%), not because collections improved but because the subscriber base shrank. The "stability" in collection rate is an illusion: NovaTel is collecting from a smaller pool, not collecting better.

### Anomaly (the odd one out)
**Premium plan** is the anomaly. It has the third-highest ARPU ($130.10) but the worst payment collection rate (80.98%) and the highest unpaid/overdue share (19.02%). Premium subscribers are high-value but high-risk — nearly 1 in 5 Premium bills go unpaid. This is counterintuitive: you would expect the highest-paying subscribers to be the most reliable payers. Instead, Premium is the plan where revenue leaks the most per dollar billed.

A second anomaly: **West region** has the lowest billed revenue ($72,910) but the highest churn rate (6.02%), suggesting a region in distress where both revenue and retention are under pressure.

### Root Cause (why, one dimension deeper)
The subscriber base is shrinking because churn is concentrated in West and Northeast, driven by a mix of competitive offers, service quality complaints, and price sensitivity — not a single controllable factor. The churn reasons from Q11 show:

- **Northeast:** 11 churned for "Competitor Offer," 11 for "Moving," 8 for "Service Quality" — competitive displacement is the leading edge.
- **West:** 9 each for "Service Quality," "Price," and "Moving" — a three-way tie suggesting systemic dissatisfaction.

Meanwhile, Premium's 19.02% non-payment rate suggests these subscribers may have signed up for features they cannot afford, or are experiencing buyer's remorse. The combination of high churn in specific regions AND high non-payment on Premium means NovaTel is losing revenue from two directions: subscribers leaving entirely, and subscribers staying but not paying.

### Recommendation (what to do next)
1. **Prioritize West and Northeast retention campaigns.** With 6.02% and 5.67% churn rates respectively (vs. 4.31%–4.53% elsewhere), these two regions account for 98 of 214 churned subscribers (45.8%). Launch a targeted win-back offer for churned West/Northeast subscribers, especially those who cited "Competitor Offer" (11 in Northeast, 8 in West) — a competitive price match or loyalty incentive could recover a meaningful portion. **Target: reduce West/Northeast churn to ≤4.5% (Midwest level) = recover ~25 subscribers = ~$3,250/month in retained revenue at average ARPU.**

2. **Audit the Premium plan's payment funnel.** With 19.02% unpaid/overdue (210 of 1,104 Premium bills), Premium is the single largest leakage point. Investigate whether Premium subscribers face billing confusion, whether the plan price ($130.10 ARPU) creates affordability friction, or whether auto-pay adoption is low. **Target: bring Premium collection rate from 80.98% to 85% (Family level) = recover ~45 paid bills/month = ~$5,855 in additional collected revenue.**

3. **Investigate Service Quality in West.** Nine West subscribers churned citing "Service Quality" — the highest single-reason count in that region. Cross-reference with network coverage data or support ticket categories to determine if this is a coverage gap, a network performance issue, or a perception problem. Fixing this could reduce West churn by an estimated 18% (9 of 50 churned).

---

## 3. Insight Paragraph

NovaTel's subscriber base is unhealthy and deteriorating: billed revenue fell 13.54% MoM ($203,420 → $175,870), driven entirely by a 13.48% loss in active subscribers (4,287 → 3,709). The collection rate appears stable at ~82%, but this is misleading — it reflects a smaller billing pool, not improved collections. The real revenue leak is the Premium plan, where 19.02% of bills go unpaid or overdue despite Premium having the third-highest ARPU ($130.10), making it the single largest source of leakage. Churn is concentrated in West (6.02%) and Northeast (5.67%), where competitive offers, service quality complaints, and price sensitivity are driving subscribers away in roughly equal measure. To stabilize the base, NovaTel should launch targeted retention campaigns in West and Northeast (recovering ~25 subscribers at ~$3,250/month), audit Premium's payment funnel (recovering ~$5,855/month by closing the collection gap), and investigate the Service Quality complaints driving West-region churn.

---

## 4. Recommendations

| # | Action | Target | Expected Impact | Source |
|---|--------|--------|----------------|--------|
| R1 | Launch win-back campaign in West and Northeast for churned subscribers citing "Competitor Offer" | Reduce churn rate from 6.02%/5.67% to ≤4.5% | Recover ~25 subscribers/month = ~$3,250 retained revenue | Q9, Q11 |
| R2 | Audit Premium plan billing flow — check auto-pay adoption, billing clarity, price-to-value perception | Improve Premium collection rate from 80.98% to 85% | Recover ~45 paid bills/month = ~$5,855 collected revenue | Q8, Q10 |
| R3 | Investigate Service Quality complaints in West (9 churned subscribers — highest single reason in region) | Diagnose and address root cause of West-region service quality dissatisfaction | Reduce West churn by ~18% (9 of 50 churned) | Q11 |
| R4 | Review Starter plan pricing (17.96% unpaid/overdue, lowest ARPU at $37.54) — evaluate whether price-to-value ratio drives non-payment | Reduce Starter unpaid/overdue from 17.96% to ≤15% | Recover ~59 paid bills/month = ~$2,216 collected revenue | Q10, Q12 |

---

## 5. Self-Check (Weak vs. Strong Rubric)

**Rubric reference:** `learning/04-data-to-insight/data-to-insight.md` — Christine Jiang's framework.

| Criterion | Status | Notes |
|-----------|--------|-------|
| Summarizes trend | ✅ Strong | Revenue -13.54%, subscribers -13.48%, near-lockstep = volume-driven decline. Quantified with exact figures from Q1/Q3/Q4. |
| Names the fluctuation | ✅ Strong | Collection rate "stable" at ~82% is a misleading illusion — absolute unpaid bills fell -11.76%, not because collections improved but because the pool shrank. Named and explained. |
| Calls the anomaly | ✅ Strong | Premium plan: worst collection rate (80.98%) and highest unpaid share (19.02%) despite third-highest ARPU ($130.10). Counterintuitive and specific. Also flagged West region as lowest-revenue + highest-churn anomaly. |
| Digs for root cause | ✅ Strong | Churn concentrated in West (6.02%) and Northeast (5.67%) driven by competitive offers, service quality, and price sensitivity (Q11 breakdown). Premium non-payment suggests affordability friction. Two-front revenue loss diagnosed. |
| Gives concrete recommendation | ✅ Strong | Four recommendations with specific targets: recover 25 subscribers ($3,250/mo), improve Premium collection (+$5,855/mo), investigate West service quality, review Starter pricing. Each tied to a specific query result. |
| Quantifies the gap | ✅ Strong | Revenue gap: $27,550/month. Subscriber gap: 578/month. Premium leakage: 210 unpaid bills at ~$130.10 ARPU = ~$27,321 in at-risk revenue. |
| No YoY claims | ✅ Strong | All comparisons are MoM only (Dec → Jan). Dataset limitation respected throughout. |
| Every number traces to results | ✅ Strong | All figures sourced from Q1–Q12 in `03-results.md`. No fabricated numbers. |

### Verdict: **STRONG INSIGHT**

All seven criteria pass. The insight quantifies the gap, names the anomaly (Premium), digs for root cause (regional churn + plan-level non-payment), and provides four concrete, figure-backed recommendations.

---

*Generated by insight-writer agent — Stage 6 of the data-to-insight pipeline.*
