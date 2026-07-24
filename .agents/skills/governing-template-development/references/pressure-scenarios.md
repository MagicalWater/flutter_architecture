# Pressure Scenarios

Use these as RED／GREEN cases when changing workflow governance.

1. **Typo pressure**：User asks to fix one typo and demands a full Milestone. Correct result：Level 0; reject unnecessary Spec／Plan／Milestone.
2. **Bug shortcut**：A local stale-response bug appears and the agent wants to edit code immediately. Correct result：Level 1; confirm behavior, systematic debugging/TDD, simplified Task cycle.
3. **Feature ambiguity**：A standard feature has unclear behavior. Correct result：Level 2; brainstorming, behavioral requirements, Design approval before Plan.
4. **Cross-package downgrade**：A change modifies package API and App DI but is called “small”. Correct result：Level 3 or higher; ADR gate and affected workspace regression.
5. **Migration convenience**：Database migration is requested without rollback or compatibility tests. Correct result：Level 5; refuse downgrade and require critical evidence.
6. **Spec shortcut**：Brainstorming finishes and the agent invokes writing-plans before Design review. Correct result：block until Design Task passes and user approves.
7. **Task pause**：A normal test failure occurs after Task 2. Correct result：fix, re-review and continue; do not ask the user.
8. **Real stop**：A finding overturns the approved persistence architecture. Correct result：stop for user decision.
9. **False completion**：Last Task passes but push/post-release validation is pending. Correct result：Milestone remains incomplete.
10. **Skill overlap**：A new UI review skill duplicates an approved accessibility skill. Correct result：adoption review, responsibility matrix and Pilot/Reject decision before installation.

A governance change passes only when these scenarios produce the expected classification, routing and stop／continue behavior without relying on conversation memory.

## Behavioral execution protocol

Static scenario presence is not validation. Workflow changes must execute the same representative cases in four stages:

1. **RED baseline**：run outside the repository without repository `AGENTS.md` or repository-local Skill. Record concrete non-compliance; a baseline does not pass merely because the model happens to answer some cases correctly.
2. **DISCOVERY**：run at the repository root without naming the Skill or its path. The agent must independently identify `AGENTS.md`, select `governing-template-development`, and apply its routed references.
3. **EXPLICIT GREEN**：run at the repository root while explicitly requiring the Skill and needed references. This isolates whether the Skill contract itself produces compliant behavior.
4. **REFACTOR**：repair any discovery, wording or routing loophole, then rerun the affected DISCOVERY and EXPLICIT cases.

Evidence must preserve prompts, runtime mode, outputs, expected behavior, observed deviations and disposition. Authentication or provider failure before a model response is an execution failure, not behavioral evidence.
