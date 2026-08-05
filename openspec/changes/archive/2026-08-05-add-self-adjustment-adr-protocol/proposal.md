# Add Self-Adjustment + ADR Protocol

## Problem Statement

The `learning-progress` skill (`.opencode/skills/learning-progress/SKILL.md`, blueprint `agent-blueprints/01-learning-progress.md`, canonical spec `openspec/specs/learning-progress/spec.md`) tracks progress across learning tracks but has no mechanism to record how or why the skill itself is adjusted. When its own definition changes — the skill file, the blueprint, or the canonical spec — the change happens silently: there is no baseline to detect drift between implementation and specification, no pre-change collection of the user's intent, and no durable decision record of the rationale, context, and consequences. The user wants the skill self-documenting: it detects changes to its own definition, collects ADR requirements from the user BEFORE a change executes, and writes an Architecture Decision Record AFTER execution.

## Proposed Solution

Add a self-adjustment + ADR protocol to the `learning-progress` skill, formalized as a decided design:

1. **Manifest baseline** — a new `.opencode/skills/learning-progress/manifest.json` records `version`, `lastChange`, `adrCount`, and a SHA-256 `files` map for exactly three definition files: `SKILL.md`, `agent-blueprints/01-learning-progress.md`, `openspec/specs/learning-progress/spec.md`. On invocation the skill re-hashes those files and diffs against the manifest. `learning/00-notes/tracks.md` is excluded (it is data, not skill definition).
2. **SELF-CHECK/ADJUST mode** — a third mode in `SKILL.md` with a 4-step protocol: DETECT (diff vs the manifest, report a "pending adjustment"), ELICIT (ask the user for ADR requirements before the adjustment executes, at planning time), EXECUTE (implement the adjustment), RECORD (write `adr/learning-progress/ADR-{NNN}-{slug}.md` per the `adr/AGENTS.md` template, then bump the manifest).
3. **ADR location** — skill-scoped `adr/learning-progress/`; `adr/AGENTS.md` naming convention is extended to permit skill-scoped folders.
4. **Routing** — `AGENTS.md` is updated so a planning intent targeting the learning-progress skill elicits ADR requirements before delegating to `@openspec-agent`.
5. **Spec** — new SHALL requirements are added to the `learning-progress` capability spec (adjustment detection, elicitation before execution, ADR creation after execution, manifest accuracy), expressed as a delta spec in this package.
6. **Blueprint** — the self-adjustment architecture is documented in `agent-blueprints/01-learning-progress.md`.
7. **Meta-ADR** — after execution the protocol produces `adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md` (status accepted), created during implementation, not by this change package.

## Scope

### In scope

- Creating `.opencode/skills/learning-progress/manifest.json` with the initial baseline (version, lastChange, adrCount, SHA-256 hashes for the three definition files).
- Adding the third SELF-CHECK/ADJUST mode (DETECT / ELICIT / EXECUTE / RECORD) to `.opencode/skills/learning-progress/SKILL.md`.
- Documenting the self-adjustment architecture in `agent-blueprints/01-learning-progress.md` (new section + Implementation Mapping rows).
- Updating `AGENTS.md` routing so learning-progress planning intents elicit ADR requirements before `@openspec-agent` delegation, and updating the `adr/` directory map entry.
- Extending the `adr/AGENTS.md` naming convention to permit skill-scoped folders (`adr/{skill-name}/`).
- Writing the meta-ADR `adr/learning-progress/ADR-001-establish-self-adjustment-adr-protocol.md` (status accepted) during implementation.
- Bumping `manifest.json` after the meta-ADR (version bump, recomputed hashes, `adrCount` +1).
- Adding MODIFIED + ADDED requirements to the `learning-progress` capability spec via a delta spec (canonical spec merged at archive time).
- Creating this change package with `proposal.md`, `design.md`, `tasks.md`, and the delta spec.

### Out of scope

- Modifying `.opencode/skills/learning-progress/SKILL.md`, `agent-blueprints/01-learning-progress.md`, `openspec/specs/learning-progress/spec.md`, `AGENTS.md`, or `adr/AGENTS.md` now — this package formalizes the plan only; implementation happens later via `tasks.md`.
- Modifying `learning/00-notes/tracks.md` or any session summary notes (data, not skill definition; excluded from detection by design).
- Changing REPORT/SUMMARIZE behavior beyond the new pending-adjustment exception to immediate execution.
- Modifying OpenSpec methodology files (`openspec/AGENTS.md`, `openspec/specs/spec-format/`, `openspec/specs/archive-safety/`).
- Making any git commits.

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `learning-progress` (1 MODIFIED requirement — Execution Without Confirmation — and 4 ADDED requirements: Self-Adjustment Detection, ADR Requirement Elicitation, ADR Creation After Execution, Manifest Accuracy)

## Value Proposition

After this change, the learning-progress skill is self-documenting. Every adjustment to its own definition is detected against a hashed manifest baseline, the user's ADR requirements are elicited before the adjustment executes, and a skill-scoped Architecture Decision Record captures the rationale, context, and consequences after execution. Future maintainers can answer "how and why was this skill changed?" from `adr/learning-progress/` alone, and the manifest accuracy invariant guarantees the baseline stays truthful — with `tracks.md` data edits explicitly excluded so routine registry updates never trigger an ADR.
