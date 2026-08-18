---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-41-task-41-1-layout-architecture-red
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Task 41-1 Layout Architecture RED Review

## Scope

建立 direct architecture regression owner，證明 current Pencil compatibility reference 雖然只有 single renderer、沒有 top-level `FittedBox`，仍以 canonical page coordinates + shared scale 重建 whole-screen page flow。

## Test Authoring Decision

Required。Fresh audit 已證明既有 tests 會錯誤 PASS，因此本 Task 必須先取得可重現 RED，再進 mapping／migration。

## RED evidence

Fresh command：

```txt
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
```

Expected RED：

```txt
WritePrecheckProjectedCanvas reconstructs page flow from canonical coordinates
and a shared whole-screen scale
```

Synthetic controls：

- bounded local `Stack`／`Positioned` fixture：PASS，不誤判。
- single renderer + canonical page coordinate projection fixture：PASS detector expectation，會被分類為 violation。

因此 direct owner 不是單純以 `Positioned` 數量判斷，而是針對 confirmed mechanism 的組合語意：page design height ownership、shared page scale、screen-root projected stack、positioned parent-data scaling。

## Review findings

第一次 synthetic positive fixture 沒有包含 production mechanism 的 `StackParentData` identity，導致 detector fixture 自身 false negative。已修正 fixture 使它重現 production pattern；沒有放寬 detector。

## Disposition

```txt
Task 41-1: accepted RED
Current production architecture test: intentionally FAIL until Task 41-4
Bounded-overlay negative control: PASS
Shortcut positive control: PASS
Open P0: 0
Open P1 without disposition: 0
```

此 RED commit 不宣稱 production acceptance；它是後續 corrective 的 primary regression owner。
