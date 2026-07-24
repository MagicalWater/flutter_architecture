---
name: starting-feature-work
description: Use when starting a new product feature, screen, user flow, or Figma-driven implementation in this repository.
---

# Starting Feature Work

## Core rule

This is a thin user-facing entry point. It does not own classification, approval, branch, Task, validation, or release policy.

**REQUIRED SUB-SKILL:** Use `governing-template-development` before feature analysis, Design, Plan, or implementation.

## Input contract

Accept a short brief containing any available combination of:

- feature or screen goal;
- Figma or other design source;
- behaviors or integrations to add;
- constraints, exclusions, or known dependencies.

Do not require the user to restate governance templates.

## Required behavior

1. Preserve the user's wording and intent as the request input.
2. Invoke `governing-template-development` and produce its Requirement Decision first.
3. Inspect the current feature, Design System, navigation, domain, data, API, state, accessibility, localization, offline, testing, and documentation boundaries only as routed by that decision.
4. If the user asked only to discuss or explore, do not start Design or implementation.
5. Follow the central governance Skill's approval, worktree／branch, Task, validation, release, and stop rules without duplicating them here.

## User-facing invocation

```txt
使用 repository-local starting-feature-work Skill。

[功能或畫面需求]
Figma：[網址，如有]
```
