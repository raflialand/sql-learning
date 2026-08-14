# Case 01 — Model Insight & Recommendations

Main question: **"How is sales performance, and where should we focus next month?"**

## What the data says (short summary of findings)

- **Revenue trend:** monthly revenue grew from $4,000 (Jan-2025) to a peak of $6,360 (Aug-2025), then fell back to the $4.5–$5.3k range in autumn, with a Q4 recovery at the end of the series (last 3 rows of Q1/Q4).
- **Stores:** BRW001 (Manhattan, $24.2k) and BRW003 (Queens, $24.1k) lead; BRW002 (Brooklyn, $22.0k) trails by ~9% — order count explains the gap (384 vs ~408).
- **Categories:** Merchandise drives 60% of revenue ($42.1k) despite only 737 of ~2,300 orders touching it; Beverage has the most orders (861) but less than half of Merchandise revenue.
- **Growth:** strongest single jumps were Feb-2025 (+22%) and Aug-2025 (+15%); the biggest dips were May (-17%) and Sep (-17%) — a repeatable seasonal pattern worth planning around.
- **AOV:** stable at $54–$61, so revenue moves are volume-driven, not basket-driven.
- **Underperformers (KPI "why"):** bottom-10 products are all low-priced staples (≤ $4.25) — they sell high volume but contribute little revenue; the two inactive seasonal items (Pumpkin Latte, Holiday Blend) sold nothing at all.

## Weak vs strong insight — model answer

**Weak insight (do not submit this):**
> "Merchandise has the highest revenue. Stores are doing okay."

**Strong insight (this is the standard to aim for):**
> "Revenue rose 59% from Jan to Aug 2025 (from $4.0k to $6.4k/month), then dropped 29% into Oct ($4.5k) before recovering in Q4 — the pattern tracks our seasonal merchandise push, not basket size (AOV stayed at $55–$61 all year). Merchandise alone contributes 60% of revenue, and it's the category that decides whether a month is good or bad. Brooklyn (BRW002) trails the other stores by ~9% entirely because it processes fewer orders (~384 vs ~407–409), not because its tickets are smaller. Next month's focus: replicate the August merchandise window at all three stores and run a volume-driving promotion at BRW002 — closing that order-count gap is worth roughly $2,200/month."

**Why it's strong:** it summarizes the trend (59% rise, 29% fall), names the fluctuation (seasonal merchandise push), calls the anomaly (BRW002 order-count gap), digs one dimension deeper for root cause (AOV stable → volume-driven, not basket-driven; category mix explains store differences), and ends with a concrete recommendation tied to a dollar figure.

## Running Log excerpt (working habit from the framework)

```
Big question: How is sales performance, and where should we focus next month?

Derived sub-questions:
  Q1: monthly revenue/orders/AOV trend          → revenue peaked Aug-25 ($6.4k), dipped Oct-25 ($4.5k)
  Q2: revenue by store                           → BRW002 trails by ~9%, fewer orders (384 vs ~408)
  Q3: revenue by category                        → Merchandise = 60% of revenue
  Q4: MoM growth %                               → +22% Feb, +15% Aug; -17% May/Sep (repeatable pattern)
  Q5: category mix per store                     → every store: Merchandise >> Beverage > Food
  Q6: why bottom products underperform           → low unit price ($2.50-$4.25), not low demand

Root cause (one layer deeper): revenue swings are driven by the merchandise category,
not by basket size — AOV is flat across all months and stores.
Recommendation: replicate the August merchandise window; fix BRW002 order volume first.
```

## Recommendations (what to do next month)

1. **Re-run the August merchandise window** — it was the single best month (+$1.4k over July); schedule it before the September dip hits.
2. **Fix BRW002 volume first** — its ~24 fewer orders/month is the entire store gap; a targeted promo beats a blanket discount.
3. **Protect the low-priced staples** — Espresso/Cookies/Bagels are volume heroes with thin revenue; keep them stocked for traffic even though they don't move the revenue needle.
4. **Plan for the seasonal pattern** — May and September dips recur; run retention offers in those months instead of reacting after the drop.
