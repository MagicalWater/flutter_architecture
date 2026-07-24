---
document_type: runtime-evidence
status: completed
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

### Manual-local zero-runner

Repository variable設為`manual-local`後，最新main push的CI、Android、iOS與Observability workflow全部在job建立前完成`skipped`。Runner維持`online`與`busy=false`，沒有execution job啟動。

### Manual self-hosted smoke

第一次manual run成功將Classify Changes與Tests派送到指定Mac，但揭露self-hosted仍沿用遠端Flutter／Pub cache上傳。Run在Tests成功後主動取消，並將此結果視為成本finding而非通過證據。

修正cache policy後重新manual dispatch：

```txt
Run ID: 30029472978
Event: workflow_dispatch
Execution mode: self-hosted
Runner: water-mac-flutter-architecture
Conclusion: success
```

Jobs：

```txt
Classify Changes: success
Quality: success
Tests: success
Generated Consistency: success
```

所有self-hosted jobs均略過GitHub Pub cache transport，沒有再次上傳遠端cache。

### Main push self-hosted acceptance

Repository variable切換為`self-hosted`後，main push commit `72b1799`由同一台Mac依序執行：

```txt
CI run 30029793095: success
Android run 30029793179: success
iOS run 30029793220: success
Observability run 30029793150: skipped
```

本次為文件變更，因此classifier保留docs-only語意；Android／iOS沒有建立不必要的平台artifact。三份execution workflow在單一runner上排隊完成，未平行搶占。

### Pull Request denial acceptance

建立temporary same-repository PR #1後：

```txt
CI run 30029988493: skipped
iOS run 30029988740: skipped
Observability run 30029990408: skipped
```

沒有job派送到Mac。此結果只證明trusted boundary生效，`skipped`不代表PR內容已驗證。測試PR與remote branch均已關閉／刪除。

### Runner offline fail-safe

停止LaunchAgent後manual dispatch self-hosted CI：

```txt
Run ID: 30030025506
Classify Changes: queued
Fallback GitHub-hosted job: none
```

確認queued後主動取消，不等待GitHub的24小時queue上限；重新啟動service後runner恢復`online`、`busy=false`。

### Runtime disposition

```txt
manual-local: verified
manual self-hosted: verified
main push self-hosted: verified
PR denial: verified
offline no-fallback: verified
github-hosted: static only, no paid run executed
observability: manual explicit gate only
```

## Final local regression and platform builds

Task 27-7 closure前重新執行完整repository verification：

```txt
tools/ci unittest discovery: 78 passed
run_local_ci.sh shell syntax: passed
cleanup_ci_secrets.sh shell syntax: passed
actionlint without ShellCheck style layer: passed
documentation checker: passed
quality suite: passed
Android development Debug build: passed
Android production Release build: passed
iOS development Simulator build: passed
iOS production unsigned device build: passed
```

Android代表build最初揭露：只要staging／production任一Firebase設定存在，Google Services plugin會全域建立development task，造成沒有development config的build失敗。修正後，缺少對應environment config的Google Services／Crashlytics tasks會被停用；production provider build仍正常產生mapping與Flutter symbols。

iOS兩個代表build均完成：development產生unsigned Simulator app，production產生unsigned `iphoneos` app與dSYM。這些artifact只屬verification evidence，不代表distribution readiness。
