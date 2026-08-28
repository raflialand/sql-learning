# Case 02 — MarketHub: Stage 6 Insight

**Main question:** How is the marketplace performing, and which vendor/segment should we invest in next?
**Basis:** verified query results in `03-results.md` (Q1–Q9). Graded against the weak-vs-strong rubric in `learning/04-data-to-insight/data-to-insight.md`.
**Scope (fixed):** Metrics — GMV, Order count, AOV, Repeat purchase rate; Dimensions — Vendor, Country, Category, Month (13 months, MoM + YoY both supported).

---

## A. Running Log

### Big question
How is the marketplace performing, and which vendor/segment should we invest in next?

### Derived sub-questions (9)
- **Overall Trends** — Q1 GMV·Month, Q2 GMV·Vendor, Q3 GMV·Category, Q4 GMV·Country.
- **Growth Rates** — Q5 GMV·Month MoM+YoY, Q6 GMV·Vendor×Month MoM+YoY.
- **Performance** — Q7 AOV·Vendor, Q8 Repeat-rate·Vendor.
- **KPI ("why")** — Q9 bottom-vendor drill (category/product mix, shipments, payments).

### Immediate findings
- **Q1/Q5** — 13-month GMV oscillates in a ~$363k–$503k band; Jan-26 = $435,492.71, only **+4.88% YoY** vs Jan-25 ($415,212.33). Mildly positive, not dramatic.
- **Q2** — TechSource is the largest vendor ($595,117.09); Metro Distributors the smallest ($186,564.18). Total marketplace GMV ≈ **$5.55M**; the top 3 vendors hold 30.5% of it.
- **Q3** — Electronics is the dominant category ($2,010,913.91 = 36.2% of GMV).
- **Q4** — USA leads ($929,335.20 = 16.8%) but the 7 countries are fairly balanced (USA → Germany, 16.8% → 12.2%).
- **Q6** — Summit Brands is the momentum outlier: Jan-26 **+84.95% YoY / +110.45% MoM** ($41,323.43), but from a small base ($264,069.81, 12th of 14 — third-smallest). Metro is the inverse: **-30.34% YoY / -36.34% MoM**.
- **Q7/Q8** — Metro is weak on basket and loyalty too: lowest AOV **$663.93** (~39% of leader Sunrise Trading's $1,708.98) and 20.09% repeat rate (11th of 14); TechSource leads loyalty at **38.35%**.
- **Q9** — Metro's payment funnel is broken: of **408 total orders**, only **193 (47%)** are cleanly paid; **74 failed + 73 refunded + 68 no-payment = 215 (53%)** are not.

### Root cause (one layer deeper)
Metro's low GMV is not primarily a catalog problem — it is a **conversion problem**. More than half its orders never become clean revenue (53% non-paid), and the orders that do survive are the smallest baskets on the marketplace ($663.93 AOV). Small basket × broken payment funnel × weak loyalty (20.09%) compound into the bottom line. Shipments are *not* the issue (Q9c: only 18 in-transit lines across 4 carriers — no delivery backlog).

---

## B. Five Components

### 1. Trend — direction over time
The marketplace is **broadly stable with mild growth**. Monthly GMV started Jan-25 at $415,212.33 and ended Jan-26 at $435,492.71 — **+4.88% year-over-year** (Q5), the only YoY point the 13-month window allows. The level arcs upward through the summer to an Aug-25 peak ($502,558.50) before settling back into the mid-$400k range. Mix is concentrated but healthy: **Electronics is 36.2%** of GMV (Q3: $2,010,913.91 of $5,548,140.62), and geography is diversified across 7 countries with no single dependency (Q4: USA 16.8% down to Germany 12.2%).

*Trace:* Q1, Q3, Q4, Q5.

### 2. Fluctuation — the wobbles
The top line is **choppy, not rhythmic**. Month-over-month swings are large in both directions: **May -14.04%**, **Jun +24.20%** (the sharpest bounce), **Sep -26.47%** ($502,558.50 → $369,541.76 — the deepest dip), **Oct +10.30%**, then a quiet Dec **+8.46%** and Jan-26 **-0.93%** (Q5). There is a recurring sawtooth (rise to late summer → September fall → October rebound), but with only **one full YoY comparison** it is **not yet proven seasonal** — it could be genuine Q3 softness or ordinary month-to-month volatility.

*Trace:* Q5 (all % changes are from the Q5 mom_pct/yoy_pct columns).

### 3. Anomaly — the odd one out
Two vendors sit at opposite ends of the anomaly spectrum:
- **Metro Distributors (the negative anomaly)** is weak on **all three levers at once**: smallest GMV ($186,564.18, Q2), smallest basket ($663.93 AOV, ~39% of the leader's, Q7), near-weakest loyalty (20.09% repeat, 11th of 14, Q8) — **and still shrinking** (-30.34% YoY, Q6). It is the only vendor combining low level *and* negative momentum.
- **Summit Brands (the positive anomaly)** is the fastest riser: Jan-26 **+110.45% MoM / +84.95% YoY** (Q6), yet it is only the 12th-largest vendor of 14 ($264,069.81, Q2) — third-smallest. Small base, outsized acceleration.

*Trace:* Q2, Q6, Q7, Q8.

### 4. Root cause — why, one dimension deeper
Digging under Metro's numbers (Q9) reveals a **broken payment/refund funnel**, not a catalog gap. Across all 408 of its orders: **193 paid (47.3%) · 74 failed (18.1%) · 73 refunded (17.9%) · 68 no-payment-row (16.7%)** — i.e. **215 of 408 (52.7%) are not clean paid** (Q9d). Demand exists, but a large share of it never converts to realized revenue. Compounding this: Metro's **basket is the smallest on the marketplace** ($663.93 vs a ~$1,287 vendor-median AOV) and its catalog is **Electronics-heavy (39.38%) with no Sports & Outdoors** (Q9a), skewing to low-ticket "Mini/Plus" SKUs (Q9b). Shipments are healthy (Q9c), so fulfillment is not the culprit — **payment completion and basket value are**.

*Trace:* Q9a, Q9b, Q9c, Q9d; Q7 (AOV), Q8 (repeat).

### 5. Recommendation — what to do next
"Invest next" is best answered by separating **size (Q2)**, **basket (Q7)**, **loyalty (Q8)**, and using **momentum (Q6)** as the forward-looking signal:

1. **Invest for growth in Summit Brands (volume/momentum lever).** It is the fastest-growing vendor (Jan-26 +84.95% YoY / +110.45% MoM; $41,323.43 vs $22,342.66 a year prior = **+$18,980.77 in that single month**). It is small ($264k), so a modest growth budget buys outsized relative lift — but confirm the surge is sustainable before scaling (one-month YoY only).
2. **Compound TechSource, the loyal leader (loyalty lever).** It is #1 in both GMV ($595,117.09) and repeat rate (38.35% = **3× the lowest vendor's** 12.75%), but its latest month cooled (-26.39% MoM, Q6) — protect its base rather than chase it.
3. **Fix Metro Distributors before divesting (conversion + basket lever).** Attack the 53% non-paid orders first (74 failed + 73 refunded + 68 no-payment); each recovered order is worth ~$664 at its AOV, and lifting its AOV ($663.93) toward the ~$1,287 median (~$623/order × ~281 fulfilled orders) is **~$175k/yr of GMV upside** — before considering divestment.

*Trace:* Q6, Q2, Q7, Q8, Q9d (figures above); derived: ~281 fulfilled orders = $186,564.18 ÷ $663.93; ~$175k = ($1,286.59 − $663.93) × 281.

---

## C. Insight Paragraph

The marketplace is broadly healthy but growing slowly: 13-month GMV closed Jan-26 at $435,492.71, only **+4.88% year-over-year**, with sales oscillating inside a $363k–$503k band. That flat headline hides sharp month-to-month whipsaws — a **-26.47% September plunge** ($502,558.50 → $369,541.76), a **+24.20% June spike**, a **+10.30% October rebound** — so there is no proven seasonal rhythm yet, just volatility. The real story sits at the two edges of the vendor set. **Metro Distributors is the anomaly**: the smallest vendor ($186,564.18), the smallest basket ($663.93 AOV, ~39% of the leader), near-weakest loyalty (20.09%), and *still* shrinking (-30.34% YoY). Drilling one layer deeper, its problem is not the catalog — it is a **broken payment funnel**: of 408 total orders, only **193 (47%) are cleanly paid**, while **74 failed, 73 were refunded, and 68 have no payment row** — so a large share of its demand never becomes realized revenue, and what survives is the lowest-value basket on the platform. The growth answer points the other way: **Summit Brands is the momentum outlier (+84.95% YoY / +110.45% MoM)** and, alongside mid-size compounders Cedar & Co (+54.24% YoY) and Atlas Wholesale (+22.44% YoY), is where forward-looking investment belongs. We should **put growth budget behind Summit, keep compounding the loyal leader TechSource (38.35% repeat), and treat Metro as fix-or-divest — starting with its payment/refund funnel.**

---

## D. Recommendations

| # | Action | Lever | Expected effect / $ (traceable) |
|---|---|---|---|
| 1 | **Invest growth budget in Summit Brands** — validate the Jan-26 surge, then scale marketing/inventory. | Volume / momentum | If it holds its Jan-26 run-rate ($41,323.43/mo), it annualizes to **~$496k** — nearly double its trailing $264k, lifting it from 14th toward the mid-tier (Q6/Q2). One-month YoY, so verify before scaling. |
| 2 | **Protect & compound TechSource** — invest to retain its loyal base and reverse the Jan-26 MoM dip (-26.39%). | Loyalty | Defends the largest revenue block ($595,117.09 = 10.7% of GMV) whose 38.35% repeat rate is **3× the lowest vendor** (Q2/Q8/Q6). |
| 3 | **Fix Metro Distributors' payment funnel** — diagnose the 74 failed + 73 refunded + 68 no-payment orders before any divest decision. | Conversion | 215 of 408 orders (52.7%) are non-paid; recovering even a fraction is worth ~$664/order at its AOV (Q9d/Q7). |
| 4 | **Lift Metro's basket** — rebalance catalog (no Sports & Outdoors; 39.38% Electronics "Mini/Plus" mix) and bundle to raise AOV. | Basket | AOV $663.93 vs ~$1,287 median → ~$623/order × ~281 fulfilled orders = **~$175k/yr GMV upside** (derived from Q7/Q9b). |

---

## E. Self-Check (weak-vs-strong rubric)

| Rubric test | Verdict | Evidence |
|---|---|---|
| 5 components present **and in order** (Trend → Fluctuation → Anomaly → Root cause → Recommendation)? | ✅ PASS | Section B lists them in the exact canonical order; Section C flows the same sequence in prose. |
| Every number traceable to a query result? | ✅ PASS | All figures cited to Q1–Q9; the two derived figures (~281 orders, ~$175k upside) are computed in-line from traceable Q7/Q9 inputs, not asserted. |
| No weak-insight filler ("X is higher than Y; it's working")? | ✅ PASS | Each component adds magnitude + context + a next step (e.g. Metro's GMV is low *and* why — 53% non-paid — *and* what to do; TechSource's loyalty is used to justify "compound", not to declare victory). |
| Momentum used as the forward-looking signal, distinct from size/basket/loyalty? | ✅ PASS | Summit (momentum) vs TechSource (size+loyalty leader) vs Metro (all three weak) are separated; the invest call cites Q6 momentum, not just Q2 size. |
| Seasonality not overclaimed? | ✅ PASS | Only one YoY point exists (Jan-26 +4.88%); the Sep dip is described as "not yet proven seasonal". |

**Strengthened before delivery:** the initial draft read "Metro is the smallest vendor, it's underperforming" (weak). It was upgraded by drilling into Q9d (payment funnel) to name the *why* and attach a fix; and TechSource was reframed from "top vendor" (weak) to "loyal leader whose latest month cooled — compound, don't chase" (strong).
