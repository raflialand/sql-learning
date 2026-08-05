# Add Self-Adjustment + ADR Protocol — Design

## Overview

The change makes the `learning-progress` skill self-documenting. A new `manifest.json` next to the skill records a version, last change date, ADR count, and SHA-256 hashes of the three files that define the skill: `.opencode/skills/learning-progress/SKILL.md`, `agent-blueprints/01-learning-progress.md`, and `openspec/specs/learning-progress/spec.md`. On invocation or at planning time the skill re-hashes those files and diffs against the manifest; any mismatch is reported as a "pending adjustment" and the skill enters a new SELF-CHECK/ADJUST mode. That mode runs four steps: DETECT (diff vs the manifest), ELICIT (collect ADR requirements from the user before the adjustment plan executes, at planning time before delegation to `@openspec-agent`), EXECUTE (implement the adjustment), and RECORD (write `adr/learning-progress/ADR-{NNN}-{slug}.md` per the `adr/AGENTS.md` template, then bump the manifest). The blueprint documents the architecture, `AGENTS.md` routing elicits ADR requirements for learning-progress planning intents, and `adr/AGENTS.md` permits skill-scoped ADR folders. The canonical spec gains the new SHALL requirements through the standard delta/archive flow.

## Design Decisions

### Decision 1: Manifest baseline with SHA-256 hashes over exactly three files

**Choice**: `.opencode/skills/learning-progress/manifest.json` holds `version`, `lastChange`, `adrCount`, and a `files` map of SHA-256 hashes for exactly `SKILL.md`, `agent-blueprints/01-learning-progress.md`, and `openspec/specs/learning-progress/spec.md`. `learning/00-notes/tracks.md` is excluded.
**Rationale**: Content hashing detects silent content edits that mtime-based checks miss, and a fixed three-file scope keeps the baseline stable and reviewable. `tracks.md` is data, not skill definition — hashing it would turn routine registry edits (adding a track row) into false "adjustments" and flood the ADR log.

### Decision 2: SELF-CHECK/ADJUST as a third skill mode

**Choice**: `SKILL.md` gains a third mode next to REPORT and SUMMARIZE with a 4-step protocol: DETECT → ELICIT → EXECUTE → RECORD. DETECT runs on invocation or at planning time; it only engages when a manifest diff exists.
**Rationale**: Normal REPORT/SUMMARIZE flow stays untouched when the skill is unchanged. Self-adjustment is triggered by evidence (a hash diff), not by a new trigger phrase, so it cannot disrupt the two existing modes' immediate-execution contract except in the specific case where a pending adjustment exists.

### Decision 3: Elicitation before execution, at planning time

**Choice**: The ADR requirements (title/slug, status, context/problem, decision, consequences/risks) are collected from the user BEFORE the adjustment plan executes, at planning time before delegation to `@openspec-agent`.
**Rationale**: An ADR must capture the decision rationale the user intends, not a post-hoc justification. Eliciting at planning time ensures the requirements exist before the plan is implemented and that `@openspec-agent` receives a decision that is already documented.

### Decision 4: Skill-scoped ADR folder

**Choice**: ADRs for the learning-progress skill live at `adr/learning-progress/ADR-{NNN}-{slug}.md`; the `adr/AGENTS.md` naming convention is extended from `adr/{agent-name}/` to also permit `adr/{skill-name}/`.
**Rationale**: Skill adjustments are self-referential decisions about the skill's own definition; scoping them under `adr/learning-progress/` keeps the ADR sequence independent from agent ADRs and mirrors the existing `adr/{agent-name}/` convention with minimal documentation change.

### Decision 5: Meta-ADR produced during implementation, not by the package

**Choice**: The change implementation writes `adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md` (status accepted, title "Establish self-adjustment + ADR protocol for the learning-progress skill") as its own output.
**Rationale**: The protocol must be self-demonstrating — the first ADR is the durable record of the protocol being established. Keeping it out of the change package preserves the package as a pure formalization artifact while giving the manifest a real `adrCount` baseline.

### Decision 6: Canonical spec changes via the standard delta/archive flow

**Choice**: The `learning-progress` spec changes are expressed as a delta (1 MODIFIED + 4 ADDED requirements) in this package and merged into `openspec/specs/learning-progress/spec.md` at archive time; the manifest's hash for the spec file is reconciled after the merge.
**Rationale**: Preserves OpenSpec's single-source-of-truth lifecycle. Because the canonical spec is one of the three manifest-tracked files, the post-archive reconciliation keeps the manifest accurate so the next invocation does not report a false pending adjustment.

## Target Structure

```
.opencode/skills/learning-progress/manifest.json              ← CREATED: detection baseline (version, lastChange, adrCount, SHA-256 files map)
.opencode/skills/learning-progress/SKILL.md                   ← MODIFIED: third mode SELF-CHECK/ADJUST (DETECT / ELICIT / EXECUTE / RECORD)
agent-blueprints/01-learning-progress.md                      ← MODIFIED: new "Self-Adjustment and ADR Protocol" section + Implementation Mapping rows
AGENTS.md                                                     ← MODIFIED: routing (elicit ADR requirements before @openspec-agent for learning-progress intents) + adr/ directory map entry
adr/AGENTS.md                                                 ← MODIFIED: naming convention permits skill-scoped folders (adr/{skill-name}/)
adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md  ← CREATED: meta-ADR (status accepted)
openspec/specs/learning-progress/spec.md                      ← MODIFIED at archive time from the delta (not in implementation tasks)
openspec/changes/2026-08-05-add-self-adjustment-adr-protocol/ ← CREATED: this change package (proposal.md, design.md, tasks.md, specs/learning-progress/spec.md)
```

## Edge Cases

- **Manifest missing**: Without `.opencode/skills/learning-progress/manifest.json` there is no baseline. The skill reports the missing manifest as a pending adjustment, runs ADR requirement elicitation, and re-establishes the baseline before normal operation.
- **Multiple tracked files changed at once**: A diff in two or all three manifest-tracked files is reported as a single pending adjustment and produces one ADR covering the combined change, not three ADRs.
- **`tracks.md` changes only**: Registry data edits are excluded from detection; the skill SHALL NOT flag them as adjustments and SHALL NOT require an ADR.
- **Incomplete elicitation**: If the user omits any required ADR field (title/slug, status, context/problem, decision, consequences/risks), the skill asks for the missing fields before execution rather than proceeding with an incomplete record.
- **ADR sequence collision**: The next ADR number derives from `adrCount` + 1; if existing ADR files in `adr/learning-progress/` have higher numbers than `adrCount`, the skill reconciles using the highest existing number to avoid overwrites.
- **Spec merged at archive changes the canonical file**: The manifest hash for `openspec/specs/learning-progress/spec.md` is reconciled after the archive merge (Step 4.3) so the next invocation does not report a false pending adjustment.
- **First invocation after implementation**: The manifest is bumped to reflect the final post-change state, so the first real detection run sees a clean baseline and no pending adjustment.

## Affected Specs

| Spec                              | Change Type                                  |
| --------------------------------- | -------------------------------------------- |
| `specs/learning-progress/spec.md` | MODIFIED (1 MODIFIED + 4 ADDED requirements) |
