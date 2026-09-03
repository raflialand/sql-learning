# Add Scope Data Reconciliation

## Problem Statement

The `data-to-insight` framework fixes Scope (`01-scope.md`: ~3 metrics + ~3 dimensions) BEFORE touching data — by design, to prevent "analyze everything by everything". But nothing systematically re-validates scope against the actual profiled dataset. The existing checks validate scope against (a) the business question and (b) the README's documented quirks — never against the data itself. A metric/dimension/data-quirk discoverable only by profiling the data (an undocumented column, status enum, boolean flag, or a join cardinality that changes the answer) can be missed until late — or never. In the MarketHub run this actually happened: the `product_id`/`product_name` drill-down for Q9 was discovered late (Stage 4 mart-coverage gap), not at scope time.

## Proposed Solution

Add a **Scope ↔ Data Reconciliation** step at Stage 3 (Silver — the first moment the dataset is actually profiled), plus a corresponding verification check in the `progress-evaluator` gate. Two capabilities are affected: `data-to-insight` gains a new ADDED "Scope Reconciliation Contract" that surfaces profile-only scope gaps and routes them to the orchestrator (scope owner) rather than `sql-builder`; `progress-evaluator` extends its Silver Evaluation Contract from five to six MANDATORY checks with a "scope coverage vs. profiled data" check that FAILs on an unflagged scope gap.

## Scope

### In scope

- A new `Scope Reconciliation Contract` requirement in `data-to-insight`.
- A sixth MANDATORY Silver check in `progress-evaluator`'s Silver Evaluation Contract.
- Scope-amendment routing to the orchestrator (not `sql-builder`).
- Re-verification of amended scope before questions/queries are locked.
- Framing a scope amendment as a legitimate, documented outcome (the "scope before data" rule's safety net).

### Out of scope

- Changes to `query-inspector`, `learning-progress`, or the track registry.
- Any change to the "scope before data" rule itself — the amendment is its safety net, not its replacement.
- Changes to the Owner Routing Contract or the fail-closed re-run loop semantics.
- Implementation edits to `.opencode/` files (deferred to Phase 2 after approval).

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `data-to-insight` — ADDED requirement
- `progress-evaluator` — MODIFIED requirement

## Value Proposition

- Moves scope-vs-data drift detection from "maybe never" to the first moment the data is actually profiled (Stage 3).
- Catches answer-changing gaps (undocumented columns, enums, flags, join cardinalities) before questions/queries are locked.
- Keeps the "scope before data" rule intact while adding its safety net: a scope amendment is a legitimate, documented outcome, not a failure.
- Closes the exact gap that bit the MarketHub run (Q9 `product` drill-down discovered at Stage 4 instead of at scope time).
