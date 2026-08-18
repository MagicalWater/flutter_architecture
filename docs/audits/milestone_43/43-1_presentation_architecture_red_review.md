---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-43-task-43-1-presentation-architecture-red
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Task 43-1 Presentation Architecture RED Review

## Scope

建立repository-wide Presentation responsibility architecture的第一個direct regression owner。此Task只固定RED與positive/negative controls，不修改production source、stable ADR、machine policy或Skills。

## Test Authoring Decision

**Required**。Milestone 43新增stable Presentation authority、role/cohesion與anti-formalism failure modes；現有Pencil-specific contract不足以成為一般Flutter feature的direct owner。

## Expected RED

Focused test：

```txt
cd apps/flutter_architecture
flutter test test/architecture/presentation_responsibility_contract_test.dart
```

Current repository預期只因stable authority尚未建立而RED：

```txt
Milestone 43 requires a stable ADR-032 authority
fresh admission must route to the stable Presentation authority
```

這個RED由Task 43-2修正；43-1不提前建立ADR-032。

## Synthetic controls

同一focused owner同時鎖定：

- `Page`／`View` source直接宣告custom RenderObject infrastructure → detected；
- handwritten `part`／`part of`把不同declared responsibility綁成同一library → detected；
- 同一primary owner的少量private helpers → allowed；
- local expand/collapse `setState` → allowed，不要求Cubit；
- Shell launcher與Dialog implementation分owner → allowed。

Detector刻意不使用：

- line count；
- class/widget count；
- fixed folder existence；
- `setState` ban；
- Bloc/Cubit presence。

## Fresh RED evidence

2026-08-18 fresh執行：

```txt
cd apps/flutter_architecture
flutter test test/architecture/presentation_responsibility_contract_test.dart
```

實際結果：

```txt
stable repository authority is discoverable from fresh admission → FAIL
Page or View orchestration cannot own custom render infrastructure → PASS
handwritten part cannot masquerade as a separate responsibility owner → PASS
cohesive private helpers may remain in one handwritten source file → PASS
local ephemeral UI state does not require Cubit or Bloc → PASS
surface launcher may differ from surface implementation owner → PASS
```

唯一RED root cause：

```txt
Milestone 43 requires a stable ADR-032 authority
```

這是accepted Plan預期由43-2修正的direct RED；不是test compile error，也不是production regression。

## Layer 1 — Focused review

- Test沒有用line count、class count、folder existence或Bloc/Cubit presence作oracle。
- Negative controls直接覆蓋Page/View + RenderObject與cross-responsibility handwritten `part`。
- Positive controls保護cohesive private helpers、local `setState`與launcher/surface分owner，不會把治理推向formalism。
- RED只鎖stable authority尚不存在，不提前修改ADR或production source。

Focused review：**PASS**。

## Fresh focused re-review

初次執行曾因test fixture raw-string quote錯誤造成compile failure；該failure不計入RED evidence。修正fixture後fresh重跑，test正常編譯並只留下預期ADR-032 authority assertion failure。

Fresh focused re-review：**PASS**。

## Layer 2 — Whole-Task review

43-1只建立direct RED與controls，沒有建立stable authority、machine implementation或production refactor。Scope與accepted Plan一致，且為43-2／43-3提供可驗證起點。

```txt
Task 43-1: accepted RED
Expected focused owner: intentionally FAIL until Task 43-2
Open P0: 0
Open P1 without disposition: 0
```
