# archive-safety Specification

## Purpose
Define mandatory behavioral contracts for the archive merge process: pre-merge snapshot, exact-text matching, post-merge diff review, approval gate, recovery on failure, and snapshot cleanup.

## Requirements

### Requirement: Pre-Merge Snapshot
The system SHALL create a recoverable snapshot of the canonical spec library before applying any delta merge.

#### Scenario: Snapshot created before merge
- GIVEN a completed change proposal is being archived
- WHEN the archiving process begins
- THEN a recoverable snapshot of `openspec/specs/` SHALL be created
- AND the snapshot SHALL be a lightweight tag pointing to the current commit

#### Scenario: Snapshot lifecycle
- GIVEN a snapshot was created for archiving
- WHEN the archive completes successfully or the merge fails
- THEN the snapshot tag SHALL be deleted after restoration or completion
- AND no residual snapshot artifacts SHALL remain

### Requirement: Exact-Text Merge Safety
The system SHALL verify byte-exact match of original requirement text before applying MODIFIED or REMOVED deltas.

#### Scenario: Modified requirement matches original
- GIVEN a MODIFIED delta includes a `Replaces` block with original requirement text
- WHEN the delta is merged into the canonical spec
- THEN the original text SHALL match byte-for-byte before replacement
- AND a mismatch SHALL halt the merge and report the discrepancy

#### Scenario: Removed requirement matches original
- GIVEN a REMOVED delta includes original requirement text
- WHEN the delta is merged into the canonical spec
- THEN the original text SHALL match byte-for-byte before removal
- AND a mismatch SHALL halt the merge and report the discrepancy

#### Scenario: ADDED requirements are exempt from exact-match
- GIVEN an ADDED delta is merged
- WHEN the delta is applied
- THEN no exact-match verification SHALL be required
- AND the new requirement SHALL be appended before the `## Boundaries` section

### Requirement: Post-Merge Diff Review
The system SHALL present a diff of all changes before completing the archive.

#### Scenario: Diff presented for review
- GIVEN all deltas have been merged into canonical specs
- WHEN the merge is validated
- THEN a diff of `openspec/specs/` SHALL be presented for review
- AND only expected changes from the deltas SHALL appear in the diff

#### Scenario: Unexpected changes detected in diff
- GIVEN the post-merge diff contains changes not described in any delta
- WHEN the diff is reviewed
- THEN those unexpected changes SHALL be flagged
- AND the archive SHALL NOT proceed until they are resolved

### Requirement: Approval Gate
The system SHALL require explicit user approval before finalizing the archive.

#### Scenario: Archive requires approval
- GIVEN the post-merge diff has been reviewed
- WHEN the archive is ready to complete
- THEN explicit user approval SHALL be required
- AND the archive SHALL NOT proceed without it

#### Scenario: Approval denied
- GIVEN the user rejects the archive after reviewing the diff
- WHEN the rejection is communicated
- THEN the merge SHALL be rolled back using the pre-merge snapshot
- AND the snapshot SHALL be deleted after recovery

### Requirement: Recovery on Merge Failure
The system SHALL restore canonical specs to their pre-merge state if the merge fails at any step.

#### Scenario: Merge failure triggers recovery
- GIVEN a merge error occurs during archiving
- WHEN the failure is detected
- THEN canonical specs SHALL be restored from the pre-merge snapshot
- AND the snapshot SHALL be deleted after recovery

#### Scenario: Recovery preserves snapshot integrity
- GIVEN a recovery is triggered
- WHEN specs are restored from the snapshot
- THEN the restored files SHALL be byte-identical to their pre-merge state
- AND no partial merge artifacts SHALL remain in `openspec/specs/`

### Requirement: Snapshot Cleanup After Success
The system SHALL remove the pre-merge snapshot after a successful archive.

#### Scenario: Snapshot cleaned up after success
- GIVEN the archive has been approved and completed
- WHEN the change is moved to the archive directory
- THEN the pre-merge snapshot SHALL be deleted
- AND no residual snapshot artifacts SHALL remain

#### Scenario: Cleanup verified after archive
- GIVEN the archive step has completed
- WHEN the system verifies cleanup
- THEN no snapshot tag named `openspec-archive-safety` SHALL exist
- AND the canonical specs SHALL reflect all merged deltas

## Boundaries

### In scope
- Snapshot creation and lifecycle management.
- Exact-text match verification for MODIFIED and REMOVED deltas.
- Post-merge diff review and unexpected change detection.
- Approval gate enforcement and rollback on rejection.
- Recovery from merge failures restoring byte-identical pre-merge state.
- Snapshot cleanup after successful archive.

### Out of scope
- The delta spec format itself (governed by `spec-format`).
- Change proposal creation and task execution.
- Git-specific tooling implementation details.
- Domain-specific spec content validation.

## Related Code
- `openspec/AGENTS.md` — Archive merge safety procedural instructions
- `openspec/specs/spec-format/spec.md` — Delta section format and exact-match safety rules
- `openspec/changes/` — Change proposals and archive directory
