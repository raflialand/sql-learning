# Spec Deltas for query-inspector

## MODIFIED Requirements

### Requirement: Cross-Capability Dependency
The query-inspector capability SHALL operate within the SQL track of the learning-progress execution domain and SHALL be registered in the project's agent routing registry.

#### Scenario: Dependency on the learning-progress domain
- GIVEN the query-inspector capability serves the SQL track managed by the learning-progress capability
- WHEN the capability is documented
- THEN the spec SHALL reference the learning-progress skill and agent blueprint in `## Related Code`
- AND the capability SHALL NOT modify the learning-progress skill or agent blueprint

#### Scenario: Registry entry required
- GIVEN the query-inspector agent is added to the project
- WHEN the capability is documented
- THEN the agent SHALL be registered in the Domain agents table of `AGENTS.md`
- AND the agent definition SHALL be referenced in `## Related Code`

> **Replaces**: The previous requirement text being modified. Include the full original `### Requirement:` header and all scenario text for exact matching during archive merge.
>
> ### Requirement: Cross-Capability Dependency
> The query-inspector capability SHALL operate within the sql-learning execution domain and SHALL be registered in the project's agent routing registry.
>
> #### Scenario: Dependency on the sql-learning domain
> - GIVEN the query-inspector capability serves the sql-learning execution domain
> - WHEN the capability is documented
> - THEN the spec SHALL reference the sql-learning skill and agent blueprint in `## Related Code`
> - AND the capability SHALL NOT modify the sql-learning skill or agent blueprint
>
> #### Scenario: Registry entry required
> - GIVEN the query-inspector agent is added to the project
> - WHEN the capability is documented
> - THEN the agent SHALL be registered in the Domain agents table of `AGENTS.md`
> - AND the agent definition SHALL be referenced in `## Related Code`
