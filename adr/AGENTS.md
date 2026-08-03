# AGENTS.md — Architecture Decision Records

## Purpose

Define conventions for Architecture Decision Records (ADRs) in this repository.

## Naming Convention

```
adr/{agent-name}/ADR-{NNN}-{slug}.md
```

- `{agent-name}`: the name of the agent that created the ADR, matching its `.opencode/agents/` filename (e.g. `openspec-agent`)
- `{NNN}`: zero-padded sequential number scoped to the agent directory (e.g. `001`, `012`). Each agent maintains its own sequence.
- `{slug}`: lowercase kebab-case description (e.g. `adopt-postgres-for-persistence`)

## Template

Every ADR SHALL include the following sections:

```markdown
# ADR-{NNN}: {Title}

## Status
<!-- draft | proposed | accepted | deprecated | superseded -->

## Context
<!-- What problem are we solving? What constraints exist? -->

## Decision
<!-- What did we decide? Be specific. -->

## Consequences
<!-- What becomes easier? What becomes harder? What are the risks? -->
```

## Lifecycle

1. **Draft** — Initial write-up, not yet proposed to the team.
2. **Proposed** — Shared for review and feedback.
3. **Accepted** — Approved and considered binding.
4. **Deprecated** — No longer applicable (superseded or obsolete).
5. **Superseded** — Replaced by a newer ADR. Reference the replacement.

When superseding, add the replacement reference to the deprecated ADR's `## Status` line:

```markdown
## Status
Superseded by [ADR-{NNN}](ADR-{NNN}-{slug}.md)
```

## Related

- `openspec/AGENTS.md` — Full methodology (canonical/delta formats, lifecycle, archive safety)
