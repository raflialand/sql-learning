# Summary: Data Quality Learning Session

**Date:** 06 August 2026
**Track:** Data Quality Engineer module (`learning/03-dq-learning/`)
**Status:** Unit 02 lessons ALL COMPLETE (2.1–2.5); Unit 02 exercises + self-assessment REMAINING

---

## Session 1: Lesson 2.5 — The Stakeholder Questions Checklist

### Completed
- Read `02-business-context/05-stakeholder-questions-checklist.md` in full — the last lesson of Unit 02.

### The Checklist (5 buckets)
1. **Purpose & Consumers** — who consumes, single most important decision, any regulatory/compliance consumer.
2. **Field-Level Semantics** — what "valid" means per critical field, required fields, business key, field dependencies.
3. **Business Rules** — allowed value sets, acceptable ranges, cross-table rules, cross-field rules.
4. **Freshness & Timing** — required freshness per consumer, load window, future dates allowed?
5. **Severity & Ownership** — worst consequence, who decides severity, who fixes root causes.

### How it connects to earlier lessons
- The checklist operationalizes the **6-question ritual** (Lesson 2.1) into checkable form, run with the owner.
- Answers map 1:1 to the **translation table** (Lesson 2.2) → rule cards.
- "Which field worries you most?" = the 80/20 Pareto isolation (Lesson 2.4).
- Severity stays a **business call** (Lesson 2.3 stakes ladder).
- Red-flag "we'll fix it later" invokes the **10× rule** (Lesson 1.4).

### Red-flag probing
| They say | You ask |
|---|---|
| "Just make sure it's clean" | "Which field worries you most — what does clean mean for it?" |
| "All fields are required" | "Even the optional ones like notes?" |
| "That can't happen" | "What's the worst case if it does?" |
| "We'll fix it later" | "Later costs 10× more — can we capture the rule now?" |

### Deliverable
A **data expectations sheet** per dataset (critical fields, required, business key, allowed values, ranges, cross-table/cross-field rules, freshness, severity) — the input to every rule in Units 04–10.

---

## Session 2: Deep-Dive — Field-Level Semantics

- **Semantics = meaning** (vs syntax = shape). Same value `3` can mean qty/price/date/category — semantics is what the bytes *represent*.
- **Field-level semantics** = the meaning contract of one column; defined by 4 questions per critical field:
  1. What does "valid" mean? (format/allowed values → Validity)
  2. Which fields are required? (Completeness)
  3. Which field is the business key? (Uniqueness/identity — incl. NULL policy & LOWER/TRIM comparison semantics)
  4. Any field dependencies? (Accuracy/Consistency — cross-field, cross-table)
- Example: `orders` order 15 breaks 4 field contracts at once — `total_amount`=0.00 (dependency/Accuracy), `status='shippd'` (allowed values/Validity), `customer_id=14` (cross-table/Consistency), future `order_date` (range/Timeliness).
- Each semantic answer → one rule card → one SQL check.

---

## Session 3: Deep-Dive — Business Rules (Checklist Point 3)

Four sub-questions → four "wrongness" flavors → four Units:

| Sub-question | Dimension | Unit | SQL pattern |
|---|---|---|---|
| Allowed value sets | Validity | 06 | `NOT IN (...)` |
| Ranges | Validity | 06 | `<= 0`, `BETWEEN` |
| Cross-table rules | Consistency | 08 | `LEFT JOIN ... IS NULL` |
| Cross-field rules | Accuracy | 07 | recompute `qty × price <> total` |

- Closed-set (enumerated) vs open/continuous (boundary) questions.
- FK constraints = hard violations; DQ checks also catch soft ones (soft-deleted master rows).

---

## Session 4: Deep-Dive — Freshness & Timing Cost Economics

- **Faster refresh = more cost** — the trade-off, not "free freshness":
  1. **Compute** — more runs = more CPU/memory/warehouse credits.
  2. **Storage** — more snapshots/higher-grained history retained.
  3. **Pipeline engineering** — idempotency, late-arriving data handling, failure recovery.
  4. **DQ checking** — rules re-run per load; more alert noise → threshold tuning + dedup.
  5. **SLA & on-call** — tighter freshness = tighter SLA, on-call, bigger impact on slip.
- **Freshness is a decision-driven business call** — match cadence to how often the consumer decides (exec dashboards → nightly is fine; live ops → P1 timeliness justifies it). Pay for freshness only up to where it changes a decision.

---

## Session 5: Role-Play — Responding to a Vague "Refresh Every 1 Minute" Request

- **Default script:** don't say yes, don't say no — "What decision does 1-minute freshness support? Once I know that, I can tell you the cheapest cadence that delivers it."
- **4 moves:**
  1. Acknowledge + ask for the decision it serves (checklist points 1 & 4).
  2. Name the cost factually (1,440 refreshes/day, compute/storage, DQ re-checks, alert fatigue).
  3. Offer the staircase — start at 15 min, escalate only if the decision needs it (10× rule thinking).
  4. If genuinely time-critical → accept and scope properly (idempotent pipeline, auto-retries, check-on-load, fail behavior).
- **Pushback handling:** "just make it 1 minute" → "which decision needs 1-min vs 15-min granularity?" Offer a shadow 1-min pipeline for a week as cheap evidence — prove need before multiplying cost.

---

## Key Takeaways

1. The stakeholder checklist converts vague needs into testable rules; run it before auditing any dataset.
2. Field-level semantics = the meaning contract per column (valid, required, key, dependencies) — one row can break multiple contracts at once.
3. Business rules = 4 flavors (value sets, ranges, cross-table, cross-field) mapping to Validity/Consistency/Accuracy checks.
4. Freshness is a cost trade-off, not free — match refresh cadence to the decision cadence.
5. Vague "make it real-time" requests get probed, not obeyed — translate them back to the decision, name the cost, offer the staircase.

---

## Next Steps

1. **Unit 02 exercises:** `02-business-context/exercises.md` (business-context case study) + self-assessment checkpoint → closes Unit 02.
2. Optional: Unit 01 Part B SQL exercises (1.7–1.8) once the dirty dataset is loaded in MySQL 8.0.
3. Then **Unit 03 — Data Profiling** (first SQL-heavy unit: `COUNT`, `COUNT(DISTINCT)`, `MIN/MAX/AVG/STDDEV`, `GROUP BY`).

---

*Happy Learning!*
