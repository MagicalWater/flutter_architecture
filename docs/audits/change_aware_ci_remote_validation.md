---
document_type: runtime-evidence
status: active
authoritative_for:
  - change-aware-ci-remote-validation
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Remote Validation

## Scope

本文件記錄Change-aware CI Task 6的本地full regression、change-class simulation、GitHub-hosted full-matrix push、documentation-only push與manual full-matrix acceptance。

## Local Regression

在commit `adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25`執行：

```txt
Python CI contracts: 54 passed
Documentation check: passed
Flutter analyze: passed in 5 packages
Flutter tests: passed in 5 packages
Generated consistency: passed
Shell syntax checks: passed
git diff --check: passed
```

原plan命令`python3 -m unittest discover -s tools -p 'test_*.py'`實際發現0個tests，因此不採為證據；改以`python3 -m unittest discover -s tools/ci -p 'test_*.py' -v`取得54個有效contract results。

## Local Change-class Simulation

```txt
docs-only     → full_ci=false, android_build=false, ios_build=false
Dart source   → full_ci=true,  android_build=true,  ios_build=true
Android native→ full_ci=true,  android_build=true,  ios_build=false
iOS native    → full_ci=true,  android_build=false, ios_build=true
VERSION       → full_ci=true,  android_build=true,  ios_build=true, release_full=true
unknown path  → full_ci=true,  android_build=true,  ios_build=true
```

## Full-matrix Push Acceptance

Implementation與workflow commits推送至：

```txt
SHA: adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25
CI run: 29981369234
iOS run: 29981369222
Android run: 29981369223
```

CI與iOS已完成成功；Android Development Debug APK已成功，Production Release APK與Android Summary在本文件首次提交時仍由GitHub-hosted runner執行。最終結果會在documentation-only與manual acceptance完成後回寫。

## Documentation-only Acceptance

本文件首次提交只修改managed Markdown，用於驗證：

- `CI / Quality`成功執行輕量文件與contract checks。
- `CI / Generated Consistency`與`CI / Tests`在原job內no-op成功，而不是整個job skipped。
- Android兩個artifact jobs skipped，classification與summary成功。
- `iOS / Simulator Build`以Ubuntu runner執行同名no-op成功。
- `iOS / Production Release Build` skipped。
- 不建立Android或iOS artifacts，不啟動macOS build runner。

Remote run IDs與job evidence將在此commit完成後回寫。

## Manual Full-matrix Acceptance

Documentation-only acceptance通過後，三份workflow將以`workflow_dispatch`對同一ref執行完整矩陣。Remote run IDs、jobs、runner與artifacts將在完成後回寫。

## Current Gate

```txt
Open P0: 0
Open P1 without disposition: 0
Local regression: Passed
Full-matrix push: In progress
Documentation-only acceptance: Pending
Manual full-matrix acceptance: Pending
Task 6 closure: Pending
```
