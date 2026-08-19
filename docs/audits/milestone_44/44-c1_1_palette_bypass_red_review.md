---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-44-post-closure-color-ownership-c1-task-c1-1
last_reviewed_baseline: 1.23.0
---

# M44 Post-closure Corrective C1 — Task C1-1 Palette Bypass RED Review

## Scope

建立 direct regression owner，證明 current Write Precheck production 可以在 feature-local shared palette owner 已存在時，仍重新 hard-code 相同 exact ARGB value。

## Test Authoring

- Disposition：Required。
- Primary owner：`apps/flutter_architecture/test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart`。
- Failure oracle：只比較 `WritePrecheckPalette` 已宣告的 exact values 與 consumer direct `Color(<same value>)`；不以 raw-color count、近似 RGB 或檔案數判定。
- Positive control：consumer 使用 palette 未宣告的 component-local exact color必須合法。

## Initial test defect and correction

首次執行時 Windows path separator 使 palette owner file 自己被誤列為 consumer，產生四個 false positives。此結果未被接受為 RED。

修正 exclusion path normalization 後 fresh rerun，只剩一個 production failure：

```txt
write_precheck_content_components.dart
hard-codes shared palette literal 0xFF7F94A7 owned by dim
```

Positive control `0xFF445566` 未被 palette 擁有，因此 PASS。

## Focused validation

Command：

```txt
cd apps/flutter_architecture
flutter test test/features/pencil_compatibility/presentation/write_precheck_architecture_contract_test.dart
```

Result：**EXPECTED RED**。

```txt
existing architecture controls: PASS
shared palette literal bypass: FAIL exactly on 0xFF7F94A7 / dim
component-local exact color positive control: PASS
```

## Layer 1 — Focused review

- failure source為 current production owner bypass：PASS。
- test本身不禁止所有 raw colors：PASS。
- palette owner source已正確排除：PASS。
- 未修改 production source：PASS。
- 未修改 `.pen`／golden／threshold：PASS。

Focused review：**PASS / RED accepted**。

## Layer 2 — Whole-Task review

C1-1 已建立 deterministic RED，且 failure 與 accepted Design／Plan 完全一致；沒有額外 scope 或 false-positive oracle。

Open P0：0。

Open P1 without disposition：0。

Task C1-1：**ACCEPTED RED**。

