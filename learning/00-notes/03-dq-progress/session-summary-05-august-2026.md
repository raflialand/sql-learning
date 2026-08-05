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

---

## Session 4: Unit 02 — Lesson 2.2 COMPLETE

### Covered
- Read `02-business-context/02-reading-business-requirements.md` in full.
- **The translation skill:** business requirements come in words → translate to a **testable expectation** (precise, machine-checkable sentence naming the field + exact condition) → then to a **rule** (SQL check that *returns the violating rows*). Never go straight to SQL.
- **The Translation Table:** common phrasings → expectations → SQL patterns ("working email" → `email IS NULL OR email NOT REGEXP ...`; unique → `GROUP BY ... HAVING COUNT(*) > 1`; prices positive → `unit_price <= 0`; status enum → `NOT IN (...)`; revenue complete → `total_amount IS NULL`; orders current → `order_date > CURRENT_DATE`).
- **Ambiguity hunting:** "one row per customer" is ambiguous — which key? Interpretation A (by email) vs B (name + phone): customers 3 & 4 (same phone, different email/state) only surface under B. Agree on the **business key** before writing the check.
- **The "So What?" test + motto:** a rule is worth keeping only if a violation has a consequence — *"If a violation wouldn't bother anyone, the rule shouldn't exist."* Drop rules like `address_line` containing `#`.
- **Rule cards:** document each rule (ID, dataset, field, dimension, requirement, expectation, SQL, threshold, severity, owner) — becomes the DQ rule catalog in Unit 11.

### Deep-dives / Q&A
- **Testable sentence:** must name the field, state an exact per-row condition, and let a script decide yes/no — no human judgment (e.g. "phone looks right" ❌ vs `phone IS NOT NULL AND phone REGEXP ...` ✅).
- **Stating a good uniqueness rule:** 4 parts — (1) exact key (which columns define "the same entity"), (2) scope (whole table vs per partition), (3) NULL policy (`WHERE ... IS NOT NULL` — NULLs are not duplicates), (4) comparison semantics (LOWER/TRIM). Ask the business the disambiguation questions before writing the check.
- **The motto** = cost-benefit filter: rules cost write/run/noise; keep only when violation hurts.
- **Industry formats:** rule cards are universal — YAML (dbt/Soda/GE), JSON (GE), SQL w/ comments, Markdown, CSV/Excel, DB table (enterprise platforms). Modern standard = YAML for machine + Markdown/comments for the human "why".
- **MySQL module convention:** rule card = **Markdown** now (Units 02–10), SQL check = **.sql** files run in MySQL, operational catalog = **MySQL table** `dq_rule_catalog` (`rule_sql TEXT`, threshold, severity, owner — Unit 11.2). Card fields map 1:1 to catalog columns.
- **Flow confirmed:** analyze requirement → clarify ambiguity → define testable expectation → write SQL rule (detects bad rows) → monitor over time (Unit 11, tracking).

### Status Notes
- **Lesson 2.2 COMPLETE** (Unit 02 still IN PROGRESS — lessons 2.3–2.5 + exercises remain).

---

## Next Steps

1. **Lesson 2.3:** `02-business-context/03-data-consumers-and-use-cases.md` — data consumers & use cases (one table, multiple consumers → conflicting priorities).
2. Lesson 2.4: prioritizing DQ dimensions.
3. Lesson 2.5: stakeholder questions checklist.
4. Unit 02 exercises: `02-business-context/exercises.md` + self-assessment.

---

*Ready to continue learning!*
