---
name: sql-learning
description: Tracks progress through the 3-month SQL learning roadmap (12 weeks, 84 days). Two modes: REPORT (continue learning, let's continue, where am I, progress) shows current position, progress percentage, Mermaid pie chart, and next topic; SUMMARIZE (summarize, daily summary, rangkuman, ringkasan) saves the session as a structured note in learning/00-notes/. Executes immediately on trigger without asking for confirmation.
---

# SQL Learning Skill

Canonical agent plan: `agent-blueprints/01-sql-learning.md`. Read it for the full spec (Intention, Goals, Requirements, Input, Output, Workflow) and follow it exactly.

## Quick Reference

- **Mode REPORT:** Run the shared report generator — read roadmap, scan `learning/00-notes/session-summary-*.md`, compute progress (84-day denominator), emit stats + Mermaid pie chart + completed/in-progress/pending tables + last-session summary + next topic, end with "Ready to continue?"
- **Mode SUMMARIZE:** Extract topics from the conversation, save/append `learning/00-notes/session-summary-{day}-{month}-{year}.md` (lowercase month), then run the shared report generator.

## Invariants

- Never overwrite or delete existing summary content — same-date sessions append under `---`.
- Never fabricate quiz scores, dates, or completion status.
- Roadmap = timeline truth; notes = progress truth.
- Only `session-summary-*.md` counts toward progress.
- Execute immediately on trigger; do not ask for confirmation.
