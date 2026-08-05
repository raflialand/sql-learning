---
name: learning-progress
description: Tracks progress across ANY learning track registered in learning/00-notes/tracks.md (SQL Fundamentals, Data Quality Engineer, Data Engineering). Two modes: REPORT (continue learning, let's continue, where am I, progress, progress <track>) shows current position, progress percentage vs the track's registry total, Mermaid pie chart, and next topic; SUMMARIZE (summarize, daily summary, rangkuman, ringkasan, summarize <track>) saves the session as a structured note in that track's notes dir. Bare triggers default to the most recently active track; ambiguous triggers ask. Executes immediately on trigger without asking for confirmation.
---

# Learning Progress Skill

Canonical agent plan: `agent-blueprints/01-learning-progress.md`. Read it for the full spec (Intention, Goals, Requirements, Input, Output, Workflow) and follow it exactly.

## Quick Reference

- **Track resolution:** Read `learning/00-notes/tracks.md`. If the trigger includes a track keyword (sql/dq/de or name), use that track. Otherwise pick the track with the most recently modified `session-summary-*.md` across all registered notes dirs. If none or tied, ask the user.
- **Mode REPORT:** Run the shared report generator — resolve track, read its roadmap, scan `<notes dir>/session-summary-*.md`, compute progress (% against the track's registry total), emit stats + Mermaid pie chart + completed/in-progress/pending tables + last-session summary + next topic, end with "Ready to continue?"
- **Mode SUMMARIZE:** Extract topics from the conversation, save/append `<resolved notes dir>/session-summary-{day}-{month}-{year}.md` (lowercase month), then run the shared report generator.

## Invariants

- Never overwrite or delete existing summary content — same-date sessions append under `---`.
- Never fabricate quiz scores, dates, or completion status.
- Roadmap = timeline truth; notes = progress truth.
- Only `session-summary-*.md` counts toward progress.
- Never mix notes between tracks — write to the resolved track's notes dir only.
- Execute immediately on trigger; do not ask for confirmation (except track clarification).
