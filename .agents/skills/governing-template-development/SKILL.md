---
name: governing-template-development
description: Use when evaluating, planning, implementing, reviewing, migrating, releasing, or governing work in this Flutter template repository.
---

# Governing Template Development

## Core rule

Before design, planning, implementation or review, classify the work and produce a Requirement Decision. Repository policy and current artifacts override this skill. This skill orchestrates Superpowers; it does not replace them.

## Required sequence

1. Inspect the request and relevant current authority.
2. Read [work classification](references/work-classification.md) and select Level 0–5.
3. Produce the Requirement Decision below.
4. Read [artifact routing](references/artifact-routing.md) and select mandatory, optional and forbidden artifacts, skills and validation.
5. Apply [two-layer Task governance](references/two-layer-task-governance.md) at the selected mode.
6. Use the routed Superpowers skills in order.
7. Keep current authority, review evidence and release state synchronized.

## Requirement Decision

```md
## Requirement Decision

- Request:
- Problem:
- Current behavior:
- Expected behavior:
- Value:
- Classification:
- Decision: Accept | Accept with reduced scope | Defer | Reject
- Scope:
- Non-goals:
- Behavioral requirements required:
- Design Spec required:
- Implementation Plan required:
- ADR required:
- Task governance mode:
- Worktree／branch:
- Regression level:
- Release required:
- Post-release validation:
- Required Superpowers skills:
- Required artifacts:
```

Do not invent artifacts for Level 0／1. Do not downgrade cross-cutting, architecture, migration, security, platform or release-critical work to avoid governance.

## Decision gates

- `Accept`：problem、value、scope與success criteria清楚。
- `Accept with reduced scope`：保留價值並明確削減scope與non-goals。
- `Defer`：記錄前置條件、重新評估條件與roadmap／backlog disposition。
- `Reject`：記錄與template定位、成本、風險或重複能力的衝突。

## Superpowers relationship

- Use `brainstorming` for accepted Level 2–5 design work.
- Use `writing-plans` only after the Design Spec completes repository Task governance and user approval.
- Use `test-driven-development` for feature and bug implementation.
- Use `systematic-debugging` for failures or unexpected behavior before fixes.
- Use `using-git-worktrees` when isolation is required by the routing matrix.
- Use `subagent-driven-development` or `executing-plans` for approved plans.
- Use review skills and `verification-before-completion` as methods inside repository review gates.
- `finishing-a-development-branch` cannot declare repository or Milestone closure before release and post-release gates pass.

## Stop and continue

Continue automatically after an accepted Task. Stop only for:

1. Scope or architecture decision requiring the user.
2. External service, credential, manual action or environment blocker.
3. A P0／P1 finding that overturns an approved Spec or Plan.
4. Entire Milestone completion.

Ordinary findings, test failures, implementation errors and stale documentation are fixed and re-verified without stopping.

## Skill adoption

Before adding or updating another skill, apply [skill adoption governance](references/skill-adoption-governance.md). Use [pressure scenarios](references/pressure-scenarios.md) to verify this skill and future workflow changes.
