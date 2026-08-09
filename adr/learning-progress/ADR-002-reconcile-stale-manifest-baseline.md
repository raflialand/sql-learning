# ADR-002: Reconcile stale manifest baseline with the skill definition

## Status

accepted

## Context

`manifest.json` version 1.1.0 (committed in `eb99aea`) recorded SHA-256 hashes that were computed against pre-final drafts of the three manifest-tracked files — `.opencode/skills/learning-progress/SKILL.md`, `agent-blueprints/01-learning-progress.md`, and `openspec/specs/learning-progress/spec.md`. The three files were finalized after the hashes were generated, but the manifest was never recomputed before commit. As a result, all three recorded hashes mismatch the actual committed file content, falsely reporting a pending adjustment on every invocation and violating the manifest-accuracy invariant.

## Decision

Recompute the three SHA-256 hashes from the actual definition files and re-baseline the manifest to reflect the current, correct state of the skill definition. Specifically:

- Set `files` to the hashes computed from the current file contents (SKILL.md `F2E966C5…`, blueprint `AAE28B01…`, spec `665EF7A9…`).
- Bump `version` from 1.1.0 to 1.2.0, set `lastChange` to 2026-08-05, and increment `adrCount` from 1 to 2.
- Make no edits to the three definition files — they are correct as committed.

## Consequences

- The detection baseline now matches reality: SELF-CHECK/DETECT will report no pending adjustment until a genuine change to the skill definition occurs.
- `adrCount` reflects two recorded adjustments (ADR-001 established the protocol; ADR-002 reconciles the baseline).
- Risk: any future edit to the definition files that skips the RECORD step will re-drift the manifest; this is mitigated by the RECORD step of the protocol, which recomputes hashes after every executed adjustment.
