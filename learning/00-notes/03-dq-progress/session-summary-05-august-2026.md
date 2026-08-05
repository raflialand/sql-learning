# Summary: Data Quality Learning Session

**Date:** 05 August 2026
**Track:** Data Quality Engineer module (`learning/03-dq-learning/`)
**Status:** Unit 01 (DQ Foundations) COMPLETE

---

## Unit 01 Exercises — Part A Knowledge Check

### Completed
- Worked through exercises 1.1–1.6 from `01-dq-foundations/exercises.md` (Part A, conceptual only; Part B SQL deferred).
- Self-assessment checkpoint: all 5 boxes ticked → **Unit 01 marked complete**.

### Key answers & corrections
- **1.1** — Data quality = how well data serves the purpose it was created for. Fit for purpose = good data depends on *its* use. Source of truth = the one authoritative, canonical place for a piece of data (e.g. `customers` master table), not merely "trustworthy data".
- **1.2** — All 6 dimensions named correctly: email NULL→Completeness, duplicate SKU→Uniqueness, `'shippd'`→Validity, `qty*price≠total`→Accuracy, `'CA'` vs `'California'`→Consistency, future order date→Timeliness.
- **1.3** — Order 15 violates **3 dimensions**: Completeness (`ship_city` NULL + customer 14 is a fully-empty row), Accuracy (`total_amount` 0.00 with order_items beneath it), Consistency (references effectively non-existent customer 14).
- **1.4** — Roles matched: DQ Engineer→builds/runs automated checks, Steward→decides "good", Owner→accountable/approves, Analyst→investigates+quantifies.
- **1.5** — Lifecycle order correct (Define→Profile→Measure→Remediate→Monitor). Mapping: Define→02, Profile→03, Measure→04–10, Monitor→11, **Remediate→12** (Process & Tooling; Unit 13 is the capstone that applies everything).
- **1.6** — Cost translation: NULL `total_amount` → CFO's revenue numbers unmeasurable (~5% can't be accounted for) → hits **Wrong decisions** first. Pitch refined: open with a dollar hook, name downstream risk, 10×-rule reframe ("cheap insurance"), propose measurement first.

---

## Key Takeaways

1. A single record can violate multiple dimensions at once — always scan a row for all six, not just the first defect you see.
2. Remediate (fixing root causes) is a *process* concern — Unit 12 — while the capstone (13) is where you apply everything.
3. When pitching DQ fixes, lead with money: a dollar figure + the 10× rule beats "we have NULLs".

---

## Next Steps

1. **Unit 02 — Business Context** (`02-business-context/`): business context before rules — how requirements become rules and stakeholder questions.
2. Optional: Part B SQL exercises (1.7–1.8) once the dirty dataset is loaded in MySQL 8.0.

---

*Ready to continue learning!*

---

## Session 2: Unit 02 — Lesson 2.1 Business Context Comes First (PARTIAL)

### Covered
- Started reading `02-business-context/01-why-business-context-first.md` (Lesson 2.1).
- **The trap of "checking everything":** beginner checks all columns NOT NULL / unique / valid → a mountain of findings, 90% nobody cares about; the 10% that would hurt the business go unnoticed. Context selects the checks.
- **DQ is use-case relative:** same table, different use case → different priorities (e.g. `customers.email` → Validity + Completeness for marketing; `orders.total_amount` → Accuracy + Completeness for the CFO; `orders.status` → Validity + Timeliness for ops; `daily_sales` → Completeness + Consistency + Timeliness for exec dashboards).
- **The 6-question business-first ritual (pre-SQL):**
  1. WHO consumes the data?
  2. WHAT decisions does it drive?
  3. WHAT goes wrong if it's bad?
  4. WHICH fields matter most?
  5. WHAT does "good" mean?
  6. HOW will we measure it? *(where SQL begins)*
- **Worked example — `orders`:** 6 questions walked through → tiny focused rules: `total_amount` never NULL, `status` in (shipped|pending|cancelled), `order_date` not in the future.

### Position
- **Stopped at the "Context Also Sets Priorities" section** — same defect, different context → different severity (email NULL = High for a $1M campaign, Low for a static archive). Severity is a *business* call; the engineer measures.
- Remaining in Lesson 2.1: the "English Translation" + "Key Takeaways" sections.

### Status Notes
- Unit 02 IN PROGRESS — Lesson 2.1 partially read (stopped mid-section). No exercises yet.

---

## Next Steps

1. **Finish Lesson 2.1:** "Context Also Sets Priorities" → "Key Takeaways".
2. Then Lessons 2.2–2.5: reading requirements, data consumers & use cases, prioritizing DQ dimensions, stakeholder questions checklist.
3. Unit 02 exercises: `02-business-context/exercises.md` + self-assessment.

---

*Ready to continue learning!*

---

## Session 3: Unit 02 — Lesson 2.1 COMPLETE

### Covered
- Finished `02-business-context/01-why-business-context-first.md` from where Session 2 paused ("Context Also Sets Priorities" → "Key Takeaways").
- **Context sets priorities:** same defect, different business context → different severity (email NULL = **High** for a $1M campaign vs **Low** for a static archive; 3% NULL order totals = **High** for auditable revenue; `'US'` vs `'USA'` country = **Low** when nothing uses it). Severity is a *business* call; the engineer provides the measurement.
- **English Translation / Key Takeaways internalized:**
  1. Check what matters, not everything — business context selects your checks.
  2. The 6 questions (who / what breaks / which fields / what's good / how to measure) are the pre-SQL ritual.
  3. Same table → different DQ priorities per use case.
  4. Severity is a business call, not an engineering call — you provide the measurement.

### Key Understandings (whole lesson)
- The "checking everything" trap: mountain of findings, 90% irrelevant, the damaging 10% missed.
- Use-case-relative quality: `customers.email` → Validity+Completeness (marketing); `orders.total_amount` → Accuracy+Completeness (CFO); `orders.status` → Validity+Timeliness (ops); `daily_sales` → Completeness+Consistency+Timeliness (exec dashboards).
- The 6-question ritual; "HOW will we measure it?" is where SQL begins.
- Worked `orders` example → tiny, consequence-tied rules (`total_amount` not NULL, `status` enum, `order_date` not future).

### Status Notes
- **Lesson 2.1 COMPLETE** (Unit 02 Business Context still IN PROGRESS — lessons 2.2–2.5 + exercises remain).

---

## Next Steps

1. **Lesson 2.2:** `02-business-context/02-reading-business-requirements.md` — reading business requirements.
2. Lesson 2.3: data consumers & use cases.
3. Lesson 2.4: prioritizing DQ dimensions.
4. Lesson 2.5: stakeholder questions checklist.
5. Unit 02 exercises: `02-business-context/exercises.md` + self-assessment.

---

*Ready to continue learning!*
