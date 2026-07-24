---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-28-task-28-2-review
last_reviewed_baseline: 1.9.0
---

# Task 28-2 — Platform Adapter and App Composition Review

## Scope

- App-only `connectivity_plus` dependency。
- Provider result到typed state的adapter。
- App Composition Root registration與generated DI。

## Focused findings

### F1 — Latest major要求高於current Android Gradle Plugin

Disposition：current repository使用AGP 8.11.1；`connectivity_plus` 7.x要求AGP 8.12.1以上，因此採仍受維護且與current toolchain相容的6.1.5，不為單一plugin擴張native toolchain scope。

### F2 — Adapter若直接暴露plugin stream會洩漏provider type

Disposition：snapshot與stream都在adapter內映射為`ConnectivityState`，contract與consumer不引用`ConnectivityResult`。

### F3 — Adapter本身沒有native subscription可取消

Disposition：native stream subscription由Task 28-3的App controller持有並取消；adapter dispose只關閉後續access，避免假造不屬於adapter的subscription ownership。

## Re-review and holistic result

- Plugin dependency只存在App pubspec。
- Reusable packages與Catalog沒有plugin import。
- Empty／none／所有usable provider types均有mapping test。
- DI由App module建立interface binding。
- Generated DI只由build_runner更新。

## Validation

```txt
Adapter tests: pass
DI focused tests: pass
Analyze: pass
Open P0: 0
Open P1 without disposition: 0
```

Task 28-2 accepted，可進入Task 28-3。
