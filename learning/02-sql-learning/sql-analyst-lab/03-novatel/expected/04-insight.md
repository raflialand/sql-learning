# Case 03 — Model Insight & Recommendations

Main question: **"Is the subscriber base healthy, and where is revenue leaking?"**

**Limitation honored:** billing spans only Dec-2025 → Jan-2026, so all trend statements are **MoM**, never YoY.

## What the data says (short summary of findings)

- **Revenue & base:** billed revenue fell MoM from $203,420 (Dec-25) to $175,870 (Jan-26), **−13.5%**, but ARPU stayed flat at ~$47.4 — the drop is entirely **base-driven** (4,287 → 3,709 billed subscribers, −578), not monetization-driven.
- **Plans:** Plus ($81.8k), Standard ($79.4k), Premium ($77.3k) are the revenue engines; Starter is huge by count (1,971 bills) but tiny by revenue ($39.4k, ARPU $37.5); Unlimited Max has the highest ARPU ($227.5) but few subscribers (173, $39.4k).
- **Regions:** revenue is balanced $72.9k–$77.8k across regions; West trails on active base (710) and revenue ($72.9k).
- **Revenue leak:** every plan leaks 14.8–19.0% of bills as Unpaid/Overdue; Premium leaks the most money ($14.7k, 19.0% rate) despite modest bill count — a serious collections problem at the high end. Total leak ≈ $65.6k across all plans.
- **Churn:** 427 churned; Standard/Starter lead raw counts (Moving and Price/Coverage/Other are top reasons), and Plus has a notable Service Quality cluster (19).
- **Usage drill-down:** excessive users (>25GB) exist on every plan, including 19 Family subs at ~26.6GB avg — Family's 120GB allowance makes this not a real overage problem, but Plus (30GB) has 39 subs at 26.6GB avg and Premium (60GB) has 30 subs at 26.5GB — those are near their limits.

## Weak vs strong insight — model answer

**Weak insight (do not submit this):**
> "Revenue dropped 13.5% in January. Some plans have unpaid bills."

**Strong insight (this is the standard to aim for):**
> "The subscriber base shrank 578 billed subscribers MoM (4,287 → 3,709, −13.5% revenue) while ARPU held at $47.4 — so January's decline is a base-loss problem, not a pricing problem, and fixing it means stopping churn and leakage, not changing fees. The leak is concentrated at the premium end: Premium leaks $14.7k (19.0% of its bills unpaid/overdue) — the highest leak rate AND the third-highest leak dollar figure — while Plus' $14.4k leak rides a Service Quality churn cluster (19 subscribers) and 39 Plus users averaging 26.6GB on a 30GB plan. Recommended next month: (1) launch a Premium collections/recovery flow to convert the $14.7k of unpaid premium bills; (2) investigate Plus Service Quality tickets before the churn cluster grows; (3) treat the 30GB-plus Plus users with a targeted upsell or allowance reminder rather than letting them churn to competitors."

**Why it's strong:** it quantifies the trend (−13.5% MoM) and its composition (base vs ARPU), names the anomaly (ARPU flat while revenue drops), digs one dimension deeper for root cause (Premium leak rate + Plus Service Quality cluster + near-limit usage), and ends with three concrete recommendations tied to dollar figures — all within the MoM-only limitation.

## Running Log excerpt (working habit from the framework)

```
Big question: Is the subscriber base healthy, and where is revenue leaking?

Derived sub-questions:
  Q1: revenue by plan            → Plus $81.8k > Standard $79.4k > Premium $77.3k; Starter low ARPU
  Q2: monthly revenue + base     → Dec $203.4k/4,287 subs → Jan $175.9k/3,709 subs
  Q3: MoM growth (MoM only!)     → -13.54% revenue, ARPU flat $47.45 → $47.42 → base-driven
  Q4: ARPU by plan               → Unlimited Max $227.5 highest, Starter $37.5 lowest
  Q5: base + revenue by region   → balanced; West trails (710 active, $72.9k)
  Q6: leak by plan               → Premium 19.0% ($14.7k), Plus $14.4k, all plans 15-19%
  Q7: churn by plan × reason     → Standard/Starter Moving/Price/Coverage; Plus Service Quality 19
  Q8: usage tier × plan          → Plus 39 subs avg 26.6GB on 30GB plan; Premium 30 subs 26.5GB/60GB

Root cause (one layer deeper): January revenue drop = fewer billed subs, not lower ARPU.
The most actionable leaks: Premium collections ($14.7k) and Plus Service Quality churn.
Recommendation: Premium recovery flow + Plus quality investigation + upsell near-limit heavy users.
```

## Recommendations (what to do next)

1. **Premium collections/recovery flow** — $14.7k of unpaid/overdue premium bills at a 19.0% leak rate is the single largest recoverable amount; prioritize it before the debt ages.
2. **Investigate Plus Service Quality** — 19 churned Plus subs citing Service Quality is the top quality-related cluster; review tickets before it spreads (Plus also leaks $14.4k).
3. **Upsell near-limit heavy users** — 39 Plus users average 26.6GB on a 30GB plan; an allowance reminder or upsell path protects both revenue and retention.
4. **Watch Starter ARPU** — 1,971 bills but only $39.4k revenue ($37.5 ARPU); any price change there has broad impact but low per-user value — measure carefully.
5. **Do NOT read YoY into this** — only 2 billing months exist; all future trend claims for NovaTel must stay MoM.
