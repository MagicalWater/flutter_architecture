---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-43-task-43-3-machine-contract
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Task 43-3 Machine Contract Review

## Scope

把43-1的RED fixture升級為repository-owned、high-confidence Presentation architecture machine contract。Semantic change-reason仍由review/pressure負責，不把它偽造成line-count或folder lint。

## Machine owners

- `test/architecture/support/presentation_architecture_policy.dart`：最小source policy helper。
- `test/architecture/presentation_responsibility_contract_test.dart`：stable authority、repository Page/View scan與synthetic controls。
- Milestone 42既有`write_precheck_architecture_contract_test.dart`繼續擁有anti-catch-all與Pencil-specific invariants，不複製到generic helper。

## Hard rules

- Repository source中宣告`*Page`／`*View`的handwritten file若同時宣告custom RenderObject infrastructure → FAIL。
- Different declared responsibility以handwritten `part`／`part of`綁成同一library → representative fixture FAIL。
- ADR-032與fresh admission route遺失 → FAIL。

## Explicitly not machine-enforced

- file line count；
- class/widget count；
- fixed presentation folder shape；
- `setState`／Hook／Controller存在；
- Bloc/Cubit存在或不存在；
- private helper是否一定拆檔。

## Test Authoring Decision

**Required**。本Task新增長期machine failure owner；source refactor尚未開始。

## Fresh validation

```txt
cd apps/flutter_architecture
flutter test \
  test/architecture/presentation_responsibility_contract_test.dart \
  test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
→ 13/13 PASS

dart run melos run docs_check
→ PASS

git diff --check
→ PASS
```

## Layer 1 — Focused review

- Generic helper只辨識high-confidence `Page/View + RenderObject infrastructure`與declared cross-responsibility handwritten `part` fixture。
- Repository-wide Page/View scan目前GREEN，證明Milestone 42已把RenderObject從Page ownership移除。
- `part`規則暫以representative fixture鎖語意，不對所有generated／same-owner `part`做全域keyword ban。
- Milestone 42 anti-catch-all仍由existing Pencil test擁有，沒有複製第二套detector。
- Positive controls確保private helper與local UI state不被hard fail。

Focused review：**PASS**。

## Fresh focused re-review

重新檢查generic helper與existing Pencil detector分工，未發現line/class/folder heuristic或Pencil-specific contract外溢。

Fresh focused re-review：**PASS**。

## Layer 2 — Whole-Task review

43-3已建立可長期保留的machine owner，且尚未修改production source；下一步可依Plan進入43-4 reference decomposition。

```txt
Task 43-3: accepted
Open P0: 0
Open P1 without disposition: 0
```
