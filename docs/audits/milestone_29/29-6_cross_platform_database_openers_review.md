---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-29-task-29-6-review-evidence
last_reviewed_baseline: 1.10.0
---

# Task 29-6 — Cross-platform Database Openers and Web Storage Disposition Review

## Scope

建立App-owned native／Web Drift opener、精確database path policy、background native
executor與Web assets，並對舊`sqflite_common_ffi_web` storage做出明確upgrade disposition。

## Implemented

- Native使用`NativeDatabase.createInBackground`。
- Android／iOS沿用既有sqflite database directory並開啟
  `flutter_architecture.db`；此directory resolver為Task 29-8移除sqflite dependency前的
  transitional bridge。
- macOS／Windows／Linux使用App documents directory與相同精確檔名。
- Web使用`WasmDatabase.open`、database name `flutter_architecture`、
  `sqlite3.wasm`與`drift_worker.js`。
- repository-owned `web/drift_worker.dart`可重現worker generation。
- `sqlite3.wasm`更新為resolved `sqlite3 3.5.0` release asset；SHA-256：
  `41cf968998241465d8b1dfffb1eb60dd10c35de5022a3647e14174ea3af84143`。

## Web Storage Investigation

現有`sqflite_common_ffi_web 1.1.1` source顯示：

- IndexedDB name：`sqflite_databases`。
- virtual database root：`/`。
- App logical file：`/flutter_architecture.db`。
- worker：`sqflite_sw.js`，使用sqflite worker protocol。

Drift opener則使用自己的storage probing、database name `flutter_architecture`與
`drift_worker.js`。兩者不是同一browser storage／worker contract，無runtime evidence
可支持automatic preservation。

## Web Disposition

選擇：`explicit reset`。

理由：Web目前依current platform authority維持Dependency-ready，沒有tracked Web
platform scaffold、Supported claim或正式production distribution。舊experimental Web
AuthUser／Catalog local SQLite data不保證保留；credential storage仍遵守其獨立contract。
不得宣稱in-place import。

## Focused Review Findings

### Finding 1 — 舊Wasm asset與resolved sqlite3不匹配

舊`web/sqlite3.wasm` SHA-256為
`8766db025f5d5b6f24c6a51cc9dec843ab7a7720e3dfa5b47d70d33db96d506b`。

**Disposition:** 以sqlite3 3.5.0 official release asset替換並加入hash test。

### Finding 2 — Pub-cache worker source無法直接解析App package graph

直接編譯pub-cache中的`drift_worker.dart`失敗。

**Disposition:** 加入repository-owned `web/drift_worker.dart`，從App package context
生成`drift_worker.js`。

### Finding 3 — Web platform scaffold不存在

`flutter build web`回報project未設定Web。Current authority明確將Web維持
Dependency-ready，禁止只為本Task暗中提升為Supported或新增runner scope。

**Disposition:** 不新增Web scaffold；保留build blocked evidence。Web runtime／artifact
驗證待獨立platform enablement milestone。此限制不影響Drift capability與assets治理，
但不得宣稱Web runtime已通過。

## Focused Re-review

- Path policy對mobile與desktop分支有獨立contract tests。
- macOS production opener實際建立精確檔名、執行query並驗證idempotent close。
- Web opener、worker source、compiled worker與Wasm hash一致。
- `sqflite_sw.js`依plan保留到Task 29-8 removal gate。
- 未提升Web／Desktop Supported claim。

## Validation

- Native path policy tests：passed。
- macOS background opener smoke：passed。
- Web storage policy test：passed。
- Web asset existence/hash test：passed。
- `dart compile js web/drift_worker.dart -O4 -o web/drift_worker.js`：passed。
- `flutter build web`：blocked，因current authority刻意沒有Web scaffold。
- `dart run melos run analyze`：passed。
- `dart run melos run docs_check`：passed。
- `git diff --check`：passed。

## Exit Criteria

- Open P0：0。
- Open P1 without disposition：0。
- Web runtime support claim：not made。
- Task 29-6：accepted with explicit platform-policy limitation。
