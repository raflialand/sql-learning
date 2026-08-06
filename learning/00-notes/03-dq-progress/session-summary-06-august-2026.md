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

## Session 6: Unit 02 Exercises — Part A (Marketing Email Campaign) STARTED

### Concept ground-work
- **Email campaign** = coordinated, automated batch send to a list, driving a specific action. Budgeted ($50K), targeted (active customers), measured (opens/clicks/purchases) — but **every downstream metric depends on delivery first**. The whole risk sits on `customers.email` (Marketing = Validity > Completeness > Uniqueness).
- **Checklist is a toolkit, not a script** — you do NOT need all 5 buckets. Context selects the questions (Lesson 2.1). For an email campaign: 3 questions on Field-Level Semantics (email is the risk), 1 each on Purpose, Freshness, Severity. Weight questions to the use case.

### Exercise 2.1 — The interview (6 questions + owner answers) COMPLETE
1. **Purpose:** "What decides success — does it depend on emails arriving?" → Everything downstream of delivery; if it doesn't arrive → $50K gone.
2. **Field semantics (valid):** "What does a deliverable email look like?" → name@domain.tld, no spaces, no null/n/a.
3. **Field semantics (required):** "Must every active customer have an email?" → Yes; no email = excluded from send, chased later.
4. **Key/duplicates:** "One customer = one email?" → Yes; duplicates = spam + double pay.
5. **Freshness:** "How fresh must the list be?" → active now; within last 30 days.
6. **Severity:** "Worst case if emails bounce?" → wasted $50K + sender reputation damage + report is fiction.

### Exercise 2.2 — Expectations sheet (customers, marketing) COMPLETE → PASS
- Critical fields: `email` · Required: `email` · Key: `email`
- Allowed values: email regex `'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'`; active flag ∈ {active, inactive} → campaign sends to active only
- Ranges: `last_activity >= CURRENT_DATE - INTERVAL 30 DAY` → defines "active enough"
- Cross-table / Cross-field: `-` (justified — no joins needed for a send) · Freshness: ≤ 30 days · Severity: HIGH
- **Feedback applied:** annotation added so the sheet is self-contained (defines `active`); nit — write severity *reason* ("wasted $50K + sender reputation") so it travels to the Unit 11 rule catalog.
- **Key insight:** interview answers ARE the source data for the sheet — each answer maps to a row (owner's "must have an email" → Required; "one person one email" → Key; "30 days" → Freshness/Ranges).

### Position
- Part A IN PROGRESS — Exercises 2.1 ✅, 2.2 ✅; **2.3 (Rule → SQL) NOT STARTED**.

---

## Next Steps

1. **Exercise 2.3 — Rule → SQL:** three queries against `customers` in `dq_learning` (non-NULL email; well-formed email via regex; no duplicate emails) — write + expected row counts (15 customers).
2. **Exercises 2.4–2.6:** priority call (which of the 3 to fix first), Finance-vs-Marketing (LTV, duplicates by email, customer 3 vs 4), translate-the-query (NULL emails by state).
3. **Part C (2.7–2.8):** ambiguity hunting ("make orders unique" — 3 interpretations) + the "so what?" test (keep/drop 5 rules).
4. **Self-assessment checkpoint** → closes Unit 02 (progress → 2 of 13).
5. Optional: Unit 01 Part B SQL (1.7–1.8) once the dirty dataset is loaded in MySQL 8.0.
6. Then **Unit 03 — Data Profiling** (first SQL-heavy unit).

---

## Session 7: Exercise 2.3 — Rule → SQL COMPLETE

### Completed
- Wrote the three rules as separate queries against `customers` in `dq_learning`:

**Rule 1 (Completeness)** — `email IS NULL OR email = ''` → **2 rows** (customers 5 NULL, 14 fully-empty).
- `OR email = ''` justified: empty string is semantically "missing" (sendability), even though the defect map has none, so count stays 2.

**Rule 2 (Validity)** — `email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'` → **2 rows** (customer 6 `david.wilson@@example.com`, customer 7 `eve.brown@example` no TLD).

**Rule 3 (Uniqueness)** — `GROUP BY email HAVING COUNT(*) > 1 AND email IS NOT NULL` → **1 group** (customers 1 & 2 exact duplicates, count 2).

### Key learnings
- **One query = one rule (rule catalog discipline):** each rule card maps to one dimension/one distinct defect; separate counts per dimension for reporting. Combined queries are fine for a quick sweep, not the catalog.
- **NOT REGEXP on NULL returns NULL (not TRUE)** — so Rule 2 *cannot* catch NULL emails; this is why Completeness (missing) and Validity (malformed) separate cleanly with zero overlap. Behavior by SQL semantics, now understood.
- **`AND email IS NOT NULL` in Rule 3 = the NULL policy (Lesson 2.2) applied:** without it, the two NULL rows would group as `COUNT(*)=2` → false positive. **NULLs are not duplicates.**
- Combined "all unusable emails" query returns 4 rows (5, 6, 7, 14) but stays out of the catalog to preserve dimension attribution.

### Position
- Part A: Exercises 2.1 ✅, 2.2 ✅, **2.3 ✅ COMPLETE**. Next: **2.4 (priority call)**.

---

## Next Steps

1. **Exercise 2.4 — Priority call:** if only ONE of the three email issues could be fixed this week, which and why (business impact, not ease).
2. **Part B (2.5–2.6):** Finance-vs-Marketing (LTV, duplicates by email, customer 3 vs 4 same phone), translate-the-query (NULL emails grouped by state).
3. **Part C (2.7–2.8):** ambiguity hunting ("make orders unique" — 3 interpretations) + the "so what?" test (keep/drop 5 rules).
4. **Self-assessment checkpoint** → closes Unit 02 (progress → 2 of 13).
5. Optional: Unit 01 Part B SQL (1.7–1.8) once the dirty dataset is loaded in MySQL 8.0.
6. Then **Unit 03 — Data Profiling** (first SQL-heavy unit).

---

*Happy Learning!*
