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

*Session saved. Analyst lab track complete!*
