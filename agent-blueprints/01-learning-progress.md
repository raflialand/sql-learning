# Agent Blueprint: Learning Progress Skill

The canonical plan for the `learning-progress` agent skill. Implemented by `.opencode/skills/learning-progress/SKILL.md`.

---

## 1. Intention

Why this agent exists:

- The user learns across multiple tracks (SQL Fundamentals, Data Quality Engineer, Data Engineering — and future ones), each defined in the track registry `learning/00-notes/tracks.md`.
- Learning happens daily through conversation (concepts, exercises, errors, insights), and tracks are picked up and resumed over time.
- Two recurring needs:
  - **(A) Persist** each session's learnings durably so nothing is lost.
  - **(B) Resume** instantly — know current position, progress %, and the exact next topic, for any registered track.
- The agent owns the notes lifecycle and progress reporting so tracking is automatic, never manual, and never tied to a single track's completion.

---

## 2. Goals

Measurable success criteria:

- **G1 — Accurate progress.** Completed units and percentage are computed correctly against the resolved track's registry total (`learning/00-notes/tracks.md`).
- **G2 — Lossless summaries.** Every learning day produces a `session-summary-{dd}-{mmm}-{yyyy}.md` note in the resolved track's notes dir. Same-day sessions are **appended**, never overwritten.
- **G3 — Clear next action.** Every report ends with the exact next unit + topic + exercise from the resolved track's roadmap.
- **G4 — Single report generator.** Both modes (REPORT and SUMMARIZE) use the same report block; no duplicated logic.
- **G5 — Robustness.** Handles missing quiz scores, partially complete units, an empty notes directory, unknown track keywords, and a missing registry. Never invents data.

---

## 3. Requirements

### Prerequisites

- Track registry exists: `learning/00-notes/tracks.md` — source of truth for track definitions (id, name, roadmap path, notes dir, total units, unit label). Adding a track = adding a row.
- The resolved track's roadmap file exists (per the registry row) — source of truth for structure, topics, exercises, and next steps.
- The resolved track's notes directory exists (per the registry row).
- Note filename convention: `session-summary-{dd}-{mmm}-{yyyy}.md` with lowercase month, e.g. `session-summary-22-june-2026.md`.

### Invariants (must never be violated)

- NEVER overwrite or delete existing summary content. Same-date sessions append under a horizontal rule (`---`).
- NEVER fabricate quiz scores, dates, or completion status. Derive only from the roadmap and the notes.
- Track registry = source of truth for denominators and track definitions; roadmap = timeline truth; notes = progress truth.
- Only `session-summary-*.md` files count toward progress within the resolved track's notes dir.
- Never mix notes between tracks — SUMMARIZE always writes to the resolved track's notes dir.
- When notes show partial completion of a unit, suggest finishing that unit before moving on.
- Registry is the only source of track definitions — never hardcode a track's roadmap, notes dir, or total in the skill or blueprint.

### Non-goals

- Not a tutor — teaching happens in conversation; this agent only tracks, persists, and reports.
- Does not modify roadmaps or create quizzes.
- Does not create or maintain tracks outside the registry (add tracks by editing `learning/00-notes/tracks.md`).

---

## 4. Input

### Triggers

Two modes plus an optional track keyword, selected by trigger phrase:

| Mode | Trigger phrases |
|------|-----------------|
| REPORT | "continue learning", "continue our learning", "let's continue", "continue my learning", "where am I", "progress", "progress <track>", "/skill learning-progress" |
| SUMMARIZE | "summarize", "summarize today", "summarize learning", "save daily summary", "daily summary", "rangkuman", "ringkasan", "summarize <track>" |

Track keyword values are the registry ids and names: `sql`, `dq`, `de` (and any future registered id).

### Track resolution (order of precedence)

1. **Explicit keyword** in the trigger matching a registry id or name → that track.
2. **Most recently active** — the track whose notes dir has the newest `session-summary-*.md` modification time.
3. **Ask** — when no keyword is present and no track has prior activity, or the newest is ambiguous (tie), list the registered tracks and ask.

### Data sources (in priority order)

1. **Conversation content** — topics taught, exercises completed, errors + fixes, insights, progress updates, quiz scores.
2. **Track registry** — `learning/00-notes/tracks.md` (track id, name, roadmap path, notes dir, total units, unit label).
3. **Roadmap file** — the resolved track's structure, topics, exercises, milestones.
4. **Notes listing + latest summary** — prior position, quiz scores, in-progress unit.

### Extraction schema (what the agent pulls from the conversation)

- Unit identifiers (e.g. "Week 6 Day 4", "Unit 03", "Phase 2 Week 6")
- Topics covered / concepts learned
- Commands and example queries
- Practice exercises completed
- Errors encountered and how they were fixed
- Quiz scores
- Database or tools used (context-dependent)
- Status updates (e.g. "Unit 03 complete")

---

## 5. Output

### Artifacts (files)

- **SUMMARIZE mode:** create or append `<resolved notes dir>/session-summary-{date}.md` following the structured note template below; then emit a progress report.
- **REPORT mode:** no file changes (read-only); emits a progress report only.

### Structured note template

```markdown
# Summary: {Track Name} Learning Session

**Date:** {day} {month} {year}
**Track:** {track name}
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
## 📊 Learning Progress Report — {Track Name}
**Date:** {today}

### Statistics
- **Overall Progress:** {X} of {N} {unit_label}s ({Z}%)
- **Completed:** {X} · **Remaining:** {Y}

### Progress Visualization
{mermaid pie: "Completed (X units)" vs "Remaining (Y units)", N = registry total for the resolved track}

---

## 📚 Progress by {Structure}

### ✅ COMPLETED
| {Unit} | Topic |
|------|-------|

### 🔄 IN PROGRESS
**{Unit}:** {Topic} — unit breakdown with ✅ done, ⏳ Next, ❌ pending

### ❌ NOT YET STARTED
| {Unit} | Topic |
|-------|--------|

---

## Summary of Last Session
- {2-3 bullets}

## Next Up
- **Today:** {next unit/topic from the resolved track's roadmap}
- **Goal:** {what to accomplish}

### Ready to Continue?
Let me know when you want to start!
```

### Formatting rules

- Markdown output.
- Status emojis: ✅ complete, 🔄 in progress, ❌ pending, ⏳ next.
- Keep the summary concise but meaningful.
- The Mermaid pie chart renders in VSCode (Mermaid extension) or any Mermaid-capable viewer.
- The denominator N and the unit label come from the resolved track's registry row; never from a hardcoded value.

---

## 6. Workflow

### Track resolution

1. Read `learning/00-notes/tracks.md`.
2. Apply the precedence in Section 4 (explicit keyword → most recently active → ask).

### Shared report generator

Both modes end with this block:

1. Resolve the track (Section 6, Track resolution).
2. Read the resolved track's roadmap → structure and topics.
3. List `<resolved notes dir>/session-summary-*.md`, sort by date.
4. Determine: completed units, in-progress unit, quiz scores.
5. Calculate: progress % = completed units / registry total × 100.
6. Read the most recent summary for last-session bullets and next topic.
7. Emit the progress report (Section 5) + "Ready to continue?" prompt.

### SUMMARIZE mode

1. Extract topics from the conversation (Section 4 extraction schema).
2. Resolve the track.
3. Get current date → filename `{day}-{month}-{year}` (lowercase month).
4. List `<resolved notes dir>/`, find the most recent `session-summary-*.md`.
5. Decide: last summary date = today → append under `---` (preserve existing content); earlier → create new file.
6. Save the structured summary.
7. Run the shared report generator.

### REPORT mode

1. Run the shared report generator.
2. If notes show partial completion of a unit, suggest finishing that unit first.
3. Connect previous learnings to the next topic where possible.

---

## 7. Implementation Mapping

| File | Role |
|---|---|
| `agent-blueprints/01-learning-progress.md` | This canonical plan |
| `.opencode/skills/learning-progress/SKILL.md` | Thin skill file: frontmatter + triggers + pointer to this plan |
| `learning/00-notes/tracks.md` | Track registry — single source of truth for track definitions |
