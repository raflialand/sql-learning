# SQL Analyst Lab — Development Discussion

**Date:** 14 August 2026
**Topic:** Personal discussion — designing and building the next level of the SQL Skill Push module: the Data-to-Insight Case Studies lab.

---

## Context

- Wanted the "next level" of `sql-skill-push` based on the 4-step analytical framework from `learning/04-data-to-insight/data-to-insight.md` (Christine Jiang's video).
- Core idea: force the learner to write **multiple answers for only one main question** — break down metrics and dimensions first, before looking at the data.
- The plan was designed first, then formalized and executed through the OpenSpec flow.

---

## Design decisions

- **New sibling module** `learning/02-sql-learning/sql-analyst-lab/` — not a level-4 inside sql-skill-push (keeps the 60-challenge track intact).
- **3 case studies**, scaffolding decreasing per case:
  - `01-brew-and-co` (retail, ~6 queries) — highest scaffolding
  - `02-markethub` (ecommerce, ~8 queries incl. MoM + YoY) — medium
  - `03-novatel` (telecom, ~8 queries, MoM only) — minimal
- **Dataset reuse** — cases reference the 3 existing sql-skill-push `.db` files read-only; no copies, no generator changes.
- **Track registration** — new `analyst` track (3 Cases) in `learning/00-notes/tracks.md` + notes dir `learning/00-notes/05-analyst-lab/`.
- **Verification model** — SQL exact-match (expected results captured by executing the model queries against the `.db`) + text rubric for the insight deliverables.

---

## OpenSpec flow

1. Designed the plan directly.
2. Asked `@openspec-agent` whether the plan could be formalized using the OpenSpec system flow → **yes**.
3. Formalized: change `2026-08-14-add-sql-analyst-lab/` (proposal.md, design.md, tasks.md) + 6-requirement capability spec `openspec/specs/sql-analyst-lab/spec.md`.
4. Executed: module built, all 22 model queries verified (0 failures), track registered, docs updated (README, changes-log #16).
5. Archived: proposal marked DONE → canonical spec created → change moved to `openspec/changes/archive/`.

---

## Adjustments when handed to openspec-agent

No changes to the core design; only additions + execution-time fixes:

- **Additions (formalization):** OpenSpec artifacts (change-id, proposal/design/tasks, capability spec); explicit scope rulings — no `learning-progress`/`query-inspector` spec delta, no ADR needed.
- **Execution fixes:**
  - `run_query.py` handles a single statement, so multi-query `03-queries.sql` results had to be captured statement-by-statement with identical formatting.
  - Case 03 Q5 double-counted active subscribers via the billing join → fixed to `COUNT(DISTINCT ...)`.
  - No subagent call for query-inspector; optional review documented as a usage note only.

---

## Quality comparison vs sql-skill-push

**Where sql-analyst-lab is stronger:**
- Full analytical loop (scope → decompose → investigate → insight), which closed-ended challenges cannot train.
- Strong model answers — internally consistent, faithful to the 4-step framework (e.g. Case 03: "base-loss problem, not a pricing problem", ARPU flat while revenue fell 13.5%).
- Honesty constraints built into the exercise (telecom no-YoY stated in the brief).
- Fixed definitions for ambiguous metrics (e.g. repeat purchase rate in Case 02).

**Where it's weaker:**
- Text deliverables (scope/questions/insight) are self-graded, not machine-verifiable.
- No new SQL ground — the queries mostly repeat advanced skill-push techniques.
- Thin bucket coverage in places (e.g. Case 01 Growth Rates has one query only).
- Coarse progress granularity (3 Cases vs 60 Challenges).
- Static, canned insights from deterministic seeded data.

---

## Kept for later — potential improvements

1. **Insight self-check checklist** — a per-case checklist to objectively grade your own `04-insight.md` before comparing to the model answer.
2. **`work/` starter templates** — blank template files (e.g. `01-scope.md`, `02-questions.md`) instead of an empty `.gitkeep`.
3. **Solutions-index table** — an index mapping each case's `expected/` files (mirrors sql-skill-push's `solutions/README.md`).
4. **Bucket re-balancing** — redistribute sub-questions so all 4 buckets get balanced coverage in each case.

Not executed — kept here for a future session.
