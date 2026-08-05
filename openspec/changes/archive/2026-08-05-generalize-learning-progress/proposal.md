# Generalize Learning Progress

## Problem Statement

The `sql-learning` skill (`.opencode/skills/sql-learning/SKILL.md`) is hardcoded to a single track: the 12-week / 84-day SQL roadmap (`learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md`), a fixed notes directory (`learning/00-notes/02-sql-progress/`), a fixed 84-day denominator, and a weeks/days report format. All of this is embedded directly in the skill file and its blueprint, so the tracker cannot follow a different learning track without editing the skill itself. The project already runs multiple tracks — SQL Fundamentals (84 days), Data Quality Engineer (13 units), and Data Engineering (26 weeks) — but only the SQL track can be tracked today. Once the SQL roadmap finishes, the tracker has nothing to report and the project "feels done". The user wants a progress tracker that works across ANY learning track (SQL, Data Quality, Data Engineering, and future ones) without hardcoding track-specific values in the skill.

## Proposed Solution

Generalize the single-track `sql-learning` skill into a multi-track `learning-progress` skill:

1. **Track registry** — a new file `learning/00-notes/tracks.md` becomes the single source of truth. It is a markdown table with one row per track: id, name, roadmap path, notes dir, total units, unit label, structure. Initial rows: `sql` (SQL Fundamentals, 84 units, "Day"), `dq` (Data Quality Engineer, 13 units, "Unit"), `de` (Data Engineering, 26 units, "Week").
2. **Skill rename** — `.opencode/skills/sql-learning/SKILL.md` moves to `.opencode/skills/learning-progress/SKILL.md` (old folder deleted). The new description supports both modes plus an optional track keyword: REPORT shows position, % vs the track's registry total, Mermaid pie, and next topic; SUMMARIZE appends a session note to that track's notes dir. Bare triggers default to the most recently active track (latest modified `session-summary-*.md` across registered notes dirs); ambiguous triggers ask the user. Executes immediately without confirmation.
3. **Blueprint rename** — `agent-blueprints/01-sql-learning.md` moves to `agent-blueprints/01-learning-progress.md`, rewritten generic (Intention, Goals, Requirements, Input, Output, Workflow, Implementation Mapping) with track resolution via the registry, a generic report template, and a generic summary template.
4. **Reference updates** — `AGENTS.md`, `README.md`, `.opencode/agents/query-inspector.md`, `openspec/specs/query-inspector/spec.md`, and `learning/03-dq-learning/README.md` are updated to reference `learning-progress` and the track registry.
5. **New directory** — `learning/00-notes/01-de-progress/` is created (empty) so Data Engineering session summaries have a home.

## Scope

### In scope

- Creating `learning/00-notes/tracks.md` with the three initial track rows.
- Renaming the skill folder to `.opencode/skills/learning-progress/` and generalizing its frontmatter and quick reference.
- Renaming the blueprint to `agent-blueprints/01-learning-progress.md` and rewriting it generically.
- Creating the empty `learning/00-notes/01-de-progress/` directory.
- Updating references in `AGENTS.md`, `README.md`, `.opencode/agents/query-inspector.md`, `openspec/specs/query-inspector/spec.md`, and `learning/03-dq-learning/README.md`.
- Adding the `learning-progress` capability spec (delta spec in this change; canonical spec created at archive time).
- Modifying the `query-inspector` capability spec to reference the renamed skill and blueprint.

### Out of scope

- Editing historical `session-summary-*.md` files or any existing notes content.
- Editing or renumbering existing roadmaps.
- Modifying archived changes under `openspec/changes/archive/`.
- Making any git commits.
- Adding new tracks beyond the three initial registry rows (future tracks are added by editing `tracks.md` in a later change).

## Capabilities

### New Capabilities

- `learning-progress`

### Modified Capabilities

- `query-inspector` (dependency declarations and related-code references updated to the renamed skill/blueprint)

## Value Proposition

After this change, progress tracking is generic and registry-driven. The same skill and blueprint track SQL Fundamentals, Data Quality Engineer, and Data Engineering — and any future track is added by appending a row to `tracks.md` with no skill edits. The tracker no longer "finishes" when the SQL roadmap ends: every registered track reports its own position, percentage, pie chart, and next topic. Notes for each track land in its own directory, and ambiguous triggers are resolved either by the most recently active track or by asking the user.
