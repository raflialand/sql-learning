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
