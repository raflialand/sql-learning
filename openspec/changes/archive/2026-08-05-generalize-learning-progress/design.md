# Generalize Learning Progress — Design

## Overview

The change converts the hardcoded, single-track `sql-learning` skill into a registry-driven, multi-track `learning-progress` skill. All track-specific facts (roadmap path, notes dir, total units, unit label, structure) move out of the skill implementation and into a markdown table at `learning/00-notes/tracks.md`. The skill and its blueprint read that registry, resolve a target track (explicit keyword, or most recently active via latest-modified `session-summary-*.md`), and then run a generic report or summary generator parameterized by the resolved track. The skill folder is renamed to `.opencode/skills/learning-progress/`, the blueprint to `agent-blueprints/01-learning-progress.md`, and all project references are updated accordingly. Historical notes, roadmaps, and archived changes are untouched.

## Design Decisions

### Decision 1: Track registry as a plain markdown table, not code

**Choice**: Store track definitions in `learning/00-notes/tracks.md` as a markdown table (id, name, roadmap path, notes dir, total units, unit label, structure).
**Rationale**: The skill's purpose is tracking progress, not managing configuration. A human-editable markdown table is the least-effort way to add future tracks without touching code or skills, matches the repo's markdown-native documentation style, and is directly parseable by the skill at runtime.

### Decision 2: Most-recently-active track as the bare-trigger default

**Choice**: When no track keyword is given, the skill resolves the target track by comparing last-modified timestamps of `session-summary-*.md` files across all registered notes dirs; if exactly one track has prior activity it wins, if none have activity the skill asks, and if the latest-modified file is ambiguous the skill asks.
**Rationale**: Bare triggers ("continue learning", "summarize") must keep working as they do today — a user mid-SQL-track should not have to remember to type `progress sql`. Defaulting to the most recently active track preserves the current single-track UX while allowing multi-track; asking on ambiguity avoids silently tracking the wrong track.

### Decision 3: Generic report template driven by the registry row

**Choice**: The report emits track name, "X of N {unit}s (Z%)" where N and the unit label come from the registry, a Mermaid pie chart, completed/in-progress/not-started sections, last-session summary, and next topic read from that track's roadmap.
**Rationale**: The 84-day denominator and "Day" label were the only hardcoded SQL facts in the report; parameterizing them from the registry row makes the same generator correct for 13 units, 26 weeks, or any future track without branching on track id.

### Decision 4: Generic summary template drops the SQL-only "Database:" field

**Choice**: The SUMMARIZE note template keeps Date, Status, main topic, examples, takeaways, and next steps, and removes the `**Database:**` line that only made sense for SQL practice.
**Rationale**: The SQL track's database mention is conversation content, not a structural field; other tracks (Data Quality, Data Engineering) have no single database to record, so the field is dropped from the shared template.

### Decision 5: Rename is a move, not a copy

**Choice**: `git mv`-style semantics — `.opencode/skills/sql-learning/` becomes `.opencode/skills/learning-progress/` and `agent-blueprints/01-sql-learning.md` becomes `agent-blueprints/01-learning-progress.md`; the old paths are deleted, not duplicated.
**Rationale**: One skill, one blueprint. Leaving the old folder behind would create two registrations with competing behavior and confuse the available-skills index.

### Decision 6: DQ track re-framed as a registered 13-unit track

**Choice**: `learning/03-dq-learning/README.md` line 152 changes from "not part of the 84-day tracker" to "a 13-unit track tracked by learning-progress".
**Rationale**: The DQ module already has a structured 13-unit outline and a dedicated notes dir (`learning/00-notes/03-dq-progress/`); registering it as a track is a documentation truth update, not a change to the module's content or pacing.

## Target Structure

```
learning/00-notes/tracks.md                            ← CREATED: track registry (sql, dq, de rows)
learning/00-notes/01-de-progress/                      ← CREATED: empty notes dir for Data Engineering
.opencode/skills/sql-learning/                         ← REMOVED (moved)
.opencode/skills/learning-progress/SKILL.md            ← CREATED (from moved file): generalized skill
agent-blueprints/01-sql-learning.md                    ← REMOVED (moved)
agent-blueprints/01-learning-progress.md               ← CREATED (from moved file): generalized blueprint
AGENTS.md                                              ← MODIFIED: project identity, registry, directory map, skill references
README.md                                              ← MODIFIED: skill references, track registry, notes dirs
.opencode/agents/query-inspector.md                    ← MODIFIED: line 41 boundary reference to renamed skill/blueprint
openspec/specs/query-inspector/spec.md                 ← MODIFIED: Related Code + non-goals reference renamed skill/blueprint
learning/03-dq-learning/README.md                      ← MODIFIED: line 152 DQ track re-framing
openspec/changes/2026-08-05-generalize-learning-progress/specs/learning-progress/spec.md  ← CREATED: delta spec (ADDED)
openspec/changes/2026-08-05-generalize-learning-progress/specs/query-inspector/spec.md    ← CREATED: delta spec (MODIFIED)
```

Note: `openspec/specs/learning-progress/spec.md` is created from the delta during the archive step, not in implementation tasks. Historical `session-summary-*.md` files, roadmaps, and `openspec/changes/archive/` are untouched.

## Edge Cases

- **No track has prior activity**: Bare REPORT/SUMMARIZE triggers have no most-recently-active track; the skill asks the user which track to use instead of guessing.
- **Track keyword unknown**: A keyword that matches no registry id (e.g. "progress ml") results in a clarification prompt listing the registered track ids.
- **Registry missing or malformed**: The skill halts with a clear failure reason identifying `learning/00-notes/tracks.md` as the missing/invalid source of truth.
- **Registered notes dir empty**: The report shows 0 of N units (0%), all units not-started, and the first roadmap topic as next up — no fabricated progress.
- **Registered roadmap path missing**: The skill reports the missing roadmap path for the resolved track and cannot compute next topic.
- **Ambiguous latest-modified tie**: If the most recent `session-summary-*.md` timestamp is tied across tracks, the skill asks rather than silently picking.
- **Same-date session**: SUMMARIZE appends under a `---` separator, never overwriting existing content, exactly as the current invariant requires.

## Affected Specs

| Spec                                   | Change Type              |
| -------------------------------------- | ------------------------ |
| `specs/learning-progress/spec.md`      | ADDED (new capability)   |
| `specs/query-inspector/spec.md`        | MODIFIED                 |
