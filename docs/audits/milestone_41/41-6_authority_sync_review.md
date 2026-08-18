---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-41-task-41-6-authority-sync
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Task 41-6 Authority Sync Review

## Scope

在 Task 41-4/41-5 runtime truth成立後，將constraint／relationship-owned screen layout同步到stable ADR、Agent procedure與human Guide；不建立第二份layout authority。

## Stable contract

- canonical page coordinates只作design evidence，不是runtime page coordinate system；
- normal App screen major-section placement由Flutter constraints、edge inset、alignment、sibling gap與container relationships擁有；
- one renderer、真Flutter widgets、沒有`FittedBox`都不能豁免whole-screen canonical-coordinate reconstruction；
- bounded local `Stack`／`Positioned`合法，但只能擁有local overlay composition；
- 真正spatial surface必須在accepted Design核准`intentional-spatial-canvas`並提供`approval_ref`；
- screen layout machine evidence由initiative-local `implementation_mapping.json` schema 2擁有。

## Authority ownership

```txt
ADR-028
→ stable architecture boundary

implementing-pencil-flutter-design references
→ Agent mapping / validation procedure

implementation_mapping.json + validator
→ machine screen-layout disposition

pencil_to_flutter_workflow.md
→ human routing summary
```

沒有新增generic Dart linter、global layout registry或第二個Pencil domain Skill。

## Fresh validation

```txt
python -m unittest \
  tools.docs.test_pencil_single_renderer_policy \
  tools.docs.test_pencil_representation_mapping_policy \
  tools.visual.test_pencil_implementation_mapping

35 tests PASS

dart run melos run docs_check
PASS

git diff --check
PASS
```

## Review disposition

```txt
ADR / Skill / Guide consistency: PASS
Machine wording owner: PASS
Bounded-overlay exception preserved: PASS
Spatial exception approval gate: PASS
Open P0: 0
Open P1 without disposition: 0
Task 41-6: PASS
```
