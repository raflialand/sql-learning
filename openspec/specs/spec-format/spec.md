# spec-format Specification

## Purpose
Define mandatory structure and language rules for canonical specs and delta specs.

## Requirements

### Requirement: Canonical Section Structure
The system SHALL require every canonical spec to include Purpose, Requirements, Boundaries, and Related Code sections.

#### Scenario: Validating canonical spec shape
- GIVEN a canonical spec exists at `openspec/specs/<capability>/spec.md`
- WHEN the spec is reviewed
- THEN it SHALL contain `## Purpose`
- AND it SHALL contain `## Requirements`
- AND it SHALL contain `## Boundaries`
- AND it SHALL contain `## Related Code`

#### Scenario: Missing required section
- GIVEN a canonical spec is missing a required section (`## Purpose`, `## Requirements`, `## Boundaries`, or `## Related Code`)
- WHEN the spec is reviewed for format compliance
- THEN the spec SHALL be flagged as non-conformant
- AND the missing section name SHALL be reported

### Requirement: Scenario-Wrapped Requirement Format
The system SHALL require each requirement to include at least one scenario block with bullet-point GIVEN/WHEN/THEN clauses.

#### Scenario: Writing requirement scenarios
- GIVEN a requirement is authored in canonical or delta form
- WHEN scenario behavior is documented
- THEN the requirement SHALL include at least one `#### Scenario:` block
- AND each scenario SHALL include `- GIVEN`, `- WHEN`, and `- THEN` clauses
- AND additional outcomes SHALL use `- AND` clauses

### Requirement: SHALL and SHOULD Language
The system SHALL use SHALL for mandatory behavior and SHOULD for recommendations.

#### Scenario: Writing mandatory and recommended rules
- GIVEN a behavior is mandatory
- WHEN requirement language is written
- THEN the text SHALL use SHALL language
- AND ambiguous wording SHALL be avoided
- AND recommended guidance SHOULD use SHOULD language

### Requirement: Delta Section Names
The system SHALL use only ADDED Requirements, MODIFIED Requirements, and REMOVED Requirements for delta sections.

#### Scenario: Writing delta sections
- GIVEN a change proposal delta spec is created
- WHEN sections are authored
- THEN new behavior SHALL appear under `## ADDED Requirements`
- AND changed behavior SHALL appear under `## MODIFIED Requirements`
- AND removed behavior SHALL appear under `## REMOVED Requirements`
- AND non-standard section markers SHALL NOT be used

#### Scenario: Non-standard section marker
- GIVEN a delta spec uses a non-standard section marker (e.g. `## UPDATED Requirements`)
- WHEN the delta is validated
- THEN the delta SHALL be flagged as non-conformant
- AND a message SHALL identify the unrecognized section

### Requirement: Exact-Match Safety for Modified and Removed Deltas
The system SHALL require full original requirement text for modified and removed deltas.

#### Scenario: Preparing a modified requirement
- GIVEN an existing requirement is changed
- WHEN a delta is written under `## MODIFIED Requirements`
- THEN the updated requirement SHALL be included with scenarios
- AND a `Replaces` block SHALL include the full original requirement text for exact matching

#### Scenario: Preparing a removed requirement
- GIVEN an existing requirement is removed
- WHEN a delta is written under `## REMOVED Requirements`
- THEN the delta SHALL include a reason for removal
- AND it SHALL include the full original requirement text for exact matching

#### Scenario: Missing Replaces block in modified delta
- GIVEN a delta includes a requirement under `## MODIFIED Requirements`
- WHEN the delta is validated
- THEN a `> **Replaces**:` block with the full original requirement text SHALL be present
- AND a missing `Replaces` block SHALL halt the merge

### Requirement: WHAT vs HOW Separation
The system SHALL use spec files (`openspec/specs/`) to define WHAT behavior is required and SHALL NOT include implementation details (HOW) in spec files.

#### Scenario: Spec limits to behavioral contracts
- GIVEN a spec file at `openspec/specs/<capability>/spec.md`
- WHEN content is written
- THEN the spec SHALL describe externally observable behavior
- AND it SHALL NOT include implementation language, tooling, or workflow steps
- AND implementation files (agents, skills, source code) SHALL describe HOW behavior is achieved

#### Scenario: Implementation detail in spec
- GIVEN a spec contains implementation details (tool names, file formats, workflow steps)
- WHEN the spec is reviewed for format compliance
- THEN those details SHALL be extracted to the `## Related Code` section as file references
- AND the requirement text SHALL be rewritten to describe only behavioral outcomes

## Boundaries

### In scope
- Canonical spec section structure.
- Scenario formatting and requirement language rules.
- Delta section naming and exact-match safety rules.

### Out of scope
- Domain-specific capability behavior.
- Implementation workflow beyond spec authoring and merging.

## Related Code
- `openspec/AGENTS.md` — Full methodology (canonical/delta formats, lifecycle, archive safety)
- `openspec/specs/service-capability-template/spec.md` — Spec template for service/operation capabilities
- `openspec/changes/` — Change proposals and archive
