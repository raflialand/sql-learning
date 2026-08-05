# Generalize Learning Progress — Implementation Tasks

## Phase 1: Track Registry and Notes Directory

### Step 1.1: Create the track registry

Create `learning/00-notes/tracks.md` with the three initial track rows. Column headers: `id`, `name`, `roadmap`, `notes dir`, `total units`, `unit label`.

```markdown
# Learning Tracks Registry

Single source of truth for all learning tracks tracked by the `learning-progress` skill. Add a row for every new track; do not edit the skill or blueprint to add tracks.

| id | name | roadmap | notes dir | total units | unit label |
| --- | --- | --- | --- | --- | --- |
| sql | SQL Fundamentals | learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md | learning/00-notes/02-sql-progress/ | 84 | Day |
| dq | Data Quality Engineer | learning/03-dq-learning/README.md | learning/00-notes/03-dq-progress/ | 13 | Unit |
| de | Data Engineering | learning/01-de-learning/data-engineering-roadmap-6months.md | learning/00-notes/01-de-progress/ | 26 | Week |
```

**Verification**: `learning/00-notes/tracks.md` exists and contains exactly the `sql`, `dq`, and `de` rows with the paths above.

### Step 1.2: Create the Data Engineering notes directory

Create the empty directory `learning/00-notes/01-de-progress/`.

**Verification**: `learning/00-notes/01-de-progress/` exists and contains no files (optionally a `.gitkeep`).

## Phase 2: Skill and Blueprint Renames

### Step 2.1: Move the skill folder and generalize the skill

Move `.opencode/skills/sql-learning/` to `.opencode/skills/learning-progress/` (remove the old folder, e.g. `git mv` if tracked, else `Move-Item`), then rewrite `.opencode/skills/learning-progress/SKILL.md`:

- **Old** frontmatter `name` and `description`:
  - `name: sql-learning`
  - description that says "3-month SQL learning roadmap (12 weeks, 84 days)" and hardcodes `learning/00-notes/02-sql-progress/`
- **New** frontmatter:
  - `name: learning-progress`
  - description: "Tracks progress across ANY learning track registered in `learning/00-notes/tracks.md` (SQL Fundamentals, Data Quality Engineer, Data Engineering). Two modes: REPORT (continue learning, let's continue, where am I, progress, progress <track>) shows current position, progress percentage vs the track's registry total, Mermaid pie chart, and next topic; SUMMARIZE (summarize, daily summary, rangkuman, ringkasan, summarize <track>) saves the session as a structured note in that track's notes dir. Bare triggers default to the most recently active track; ambiguous triggers ask. Executes immediately on trigger without asking for confirmation."

Replace the body:
- **Old**: `Canonical agent plan: \`agent-blueprints/01-sql-learning.md\`.`
- **New**: `Canonical agent plan: \`agent-blueprints/01-learning-progress.md\`.`
- **Old**: "Mode REPORT" bullet hardcodes the roadmap path and 84-day denominator.
- **New**: "Mode REPORT" bullet reads the resolved track's roadmap and notes dir from the registry and uses the track's registry total as the denominator.
- **Old**: "Mode SUMMARIZE" bullet hardcodes `learning/00-notes/02-sql-progress/`.
- **New**: "Mode SUMMARIZE" bullet saves to the resolved track's notes dir.
- Add a "Track resolution" bullet: read `learning/00-notes/tracks.md`; use a trigger track keyword if present; otherwise pick the track with the most recently modified `session-summary-*.md` across all registered notes dirs; if none or tied, ask the user.
- Keep all five invariants unchanged, extending the last to "(except track clarification)".

**Verification**: `.opencode/skills/sql-learning/` no longer exists, `.opencode/skills/learning-progress/SKILL.md` exists, contains `name: learning-progress`, references `tracks.md` and `agent-blueprints/01-learning-progress.md`, and contains no hardcoded roadmap path, 84-day denominator, or `02-sql-progress` reference.

### Step 2.2: Move the blueprint and rewrite generically

Move `agent-blueprints/01-sql-learning.md` to `agent-blueprints/01-learning-progress.md` (remove the old file), then rewrite it generically. The new blueprint SHALL keep the sections Intention, Goals, Requirements, Input, Output, Workflow, and Implementation Mapping with these changes:

- **Intention**: describe multi-track progress tracking (SQL Fundamentals, Data Quality Engineer, Data Engineering) instead of only the 84-day SQL roadmap; state the registry as the source of truth for track definitions.
- **Goals**: keep G1–G5 intent but generalize denominators ("the resolved track's registry total" instead of "84-day / 12-week denominator").
- **Requirements / Prerequisites**: require `learning/00-notes/tracks.md` to exist; per-track roadmap and notes dir resolved from the registry.
- **Input / Triggers**: add track keywords (`progress <track>`, `summarize <track>`); document bare-trigger resolution (most recently active track) and the ask-on-ambiguity behavior.
- **Output / Report template**: replace "X of 84 days ({Z}%)" with "X of N {unit}s (Z%)" where N and the unit label come from the registry; include track name in the header; next topic read from the resolved track's roadmap.
- **Output / Summary template**: drop the SQL-only `**Database:**` field; keep Date, Status, main topic, examples, takeaways, and next steps.
- **Implementation Mapping**: rename the skill row to `.opencode/skills/learning-progress/SKILL.md` and the blueprint row to `agent-blueprints/01-learning-progress.md`.

**Verification**: `agent-blueprints/01-sql-learning.md` no longer exists, `agent-blueprints/01-learning-progress.md` exists, contains all seven sections, references `tracks.md` and `.opencode/skills/learning-progress/SKILL.md`, and contains no "84 days" or "Database:" template field.

## Phase 3: Reference Updates

### Step 3.1: Update `AGENTS.md` project identity

- **Old**: `sql-learning is a 3-month, 12-week SQL learning environment. Its execution domain is driven by the \`sql-learning\` skill (\`.opencode/skills/sql-learning/\`) and the canonical agent plan (\`agent-blueprints/01-sql-learning.md\`). It also uses the OpenSpec methodology for spec-driven, plan-first changes to project capabilities.`
- **New**: `sql-learning is a multi-track learning environment (SQL Fundamentals, Data Quality Engineer, Data Engineering). Its execution domain is driven by the \`learning-progress\` skill (\`.opencode/skills/learning-progress/\`), the canonical agent plan (\`agent-blueprints/01-learning-progress.md\`), and the track registry (\`learning/00-notes/tracks.md\`). It also uses the OpenSpec methodology for spec-driven, plan-first changes to project capabilities.`

**Verification**: The `## Project Identity` paragraph references `learning-progress`, `01-learning-progress.md`, and `learning/00-notes/tracks.md`, and no longer references `.opencode/skills/sql-learning/`.

### Step 3.2: Update `AGENTS.md` domain agents note and directory map

- **Old**: `The \`sql-learning\` execution capability is defined in \`.opencode/skills/sql-learning/\` and \`agent-blueprints/01-sql-learning.md\`.`
- **New**: `The \`learning-progress\` execution capability is defined in \`.opencode/skills/learning-progress/\`, \`agent-blueprints/01-learning-progress.md\`, and the track registry \`learning/00-notes/tracks.md\`.`
- **Old** (directory map): `│   └── skills/            # Skill definitions (e.g. sql-learning)`
- **New** (directory map): `│   └── skills/            # Skill definitions (e.g. learning-progress)`
- **Old** (directory map): `├── learning/              # Learning material and progress notes`
- **New** (directory map): `├── learning/              # Learning material and progress notes (track registry: learning/00-notes/tracks.md)`

**Verification**: `AGENTS.md` contains no remaining `sql-learning` skill references (`.opencode/skills/sql-learning/`, `01-sql-learning.md`) and lists the registry in the directory map.

### Step 3.3: Update `README.md`

- **Old**: `tracked automatically by an opencode skill (\`sql-learning\`)`
- **New**: `tracked automatically by an opencode skill (\`learning-progress\`)`
- **Old**: `**Automatic progress reporting** — each session saves a structured note (\`learning/00-notes/02-sql-progress/session-summary-*.md\`), and the skill computes completed days/weeks as a percentage of the 84-day plan, with a Mermaid progress chart.`
- **New**: `**Automatic progress reporting** — the \`learning-progress\` skill tracks every registered learning track (SQL Fundamentals, Data Quality Engineer, Data Engineering) via \`learning/00-notes/tracks.md\`; each session saves a structured note in that track's notes dir (\`session-summary-*.md\`), and the skill computes completed units as a percentage of the track's registry total, with a Mermaid progress chart.`
- **Old**: `**Two complementary learning tracks**: a 6-month data engineering roadmap (\`learning/01-de-learning/\`) and a standalone MySQL-based Data Quality Engineer module (\`learning/03-dq-learning/\`, 13 self-paced units against a purpose-built "dirty" dataset).`
- **New**: `**Three registered learning tracks** in \`learning/00-notes/tracks.md\`: SQL Fundamentals (84 units), Data Quality Engineer (13 units, MySQL-based against a purpose-built "dirty" dataset), and Data Engineering (26 weeks).`
- **Old** (directory map): `│   ├── 00-notes/           # Learning notes — excluded from numbering rules` followed by `│   │   └── 02-sql-progress/      # Daily session summaries (progress truth)`
- **New** (directory map): `│   ├── 00-notes/           # Learning notes — excluded from numbering rules; tracks.md is the track registry` followed by `│   │   ├── tracks.md           # Track registry (single source of truth)`, `│   │   ├── 01-de-progress/     # Data Engineering session summaries`, `│   │   └── 02-sql-progress/    # SQL session summaries (progress truth)`, and `│   │   └── 03-dq-progress/     # Data Quality session summaries`
- **Old** (directory map): `│   ├── 01-sql-learning.md     # SQL learning execution plan`
- **New** (directory map): `│   ├── 01-learning-progress.md # Multi-track learning progress plan`
- **Old**: `The \`sql-learning\` skill (\`.opencode/skills/sql-learning/SKILL.md\`) executes on two trigger modes:`
- **New**: `The \`learning-progress\` skill (\`.opencode/skills/learning-progress/SKILL.md\`) executes on two trigger modes, optionally scoped to a track keyword (\`progress <track>\`, \`summarize <track>\`); bare triggers default to the most recently active track:`
- **Old** (progress rules): `Progress = completed days ÷ 84 days (12 weeks × 7 days).`
- **New** (progress rules): `Progress = completed units ÷ the track's total units from \`learning/00-notes/tracks.md\`.`
- **Old** (Prerequisites): `opencode — for the \`sql-learning\` skill and \`openspec-agent\` planning workflow`
- **New** (Prerequisites): `opencode — for the \`learning-progress\` skill and \`openspec-agent\` planning workflow`

**Verification**: `README.md` references `learning-progress` throughout, mentions `tracks.md` and the three registered tracks, and contains no `sql-learning` skill references (`.opencode/skills/sql-learning/SKILL.md`, `01-sql-learning.md`).

### Step 3.4: Update `.opencode/agents/query-inspector.md`

- **Old**: `- Modifying the \`sql-learning\` skill or the agent blueprint (\`agent-blueprints/01-sql-learning.md\`).`
- **New**: `- Modifying the \`learning-progress\` skill or the agent blueprint (\`agent-blueprints/01-learning-progress.md\`).`

**Verification**: `.opencode/agents/query-inspector.md` line 41 references `learning-progress` and `01-learning-progress.md`.

### Step 3.5: Update `openspec/specs/query-inspector/spec.md` (Related Code and non-goals)

Apply direct edits to the non-requirement sections (the Cross-Capability Dependency requirement itself is merged from the delta at archive time):

- **Old** (Boundaries, Out of scope): `- Modifying the \`sql-learning\` skill (\`.opencode/skills/sql-learning/\`) or the agent blueprint (\`agent-blueprints/01-sql-learning.md\`).`
- **New** (Boundaries, Out of scope): `- Modifying the \`learning-progress\` skill (\`.opencode/skills/learning-progress/\`) or the agent blueprint (\`agent-blueprints/01-learning-progress.md\`).`
- **Old** (Related Code): `- \`.opencode/skills/sql-learning/\` — the sql-learning execution domain skill`
- **New** (Related Code): `- \`.opencode/skills/learning-progress/\` — the learning-progress execution domain skill`
- **Old** (Related Code): `- \`agent-blueprints/01-sql-learning.md\` — the canonical agent plan`
- **New** (Related Code): `- \`agent-blueprints/01-learning-progress.md\` — the canonical agent plan`

**Verification**: `openspec/specs/query-inspector/spec.md` contains no `sql-learning` skill or `01-sql-learning.md` references outside the requirement text (which is replaced by the delta merge).

### Step 3.6: Update `learning/03-dq-learning/README.md`

- **Old**: `The \`sql-learning\` skill tracks the 12-week **SQLite** roadmap. This module is **MySQL-native, self-paced, and standalone** — it is not part of the 84-day tracker. Treat it as a focused specialization after you have solid SQL fundamentals.`
- **New**: `The \`learning-progress\` skill tracks this module as a **13-unit** track registered in \`learning/00-notes/tracks.md\`. The module is **MySQL-native and self-paced**; treat it as a focused specialization after you have solid SQL fundamentals.`

**Verification**: `learning/03-dq-learning/README.md` no longer says DQ is "not part of the 84-day tracker" and references `tracks.md` and `learning-progress`.

## Phase 4: Validation

### Step 4.1: Verify no stale skill references remain

Search the project for `sql-learning` skill references outside `learning/` content files and `openspec/changes/archive/`.

**Verification**: `grep` for `.opencode/skills/sql-learning/`, `01-sql-learning.md`, and "the `sql-learning` skill" returns no matches in `AGENTS.md`, `README.md`, `.opencode/agents/query-inspector.md`, `openspec/specs/query-inspector/spec.md`, and `learning/03-dq-learning/README.md`.

### Step 4.2: Verify the registry resolves all three tracks

Confirm every path referenced in `learning/00-notes/tracks.md` exists.

**Verification**: The following paths exist: `learning/02-sql-learning/sql-roadmaps/sql-learning-roadmap-3months.md`, `learning/03-dq-learning/README.md`, `learning/01-de-learning/data-engineering-roadmap-6months.md`, `learning/00-notes/02-sql-progress/`, `learning/00-notes/03-dq-progress/`, `learning/00-notes/01-de-progress/`.

## Summary of Changes

| Category   | Before            | After             |
| ---------- | ----------------- | ----------------- |
| Track registry | (none) | `learning/00-notes/tracks.md` — CREATED with `sql`, `dq`, `de` rows |
| Notes dir | (none) | `learning/00-notes/01-de-progress/` — CREATED (empty) |
| Skill | `.opencode/skills/sql-learning/SKILL.md` | `.opencode/skills/learning-progress/SKILL.md` — MOVED + generalized (registry-driven, track keyword, most-recently-active default) |
| Blueprint | `agent-blueprints/01-sql-learning.md` | `agent-blueprints/01-learning-progress.md` — MOVED + rewritten generic (report template "X of N {unit}s (Z%)", summary template without "Database:" field) |
| Agent routing | references `sql-learning` in `AGENTS.md` | `AGENTS.md` — MODIFIED (project identity, domain agents note, directory map) |
| README | references `sql-learning` skill | `README.md` — MODIFIED (skill references, track registry, notes dirs, progress rules) |
| Query-inspector agent | boundary references `sql-learning`/`01-sql-learning.md` | `.opencode/agents/query-inspector.md` — MODIFIED (line 41) |
| Query-inspector spec | Related Code + non-goals reference `sql-learning` | `openspec/specs/query-inspector/spec.md` — MODIFIED (Related Code + non-goals; requirement merged from delta at archive) |
| DQ README | "not part of the 84-day tracker" | `learning/03-dq-learning/README.md` — MODIFIED (13-unit registered track) |
| Delta specs | (none) | `openspec/changes/2026-08-05-generalize-learning-progress/specs/learning-progress/spec.md` — CREATED (ADDED); `.../specs/query-inspector/spec.md` — CREATED (MODIFIED) |
| Canonical spec | (none) | `openspec/specs/learning-progress/spec.md` — CREATED at archive time from delta (not in tasks) |
