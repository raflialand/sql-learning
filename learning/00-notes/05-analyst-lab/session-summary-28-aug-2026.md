# Summary: SQL Analyst Lab Session

**Date:** 28 August 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 — Stage 5 (Queries) COMPLETE: user ran `03-queries.sql` against `datainsight_markethub`, all 13 statements captured in `03-results.md` (Q1–Q8, Q9(0), Q9(a–d)). Checkpoint 5 closed. Stage 6 (Insight) next.

---

## Completed

- **Q6 (vendor momentum) reviewed in depth** — walked the dense-grid pattern line by line and clarified why the grid is required.
- **Q8 (repeat purchase rate) reviewed in depth** — walked the two-`COUNT(DISTINCT)` pattern line by line.
- **Stage 5 executed & captured** — user ran all 13 statements; results saved to `work/03-results.md` (Q1–Q8, Q9(0), Q9(a–d)). Verified 13/13 present, including the Q9(0) bottom-vendor anchor (VEN009 "Metro Distributors" $186,564.18).

## Key Takeaways (conceptual this session)

1. **`COALESCE` fills a missing VALUE; the grid fills a missing ROW — and `LAG` only sees rows.** That's why you can't fix a skipped month with `COALESCE(LAG(...))` alone: `LAG` skips over the absent row and compares to the last *selling* period. The `vendors CROSS JOIN months` grid manufactures the gap month as `gmv=0` so "previous month" literally means the previous calendar month.
2. **Momentum (Q6) needs the grid most** because a growth rate is a comparison between two periods — if those aren't the true adjacent calendar periods, every % is wrong, and vendors with irregular sales (the exact ones the invest-next decision hinges on) are the most exposed.
3. **Q8 repeat rate = a two-step `COUNT(DISTINCT)`.** Step 1 (CTE): `COUNT(DISTINCT order_id)` per vendor-customer = baskets, not line rows (mart is line-grain). Step 2: `SUM(CASE WHEN fulfilled_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*) × 100` per vendor.

## Mistakes / Notes

- None (review + execution session; queries authored earlier, run by the user this session).

## Next Steps

1. **Stage 6 — Insight** (`@insight-writer`): 5-component insight (Trend / Fluctuation / Anomaly / Root cause / Recommendation) + recommendations + self-check → `work/04-insight.md` → checkpoint.
2. Then Case 03 (NovaTel), then archive the OpenSpec change once both pilots validate.

---

# Summary: SQL Analyst Lab Session (continued — Stage 6 insight + progress-evaluator capability)

**Date:** 28 August 2026 (same-day continuation)
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 02 — Stage 6 (Insight) COMPLETE (`04-insight.md`), rank error fixed. Also formalized, implemented, and archived the new `progress-evaluator` verification capability (OpenSpec `add-progress-evaluator`), and archived the `add-data-to-insight-ecosystem` change.

---

## Completed

- **Stage 6 — Insight synthesized** (`@insight-writer`) → `work/04-insight.md`: running log + 5 components (Trend/…/Recommendation) + insight paragraph + 4 recommendations + rubric self-check (PASS).
- **Fixed a factual error** in `04-insight.md`: Summit Brands "14th largest" → "12th of 14 — third-smallest" (Metro is the true 14th); caught by cross-checking against Q2.
- **Analyzed the data-to-insight workflow for gaps** → the pipeline had no independent verification layer (the Q9(0) miss and the "14th" error both slipped past self-checking).
- **Designed `progress-evaluator`** — read-only blocking gate at all 6 checkpoints; PASS / PASS-WITH-NOTES / FAIL verdict model; per-stage MANDATORY checks; 3-fix retry budget + fail-closed; owner routing (orchestrator / `@sql-builder` / `@insight-writer`).
- **OpenSpec `add-progress-evaluator`** formalized (`@openspec-agent`), applied (new agent + spec + blueprint/skill/registry wiring), archived to `openspec/changes/archive/2026-08-28-add-progress-evaluator/`.
- **Archived `add-data-to-insight-ecosystem`** → `openspec/changes/archive/2026-08-28-add-data-to-insight-ecosystem/`.

## Key Takeaways (conceptual this session)

1. **Self-grading is not verification.** `insight-writer` reported PASS while shipping a wrong rank — because it graded its own work. An independent grader (a different agent) is what catches this.
2. **"Largest" ≠ "invest next".** Q2 size (TechSource #1) is a snapshot of the past; Q6 momentum (Summit +84.95% YoY / +110.45% MoM) is the forward-looking signal. Different questions → different actions (protect the leader vs invest in the riser).
3. **A verification gate must be fail-closed and read-only.** It blocks the checkpoint on FAIL, routes the defect to the owning agent, and never fixes what it grades — keeping the grader independent.
4. **Completeness and traceability are the two failure classes** a gate must catch: a missing result block (Q9(0)) and an untraceable/wrong claim ("14th").

## Mistakes / Notes

- `04-insight.md` rank error ("14th" vs "12th") — root cause: the writer's self-check graded its own output; lesson: an independent verification layer is needed (→ built `progress-evaluator`).

## Next Steps

1. **Close Case 02** — approve `04-insight.md`, mark Case 02 complete in the progress snapshot.
2. **Case 03 (NovaTel)** — telecom, minimal scaffolding, MoM-only (no YoY).
3. Optionally pilot `progress-evaluator` on Case 03 (first live use of the new gate).

---

*Happy Learning!*
