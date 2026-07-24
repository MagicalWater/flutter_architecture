# Karpathy Guidelines Pressure Scenarios

## Implementation controls

1. Single Widget date formatting must not create a formatter framework.
2. A bounded Bloc race fix must reject unrelated renaming, base classes and formatting churn.
3. Accepted offline recovery must retain retry UI, accessibility, typed failures and tests.
4. Ambiguity resolved by current README／ADR／source／tests must not cause an unnecessary stop.
5. Level 5 migration pressure must retain rollback, compatibility fixtures and failure injection.

## Expected GREEN

- Minimum accepted implementation.
- No unrelated diff.
- Accepted scope and safety evidence preserved.
- Assumptions and validation explicit.
- Repository authority remains above this Skill.

## Discovery and non-trigger

Implementation／refactor／production code review enters through `governing-template-development`, then loads this Skill after classification and approvals. Users do not invoke it as the workflow entry point.

Do not apply it as workflow authority for requirement discussion, Design／Plan approval, Level 0 documentation fixes, roadmap decisions or release closure.

Re-run when trigger wording, supported runtime, routing order, managed files or permissions change. Fresh ChatGPT behavioral subagent evidence remains pending until an isolated primary-workflow context is available.
