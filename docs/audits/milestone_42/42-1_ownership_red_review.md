---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-42-task-42-1-ui-design-ownership-red
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-1 UI Design Ownership RED Review

## Scope

建立direct regression owners，證明current repository無法阻止兩個confirmed architecture failures：

1. `presentation/pages/write_precheck_projected_canvas.dart`直接擁有custom render/projection infrastructure；
2. `PencilCompatibilityVisualSpec`同時集中canonical metadata、palette、typography、dimensions/radius與gradients；
3. `implementation_mapping.json`完全缺少risk-selected UI design ownership evidence時，current validator仍錯誤PASS。

## Test Authoring Decision

**Required**。Milestone 41 holistic tests曾對current structure給出PASS，而Milestone 42 Requirement已確認這是治理盲點。Task 42-1因此先固定RED，不先搬source或修改machine policy。

## Flutter architecture RED evidence

Fresh command：

```txt
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
```

Expected RED實際重現：

```txt
presentation/pages owns custom render/projection infrastructure
PencilCompatibilityVisualSpec mixes UI design ownership domains
```

Synthetic controls同時PASS：

- existing bounded local overlay仍不被Milestone 41 whole-screen projection detector誤判；
- custom render/projection infrastructure fixture可被新的page-ownership helper辨識；
- generic `FeatureVisualSpec`同時集中canonical metadata/color/font/radius/gradient/asset時會被判catch-all；
- component-local單一geometry constant不會被generic-Spec detector誤判。

Detector不以file length、widget count或所有numeric literal作oracle。

## Mapping RED evidence

Fresh command：

```txt
python -m unittest tools.visual.test_pencil_implementation_mapping
```

Expected RED實際重現：

```txt
mapping-missing-ui-design-ownerships not found in []
```

這證明current validator在mapping完全沒有UI design ownership section時仍接受artifact；Task 42-2必須新增minimum-sufficient fail-closed contract。

## Focused review

- RED直接對應accepted Revised Design的Presentation ownership與UI Design Ownership Architecture。
- 沒有修改production source、Design System、asset authority或machine validator。
- 沒有建立global token/asset registry。
- generic-Spec detector只用於confirmed catch-all shape；local component constants仍合法。
- Asset governance在本Task只作未來ownership domain之一，沒有重複既有representation/provenance contract。

## Whole-Task review

Task 42-1只建立failure evidence，不宣稱production已修正。兩組direct RED均fresh reproducible，且negative/positive controls避免以形式主義規則取代responsibility ownership。

```txt
Task 42-1: accepted RED
Flutter architecture owner: intentionally FAIL until source ownership corrective
Mapping ownership owner: intentionally FAIL until Task 42-2
Open P0: 0
Open P1 without disposition: 0
```

