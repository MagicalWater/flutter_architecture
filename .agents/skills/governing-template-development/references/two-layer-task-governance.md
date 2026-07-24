# Two-layer Task Governance

## Modes

### Minimal — Level 0

```txt
change → diff review → focused validation → authority check → commit
```

### Simplified — Level 1

```txt
reproduce／confirm → implement with TDD or focused fix → focused review
→ findings → fix → re-review → affected validation → authority check → commit
```

### Standard — Level 2

Use the complete formal Task cycle for Design, Plan and each implementation unit. Feature regression is required; full workspace regression is conditional on affected boundaries.

### Full — Level 3–4

Every Design Spec, Implementation Plan and implementation unit is a formal Task:

```txt
create／implement
→ focused review
→ findings
→ fix
→ focused re-review
→ whole-task holistic review
→ documentation authority check
→ required validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
→ next Task
```

Design must pass before Plan creation. Plan must pass before implementation.

## Automatic continuation

After a Task passes, continue directly to the next Task. Do not stop for ordinary findings, failed tests, implementation defects or stale documents; fix and re-run the gate.

Stop only for user-owned scope/architecture decisions, external/manual blockers, P0/P1 findings overturning approved artifacts, or complete Milestone closure.

## Milestone closure

```txt
holistic review
→ cross-Task consistency
→ architecture and authority review
→ runtime／remote evidence
→ full regression
→ findings and fixes
→ holistic re-review
→ VERSION／CHANGELOG／roadmap/current authority sync
→ release and archive decision
→ commit and push
→ clean-checkout／post-release validation
→ formal closure
```

The last implementation Task does not complete a Milestone. Open P0 must be zero and every P1 must have disposition.

## Acceptance and commit gate

A Task may be committed with completion semantics only after all required validation passes. A failing Task stays open or is explicitly blocked／rejected. A later Task may repair it, but must record the recovery and cannot rewrite the earlier gate as passed.

Design and Plan remain `proposed` until their full Task cycle and explicit user approval complete. Implementation cannot start from a proposed Plan.

## Evidence chain

Each formal Task records Task ID, artifact scope, focused findings, fixes, fresh re-review, whole-task coverage, authority check, exact validation and independent commit. `Resolved` without fix and re-review evidence is insufficient.

## Critical additions — Level 5

Require rollback/recovery, compatibility matrix, migration fixtures, failure injection, platform artifacts and explicit deferred scope where applicable.
