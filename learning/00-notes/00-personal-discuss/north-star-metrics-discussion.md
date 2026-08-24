# North Star Metrics & Dimensions — Discussion Notes

**Date:** 14 August 2026
**Topic:** Personal discussion — why defining the *right* north star metrics and dimensions is genuinely hard, and the mental model that makes it repeatable.

---

## Context

- Source material: `learning/04-data-to-insight/data-to-insight.md` (Christine Jiang, 4-step framework: ~3 north star metrics, ~3 dimensions before touching data).
- Reference implementation: the 3 case studies in `learning/02-sql-learning/sql-analyst-lab/`.
- Struggle acknowledged: "turning a business question into an actionable metric" feels easy in theory but is hard in reality — the missing piece was the underlying logic for *why* specific metrics are chosen.

---

## The core reframe

> **A north star metric is not a property of the data. It is an answer to a decision the stakeholder is about to make.**

If you cannot say what decision changes based on this number, it is not a north star metric — it is just a number.

This fixes the original mistake: treating a metric as something you *find* in the data instead of something you *derive from the decision*.

---

## The 3-filter recipe

Apply in order. A candidate survives all three → it's in. Otherwise cut it.

### Filter 1 — Decision
What is the stakeholder going to **do** with the answer?

| Case | Main question | Decision type |
| --- | --- | --- |
| 01-brew-and-co | "How is sales performance, where to focus next month?" | Allocation (where) |
| 02-markethub | "Which vendor/segment to invest in next?" | Investment (which segment) |
| 03-novatel | "Is the base healthy, where is revenue leaking?" | Health + fix-it |

### Filter 2 — Factorization
The ~3 metrics are NOT arbitrary. They come from factoring the headline number into its multiplicative components:

- **Retail:** Revenue = Order Count × AOV → Case 01 M1/M2/M3 (the "why it matters" column literally says "revenue alone hides whether growth comes from more orders or bigger orders").
- **Marketplace:** GMV = Orders × AOV, plus repeat purchase rate as the loyalty/health signal → Case 02.
- **Telecom:** Revenue = Active Subscribers × ARPU → Case 03 ("whether revenue moves because the base grows or because each user pays more").

This factorization is why the video says "~3": a headline + its 2–3 factors is a complete, self-justifying set. If the question is about health/loyalty rather than pure revenue, swap one factor for a leading indicator (repeat rate, churn, ARPU).

### Filter 3 — Reality
Can you write the metric unambiguously against the data you actually have? Fix: **scope, numerator, denominator, window, dedup rule.**

- Case 02 repeat purchase rate is the textbook example — fixed as "≥2 Completed/Shipped orders ÷ ≥1, no windowing" because it had multiple plausible definitions.
- **If you can't write it as `SELECT ... WHERE ...` with zero ambiguity, it is not yet a metric.**

---

## The dimension rule

A dimension earns a slot only if it satisfies one of:

1. It is the **axis of the decision** (invest in *which segment* → country/category).
2. It is a **plausible driver of the "why"** (store, plan, region).
3. It is **time** (month — always mandatory).

The video's trap — "all metrics × all dimensions" — is exactly what happens when dimensions are picked from the schema instead of from the decision. Case 03 is the cleanest proof: Region and Plan are there because the question is "where is revenue leaking" (geography + product), not because they are columns in the table.

---

## Validation test (run before writing any SQL)

1. **Relevance** — if this metric moves, does the stakeholder's answer change?
2. **Definability** — could a colleague reproduce my exact numbers from the definition alone?
3. **Actionability** — would the business do something *different* based on which direction this metric went?

Any metric failing one of these gets replaced. This is the test that separates "easy" from "actually hard" — most candidate metrics fail the actionability test.

---

## Follow-up

- Practice applying the 3 filters + dimension rule to a real business question the learner is wrestling with (stakeholder, what they'll do with the answer, available data).
- Session ends with the invitation: walk through the filters on a live example and see where it breaks.
