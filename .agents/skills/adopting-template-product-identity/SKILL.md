---
name: adopting-template-product-identity
description: Use when adopting this Flutter template into a concrete product by changing cross-platform Android and iOS product identity or development, staging, and production display-name mapping.
---

# Adopting Template Product Identity

## Core rule

This is a thin optional user-facing entry point. It does not own classification, approval, worktree, Task, validation, release, environment contract, signing, or Store policy.

**REQUIRED SUB-SKILL:** Use `governing-template-development` before adoption analysis, Design, Plan, or repository mutation.

Repository policy, accepted Design／Plan／ADR, current source, tests and runtime evidence override this Skill.

## Trigger boundary

Use this Skill for accepted work that adopts the template into a concrete product by changing cross-platform Android／iOS product identity or development／staging／production display-name mapping.

Do not treat these as automatic triggers:

- visual-only rebranding, App icon or screen-title changes;
- API-only configuration changes;
- bounded single-platform identifier repair;
- environment addition, rename, ordering or suffix changes;
- production signing, credential custody or Store distribution.

Those requests return to `governing-template-development` for classification.

## Input and mutation gates

Distinguish three scopes:

1. **Discussion／inventory only** — may inspect current authority and propose candidate values without mutation.
2. **Identity projection mutation** — requires an explicit base identifier plus confirmed development, staging and production display names.
3. **Real API build／runtime closure** — additionally requires valid staging and production API domains when those environments are included in accepted evidence scope.

Never guess the base identifier. A product name may generate candidate display names, but it cannot silently confirm them. Missing API domains leave related build／runtime evidence `Pending`; do not use template placeholders as proof.

Never write or retain keystore passwords, private keys, Apple certificates, provisioning credentials, service-account secrets, API tokens or other credentials in tracked files.

## Required reading

After central classification, read the current versions of:

```txt
AGENTS.md
VERSION
docs/project_context.md
docs/adr/adr-014-app-configuration-environment-entrypoints.md
docs/adr/adr-025-native-environment-mapping-product-identity-contract.md
docs/guides/native_environment_adoption.md
apps/flutter_architecture/config/environments.json
Android and iOS current projections
tools/ci/verify_environment_contract.py
tools/ci/test_environment_contract.py
related build scripts and tests
```

This Skill stores only the reading route. It does not copy mapping values, platform procedures or exact verification commands.

## Required behavior

1. Preserve the user's original scope and any discussion-only restriction.
2. Delegate to `governing-template-development` and produce its Requirement Decision first.
3. Classify the request as complete template adoption, bounded repair or architecture change.
4. Inventory `environments.json`, Dart entrypoints, Android projection, iOS projection and verifier expectations before mutation.
5. Disposition pre-existing drift before applying a new identity.
6. Use manifest-first ordering: update the accepted manifest authority before synchronizing projections.
7. Use `docs/guides/native_environment_adoption.md` as the complete procedure and current exact-command authority.
8. Report evidence only as `Verified`, `Statically verified`, `Pending`, `Blocked` or `Not in scope`.
9. Never describe static iOS projection checks as an Xcode build.

## Hard stops and escalation

Stop mutation or return to central classification when any of these apply:

- missing or invalid base identifier;
- unconfirmed display names;
- duplicate environment identifiers or suffix conflicts;
- environment addition, rename, ordering or entrypoint changes;
- tracked secrets, signing credentials or credential custody;
- production signing or Store distribution;
- unresolved manifest／native drift;
- required platform or runtime evidence is unavailable.

Do not weaken verifier rules, change supported-platform claims, create a second identity mapping, or copy the Guide's exact command suite into this Skill.

## Forbidden responsibility

This Skill must not classify its own work, approve Design or Plan, choose branch／worktree policy, accept Tasks, close releases, change the environment contract, own signing, or claim Store readiness.
