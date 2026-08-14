# Case 02 — Model Insight & Recommendations

Main question: **"How is the marketplace performing, and which vendor/segment should we invest in next?"**

## What the data says (short summary of findings)

- **Marketplace level:** GMV ran $363k–$503k/month across 2025 (peaks Jun–Aug, dips May and Sep), with Jan-2026 GMV ($435.5k) up ~4.9% YoY vs Jan-2025 ($415.2k) on +8 more orders but slightly lower AOV ($2,884 vs $2,904).
- **Categories:** Electronics dominates ($2.01M, 36% of GMV) but only ~1.2k orders vs Clothing's 982 orders at $1.55M — electronics tickets are much larger. Sports & Outdoors trails badly ($695k).
- **Countries:** USA leads on GMV ($929k) with the highest AOV ($3,216); France trails both on GMV ($724k) and AOV ($2,906).
- **Repeat purchase:** rates are high everywhere (86–97%) under the fixed ≥2-order definition; Australia (96.97%) leads, France (85.71%) lags — the country with the lowest repeat rate also has the lowest AOV and 2nd-lowest GMV.
- **Payments:** Card has the highest failure rate (22.83%), PayPal the lowest (18.41%). Card is also the most-used method (911 attempts), so the leak is material.
- **Investment drill-down:** German vendors dominate Electronics ($1.14M) — nearly 57% of that category; Netherlands vendors lead Sports & Outdoors ($306k).

## Weak vs strong insight — model answer

**Weak insight (do not submit this):**
> "Electronics has the highest GMV. USA is the best country."

**Strong insight (this is the standard to aim for):**
> "The marketplace grew 4.9% YoY in Jan (GMV $415k → $436k) on higher order volume, but AOV slipped slightly ($2,904 → $2,884) — growth is volume-led, not basket-led. Electronics is the engine: 36% of GMV on 1.2k orders, with German vendors alone accounting for $1.14M (57% of the category). France is the underperformer to act on: it has the lowest repeat purchase rate (85.71% vs 97% in Australia), the lowest AOV ($2,906), and only the 6th-highest GMV despite a solid buyer base — and Card, its most common payment method, fails 22.8% of the time. Next quarter: invest in German Electronics vendor onboarding (feeds the strongest segment) and run a France retention program with a PayPal-first checkout prompt, which has the lowest failure rate at 18.4%."

**Why it's strong:** it names the YoY trend (+4.9%) and its composition (volume vs AOV), points to the anomaly (France lags on every loyalty/health metric), digs one dimension deeper for root cause (Card payment failures + low repeat rate), and ends with two concrete, segment-specific recommendations tied to observed numbers.

## Running Log excerpt (working habit from the framework)

```
Big question: How is the marketplace performing, and which vendor/segment should we invest in next?

Derived sub-questions:
  Q1: monthly GMV trend              → peaks Jun-Aug 2025 ($488-$503k), dips May/Sep ($363-370k)
  Q2: GMV by category                → Electronics $2.01M (36%), Sports & Outdoors worst $695k
  Q3: MoM growth %                   → biggest swings: +24% Jun, -26% Sep
  Q4: YoY Jan-25 vs Jan-26           → +4.9% GMV, +8 orders, AOV -$20 (volume-led growth)
  Q5: GMV + AOV by country           → USA $929k/AOV $3,216; France $724k/AOV $2,906
  Q6: repeat rate by country         → Australia 96.97% top, France 85.71% bottom
  Q7: payment failure by method      → Card 22.83% worst, PayPal 18.41% best
  Q8: vendor country × category      → German vendors = $1.14M Electronics; NL leads Sports

Root cause (one layer deeper): France's weakness is structural — low repeat + low AOV +
high-failure payment channel (Card), not a small buyer base (70 buyers, near-top country count).
Recommendation: German Electronics onboarding + France PayPal-first retention.
```

## Recommendations (what to do next)

1. **Invest in German Electronics vendors** — the strongest, fastest-growing segment ($1.14M, 57% of Electronics GMV); onboard more vendors there to compound the category engine.
2. **Fix France with a retention + payment play** — lowest repeat rate (85.7%) and low AOV; pair a loyalty program with a PayPal-first checkout (lowest failure rate 18.4%) to recover the ~22.8% of Card attempts lost.
3. **Watch AOV erosion** — YoY growth came from volume; if AOV keeps slipping, GMV growth will flatten. Monitor by category monthly.
4. **Review Card processing** — 208 failed Card attempts is the single largest payment leak; investigate decline reasons before expanding Card usage.
5. **Do not pour more into Sports & Outdoors yet** — $695k GMV vs Electronics' $2.01M; re-validate demand before scaling vendor supply there.
