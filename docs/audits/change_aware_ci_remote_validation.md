---
document_type: runtime-evidence
status: accepted
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

三份workflow均完成成功：

```txt
CI / Classify Changes: success
CI / Quality: success
CI / Generated Consistency: success
CI / Tests: success
Android / Classify Changes: success
Android / Development Debug APK: success
Android / Release APK: success
Android / Summary: success
iOS / Classify Changes: success
iOS / Simulator Build: success
iOS / Production Release Build: success
```

Artifacts：

```txt
8553366813 android-development-debug-adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25
  sha256:8913d144ef4eeab6f35fe23b80ecceafd3320b1bbafbbd27ce45f61d8605bf11
8553447624 android-production-release-adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25
  sha256:1b04323992bee30ef8301fc3e17955a7eedbddab6ec4bd8c813b5e8605a8e65a
8553311415 ios-development-toolchain-adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25
  sha256:a0c3e7dafd336539e1768631da9ee082df59beef5a1f7c5cae93992462fc3e84
8553336959 ios-development-debug-simulator-adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25
  sha256:164d7249f11a6e2169f1295a63e35937b3865ad58f4896d91de0fcf57edca33a
8553318224 ios-production-toolchain-adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25
  sha256:9a7126e11c3cdb59bb585f5cea3ffbfe1ef9fa97dad391a919178cfbb5a7afe0
8553338810 ios-production-release-adc9d650971f1a0c0bd127dfe5fbfaf6fbcaac25
  sha256:eed9f9f9fb7ee778b2c4e30e52edeba0a9e9d315ad000d3f5c8e58f384ab4b96
```

## Documentation-only Acceptance

Acceptance commit：

```txt
SHA: 0607058a3ae40265db5bf70bfceba0d694bec82d
CI run: 29981836185
Android run: 29981836193
iOS run: 29981836201
```

Remote結果：

- `CI / Quality`在`ubuntu-24.04`成功執行documentation、workflow contracts與whitespace；Java、Flutter、dependency resolution與analyze均skipped。
- `CI / Generated Consistency`與`CI / Tests`job本身success，原重量steps skipped，各自同job no-op success。
- Android Development Debug與Release APK jobs均`skipped`；`Android / Summary`在`ubuntu-24.04`success。
- `iOS / Simulator Build`保留原job名稱，在`ubuntu-24.04`執行no-op success。
- `iOS / Production Release Build`為`skipped`且沒有runner instance。
- CI、Android與iOS三個runs的artifact count均為0。
- 沒有啟動macOS build runner。

因此documentation-only路徑沒有破壞stable required-check名稱，也沒有建立平台artifact或遞迴觸發新的full evidence需求。

## Manual Full-matrix Acceptance

Manual acceptance ref：

```txt
SHA: 0607058a3ae40265db5bf70bfceba0d694bec82d
CI run: 29981898363
Android run: 29981899568
iOS run: 29981900806
```

Jobs與runners：

```txt
CI Classify / Quality / Generated Consistency / Tests: success, ubuntu-24.04
Android Classify / Development Debug APK / Release APK / Summary: success, ubuntu-24.04
iOS Classify: success, ubuntu-24.04
iOS Simulator Build: success, macos-15
iOS Production Release Build: success, macos-15
```

Manual artifacts：

```txt
8553579819 android-development-debug-0607058a3ae40265db5bf70bfceba0d694bec82d
  sha256:11ba32773bbbea5dc7636234c328d216f31ef52c5d0cd0610e4e6851813a0c18
8553660551 android-production-release-0607058a3ae40265db5bf70bfceba0d694bec82d
  sha256:3b51b8f38287c549289a6e8e06f7e2f1b7cf6b848ee1cb0d92254d51e145f649
8553539816 ios-development-toolchain-0607058a3ae40265db5bf70bfceba0d694bec82d
  sha256:5c2ebe93de8bc9d62d26b7e13b2b2ead65e015cc6532996d712256392f5fe80a
8553560404 ios-development-debug-simulator-0607058a3ae40265db5bf70bfceba0d694bec82d
  sha256:c43f36475ce009277f497b693e315a7a5fc66e672cafaa3538c0e3fef08cc325
8553515259 ios-production-toolchain-0607058a3ae40265db5bf70bfceba0d694bec82d
  sha256:d8155836fe978faf57760c64b80fff7faa852a2006362fa787c25cbb52bb6289
8553540400 ios-production-release-0607058a3ae40265db5bf70bfceba0d694bec82d
  sha256:20bc0324df6afaa96832566dea3056a788a20ed3e2936ec35e81cd078bb2f8f1
```

Android artifacts retention為14天，expires at `2026-08-06`；iOS verification與toolchain artifacts同樣依workflow contract保存14天。

## Review Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-T6-R01 | P1 | Plan原Python discovery command從`tools/`開始只發現0個tests，可能產生假綠證據 | 改由`tools/ci` discovery執行54個實際contracts，並在本文件記錄命令修正 |
| CA-CI-T6-R02 | P2 | 本地`git diff --name-only`不包含untracked audit文件，手動pre-commit simulation只列出已追蹤plan文件 | Remote classifier使用committed SHA range，實際包含兩個Markdown檔並正確判為docs-only；後續本地模擬需使用staged／committed paths或額外列入untracked files |

## Re-review

- Local full regression與54個CI contracts通過。
- 六類classification simulation符合design matrix。
- Implementation push證明source／workflow變更會執行完整矩陣。
- Documentation-only push證明stable jobs存在、重量steps no-op、Android與Production iOS skipped、Simulator使用Ubuntu且零artifacts。
- Manual dispatch證明三份workflow強制完整矩陣並建立六個預期平台／toolchain artifacts。
- Required-check名稱、minimal permissions、full SHA Action pin、secret boundary與artifact classification沒有漂移。

## Current Gate

```txt
Open P0: 0
Open P1 without disposition: 0
Local regression: Passed
Full-matrix push: Passed
Documentation-only acceptance: Passed
Manual full-matrix acceptance: Passed
Task 6 status: Completed / Reviewed
Original implementation remote acceptance: Passed
Holistic follow-up classifier revalidation: Pending
```
