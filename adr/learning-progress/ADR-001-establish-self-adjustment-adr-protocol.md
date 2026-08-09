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
