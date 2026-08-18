---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-41-task-41-3-reference-architecture-detector
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Task 41-3 Reference Architecture Detector Review

## Scope

把 Task 41-1 的 direct RED owner 強化為 current reference source architecture gate；它掃描實際 delegated production owner，而不是只看 `WritePrecheckView`。

## Detector ownership

Direct owner同時驗證：

- confirmed old mechanism 組合會 FAIL；
- bounded local overlay synthetic fixture不誤判；
- current reference 必須有 `Column` + flow-region page composition；
- current reference 不得重新出現 whole-page `designHeight=1672`、custom projected `RenderStack` 或已確認的 canonical section page-top constants。

此 detector 是 template reference 的 direct regression owner，不是 generic repository-wide Dart AST framework，也不以 `Positioned` 數量作判決。

## Fresh validation

在 Task 41-4 candidate 上 fresh 執行：

```txt
flutter test test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
PASS
```

同一 test 在 Task 41-1 old mechanism 上已有可重現 RED evidence。

## Review disposition

```txt
Delegation blind spot: fixed
Bounded overlay false positive: not found
Generic linter scope creep: not introduced
Open P0: 0
Open P1 without disposition: 0
Task 41-3: PASS
```
