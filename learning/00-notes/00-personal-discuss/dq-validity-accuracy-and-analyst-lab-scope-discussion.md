# DQ Concepts + Analyst Lab Scope — Discussion

**Date:** 24 August 2026
**Topic:** Personal discussion — DQ learning progress, validity vs accuracy, CASE-expression flags, and Brew & Co Case 01 scope questions.

---

## DQ learning progress

- 1 of 13 Units (**8%**). Unit 01 complete; **Unit 02 in progress** — all lessons (2.1–2.5) done, Part A exercises (2.1–2.4) done, next up **Exercise 2.5** (Finance vs Marketing), then self-assessment closes Unit 02.

---

## Brew & Co Case 01 — scope analysis (`01-scope.md`, `02-questions.md`)

- **Payment method: NOT in scope** (metrics: Revenue · Order count · AOV; dimensions: Store · Category · Month). NULL `payment_method` from EDA affects no sub-question — keep as a side DQ note, not part of Case 01.
- **City: not in scope** — not in the locked dimension pool, no sub-question slices by it.
- **Product: YES, in scope via Bucket 4.** Q4a = *which products underperform?* (product revenue, bottom decile ~3 of 31, flag zero-sales) — that's the "focus products" answer; Q4b–d explain *why* (price band, `is_active`, basket context). Caveat: only underperformers, not "which to promote."

---

## Validity vs Accuracy (Lesson 1.2, `02-six-dq-dimensions.md`)

- **Validity** = *does the value obey the defined format/domain rules?* (regex, allowed set, range). Judge = the rule you defined.
- **Accuracy** = *is the value the true one?* Judge = a source of truth (recompute, master record, reality).
- Key idea: a value can be **valid but inaccurate** — well-formed but wrong, and it slips past every earlier check.
- Paraphrase correction: validity ≈ obeys the field's rules (not "data identity"); accuracy ≠ just cross-table aggregation — also single-table recompute (`qty×unit_price <> total`), master-data diff, cross-field logic, or reality itself.

---

## CASE-expression style for validity/accuracy flags

- **1/0** (`is_valid`/`is_accurate`, TINYINT) — best for logic: `SUM`/`AVG` counts, `WHERE = 1`, feeds dashboards/alerts.
- **'valid'/'invalid'** phrases — best for human-readable output only.
- **Hybrid** (recommended): store `1/0`, decode to text at display. *"1/0 for logic, phrases for presentation."*

---

## Key takeaways

1. Scope locks which fields matter — payment method and city are out of scope for Case 01; product is in via Bucket 4.
2. Validity asks "allowed by the rule?"; accuracy asks "true against a source of truth?" — valid-but-inaccurate is the silent killer.
3. Use numeric flags for logic, text for presentation; name columns `is_valid` / `is_accurate`.
