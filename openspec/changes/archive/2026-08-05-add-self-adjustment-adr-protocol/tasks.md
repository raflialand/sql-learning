# Add Self-Adjustment + ADR Protocol — Implementation Tasks

## Phase 1: Manifest Baseline and Skill Mode

### Step 1.1: Create the manifest baseline

Create `.opencode/skills/learning-progress/manifest.json` with `version`, `lastChange`, `adrCount`, and a `files` map of SHA-256 hashes for exactly three files: `.opencode/skills/learning-progress/SKILL.md`, `agent-blueprints/01-learning-progress.md`, and `openspec/specs/learning-progress/spec.md`. Compute the hashes of the CURRENT files at creation time (e.g. PowerShell `Get-FileHash -Algorithm SHA256 -Path <file>`); do NOT include `learning/00-notes/tracks.md`.

```json
{
  "version": "1.0.0",
  "lastChange": "2026-08-05",
  "adrCount": 0,
  "files": {
    ".opencode/skills/learning-progress/SKILL.md": "<sha256 of current SKILL.md>",
    "agent-blueprints/01-learning-progress.md": "<sha256 of current blueprint>",
    "openspec/specs/learning-progress/spec.md": "<sha256 of current canonical spec>"
  }
}
```

**Verification**: `manifest.json` exists, contains exactly the three keys above in `files`, `adrCount` is `0`, and every hash matches `Get-FileHash -Algorithm SHA256` for the corresponding current file.

### Step 1.2: Add the SELF-CHECK/ADJUST mode to SKILL.md

Update `.opencode/skills/learning-progress/SKILL.md`:

- **Old** (frontmatter `description`): `Tracks progress across ANY learning track registered in learning/00-notes/tracks.md (SQL Fundamentals, Data Quality Engineer, Data Engineering). Two modes: REPORT (continue learning, let's continue, where am I, progress, progress <track>) shows current position, progress percentage vs the track's registry total, Mermaid pie chart, and next topic; SUMMARIZE (summarize, daily summary, rangkuman, ringkasan, summarize <track>) saves the session as a structured note in that track's notes dir. Bare triggers default to the most recently active track; ambiguous triggers ask. Executes immediately on trigger without asking for confirmation.`
- **New**: same description but with `Three modes: REPORT ...; SUMMARIZE ...; and SELF-CHECK/ADJUST (detects changes to the skill's own definition via manifest.json, elicits ADR requirements before an adjustment executes, and writes adr/learning-progress/ADR-{NNN}-{slug}.md after execution)`.
- Add a Quick Reference bullet:

  `- **Mode SELF-CHECK/ADJUST:** Run when a manifest diff is detected. DETECT — re-hash the three manifest-tracked files and diff against manifest.json; report differences as a pending adjustment. ELICIT — before the adjustment plan executes, ask the user for ADR requirements (title/slug, status, context/problem, decision, consequences/risks). EXECUTE — implement the adjustment. RECORD — write adr/learning-progress/ADR-{NNN}-{slug}.md per the adr/AGENTS.md template, then bump manifest.json (version bump, recomputed hashes, adrCount +1).`

- Add to Invariants:

  - `Manifest accuracy — after every adjustment, recompute the three file hashes and bump adrCount; never let manifest.json drift from the actual files.`
  - `learning/00-notes/tracks.md is data, not skill definition — never include it in the manifest files map and never flag registry edits as adjustments.`

**Verification**: `SKILL.md` frontmatter says `Three modes`, contains the SELF-CHECK/ADJUST Quick Reference bullet with all four steps (DETECT / ELICIT / EXECUTE / RECORD), and the new invariants mention manifest accuracy and the `tracks.md` exclusion.

## Phase 2: Blueprint, Routing, and ADR Conventions

### Step 2.1: Document the self-adjustment architecture in the blueprint

Update `agent-blueprints/01-learning-progress.md`:

- Insert a new section `## 7. Self-Adjustment and ADR Protocol` (after the existing Workflow section) documenting: the manifest file (`.opencode/skills/learning-progress/manifest.json`) as the detection baseline; the three hashed definition files and the `tracks.md` exclusion; the 4-step DETECT / ELICIT / EXECUTE / RECORD protocol; and the ADR lifecycle (`adr/learning-progress/ADR-{NNN}-{slug}.md` per the `adr/AGENTS.md` template, then the manifest bump).
- Renumber the existing `## 7. Implementation Mapping` to `## 8. Implementation Mapping`.
- Add rows to the Implementation Mapping table:

  | `learning/00-notes/tracks.md` | Track registry — data, excluded from adjustment detection |
  | `.opencode/skills/learning-progress/manifest.json` | Adjustment baseline (version, lastChange, adrCount, SHA-256 files map) |
  | `adr/learning-progress/` | Skill-scoped ADRs produced by SELF-CHECK/ADJUST |

**Verification**: The blueprint contains a `## 7. Self-Adjustment and ADR Protocol` section covering manifest, detection, elicitation, and ADR lifecycle; `## 8. Implementation Mapping` lists `manifest.json` and `adr/learning-progress/`; no section numbering is duplicated.

### Step 2.2: Update AGENTS.md routing and directory map

Update `AGENTS.md`:

- **Old** (Agent Routing paragraph): `When the intent is planning, the main agent SHALL delegate to `@openspec-agent`. When the intent is execution, the main agent SHALL delegate to the named agent or execute the task directly.`
- **New**: keep that sentence and add: `When a planning intent targets the learning-progress skill, the main agent SHALL first run SELF-CHECK/ADJUST to elicit ADR requirements from the user (DETECT/ELICIT), then delegate to `@openspec-agent`.`
- **Old** (directory map, `adr/` entry): `│   └── AGENTS.md          # ADR conventions and template`
- **New**: `│   ├── AGENTS.md          # ADR conventions and template` followed by `│   └── learning-progress/  # Skill-scoped ADRs (SELF-CHECK/ADJUST)`

**Verification**: `AGENTS.md` instructs the main agent to elicit ADR requirements for learning-progress planning intents before `@openspec-agent` delegation, and the directory map lists `adr/learning-progress/`.

### Step 2.3: Extend the adr/AGENTS.md naming convention

Update `adr/AGENTS.md`:

- **Old** (naming convention block):

  ```
  adr/{agent-name}/ADR-{NNN}-{slug}.md
  ```

- **New**:

  ```
  adr/{agent-name}/ADR-{NNN}-{slug}.md
  adr/{skill-name}/ADR-{NNN}-{slug}.md
  ```

- **Old**: `- `{agent-name}`: the name of the agent that created the ADR, matching its `.opencode/agents/` filename (e.g. `openspec-agent`)`
- **New**: keep the agent bullet and add: `- `{skill-name}`: the name of a skill that records adjustments to its own definition, matching its `.opencode/skills/` folder (e.g. `learning-progress`)`
- **Old**: `- `{NNN}`: zero-padded sequential number scoped to the agent directory (e.g. `001`, `012`). Each agent maintains its own sequence.`
- **New**: `- `{NNN}`: zero-padded sequential number scoped to the directory (e.g. `001`, `012`). Each agent or skill directory maintains its own sequence.`
- Add a sentence in the Purpose section: `Skills that self-adjust (SELF-CHECK/ADJUST mode) write their decision records under `adr/{skill-name}/` (e.g. `adr/learning-progress/`).`

**Verification**: `adr/AGENTS.md` documents both `{agent-name}` and `{skill-name}` variants, and `{NNN}` is described as scoped to the directory.

## Phase 3: Meta-ADR and Manifest Bump

### Step 3.1: Write the meta-ADR

Create `adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md` per the `adr/AGENTS.md` template with the exact content below (title and status binding):

```markdown
# ADR-001: Establish self-adjustment + ADR protocol for the learning-progress skill

## Status

accepted

## Context

The `learning-progress` skill tracks progress across learning tracks but has no durable decision record for its own changes. When the skill's definition (SKILL.md, blueprint, or canonical spec) changes, the rationale, context, and consequences are lost — there is no baseline to detect drift, no pre-change elicitation of intent, and no post-change record of why the change was made.

## Decision

Add manifest-based detection plus a SELF-CHECK/ADJUST mode and skill-scoped ADRs in `adr/learning-progress/`:

- A `manifest.json` baseline records SHA-256 hashes for exactly three definition files (`SKILL.md`, `agent-blueprints/01-learning-progress.md`, `openspec/specs/learning-progress/spec.md`); on invocation or at planning time the skill re-hashes them and reports any diff as a pending adjustment.
- SELF-CHECK/ADJUST runs four steps: DETECT (diff vs the manifest), ELICIT (collect ADR requirements from the user before execution), EXECUTE (implement the adjustment), RECORD (write `adr/learning-progress/ADR-{NNN}-{slug}.md` per the adr/AGENTS.md template, then bump the manifest).
- `learning/00-notes/tracks.md` is excluded from detection — it is data, not skill definition.

## Consequences

- Durable rationale per change: every adjustment to the skill is captured in a skill-scoped ADR with the user's elicited requirements and what actually changed.
- The manifest must be kept accurate — a stale hash falsely reports a pending adjustment, so every adjustment must recompute the file hashes and bump `adrCount`.
- An extra elicitation step precedes each skill change — adjustments are no longer silent, and a planning intent for the learning-progress skill requires the user's ADR requirements before delegation to `@openspec-agent`.
```

**Verification**: `adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md` exists with Status `accepted` and the Context / Decision / Consequences sections per the `adr/AGENTS.md` template.

### Step 3.2: Bump the manifest

Update `.opencode/skills/learning-progress/manifest.json` to reflect the executed change:

- **Old** (baseline): `"version": "1.0.0"`, `"lastChange": "2026-08-05"`, `"adrCount": 0`, hashes of the pre-change files.
- **New**: `"version": "1.1.0"`, `"lastChange": "2026-08-05"`, `"adrCount": 1`, recomputed SHA-256 hashes for `.opencode/skills/learning-progress/SKILL.md` and `agent-blueprints/01-learning-progress.md` as they now stand. The hash for `openspec/specs/learning-progress/spec.md` is reconciled at Step 4.3 after the archive merge.

**Verification**: `manifest.json` has `version 1.1.0`, `adrCount 1`, and the SKILL.md and blueprint hashes match `Get-FileHash -Algorithm SHA256` on the modified files.

## Phase 4: Validation

### Step 4.1: Verify the protocol reads the right files

Confirm that the SKILL.md SELF-CHECK/ADJUST mode references exactly three tracked files and the `tracks.md` exclusion.

**Verification**: The SKILL.md Quick Reference and the blueprint section reference only `.opencode/skills/learning-progress/SKILL.md`, `agent-blueprints/01-learning-progress.md`, and `openspec/specs/learning-progress/spec.md` as hashed files; `learning/00-notes/tracks.md` is explicitly excluded.

### Step 4.2: Verify ADR template compliance

**Verification**: `adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md` matches the `adr/AGENTS.md` template (Status / Context / Decision / Consequences), status is `accepted`, and its filename follows `ADR-{NNN}-{slug}.md` with `001` and the kebab-case slug.

### Step 4.3: Reconcile the manifest after the archive merge

After this change is archived (the delta is merged into `openspec/specs/learning-progress/spec.md`), recompute the SHA-256 hash of the canonical spec and update `manifest.json` if it changed.

**Verification**: `Get-FileHash -Algorithm SHA256` on `openspec/specs/learning-progress/spec.md` equals the value in `manifest.json`, so the next invocation reports no false pending adjustment.

## Summary of Changes

| Category         | Before                                                        | After                                                         |
| ---------------- | ------------------------------------------------------------- | ------------------------------------------------------------- |
| Manifest         | (none)                                                        | `.opencode/skills/learning-progress/manifest.json` — CREATED (baseline 1.0.0, adrCount 0; bumped to 1.1.0, adrCount 1) |
| Skill            | two modes (REPORT, SUMMARIZE)                                 | `.opencode/skills/learning-progress/SKILL.md` — MODIFIED (third mode SELF-CHECK/ADJUST: DETECT / ELICIT / EXECUTE / RECORD + manifest invariants) |
| Blueprint        | no self-adjustment documentation                              | `agent-blueprints/01-learning-progress.md` — MODIFIED (new `## 7. Self-Adjustment and ADR Protocol`; Implementation Mapping renumbered to 8 with manifest + adr rows) |
| Routing          | planning intents delegate directly to `@openspec-agent`       | `AGENTS.md` — MODIFIED (learning-progress planning intents elicit ADR requirements first; `adr/learning-progress/` in directory map) |
| ADR conventions  | `adr/{agent-name}/` only                                      | `adr/AGENTS.md` — MODIFIED (permits `adr/{skill-name}/`, e.g. `learning-progress`) |
| Meta-ADR         | (none)                                                        | `adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md` — CREATED (status accepted) |
| Canonical spec   | `openspec/specs/learning-progress/spec.md` (existing 9 requirements) | MODIFIED at archive time from the delta (1 MODIFIED + 4 ADDED requirements) — not in implementation tasks |
| Delta spec       | (none)                                                        | `openspec/changes/2026-08-05-add-self-adjustment-adr-protocol/specs/learning-progress/spec.md` — CREATED |
