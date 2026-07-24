---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-31-r4-task-and-skill-adoption-recovery-review
last_reviewed_baseline: 1.13.0
---

# Task 31-R4 — Two-layer Task and Skill Adoption Recovery Review

## Scope

Reviewed `two-layer-task-governance.md` and `skill-adoption-governance.md` against the approved Spec and Plan. Original implementation is treated as historical input, not proof of prior compliance.

## Focused findings and fixes

- P1 — Standard, Full and Full-critical modes were collapsed into one section, weakening the Level 2 versus Level 3–5 distinction. Split Standard and Full while retaining the same formal Task cycle.
- P1 — Completion commit prohibition after validation failure was implicit. Added a direct acceptance and commit gate.
- P1 — User approval state for proposed Design／Plan was missing from the Task reference. Added explicit state transitions and implementation prohibition.
- P1 — Evidence-chain fields were not listed. Added Task ID, findings, fixes, re-review, whole-task, authority, validation and commit requirements.
- P1 — Skill adoption lacked a durable registry schema, precise revalidation triggers and removal contract. Added all three.

## Focused re-review

Minimal, Simplified, Standard, Full and Full-critical responsibilities are now distinguishable. Ordinary findings remain inside the Task; only user-owned decisions, external blockers or approved-artifact-overturning findings stop execution. Release and post-release remain required before Milestone closure. Skill adoption cannot create parallel authority and now has upgrade and rollback evidence requirements.

## Whole-task and authority review

The Task reference owns executable acceptance gates; the adoption reference owns evaluation procedure. `AGENTS.md` remains policy authority, ADR owns stable architecture and tests／CI own mechanical enforcement. No duplicate current-state owner was introduced.

## Validation

- Required mode names, approval gate, validation failure, evidence chain, automatic continuation and closure clauses checked.
- Skill adoption statuses, registry, overlap, permissions, revalidation and rollback clauses checked.
- `python3 -m unittest tools.docs.test_check_docs` passed.
- `dart run melos run docs_check` passed.
- `git diff --check` passed.

## Disposition

Open P0 = 0. Open P1 without disposition = 0. Task 31-R4 accepted.
