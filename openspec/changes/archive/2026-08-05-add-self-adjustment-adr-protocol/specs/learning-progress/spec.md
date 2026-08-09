# Spec Deltas for learning-progress

## ADDED Requirements

### Requirement: Self-Adjustment Detection
The learning-progress capability SHALL detect pending adjustments to its own skill definition by re-hashing the three manifest-tracked files — `.opencode/skills/learning-progress/SKILL.md`, `agent-blueprints/01-learning-progress.md`, and `openspec/specs/learning-progress/spec.md` — and diffing the results against the `files` map in `.opencode/skills/learning-progress/manifest.json` on invocation or at planning time.

#### Scenario: All tracked files unchanged
- GIVEN every manifest-tracked file hashes to the value recorded in `.opencode/skills/learning-progress/manifest.json`
- WHEN the capability is invoked or planning starts
- THEN the capability SHALL report no pending adjustment
- AND SHALL proceed with normal REPORT or SUMMARIZE behavior

#### Scenario: One or more tracked files changed
- GIVEN at least one manifest-tracked file hashes differently from `.opencode/skills/learning-progress/manifest.json`
- WHEN the capability is invoked or planning starts
- THEN the capability SHALL report the differences as a pending adjustment
- AND SHALL enter SELF-CHECK/ADJUST mode instead of executing immediately

#### Scenario: Registry data changes are not adjustments
- GIVEN `learning/00-notes/tracks.md` changes while the three manifest-tracked files are unchanged
- WHEN the capability is invoked or planning starts
- THEN the capability SHALL NOT report a pending adjustment
- AND SHALL NOT treat registry data edits as skill-definition changes

#### Scenario: Manifest missing
- GIVEN `.opencode/skills/learning-progress/manifest.json` does not exist
- WHEN the capability is invoked or planning starts
- THEN the capability SHALL report the missing manifest as a pending adjustment
- AND SHALL require ADR requirement elicitation before any adjustment proceeds

### Requirement: ADR Requirement Elicitation
The learning-progress capability SHALL collect ADR requirements from the user before any adjustment plan executes, covering title/slug, status, context/problem, decision, and consequences/risks.

#### Scenario: Adjustment plan pending execution
- GIVEN a pending adjustment is detected and the adjustment plan is ready to execute
- WHEN the capability is about to execute the adjustment
- THEN the capability SHALL ask the user for the ADR requirements (title/slug, status, context/problem, decision, consequences/risks)
- AND SHALL NOT execute the adjustment before the requirements are collected

#### Scenario: Incomplete ADR requirements
- GIVEN the user omits one or more required ADR fields during elicitation
- WHEN the elicitation step completes
- THEN the capability SHALL ask for the missing fields
- AND SHALL NOT proceed to execution with an incomplete ADR record

### Requirement: ADR Creation After Execution
The learning-progress capability SHALL write an Architecture Decision Record to `adr/learning-progress/ADR-{NNN}-{slug}.md` after an adjustment executes, using the elicited requirements plus what actually changed, and SHALL follow the `adr/AGENTS.md` template with status accepted and Context, Decision, and Consequences sections.

#### Scenario: Adjustment completed
- GIVEN an adjustment plan has executed
- WHEN the change is complete
- THEN the capability SHALL write `adr/learning-progress/ADR-{NNN}-{slug}.md`
- AND the ADR SHALL contain Status accepted, Context, Decision, and Consequences per the `adr/AGENTS.md` template

#### Scenario: ADR sequence and slug
- GIVEN existing ADRs in `adr/learning-progress/`
- WHEN a new ADR is written
- THEN the capability SHALL assign the next sequential number `{NNN}`
- AND SHALL use a lowercase kebab-case `{slug}` derived from the adjustment title

### Requirement: Manifest Accuracy
The learning-progress capability SHALL update `.opencode/skills/learning-progress/manifest.json` after every executed adjustment so the manifest reflects the current skill definition, and SHALL exclude `learning/00-notes/tracks.md` from adjustment detection.

#### Scenario: Post-adjustment manifest update
- GIVEN an adjustment has executed and its ADR has been written
- WHEN the manifest is updated
- THEN the capability SHALL bump the version, recompute the SHA-256 hashes of the three manifest-tracked files, increment `adrCount` by one, and set `lastChange` to the change date
- AND the updated manifest SHALL match the actual state of the tracked files

#### Scenario: Registry excluded from the manifest
- GIVEN the manifest baseline is created or updated
- WHEN the capability hashes its skill definition files
- THEN `learning/00-notes/tracks.md` SHALL NOT be included in the `files` map
- AND SHALL NOT be hashed for adjustment detection

## MODIFIED Requirements

### Requirement: Execution Without Confirmation
The learning-progress capability SHALL execute immediately on trigger without asking for confirmation, except when track resolution requires clarification or a pending adjustment to the skill definition requires ADR requirement elicitation.

#### Scenario: Direct trigger
- GIVEN a REPORT or SUMMARIZE trigger phrase is detected and the track is resolvable
- WHEN the capability is invoked
- THEN the capability SHALL execute immediately
- AND SHALL NOT ask for confirmation

#### Scenario: Clarification required
- GIVEN the track cannot be resolved without user input, such as no prior activity or an unknown track keyword
- WHEN the capability is invoked
- THEN the capability SHALL ask which track to use before executing

#### Scenario: Pending adjustment requires elicitation
- GIVEN a pending adjustment is detected against the skill definition manifest
- WHEN the capability is invoked or planning starts
- THEN the capability SHALL ask the user for ADR requirements before executing the adjustment
- AND SHALL NOT execute immediately while a pending adjustment exists

> **Replaces**: The previous requirement text being modified. Include the full original `### Requirement:` header and all scenario text for exact matching during archive merge.
>
> ### Requirement: Execution Without Confirmation
> The learning-progress capability SHALL execute immediately on trigger without asking for confirmation, except when track resolution requires clarification.
>
> #### Scenario: Direct trigger
> - GIVEN a REPORT or SUMMARIZE trigger phrase is detected and the track is resolvable
> - WHEN the capability is invoked
> - THEN the capability SHALL execute immediately
> - AND SHALL NOT ask for confirmation
>
> #### Scenario: Clarification required
> - GIVEN the track cannot be resolved without user input, such as no prior activity or an unknown track keyword
> - WHEN the capability is invoked
> - THEN the capability SHALL ask which track to use before executing
