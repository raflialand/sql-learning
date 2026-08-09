# Spec Deltas for learning-progress

## ADDED Requirements

### Requirement: Track Registry Contract
The learning-progress capability SHALL read `learning/00-notes/tracks.md` as the single source of truth for learning track definitions before producing any report or summary.

#### Scenario: Registry present with valid track rows
- GIVEN `learning/00-notes/tracks.md` exists and contains rows for the `sql`, `dq`, and `de` tracks
- WHEN the capability resolves a track
- THEN the capability SHALL read the track's roadmap path, notes dir, total units, unit label, and structure from the registry
- AND SHALL NOT use hardcoded track values

#### Scenario: Registry missing
- GIVEN `learning/00-notes/tracks.md` does not exist
- WHEN the capability is invoked
- THEN the capability SHALL halt before producing any report or summary
- AND a failure reason SHALL identify the missing registry file

#### Scenario: Registry row for unknown track id
- GIVEN a user references a track id not present in `learning/00-notes/tracks.md`
- WHEN the capability resolves the track
- THEN the capability SHALL ask the user to pick a registered track id
- AND SHALL list the available registered track ids

### Requirement: Track Resolution
The learning-progress capability SHALL resolve the target track from an optional track keyword in the trigger, defaulting to the most recently active track when no keyword is given.

#### Scenario: Explicit track keyword
- GIVEN a trigger includes a track keyword such as "progress dq" or "summarize de"
- WHEN the capability is invoked
- THEN the capability SHALL resolve the named track from the registry
- AND SHALL operate on that track's roadmap and notes dir

#### Scenario: Bare trigger with prior activity
- GIVEN a trigger has no track keyword
- AND exactly one registered track has the most recently modified `session-summary-*.md` file across all registered notes dirs
- WHEN the capability is invoked
- THEN the capability SHALL default to that most recently active track
- AND SHALL operate on it without asking

#### Scenario: Bare trigger with no prior activity
- GIVEN a trigger has no track keyword
- AND no registered track has any `session-summary-*.md` file
- WHEN the capability is invoked
- THEN the capability SHALL ask the user which track to use
- AND SHALL NOT silently pick a track

#### Scenario: Ambiguous latest-modified tie
- GIVEN a trigger has no track keyword
- AND the most recently modified `session-summary-*.md` timestamps are tied across more than one registered track
- WHEN the capability is invoked
- THEN the capability SHALL ask the user which track to use

### Requirement: Report Mode
The learning-progress capability SHALL produce a progress report for the resolved track showing position, percentage against the track's registry total, a Mermaid pie chart, completed/in-progress/not-started sections, last-session summary, and the next topic from that track's roadmap.

#### Scenario: Report for a track with prior sessions
- GIVEN a track is resolved and its notes dir contains `session-summary-*.md` files
- WHEN REPORT mode is invoked
- THEN the capability SHALL report "X of N {unit}s (Z%)" using the track's registry total and unit label
- AND SHALL render a Mermaid pie chart of completed versus remaining units
- AND SHALL list completed, in-progress, and not-started units
- AND SHALL summarize the last session and state the next topic from the track's roadmap

#### Scenario: Report for a track with no sessions
- GIVEN a track is resolved and its notes dir contains no `session-summary-*.md` files
- WHEN REPORT mode is invoked
- THEN the capability SHALL report "0 of N {unit}s (0%)" using the track's registry total
- AND SHALL state the first roadmap topic as the next topic
- AND SHALL NOT fabricate progress or completion status

#### Scenario: Report references the wrong track's data
- GIVEN a report is generated for one track
- WHEN the report is emitted
- THEN every figure, next topic, and session summary SHALL come only from the resolved track's roadmap and notes dir
- AND SHALL NOT mix in data from another registered track

### Requirement: Summarize Mode
The learning-progress capability SHALL append a structured session note to the resolved track's notes directory and then emit the progress report.

#### Scenario: Summarize with explicit track
- GIVEN SUMMARIZE mode is invoked with a track keyword
- WHEN the session note is saved
- THEN the capability SHALL write or append `session-summary-{day}-{month}-{year}.md` in the resolved track's notes dir
- AND SHALL then emit the progress report for that track

#### Scenario: Same-date session append
- GIVEN a `session-summary-{day}-{month}-{year}.md` already exists for today's date in the resolved track's notes dir
- WHEN SUMMARIZE mode is invoked
- THEN the capability SHALL append the new session under a `---` separator
- AND SHALL NOT overwrite or delete the existing content

#### Scenario: Summary for a different track
- GIVEN SUMMARIZE mode is invoked for track A
- WHEN the session note is saved
- THEN the note SHALL be written only to track A's notes dir
- AND SHALL NOT be written to any other track's notes dir

### Requirement: Execution Without Confirmation
The learning-progress capability SHALL execute immediately on trigger without asking for confirmation, except when track resolution requires clarification.

#### Scenario: Direct trigger
- GIVEN a REPORT or SUMMARIZE trigger phrase is detected and the track is resolvable
- WHEN the capability is invoked
- THEN the capability SHALL execute immediately
- AND SHALL NOT ask for confirmation

#### Scenario: Clarification required
- GIVEN the track cannot be resolved without user input, such as no prior activity or an unknown track keyword
- WHEN the capability is invoked
- THEN the capability SHALL ask which track to use before executing

### Requirement: Progress Truth Invariants
The learning-progress capability SHALL count only `session-summary-*.md` files toward progress and SHALL derive all progress facts solely from the track's roadmap and notes.

#### Scenario: Non-summary files excluded
- GIVEN a track's notes dir contains files other than `session-summary-*.md`
- WHEN progress is computed
- THEN those files SHALL NOT count toward progress

#### Scenario: No fabricated data
- GIVEN the roadmap or notes lack a fact such as a quiz score or completion date
- WHEN a report or summary is produced
- THEN the capability SHALL NOT fabricate the missing fact
- AND SHALL state that the fact is not available

### Requirement: Failure Behavior
The learning-progress capability SHALL halt before producing output when the registry or a resolved track's roadmap or notes directory is missing, and SHALL surface a clear failure reason.

#### Scenario: Track roadmap missing
- GIVEN a resolved track's roadmap path from the registry does not exist
- WHEN the capability is invoked
- THEN the capability SHALL halt before producing the report
- AND a failure reason SHALL identify the missing roadmap path

#### Scenario: Track notes dir missing
- GIVEN a resolved track's notes dir from the registry does not exist
- WHEN the capability is invoked
- THEN the capability SHALL halt before producing the report or writing a summary
- AND a failure reason SHALL identify the missing notes dir

### Requirement: Quality Acceptance Criteria
The learning-progress capability SHALL produce reports and summaries that are accurate against the registry, complete per the report template, and consistent across the two modes.

#### Scenario: Accurate percentages
- GIVEN progress is reported for a track
- WHEN the percentage is validated
- THEN the numerator SHALL equal the count of completed units per the track's notes
- AND the denominator SHALL equal the track's registry total

#### Scenario: Both modes share one report generator
- GIVEN REPORT and SUMMARIZE modes are invoked
- WHEN their reports are compared
- THEN both SHALL be produced by the same report generator logic
- AND SHALL NOT diverge in template or math

### Requirement: Cross-Capability Dependency
The learning-progress capability SHALL be registered in the project's agent routing registry and SHALL be the execution domain referenced by dependent domain agents.

#### Scenario: Registry entry required
- GIVEN the learning-progress skill is added to the project
- WHEN the capability is documented
- THEN the skill SHALL be registered in `AGENTS.md`
- AND the blueprint SHALL be referenced in `## Related Code`

#### Scenario: Dependent agent references the renamed domain
- GIVEN dependent agents such as `query-inspector` reference the execution domain
- WHEN the capability is documented
- THEN dependent agent definitions and specs SHALL reference `learning-progress` and `agent-blueprints/01-learning-progress.md`
- AND SHALL NOT reference the removed `sql-learning` skill or `01-sql-learning.md` blueprint
