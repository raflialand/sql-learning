# Add Progress Evaluator — Implementation Tasks

> These tasks implement Phase 2. The canonical specs (`openspec/specs/progress-evaluator/spec.md` and the MODIFIED `openspec/specs/data-to-insight/spec.md`) are created from the delta specs at archive time and are intentionally NOT listed here.

## Phase 1: Spec Deltas

### Step 1.1: Author the `progress-evaluator` delta spec

Create `openspec/changes/add-progress-evaluator/specs/progress-evaluator/spec.md` with `## ADDED Requirements` following the `service-capability-template` structure (Capability Input Contract, Read-Only Verification Constraint, Verdict Model Contract, the six per-stage Evaluation Contracts, Output Artifact Contract, Re-Run Loop Contract, Owner Routing Contract, Failure Behavior, Quality Acceptance Criteria, Cross-Capability Dependency), plus `## Boundaries` and `## Related Code`.

**Verification**: The delta contains the PASS / PASS-WITH-NOTES / FAIL verdict model, the MANDATORY-vs-ADVISORY split, all per-stage MANDATORY checks from the proposal/design, the 3-fix retry budget + fail-closed behavior, the owner-routing table, and the `docs/04-progress-evaluator/` output location.

### Step 1.2: Author the `data-to-insight` delta spec

Create `openspec/changes/add-progress-evaluator/specs/data-to-insight/spec.md` with `## ADDED Requirements` (Evaluation Gate Contract) and `## MODIFIED Requirements` (Checkpoint Autonomy Contract, Orchestration Contract, Cross-Capability Dependency), each MODIFIED entry carrying a `> **Replaces**:` block with the exact original requirement text from `openspec/specs/data-to-insight/spec.md`.

**Verification**: Each MODIFIED requirement's `Replaces` block byte-matches the current canonical text; the ADDED Evaluation Gate Contract captures block/rerun/fail-closed behavior.

## Phase 2: Agent Definition

### Step 2.1: Author the `progress-evaluator` subagent definition

Create `.opencode/agents/progress-evaluator.md` with YAML frontmatter (`description`, `mode: subagent`), Purpose, Inputs (case `case.md` + dataset README + the artifact under inspection), Outputs (verification report to `docs/04-progress-evaluator/`, dated variant if one exists), Behavior (read-only inspection → per-stage MANDATORY/ADVISORY checks → verdict), and Boundaries (never authors/edits any artifact; never creates change proposals; does not modify `query-inspector`/`learning-progress`/datasets).

**Verification**: Frontmatter has `mode: subagent`; the file mirrors the `.opencode/agents/query-inspector.md` structure, declares itself read-only, and encodes the three-verdict model + per-stage checks + `docs/04-progress-evaluator/` output.

## Phase 3: Blueprint + Skill Wiring

### Step 3.1: Insert the evaluator into the canonical blueprint

Edit `agent-blueprints/03-data-to-insight.md`:
- Add a `progress-evaluator` verification step to each of stages 1–6 and to the six checkpoint gates (evaluator runs before the human-approval pause).
- Add an owner-routing table: Stages 1–2 → orchestrator; Stages 3–5 → `sql-builder`; Stage 6 → `insight-writer`.
- Add a `progress-evaluator` row to the "Implementation Mapping" table.
- Add a non-goal noting the evaluator is read-only and never authors artifacts.

**Verification**: The blueprint references `progress-evaluator` at every checkpoint, includes the owner-routing table, and lists `.opencode/agents/progress-evaluator.md` in the mapping table.

### Step 3.2: Update the orchestrator skill

Edit `.opencode/skills/data-to-insight/SKILL.md`:
- Update the frontmatter `description` to mention the new delegation + gate.
- Add a delegation bullet: checkpoint verification → `@progress-evaluator` (blocking gate, FAIL blocks the checkpoint).
- Add an invariant: the evaluator is read-only and never authors artifacts.

**Verification**: The SKILL.md frontmatter `description` and delegation list name `@progress-evaluator` as the checkpoint gate; no conflicting claim that the evaluator authors artifacts.

## Phase 4: Registry

### Step 4.1: Register `progress-evaluator` in the routing registry

Edit `AGENTS.md` Domain agents table — insert a new row after `insight-writer`:

- **Old**:
  `| `insight-writer`     | Synthesizes the 5-component insight (Trend, Fluctuation, Anomaly, Root cause, Recommendation) + recommendations + self-check (stage 6), graded against the weak-vs-strong rubric |`
- **New**:
  `| `insight-writer`     | Synthesizes the 5-component insight (Trend, Fluctuation, Anomaly, Root cause, Recommendation) + recommendations + self-check (stage 6), graded against the weak-vs-strong rubric |`
  `| `progress-evaluator` | Read-only verification gate at every data-to-insight checkpoint (stages 1–6); emits PASS / PASS-WITH-NOTES / FAIL verdicts; writes dated reports to `docs/04-progress-evaluator/` |`

Also update the `data-to-insight` paragraph to note the evaluator gate (checkpoint verification → `@progress-evaluator`).

**Verification**: `AGENTS.md` Domain agents table lists `progress-evaluator` with its purpose; the agent is described as an execution agent that never creates OpenSpec change proposals.

## Summary of Changes

| Category                | Before                                              | After                                                   |
| ----------------------- | --------------------------------------------------- | ------------------------------------------------------- |
| Verification subagent   | (none)                                              | `.opencode/agents/progress-evaluator.md` — CREATED      |
| Canonical blueprint     | no evaluator step / owner-routing table             | `agent-blueprints/03-data-to-insight.md` — MODIFIED     |
| Orchestrator skill      | no evaluator delegation                             | `.opencode/skills/data-to-insight/SKILL.md` — MODIFIED  |
| Routing registry        | no progress-evaluator entry                         | `AGENTS.md` — MODIFIED (Domain agents table)            |
| Delta spec (new)        | (none)                                              | `openspec/changes/add-progress-evaluator/specs/progress-evaluator/spec.md` — CREATED (ADDED) |
| Delta spec (modified)   | (none)                                              | `openspec/changes/add-progress-evaluator/specs/data-to-insight/spec.md` — CREATED (ADDED + MODIFIED) |
| Canonical spec (new)    | (none)                                              | `openspec/specs/progress-evaluator/spec.md` — CREATED at archive time from delta (not in tasks) |
| Canonical spec (mod)    | current `data-to-insight` spec                      | `openspec/specs/data-to-insight/spec.md` — MODIFIED at archive time from delta (not in tasks) |
