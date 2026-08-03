# Agent Blueprint: SQL Learning Skill

The canonical plan for the `sql-learning` agent skill. Implemented by `.opencode/skills/sql-learning/SKILL.md`.

---

## 1. Intention

Why this agent exists:

- The user is on a fixed 12-week / 84-day SQL roadmap (`learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md`), from beginner to intermediate/advanced.
- Learning happens daily through conversation (concepts, exercises, errors, insights).
- Two recurring needs:
  - **(A) Persist** each session's learnings durably so nothing is lost.
  - **(B) Resume** instantly — know current position, progress %, and the exact next topic.
- The agent owns the notes lifecycle and progress reporting so tracking is automatic, never manual.

---

## 2. Goals

Measurable success criteria:

- **G1 — Accurate progress.** Completed days/weeks and percentage are computed correctly against the 84-day / 12-week denominator.
- **G2 — Lossless summaries.** Every learning day produces a `session-summary-{dd}-{mmm}-{yyyy}.md` note. Same-day sessions are **appended**, never overwritten.
- **G3 — Clear next action.** Every report ends with the exact next day + topic + exercise from the roadmap.
- **G4 — Single report generator.** Both modes (REPORT and SUMMARIZE) use the same report block; no duplicated logic.
- **G5 — Robustness.** Handles missing quiz scores, partially complete days, and an empty notes directory. Never invents data.

---

## 3. Requirements

### Prerequisites

- Roadmap file exists: `learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md`
  - Source of truth for structure: 12 weeks × 7 days = 84 days, week/day topics, exercises, quiz milestones.
- Notes directory exists: `learning/00-notes/`
- Note filename convention: `session-summary-{dd}-{mmm}-{yyyy}.md` with lowercase month, e.g. `session-summary-22-june-2026.md`.

### Invariants (must never be violated)

- NEVER overwrite or delete existing summary content. Same-date sessions append under a horizontal rule (`---`).
- NEVER fabricate quiz scores, dates, or completion status. Derive only from the roadmap and the notes.
- Roadmap = source of truth for the timeline; notes = source of truth for actual progress.
- Only `session-summary-*.md` files count toward progress. (`rangkuman-belajar-sql.md` and any other files are excluded from the scan.)
- When notes show partial completion of a day, suggest finishing that day before moving on.

### Non-goals

- Not a SQL tutor — teaching happens in conversation; this agent only tracks, persists, and reports.
- Does not modify the roadmap or create quizzes.

---

## 4. Input

### Triggers

Two modes, selected by trigger phrase:

| Mode | Trigger phrases |
|------|-----------------|
| REPORT | "continue learning", "continue our learning", "let's continue", "continue my learning", "where am I", "progress", "/skill sql-learning" |
| SUMMARIZE | "summarize", "summarize today", "summarize learning", "save daily summary", "daily summary", "rangkuman", "ringkasan" |

### Data sources (in priority order)

1. **Conversation content** — topics taught, exercises completed, errors + fixes, insights, progress updates, quiz scores.
2. **Roadmap file** — week/day structure, topics, exercises, quiz milestones.
3. **Notes listing + latest summary** — prior position, quiz scores, in-progress week/day.

### Extraction schema (what the agent pulls from the conversation)

- Week/day identifiers (e.g. "Week 6 Day 4")
- Topics covered / SQL concepts learned
- Commands and example queries
- Practice exercises completed
- Errors encountered and how they were fixed
- Quiz scores
- Database used (e.g. `sql-learn-db-week6.db`)
- Status updates (e.g. "Week 2, Day 4 complete")

---

## 5. Output

### Artifacts (files)

- **SUMMARIZE mode:** create or append `learning/00-notes/session-summary-{date}.md` following the structured note template below; then emit a progress report.
- **REPORT mode:** no file changes (read-only); emits a progress report only.

### Structured note template

```markdown
# Summary: SQL Learning Session

**Date:** {day} {month} {year}
**Database:** {database mentioned}
**Status:** {progress/status mentioned}

---

## {Main Topic or Section}

### What was learned:
- {concept 1}
- {concept 2}

### Examples practiced:
```sql
-- {example}
```

---

## Key Takeaways

1. {point}

---

## Next Steps

1. {step}

---

*Happy Learning!*
```

### Progress report (user-facing, both modes)

```
## 📊 Learning Progress Report
**Date:** {today}

### Statistics
- **Overall Progress:** {X} of 84 days ({Z}%)
- **Weeks Completed:** {X} of 12 ({Z}%)
- **Quiz Score:** {score if available, otherwise "In progress"}

### Progress Visualization
{mermaid pie: "Completed (X days)" vs "Remaining (Y days)", 84-day denominator}

---

## 📚 Learning Progress

### ✅ COMPLETED
| Week | Topic | Quiz |
|------|-------|------|

### 🔄 IN PROGRESS
**Week {X}:** {Topic} — day-by-day table with ✅ done, ⏳ Next, ❌ pending

### ❌ NOT YET STARTED
| Month | Weeks | Topics |
|-------|-------|--------|

---

## Summary of Last Session
- {2-3 bullets}

## Next Up
- **Today:** {next day/topic from roadmap}
- **Goal:** {what to accomplish}

### Ready to Continue?
Let me know when you want to start!
```

### Formatting rules

- Markdown output.
- Status emojis: ✅ complete, 🔄 in progress, ❌ pending, ⏳ next.
- Keep the summary concise but meaningful.
- The Mermaid pie chart renders in VSCode (Mermaid extension) or any Mermaid-capable viewer.

---

## 6. Workflow

### Shared report generator

Both modes end with this block:

1. Read `learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md` → total 12 weeks / 84 days, week structure.
2. List `learning/00-notes/session-summary-*.md`, sort by date.
3. Determine: completed weeks, in-progress week, days done in that week, quiz scores.
4. Calculate: completed days = (completed weeks × 7) + days done in current week; remaining = 84 − completed; progress % = completed / 84 × 100.
5. Read the most recent summary for last-session bullets and next topic.
6. Emit the progress report (Section 5) + "Ready to continue?" prompt.

### SUMMARIZE mode

1. Extract topics from the conversation (Section 4 extraction schema).
2. Get current date → filename `{day}-{month}-{year}` (lowercase month).
3. List `learning/00-notes/`, find the most recent `session-summary-*.md`.
4. Decide: last summary date = today → append under `---` (preserve existing content); earlier → create new file.
5. Save the structured summary.
6. Run the shared report generator.

### REPORT mode

1. Run the shared report generator.
2. If notes show partial completion of a day, suggest finishing that day first.
3. Connect previous learnings to the next topic where possible.

---

## 7. Implementation Mapping

| File | Role |
|---|---|
| `agent-blueprints/01-sql-learning.md` | This canonical plan |
| `.opencode/skills/sql-learning/SKILL.md` | Thin skill file: frontmatter + triggers + pointer to this plan |
| `.opencode/skills/continue-learning/` | Removed (superseded) |
| `.opencode/skills/daily-summary/` | Removed (superseded) |
