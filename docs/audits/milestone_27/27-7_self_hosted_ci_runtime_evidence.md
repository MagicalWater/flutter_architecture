---
document_type: runtime-evidence
status: active
authoritative_for:
  - milestone-27-task-27-7-self-hosted-ci-runtime-evidence
last_reviewed_baseline: 1.8.0
---

# Task 27-7 — Self-hosted CI Runtime Evidence

## Runner installation

```txt
Repository: MagicalWater/flutter_architecture
Scope: repository-scoped
Runner name: water-mac-flutter-architecture
Runner id: 21
Account: water
Install root: /Users/water/actions-runner/flutter-architecture
Work root: /Users/water/actions-runner/flutter-architecture/_work
Runner version: 2.336.0
Platform: macOS ARM64
```

Custom／default labels：

```txt
self-hosted
macOS
ARM64
flutter-architecture
trusted-main
```

安裝套件`actions-runner-osx-arm64-2.336.0.tar.gz`已使用GitHub官方release所列SHA-256驗證：

```txt
8e8839c49b7060b6b2154f4931f815df330c27f167d53ef2239ee3dfce28b079
```

Registration token只在有效期內透過GitHub API取得並直接傳入`config.sh`，未寫入repository或本文件。

## Service acceptance

Runner已使用官方`svc.sh`安裝為`water`帳號的LaunchAgent：

```txt
/Users/water/Library/LaunchAgents/
actions.runner.MagicalWater-flutter_architecture.water-mac-flutter-architecture.plist
```

實際完成stop／start循環後：

```txt
service: started
GitHub API status: online
busy: false
labels: complete
```

Runner listener log確認：

```txt
Connected to GitHub
Current runner version: 2.336.0
Listening for Jobs
```

## Boundary review

- Runner安裝目錄與日常project checkout分離。
- Actions checkout固定使用runner自己的`_work`。
- Runner以`water`帳號執行，並非VM、專用使用者或完整sandbox。
- Workflow只允許trusted `main` push與manual dispatch使用此runner；PR不得進入。
- Service status命令必須從runner root執行。

## Runtime routing acceptance

尚待Task 6填入manual-local、manual self-hosted、main push、PR denial與offline queue證據。
