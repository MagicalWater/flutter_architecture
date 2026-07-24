---
name: karpathy-guidelines
description: Use when implementing, refactoring, or reviewing production code where unnecessary abstraction, unrelated changes, scope creep, or unverifiable work may occur.
---

# Karpathy Guidelines

Adapted from `multica-ai/andrej-karpathy-skills`, path `skills/karpathy-guidelines/SKILL.md`, pinned commit `2c606141936f1eeef17fa3043a72095b4765b9c2`.

**REQUIRED GOVERNANCE:** The current Requirement Decision, accepted Design／Plan／ADR, repository policy and routed Superpowers workflow override these heuristics.

## Think before coding

- Read the affected authority, source, callers and tests before editing.
- Resolve ambiguity from repository evidence when possible; stop only when approved scope or architecture truly needs a user decision.
- State assumptions that affect behavior or validation.

## Simplicity first

- Implement the smallest solution that satisfies accepted scope.
- Reuse current code, platform features and installed dependencies before adding abstractions.
- Do not add interfaces, factories, registries, generic frameworks or future scaffolding without demonstrated need.

## Surgical changes

- Keep the diff inside the Task boundary.
- Do not combine a bounded fix with renaming, formatting, comment cleanup or adjacent refactors.
- Fix a shared root cause when evidence shows one; do not patch unrelated paths “while here”.

## Goal-driven execution

- Define the observable result and the command or evidence that proves it.
- A change is not complete until required review, tests and repository validation pass freshly.
- Record deliberate non-goals and rejected scope expansion.

## Restrictions

This Skill must not classify work; change approval, stop, Task, branch, commit, release or closure gates; shrink accepted scope; remove required security, migration, rollback, accessibility, error handling or validation evidence; or trigger for pure discussion, approval decisions, roadmap disposition, documentation-only Level 0 work or release metadata unless production code is also under review.

Pressure protocol: [references/pressure-scenarios.md](references/pressure-scenarios.md).
