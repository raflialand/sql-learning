# learning-progress Specification

## Purpose

Govern the learning-progress capability: tracking progress across multiple learning tracks (SQL Fundamentals, Data Quality Engineer, Data Engineering, and future ones) via a shared track registry, reporting position and percentage per track, and persisting lossless session summaries per track.

## Requirements

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

## Boundaries

### In scope
- Reading `learning/00-notes/tracks.md` as the single source of truth for track definitions.
- Resolving the target track (explicit keyword → most recently active → ask).
- Emitting per-track progress reports and persisting per-track session summaries.
- Computing progress against each track's registry total.

### Out of scope
- Tutoring — teaching happens in conversation; this capability only tracks, persists, and reports.
- Modifying roadmaps or creating quizzes.
- Creating or maintaining tracks outside the registry (add tracks by editing `learning/00-notes/tracks.md`).
- Acting as an OpenSpec planning agent (planning is the responsibility of `openspec-agent`).

## Related Code

- `learning/00-notes/tracks.md` — the track registry (single source of truth)
- `.opencode/skills/learning-progress/SKILL.md` — the learning-progress skill implementation
- `agent-blueprints/01-learning-progress.md` — the canonical agent plan
- `AGENTS.md` — agent routing registry (execution capability reference)
