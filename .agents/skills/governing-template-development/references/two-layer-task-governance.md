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

### Standard／Full — Level 2–5

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

## Critical additions — Level 5

Require rollback/recovery, compatibility matrix, migration fixtures, failure injection, platform artifacts and explicit deferred scope where applicable.
