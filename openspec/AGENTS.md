# AGENTS.md — OpenSpec Methodology

This file is the methodology authority for everything under `openspec/`. It is the single source of truth for canonical specs, delta specs, change proposals, and archive flow.

## Purpose

- Define OpenSpec conventions for spec-driven development.
- Keep the methodology generic so this repository can be reused for any domain.

## Core Principles

1. **Specs are the living source of truth** — `openspec/specs/` holds durable behavioral guarantees that evolve as changes are applied and archived.
2. **Specs = WHAT, Implementation = HOW** — Spec files describe WHAT behavior is required. Implementation files (agents, skills, source code) describe HOW behavior is achieved. Neither replaces the other.
3. **One spec per capability** — Each capability has exactly one `spec.md` in `openspec/specs/<capability>/`.
4. **Changes produce deltas** — Change proposals contain only the changes (ADDED/MODIFIED/REMOVED requirements), not the full spec.
5. **Archive merges deltas** — When archiving a completed change, deltas are merged into the living spec library. The archive preserves the full change history.
6. **Specs are long-lived** — They describe durable behavioral guardrails, not implementation timelines.
7. **Specs are requirements** — Written in SHALL / GIVEN-WHEN-THEN style.
8. **Specs live with code** — They stay in the repo as living documentation.

## Directory Structure

```
openspec/
├── AGENTS.md          # This file — methodology authority
├── specs/             # Canonical capability specifications
│   ├── spec-format/
│   ├── service-capability-template/
│   └── archive-safety/
└── changes/           # Active change proposals
    ├── AGENTS.md       # Agent instructions for generating change proposals
    ├── .gitkeep
    └── archive/       # Completed and merged changes
        └── .gitkeep
```

## Canonical Spec Format

Every spec in `openspec/specs/<capability>/spec.md` must include:

```markdown
# <capability> Specification

## Purpose
One sentence describing what capability this spec governs.

## Requirements

### Requirement: <requirement-name>
The system SHALL <behavior>.

#### Scenario: <scenario-name>
- GIVEN <precondition>
- WHEN <action>
- THEN <outcome>
- AND <additional outcome>

## Boundaries

### In scope
- ...

### Out of scope
- ...

## Related Code
- Path to relevant implementation files
```

### Requirement Rules

- Use `SHALL` for mandatory behavior.
- Use `SHOULD` for recommended behavior.
- Avoid ambiguous language (no "appropriate" or "reasonable").
- Every requirement MUST include at least one `#### Scenario:` block.
- Scenario clauses MUST use bullet form: `- GIVEN`, `- WHEN`, `- THEN`, `- AND`.
- Cover both happy path and error cases.

### Boundaries

- State what this spec does NOT cover.
- Define upper limits where applicable.
- Note intentional omissions.

### Related Code

- Link to implementation files, configuration files, or related specs.
- Keep paths relative to the project root.

## Delta Spec Format

Change proposals produce delta specs. A delta spec contains only the changes — not the full spec. Use three first-class sections:

```markdown
# Spec Deltas for <capability>

## ADDED Requirements

### Requirement: <New Requirement Title>
The system SHALL <behavior>.

#### Scenario: <scenario-name>
- GIVEN ...
- WHEN ...
- THEN ...
- AND ...

## MODIFIED Requirements

### Requirement: <Modified Requirement Title>
The system SHALL <updated behavior>.

#### Scenario: <scenario-name>
- GIVEN ...
- WHEN ...
- THEN ...
- AND ...

> **Replaces**: The previous requirement text being modified. Include the full original `### Requirement:` header and all scenario text for exact matching during archive merge.

## REMOVED Requirements

### Requirement: <Deprecated Requirement Title>
> **Reason**: <Description of why this is being removed and what replaces it.>

**Original requirement text** (for exact matching during archive merge):
<Full original `### Requirement:` header, description, and all `#### Scenario:` blocks>
```

### Delta Rules

- **ADDED**: Include full requirement and at least one scenario.
- **MODIFIED**: Include updated requirement and a `Replaces` block with full original requirement text for exact matching.
- **REMOVED**: Include reason and full original requirement text for exact matching.
- Omit empty sections.
- If a capability has NO changes, do not create a specs/ subfolder for it.

## Change Lifecycle

### Proposing a Change

1. Read `openspec/changes/AGENTS.md` and generate the change proposal from its templates.
2. Create `openspec/changes/<change-id>/` with `proposal.md`, `design.md`, `tasks.md`, and delta specs under `specs/<capability>/spec.md`.

### Applying a Change

1. Execute `tasks.md` in order and verify each step.

### Archiving a Change

1. **Pre-merge snapshot**: `git tag openspec-archive-safety`
2. **List affected specs**: `ls openspec/changes/<change-id>/specs/*/spec.md`
3. **For new capabilities** (no existing spec in `openspec/specs/<capability>/`):
    a. For service/operation capabilities, start from the section structure defined in `openspec/specs/service-capability-template/spec.md` (Input Contract, Output Contract, Failure Behavior, Quality Acceptance Criteria, Cross-Capability Dependency). For all other capabilities, use the canonical format from `openspec/AGENTS.md#canonical-spec-format`.
   b. Create `openspec/specs/<capability>/spec.md`.
   c. Populate `## Requirements` from the `## ADDED Requirements` in the delta spec.
   d. Skip to step 5 (no merge needed for new specs).
4. **For existing capabilities, merge each spec delta**:
   - **ADDED**: Append new requirements to `## Requirements` before `## Boundaries`, in the order they appear in the delta spec.
   - **MODIFIED**: Find the exact original requirement text, replace with the new text.
   - **REMOVED**: Find and remove the exact original requirement text.
   - Confirm byte-exact match before any modification or removal.
5. **Post-merge diff review**: `git diff openspec/specs/` — present to user.
6. **Approval gate**: Do not proceed without explicit approval.
7. **Complete archive**: `cp -r openspec/changes/<change-id> openspec/changes/archive/<YYYY-MM-DD-slug>/ && rm -rf openspec/changes/<change-id>/ && git tag -d openspec-archive-safety`
8. **Recovery on failure**: `git checkout openspec-archive-safety -- openspec/specs/ && git tag -d openspec-archive-safety` to restore pre-merge state.

## Naming Conventions

- **Capability folder**: lowercase kebab-case (`customer-onboarding`, `auth-service`).
- **Change folder**: lowercase kebab-case with verb prefix (`add-id-mismatch-review`, `refactor-auth-flow`).
- **Spec filename**: always `spec.md`.
- **Archive folder**: `YYYY-MM-DD-slug` format (`2026-06-29-add-id-validation`).

## Scope Boundaries

In scope for this methodology file:

- OpenSpec file structure and lifecycle.
- Canonical and delta spec format requirements.
- Change archive safety requirements.

Out of scope for this methodology file:

- Domain-specific business requirements.
- Implementation code patterns.
- Team process outside OpenSpec artifacts.

## Related Code

- `openspec/specs/spec-format/spec.md`
- `openspec/specs/service-capability-template/spec.md`
- `openspec/specs/archive-safety/spec.md`
