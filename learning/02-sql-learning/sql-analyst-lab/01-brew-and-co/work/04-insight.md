# Case 01 — Brew & Co. — Insight

## Table of Contents

- [A. RUNNING LOG](#a-running-log)
  - [Bucket 1 — Overall Trends](#bucket-1-overall-trends)
  - [Bucket 2 — Growth Rates](#bucket-2-growth-rates)
  - [Bucket 3 — Performance Measurement](#bucket-3-performance-measurement)
  - [Bucket 4 — KPI Reporting](#bucket-4-kpi-reporting)
- [B. INSIGHT COMPONENTS](#b-insight-components)
  - [1. TREND](#1-trend)
  - [2. FLUCTUATION](#2-fluctuation)
  - [3. ANOMALY](#3-anomaly)
  - [4. ROOT CAUSE](#4-root-cause)
  - [5. RECOMMENDATION](#5-recommendation)
- [C. INSIGHT PARAGRAPH](#c-insight-paragraph)
- [D. RECOMMENDATIONS](#d-recommendations)
- [E. SELF-CHECK](#e-self-check)

---

<a id="a-running-log"></a>
## A. RUNNING LOG

> **Main Question:** How is sales performance, and where should we focus next month?

<a id="bucket-1-overall-trends"></a>
### Bucket 1 — Overall Trends (level)

| # | Sub-question | Metric × Dimension | Finding |
|---|---|---|---|
| Q1a | "What is the chain-wide Revenue trend over time?" | Revenue · Month | Overall, revenue increased from $4,000 in January 2025 to a peak of $6,360 in August 2025, declined to $4,519 in October 2025, then recovered to an all-time high of $6,575 in January 2026. |
| Q1b | "How is Revenue split across menu categories?" | Revenue · Category | Merchandise $42,145 (60%) ≫ Beverage $14,748 (21%) > Food $13,342 (19%). |
| Q1c | "How is Revenue split across the 3 stores?" | Revenue · Store | Store ID: BRW002, trails the other two stores by ~9% ($21,963 vs ~$24,190)<br>BRW002: $21,963.25, BRW001: $24,189.20, BRW003: $24,081.65 |

<a id="bucket-2-growth-rates"></a>
### Bucket 2 — Growth Rates (% change)

| # | Sub-question | Metric × Dimension | Finding |
|---|---|---|---|
| Q2a | "Which store is growing/shrinking Revenue MoM — where should next month's focus go?" | Revenue · Store × Month, MoM % change | BRW003 = largest recurring $ loss (−$2,848.75/yr); worst month May 2025,<br>revenue −51.7% MoM (−$1,129.30); Sep −39.2%, Oct −27.3% — May & Sep dips recur. |
| Q2b | "For the flagged store: did the change come from order volume or basket size?" | AOV vs Order count · Store × Month, MoM % change | BRW003 collapses: May count −37.5% vs AOV −22.8%; Sep count −28.6% vs AOV −14.9%.<br>Count fell more than AOV both times → volume-driven (traffic), basket held up. |

<a id="bucket-3-performance-measurement"></a>
### Bucket 3 — Performance Measurement (snapshot head-to-head)

| # | Sub-question | Metric × Dimension | Finding |
|---|---|---|---|
| Q3a | "Which store earns the most per order (efficiency contest, best vs worst)?" | AOV · Store | AOV effectively flat across stores —<br>BRW001 $59.43 ≈ BRW003 $58.88 > BRW002 $57.20 (spread < $2.25); no store wins on basket efficiency. |
| Q3b | "Which category has the stronger basket?" | AOV · Category | Basket strength: Merchandise $57.18 ≫ Food $18.08 > Beverage $17.13<br>Merchandise baskets are ~3× the other categories. |
| Q3c | "Which category drives the volume (traffic/quantity side)?" | Order count · Category | Volume: Beverage 861 orders > Food 738 > Merchandise 737<br>Beverage wins on traffic, Merchandise wins on basket despite fewest orders. |

<a id="bucket-4-kpi-reporting"></a>
### Bucket 4 — KPI Reporting (the "why")

| # | Sub-question | Metric × Dimension | Finding |
|---|---|---|---|
| Q4a | "Which products underperform?" | Product Revenue, bottom-decile (~3 of 31); flag zero-sales | The most underperformed products by revenue are Espresso($598.85), followed by Chocolate Chip Cookie($622.50), then Americano($624.00)<br>Verified: none exist — all 31 products sold at least once. |
| Q4b | "Are the underperformers cheap, mid, or expensive relative to the menu?" | Revenue · unit_price band | Three of them are defined as cheap products.<br>all ≤ $3.25 vs category avg $5.25 (Beverage) / $5.81 (Food). |
| Q4c | "Are the underperformers active or inactive products?" | Revenue · is_active | Three of them are active products<br>all active → underperformance is NOT a deactivation/stale-menu problem. |
| Q4d | "Are the underperformers bought alone or as add-ons inside bigger orders?" | Revenue · basket context | Most of the time bought as add-ons |

**Q4d — basket context (detail):**

| Product | alone - add-ons (count) |
|---|---|
| Americano | 11 - 83 |
| Chocolate Chip Cookie | 4 - 119 |
| Espresso | 2 - 98 |

---

<a id="b-insight-components"></a>
## B. INSIGHT COMPONENTS

<a id="1-trend"></a>
### 1. TREND - direction of the Northstar metric over time

Chain-wide revenue rose from $4.0k (Jan-25) to a peak of $6.4k (Aug-25), dipped to $4.5k (Oct-25), then recovered to an all-time high of $6.6k (Jan-26) — +64.4% over 13 months.

<a id="2-fluctuation"></a>
### 2. FLUCTUATION - the wobbles

- Revenue didn't rise smoothly — it spiked in Feb (+22%) and Aug (+15%), dipped in May (−17%) and Sep (−17%), then recovered into Nov (+25.6%) and Jan (+17.7%) within 2025 — a dip-then-recover shape worth watching, but not yet proven seasonality.
- BRW003 is far more volatile than the chain: May −51.7%, Sep −39.2%, Oct −27.3%, then a +83.4% Nov snap-back — the largest swings in the dataset (single year, not yet proven seasonal).

<a id="3-anomaly"></a>
### 3. ANOMALY — the odd one out

BRW002 earns ~9% less ($21,963 vs ~$24,135) even though AOV is flat ($57.20 vs $58–59) — so it's not a basket problem.

<a id="4-root-cause"></a>
### 4. ROOT CAUSE — the why, one layer deeper

- **Volume, not basket** — Revenue differences are volume-driven, not basket-driven — AOV is flat everywhere (spread < $2.25), so BRW002's ~9% gap comes from processing 24 fewer orders/month (384 vs 408).
- **Category levers run opposite** — Merchandise = 60% of revenue ($42,145) on the fewest orders (737) → wins via basket ($57.18, ~3× others); Beverage = most orders (861) but smallest basket ($17.13) → wins via traffic. So a good month/store is a Merchandise month — that's what drives the revenue swings, not overall traffic.
- **Bottom products = price-driven** — Cheap (≤ $3.25), active, high-volume staples bought ~90% as add-ons → they underperform because of low unit price, not low demand or deactivation.

<a id="5-recommendation"></a>
### 5. RECOMMENDATION

- Run a traffic-driving promotion at BRW002 to close its ~24-order gap vs the other stores — worth ~$1,372/month (up to ~$2,172 if the basket gap closes too).
- Replicate the August Merchandise window — it drove the +15% Aug peak, and Merchandise is 60% of revenue ($42,145).
- Don't cut Espresso/Cookie/Americano — they're cheap staples bought as add-ons ~90% of the time (88–98%), so they drive traffic even though they add little revenue.
- Monitor May/Sep — if the dip recurs, have a Merchandise push ready (not yet proven seasonal).

---

<a id="c-insight-paragraph"></a>
## C. INSIGHT PARAGRAPH

> Over 13 months chain-wide revenue rose 64.4% to an all-time high of $6.6k — but not smoothly: it dipped in May (−17%) and Sep (−17%) and swung sharply at BRW003 (May −51.7%, Nov +83.4%).
> The swings trace to one lever: Merchandise, which drives 60% of revenue through high basket values, while Beverage carries the foot traffic.
> One store stands out: BRW002 trails its peers by ~9% even though AOV is flat everywhere — the gap is volume, not baskets (a ~24-order monthly deficit).
> Next month: run a traffic-driving promo at BRW002 (worth ~$1,372/month, up to ~$2,172) and replicate the August Merchandise window to guard against May/Sep if the dip recurs.
> And keep the cheap staples — Espresso, Cookies, Americanos — they're ~90% add-ons and hold the traffic together.

---

<a id="d-recommendations"></a>
## D. RECOMMENDATIONS

- Run a traffic-driving promotion at BRW002 to close its ~24-order gap vs the other stores — worth ~$1,372/month (up to ~$2,172 if the basket gap closes too).
- Replicate the August Merchandise window — it drove the +15% Aug peak, and Merchandise is 60% of revenue ($42,145).
- Don't cut Espresso/Cookie/Americano — they're cheap staples bought as add-ons ~90% of the time (88–98%), so they drive traffic even though they add little revenue.
- Monitor May/Sep — if the dip recurs, have a Merchandise push ready (not yet proven seasonal).

---

<a id="e-self-check"></a>
## E. SELF-CHECK

- [x] 5 components present (Trend → Fluctuation → Anomaly → Root cause → Recommendation).
- [x] Every number traceable to a query result.
- [x] No weak-insight filler.
- [x] PRD030/031 = DB truth (all 31 products sold at least once; the expected "0 units" note is stale).
- [x] Hedges preserved: "if the dip recurs" / "primarily" (one year ≠ proven seasonality).
