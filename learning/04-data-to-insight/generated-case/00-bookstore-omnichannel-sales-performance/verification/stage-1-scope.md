# Progress Evaluator — Stage 1: Scope

**Case**: 00-bookstore-omnichannel-sales-performance
**Date**: 2026-09-03
**Verdict**: PASS

## Checks

| # | Check | Result | Notes |
|---|-------|--------|-------|
| 1 | Metric floor | PASS | 5 metrics defined (M1–M5): Total Revenue, AOV, Order Volume, Repeat Purchase Rate, Inventory Turnover. Each has clear definition, source tables, and rationale. Exceeds ≥3 floor. |
| 2 | Dimension floor | PASS | 5 dimensions defined (D1–D5): Time Period, Channel, Customer Segment, Book Category, Store Location. Each has column/derivation and source tables. Exceeds ≥3 floor. |
| 3 | Definitions section | PASS | Section 3 "Definitions Fixed Here" contains 5 entries resolving ambiguity: Revenue (tax-inclusive vs item-level), Online Channel (inference method), Repeat Customer (period-based vs cohort), Inventory Turnover (avg vs begin/end), AOV (standard vs weighted). Each has definition used, alternative rejected, and rationale. |
| 4 | No forbidden comparisons | PASS | L3 (no COGS): "True margin analysis" explicitly out of scope; proxy discount spread permitted with caveat. L5 (no promo FK): "Causal promotional ROI" explicitly out of scope; discount-associated lift only. L6 (shipping): out of scope — directional only. No forbidden comparison introduced. |
| 5 | Limitations acknowledged | PASS | L1 referenced in in-scope ("MoM and YoY growth rates (allowed per L1)"). L3, L5, L6 cited in out-of-scope section with limitation codes. L4 acknowledged in D2 dimension with assumption note. L2 is a Stage 3 concern not relevant to scope definition. |
| 6 | In/out of scope | PASS | Section 4 has three clear subsections: "In Scope" (6 items), "Out of Scope (Limitation-Driven)" (3 items with limitation codes), "Out of Scope (Choice)" (3 items). Boundaries are explicit and well-organized. |

## Summary

The Scope artifact is well-structured and passes all MANDATORY checks. Five metrics and five dimensions are defined, each traceable to the main business question. Ambiguous terms are resolved in a dedicated definitions section. Dataset limitations (L1, L3, L4, L5, L6) are explicitly acknowledged — either carried into the scope (channel inference, YoY allowance) or placed into out-of-scope with clear rationale (true margin, causal promotional ROI, shipping optimization). No forbidden comparisons are introduced. The scope is ready to proceed to Stage 2 (Questions).
