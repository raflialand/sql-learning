# AGENTS.md — Change Proposals

This file is the agent instruction surface for creating and managing change proposals in this directory. It is injected into context when working under `openspec/changes/`.

See `openspec/AGENTS.md` for the complete methodology (canonical/delta formats, lifecycle, archive safety). This file defines WHAT to generate for a change proposal; `openspec/AGENTS.md` defines the rules those artifacts must follow.

## Purpose

Every change proposal translates a user's natural-language intent into structured, spec-driven artifacts. You are the agent that performs this translation.

## Change ID Naming

- Lowercase kebab-case with a verb prefix: `add-`, `refactor-`, `remove-`, `fix-`, `update-`
- Examples: `add-login`, `refactor-auth-flow`, `remove-legacy-payment`
- If the user does not provide a name, derive one from the primary action + scope

## File Structure

When creating a change proposal, generate this directory layout:

```
openspec/changes/<change-id>/
├── proposal.md                    # What problem, what solution, what scope
├── design.md                      # How it works, decisions, file changes
├── tasks.md                       # Ordered implementation steps
└── specs/                         # Delta specs (one subdirectory per affected capability)
    └── <capability>/
        └── spec.md                # ADDED / MODIFIED / REMOVED requirements
```

Generate ALL files from the templates below. Never leave a file empty. Never use copy-and-paste — the templates are format guides to populate with concrete content.

## Change Workflow

When a user describes a goal, capability, or change, follow this sequence:

1. **Identify affected specs** — Read `openspec/specs/` to find which capability specs exist and which would be affected by this change.
2. **Generate change ID** — Derive a kebab-case verb-prefixed ID.
3. **Clarify ambiguity (if needed)** — If scope, affected capabilities, or desired behavior is unclear, ask the user. Do this within the "Propose changes" phase, before generating proposal files.
4. **Create the directory** — `openspec/changes/<change-id>/` with all files populated.
5. **Populate proposal.md** — Translate user intent into the problem/solution/scope template.
6. **Populate design.md** — Describe the approach, decisions, and target file structure.
7. **Populate tasks.md** — Break the implementation into ordered, verifiable steps.
8. **Create delta specs** — For each affected capability, create `specs/<capability>/spec.md` with ADDED, MODIFIED, or REMOVED requirements. Follow the delta format in `openspec/AGENTS.md`.

After all files are generated, present the complete change proposal to the user for review and approval.

## Archive Naming

When archiving a completed change, use the format `YYYY-MM-DD-slug` matching the change ID:

```
openspec/changes/archive/YYYY-MM-DD-<change-id>/
```

Example: `openspec/changes/archive/2026-07-06-add-login/`

---

## proposal.md Template

Generate a file with this structure, replacing every `<placeholder>` and placeholder comment:

```markdown
# [Change Title]

## Problem Statement

<!-- What problem are we solving? What is currently broken, missing, or suboptimal? -->

...

## Proposed Solution

<!-- High-level description of the change. What is the approach? -->

...

## Scope

### In scope

- ...

### Out of scope

- ...

## Capabilities

<!-- Which specs will be created or modified? Check openspec/specs/ for existing ones. -->

### New Capabilities

- <!-- Capability name (kebab-case) -->

### Modified Capabilities

- <!-- Existing capability name from openspec/specs/ -->

## Value Proposition

<!-- Why does this change matter? What improves after it is applied? -->

...
```

### Rules

- The title is the change ID in sentence case (e.g. `add-login` → "Add Login").
- Every section must be filled. Remove placeholder comments after populating.
- Scope must list concrete items, not vague intentions.

---

## design.md Template

Generate a file with this structure:

```markdown
# [Change Title] — Design

## Overview

<!-- Architecture and approach summary. How will the change work? -->

...

## Design Decisions

<!-- Key choices made and why. One decision per subsection. -->

### Decision 1: [Decision Title]

**Choice**: ...
**Rationale**: ...

### Decision 2: [Decision Title]

**Choice**: ...
**Rationale**: ...

## Target Structure

<!-- Files created, modified, or removed. Use a before/after tree or table. -->

```
path/to/file.md    ← MODIFIED: description
path/to/new.md     ← CREATED: description
```

## Edge Cases

<!-- Known tricky cases and how they are handled. -->

- **Case 1**: ...
  - Handling: ...
- **Case 2**: ...
  - Handling: ...

## Affected Specs

<!-- Which capability specs have delta changes? One per row. -->

| Spec                          | Change Type                |
| ----------------------------- | -------------------------- |
| `specs/<capability>/spec.md` | ADDED / MODIFIED / REMOVED |
```

### Rules

- At least one design decision must be documented. If the change is simple, document why the simple approach was chosen.
- The Target Structure must reference real file paths relative to the project root.
- Edge Cases must not be empty. If none are known, state "No edge cases identified" with a brief justification.

---

## tasks.md Template

Generate a file with this structure:

```markdown
# [Change Title] — Implementation Tasks

## Phase 1: [Phase Name]

### Step 1.1: [Task Name]

<!-- Describe the edit or action. -->

<!--
For text edits, use old/new format:
- **Old**: `"original text"`
- **New**: `"replacement text"`
-->

...

**Verification**: <!-- How to confirm this step is complete -->

### Step 1.2: [Task Name]

...

**Verification**: ...

## Phase 2: [Phase Name]

### Step 2.1: [Task Name]

...

**Verification**: ...

## Summary of Changes

| Category   | Before            | After             |
| ---------- | ----------------- | ----------------- |
| ...        | ...               | ...               |
```

### Rules

- Group steps into Phases. Each phase represents a logical chunk of work (e.g. "Spec Changes", "Implementation", "Validation").
- Every step must have a **Verification** line — how to confirm the step is done correctly.
- Text edits must use **Old** / **New** format to make exact-string replacement unambiguous.
- The **Summary of Changes** table must list every artifact created, modified, or removed by this change.
- Canonical spec creation (`openspec/specs/`) SHALL NOT be listed in `tasks.md` — canonical specs are created from delta specs during the archive step.

---

## Delta Specs

Delta specs follow the format defined in `openspec/AGENTS.md#delta-spec-format`. The format is:

- `## ADDED Requirements` — new requirements with `SHALL` and at least one `#### Scenario:` block
- `## MODIFIED Requirements` — updated requirements with a `> **Replaces**:` block containing the original full text
- `## REMOVED Requirements` — deprecated requirements with a `> **Reason**:` and the original full text

Key rules:
- Omit empty sections. If a section has no entries, delete it.
- If a capability has no changes, do not create a `specs/<capability>/` subdirectory for it.
- Use `SHALL` for mandatory behavior, `SHOULD` for recommendations.
- Every requirement MUST include at least one `#### Scenario:` block with bullet-form `GIVEN/WHEN/THEN/AND` clauses.

---

## Validation Checklist

Before presenting a change proposal as ready, verify:

| Check                                                         | Status |
| ------------------------------------------------------------- | ------ |
| All files (`proposal.md`, `design.md`, `tasks.md`) exist and are populated |        |
| All placeholder markers (`[Change Title]`, `<capability>`, `...`) are replaced |        |
| At least one delta spec exists under `specs/<capability>/spec.md`              |        |
| `tasks.md` has ordered, verifiable steps with completion checks               |        |
| `design.md` Target Structure references real file paths                       |        |
| `proposal.md` Scope sections contain concrete items, not placeholders          |        |
| Change ID follows kebab-case-with-verb-prefix convention                       |        |
| Affected capability names match existing folders in `openspec/specs/` or are declared as new |        |
