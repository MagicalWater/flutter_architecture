---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-24-post-release-remote-validation
last_reviewed_baseline: 1.6.1
---

# Milestone 24-7 — Post-release Remote Validation

## Purpose

本review補齊Milestone 24封存時尚未取得的GitHub-hosted runtime evidence，並記錄首次remote CI失敗後的systematic debugging、修正與re-validation。

## Initial Remote Failure

Template Baseline 1.6.0推送後：

- `CI / Quality`成功。
- `CI / Generated Consistency`成功。
- `CI / Tests`失敗。
- `Android / Release APK`成功。

唯一失敗為`packages/design_system/test/design_system_gallery_golden_test.dart`。Windows建立的golden在Ubuntu先出現0.53%差異；固定Flutter SDK字型後仍存在1.00%差異，證明問題包含host rasterization差異，而不是production UI regression。

## Findings and Fixes

| ID | Severity | Finding | Resolution |
| --- | --- | --- | --- |
| M24-7-R01 | P1 | Golden test依賴host預設字型，跨OS不具deterministic authority | 明確載入Flutter 3.41.6 SDK內Roboto與Material Icons |
| M24-7-R02 | P1 | Linux大小寫敏感檔案系統無法解析Windows可接受的字型檔名字面 | 在固定SDK目錄內進行case-insensitive精確檔名解析 |
| M24-7-R03 | P1 | Windows與Linux在相同字型下仍有Skia／host rasterization差異 | 建立Windows與Linux各自經review的平台golden authority，不放寬pixel tolerance |
| M24-7-R04 | P1 | 舊版官方Actions產生Node 20 deprecation annotation | 升級至Node 24世代major並維持full-SHA pinning |
| M24-7-R05 | P2 | Golden失敗缺少可下載的remote差異圖片 | Tests job失敗時上傳golden failure artifact，retention 14天 |
| M24-7-R06 | P1 | Melos `docs_check`寫死`python`，macOS預設僅提供`python3` | 改由Dart launcher跨平台解析`python3`、`python`或Windows `py -3` |

## Final GitHub-hosted Evidence

Commit：

```txt
2ea623c02b2f4957ef115ad17ea465a8235892ee
```

CI run `29887025664`：

- `CI / Quality`：success。
- `CI / Generated Consistency`：success。
- `CI / Tests`：success。
- Golden failure artifact step因tests成功而正確skip。

Android run `29887025645`：

- Generated consistency：success。
- Android release APK build：success。
- Artifact upload：success。

Artifact：

```txt
flutter-architecture-android-release-2ea623c02b2f4957ef115ad17ea465a8235892ee
size: 59,868,171 bytes
digest: sha256:80453c4478b4c745d773f6c7aab3d16e1626c24e0875cb82a047c51d766f891e
expires: 2026-08-05
```

## Release Decision

本次修正不新增新的template capability，屬CI跨平台相容性、debuggability與官方Action runtime相容性修正，因此依Versioning Policy發布PATCH：

```txt
1.6.0 → 1.6.1
```

## Final Status

```txt
Open P0: 0
Open P1: 0
GitHub-hosted CI: verified
GitHub-hosted Android artifact: verified
Production signing / deployment: still out of scope
```
