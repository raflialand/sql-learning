# service-capability-template Specification

## Purpose

Define the mandatory behavioral contract patterns for service and operation capabilities (APIs, ETL pipelines, feature modules); for non-service capabilities (format specs, naming conventions, governance policies, lifecycle rules), use the canonical format directly from `openspec/AGENTS.md`.

## Requirements

### Requirement: Capability Input Contract

The system SHALL define required inputs for the capability before execution begins.

#### Scenario: Valid input declaration

- GIVEN a capability is documented
- WHEN inputs are described
- THEN required inputs SHALL be explicitly listed
- AND missing required inputs SHALL be treated as a precondition failure

#### Scenario: Precondition failure on missing input
- GIVEN a required input is not provided
- WHEN capability execution is attempted
- THEN the capability SHALL halt before any side effects are applied
- AND a failure reason SHALL identify the missing input by name

#### Scenario: Optional input handling

- GIVEN a capability accepts optional inputs
- WHEN an optional input is not provided
- THEN the capability SHALL use a documented default value
- AND the default behavior SHALL be explicitly stated in the spec

### Requirement: Capability Output Contract

The system SHALL define expected outputs and output quality criteria for the capability.

#### Scenario: Valid output declaration

- GIVEN a capability is documented
- WHEN outputs are described
- THEN output artifacts SHALL be explicitly listed
- AND output acceptance criteria SHALL be testable

#### Scenario: Output validation

- GIVEN a capability produces outputs
- WHEN outputs are validated against acceptance criteria
- THEN outputs not meeting criteria SHALL trigger a failure
- AND the failure SHALL identify which criterion was not met

### Requirement: Failure Behavior

The system SHALL define behavior for validation or execution failures.

#### Scenario: Handling failed input validation

- GIVEN input validation fails
- WHEN capability execution is attempted
- THEN execution SHALL stop before side effects are applied
- AND a failure reason SHALL be recorded

#### Scenario: Handling partial execution failure

- GIVEN execution fails after partial completion
- WHEN the failure is detected
- THEN previously persisted state SHALL remain consistent
- AND the failure SHALL be surfaced with context about what completed and what did not

### Requirement: Quality Acceptance Criteria

The system SHALL define measurable quality thresholds that the capability must meet.

#### Scenario: Defining quality thresholds

- GIVEN a capability produces outputs
- WHEN quality criteria are documented
- THEN each criterion SHALL be measurable (numeric threshold, boolean condition, or enumerated pass/fail)
- AND criteria SHALL cover correctness, completeness, and consistency

#### Scenario: Failing quality thresholds

- GIVEN outputs fail to meet a quality threshold
- WHEN the threshold violation is detected
- THEN the capability SHALL report the violation with the measured value and expected threshold
- AND the violation SHALL block downstream consumption until resolved

### Requirement: Cross-Capability Dependency

The system SHALL declare dependencies on other capabilities and define behavior when those dependencies change.

#### Scenario: Declaring upstream dependency

- GIVEN a capability depends on another capability's outputs
- WHEN the dependency is documented
- THEN the spec SHALL reference the upstream capability in `## Related Code`
- AND the spec SHALL define what input contract the dependency must satisfy

#### Scenario: Upstream contract change

- GIVEN an upstream capability's output contract changes
- WHEN the change is proposed in a delta spec
- THEN the dependent capability SHALL be listed as an affected spec
- AND a compatibility assessment SHALL be included in the change's `design.md`

## Boundaries

### In scope

- Pattern for documenting service/operation capability behavior: input contracts, output contracts, failure handling, quality criteria, and dependency management.

### Out of scope

- Non-service capabilities (format specs, naming conventions, governance policies, lifecycle rules).
- Any specific business domain logic.
- Any specific tooling or implementation details.

## Related Code

- `openspec/AGENTS.md` — Full methodology (canonical/delta formats, lifecycle, archive safety) and fallback canonical format for non-service specs
- `openspec/specs/spec-format/spec.md` — Format contract this spec must follow
