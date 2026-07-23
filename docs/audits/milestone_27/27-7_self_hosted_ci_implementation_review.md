---
document_type: phase-review
status: active
authoritative_for:
  - milestone-27-task-27-7-self-hosted-ci-implementation-review
last_reviewed_baseline: 1.8.0
---

# Task 27-7 — Self-hosted CI Implementation Review

## Review state

Task 27-7 implementation進行中。本文件累積各小Task的focused review、findings disposition與最後holistic closure；在Task 8通過前不得視為final review。

## Task 2 — Execution Mode Contract and Naming Migration

```txt
Disposition: ACCEPTED
Open P0: 0
Open P1: 0
```

### Focused review

- 合法runtime mode固定為`manual-local`、`self-hosted`、`github-hosted`。
- `repository-default`只作為manual override sentinel，不屬runtime mode。
- Legacy `local`、空值與未知值均fail closed。
- Resolver是純validation contract，不讀取GitHub context，也不修改repository variable。
- `run_local_ci.sh`明確標示自己是`manual-local`入口，suite contract沒有漂移。

### Finding

本機tooling仍使用Python 3.9，初版`str | None`型別語法在import時失敗。已改用`typing.Optional`，維持現有Python基線；focused tests重新執行後全部通過。

### Whole-task review

Task 2只建立mode validation與命名契約，沒有提前修改workflow routing。Runtime mode集合、manual sentinel與本機入口責任互斥，未發現新的P0／P1。

## Task 3 — Workflow Routing and Trusted Event Boundary

```txt
Disposition: ACCEPTED
Open P0: 0
Open P1: 0
```

### Focused review

- 四份workflow均以`execution_mode` choice取代舊`run_hosted` boolean。
- `repository-default`只在manual dispatch時回讀repository variable。
- Self-hosted runner使用完整`self-hosted/macOS/ARM64/flutter-architecture/trusted-main` labels。
- PR只允許`github-hosted`，不會派送到`water`帳號runner。
- Main push只在repository variable為`self-hosted`或`github-hosted`時建立execution jobs。
- Observability symbols jobs只接受manual dispatch且`remote_acceptance=true`，main push不再自動上傳symbols或建立受控事件。
- Stable job names與原change classifier outputs維持不變。

### Findings and disposition

| Finding | Severity | Disposition |
|---|---|---|
| 原workflow仍使用`github`／`local`與`run_hosted` | P1 | 已全面改為三種正式mode與manual sentinel |
| Self-hosted若只使用泛用label可能誤接其他runner | P1 | 所有dynamic runner expressions固定完整trusted label集合 |
| Observability原本允許main push執行remote jobs | P1 | 已收斂為manual explicit acceptance only |
| `actionlint`會因既有SC2129 style findings回傳非零 | P2 | YAML／expression驗證使用`actionlint -shellcheck=`通過；既有ShellCheck style findings不屬本Task功能缺陷，Task 8另列整體狀態 |
| Self-hosted首次runtime仍嘗試上傳數GB Flutter／Pub cache | P1 | Flutter action cache全面關閉；explicit Pub cache只允許`runner.environment == 'github-hosted'`，Android Gradle cache input移除 |

### Whole-workflow review

逐份檢查PR、main push、manual dispatch、unknown mode與manual-local後，execution jobs均fail closed；沒有自動fallback到GitHub-hosted。Dynamic runner expression只在已允許的self-hosted event成立時回傳trusted labels，否則維持原Ubuntu／macOS runner。首次runtime揭露的cache storage風險已在重新驗收前修正。

## Task 4 — Persistent Workspace and Secret Cleanup

```txt
Disposition: ACCEPTED
Open P0: 0
Open P1: 0
```

### Focused security review

- Cleanup只接受明確job root，拒絕空值、filesystem root與home root。
- 白名單只涵蓋materialized Firebase service account與provider config檔名。
- Script只在傳入root內搜尋與刪除，不輸出secret內容。
- Cleanup可重複執行；不存在檔案時仍成功。
- Android與iOS observability jobs均以`if: always()`清理workspace與`RUNNER_TEMP`，涵蓋build／upload失敗。

### Whole-task review

Temporary provider files不再依賴ephemeral GitHub-hosted runner自動消失。Self-hosted持久workspace的主要secret殘留風險已有repository-owned、可測試且fail-closed的cleanup；清理scope不會觸及`water`帳號home或其他專案。Focused tests、shell syntax與workflow lint通過，未發現新的P0／P1。

## Task 5 — Mac Repository-scoped Runner Installation

```txt
Disposition: ACCEPTED
Open P0: 0
Open P1: 0
```

### Operational review

- Runner以repository scope註冊，不會接受其他repository job。
- 安裝與`_work`均位於`/Users/water/actions-runner/flutter-architecture`，沒有使用日常開發checkout。
- macOS ARM64 package以GitHub官方SHA-256驗證後解壓。
- Runner name與完整labels已透過GitHub API核對。
- 官方LaunchAgent service完成stop／start循環後恢復`online`、`busy=false`。
- Registration token沒有進入Git、文件或可重用設定。

### Whole-task review

Runner實際身份、workspace、service與GitHub API state均符合Spec。使用`water`帳號的隔離限制已明確保留，沒有誤稱為sandbox；未發現新的P0／P1。
