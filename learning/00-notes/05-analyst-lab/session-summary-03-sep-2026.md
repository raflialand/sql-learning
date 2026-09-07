# Summary: SQL Analyst Lab Session

**Date:** 3 September 2026
**Track:** Data-to-Insight Case Studies (analyst)
**Status:** Case 03 (NovaTel) — CLOSED. Track 3/3 COMPLETE.

---

## Completed

- **Case 03 approved and closed** — `04-insight.md` verified, all 7 stages (0–6) done.
- **Progress snapshot updated** — `README.md` progress table now shows 3/3 cases complete.
- **Track finished** — Data-to-Insight Case Studies module complete.

## Case 03 Final Summary

| Stage | Status |
|-------|--------|
| Stage 0 — Context | ✅ Complete |
| Stage 1 — Scope | ✅ Complete |
| Stage 2 — Questions | ✅ Complete |
| Stage 3 — Silver | ✅ Complete |
| Stage 4 — Gold | ✅ Verified |
| Stage 5 — Query + results | ✅ PASS |
| Stage 6 — Insight | ✅ PASS-WITH-NOTES |

## Key Takeaways

1. **Type consistency in JOINs** — `EXTRACT(MONTH ...)` returns numeric, `TO_CHAR(...)` returns text. Always match types explicitly.
2. **Grain mismatch is a silent killer** — `COUNT(*)` on a subscriber-level flag LEFT JOINED into billing-record grain inflates by bill count. Use `COUNT(DISTINCT sub_id)`.
3. **Verification files belong with the case** — per-case `verification/` folders keep evaluator reports co-located with pipeline artifacts.

## Mistakes / Notes

- None this session (approval + close only).

## Next Steps

1. **Track complete** — all 3/3 cases done.
2. **Optional:** Review `expected/` folders for comparison, or start a new learning track.

---

## Session 2 — Case 00: Bookstore Omnichannel Sales Performance (Generated Case)

**Time:** ~15 min
**Case path:** `learning/04-data-to-insight/generated-case/00-bookstore-omnichannel-sales-performance/`

### What was done

- **Stage 0 — Context**: Read dataset README (`data/02-bookstore/`), case brief (`omnichannel-sales-performance.md`), and SAD (`02-bookstore-sad.md`). Surfaced 6 dataset limitations (L1–L6). Created `work/00-context.md`.
- **Stage 1 — Scope**: Defined 5 Northstar metrics (Total Revenue, AOV, Order Volume, Repeat Purchase Rate, Inventory Turnover) × 5 dimensions (Time Period, Channel, Customer Segment, Book Category, Store Location). Fixed definitions for ambiguous terms. Created `work/01-scope.md`.
- **Progress-evaluator**: Stage 1 Scope verified — **PASS** (all 6 mandatory checks green).

### Artifacts created

| File | Status |
|------|--------|
| `work/00-context.md` | ✅ Created |
| `work/01-scope.md` | ✅ Created |
| `verification/stage-1-scope.md` | ✅ PASS |

### Key notes

- This is a **generated case** (not part of original sql-analyst-lab 01–03). Dataset is `data/02-bookstore/bookstore.db` (SQLite).
- **No true margin** (L3) — COGS absent. Proxy: `list_price - price`.
- **Channel inferred** (L4) — `store_id IS NULL` = Online.
- **Promotions not linked** (L5) — inferential only via `order_items.discount > 0`.

### Next Steps

1. **Stage 2 — Questions**: Decompose main question into sub-questions across 4 buckets.
2. Awaiting user approval before proceeding.

---

*Session saved. Case 00 in progress — Stages 0–1 complete, awaiting approval for Stage 2.*
