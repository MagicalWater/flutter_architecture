---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-27-self-hosted-ci-execution-mode-design
last_reviewed_baseline: 1.8.0
---

# Milestone 27 — Self-hosted CI Execution Mode Design

本設計對應：

```txt
Task 27-7 — CI Execution Mode and Self-hosted Runner Foundation
```

Task 27-6保留Production Observability remote acceptance與symbolication closure責任；Task 27-7處理因Actions額度與執行端切換所新增的CI治理與self-hosted runner能力。Task 27-7完成後，Task 27-6仍須依最新本機runtime evidence完成自身closure，不得以runner建置取代observability驗收。

## 1. 背景

目前repository已提供GitHub-hosted CI與本機統一入口，但現行`CI_EXECUTION_MODE=local`只會讓GitHub Actions jobs全部skip，再由使用者人工執行：

```bash
bash tools/ci/run_local_ci.sh <suite>
```

它不是GitHub自動通知Mac執行CI的完整替代方案。由於private repository的GitHub Actions額度已用盡，且iOS／Observability需要昂貴的macOS runner，本階段需要新增正式的self-hosted執行模式，同時保留GitHub-hosted與人工本機兩條回退路徑。

本設計也補正先前Task流程缺口：上一輪技術修改先提交與推送，但current authority、runtime evidence、Task review與holistic review沒有在同一closure循環完成。本階段必須在實作結束前補齊狀態同步與完整review。

## 2. 已確認決策

### 2.1 觸發事件

Self-hosted runner只接受：

```txt
push 到 main
workflow_dispatch
```

不接受：

```txt
pull_request
pull_request_target
fork pull request
Dependabot pull request
未合併branch的自動執行
```

Pull Request階段不把未信任程式碼送入本機Mac。PR驗證維持人工本機執行，或在未來額度恢復後切回GitHub-hosted模式。

### 2.2 macOS使用者

Runner直接以目前的`water`帳號執行，不要求切換到專用macOS使用者。

這項決策以操作便利性為優先，接受較弱的使用者層級隔離。因此workflow與runner設定必須採更嚴格的事件限制、專用label、最小權限與workspace邊界。

### 2.3 執行模式

Repository正式支援三種模式：

```txt
manual-local
self-hosted
github-hosted
```

不得繼續以模糊的`local`表示自動與手動兩種不同語意。

## 3. 模式語意

### 3.1 `manual-local`

```txt
GitHub收到push／PR
→ 所有hosted與self-hosted jobs skipped
→ 使用者人工執行tools/ci/run_local_ci.sh
```

用途：

- Mac runner維護中。
- 暫時不希望任何GitHub派送。
- 本機一次性debug或focused verification。

### 3.2 `self-hosted`

```txt
GitHub收到main push或manual dispatch
→ GitHub排程self-hosted job
→ Mac runner背景接收
→ checkout精確commit SHA
→ 執行repository-owned scripts
→ 結果回傳GitHub Checks
```

這是private repository額度不足期間的預設模式。

### 3.3 `github-hosted`

```txt
GitHub收到既有workflow event
→ 使用ubuntu／macOS GitHub-hosted runner
→ 維持既有remote CI能力
```

用途：

- Actions額度恢復。
- Repository轉public且完成公開安全審查。
- 需要乾淨遠端runner作為獨立證據。

## 4. 模式選擇契約

Repository variable：

```txt
CI_EXECUTION_MODE
```

允許值：

```txt
manual-local
self-hosted
github-hosted
```

未知值或空值不得默默啟動runner。Fail-safe行為為：

```txt
自動事件：所有執行job skipped，不啟動任何runner
workflow_dispatch：只有明確manual override才允許執行
```

由於「不啟動任何runner」與「執行一個job輸出configuration error」無法同時成立，未知模式在GitHub Checks中只能呈現為skipped／未派送；明確錯誤說明由repository文件、contract tests與人工檢查命令提供。不得為了顯示configuration error而偷偷啟動GitHub-hosted runner並消耗額度。

Manual dispatch提供一次性override：

```txt
execution_mode:
  repository-default
  manual-local
  self-hosted
  github-hosted
```

`repository-default`只是一個manual input sentinel，不是第四種execution mode。它表示沿用repository variable。其他三個值只影響該次run，不改寫repository variable。若repository variable沒有合法值且manual input為`repository-default`，所有execution jobs必須fail closed並skipped，而不是自行猜測執行端。

## 5. Runner註冊與label

Mac runner採repository-scoped self-hosted runner，不註冊為organization-wide runner。

必要labels：

```txt
self-hosted
macOS
ARM64
flutter-architecture
trusted-main
```

Workflow不得只使用泛用的：

```yaml
runs-on: self-hosted
```

而必須指定完整專用label集合，避免其他self-hosted runner誤接工作。

Runner安裝於`water`帳號下的專用目錄，runner自己的`_work`作為GitHub checkout與執行workspace。不得直接把日常開發checkout當成runner workspace。

## 6. 背景服務與可用性

Runner使用GitHub官方Actions Runner，安裝為macOS背景服務。使用者不需要每次手動開Terminal，也不需要自行維護Webhook listener。

執行模型：

```txt
Mac開機並登入water帳號
→ runner service啟動
→ 與GitHub維持官方連線
→ 等待符合label與事件條件的job
```

本階段不保證：

- Mac關機時仍可執行。
- Mac深度睡眠時能可靠喚醒。
- 跨macOS重啟前未登入使用者時一定可執行。
- Runner離線時自動改派GitHub-hosted並產生費用。

Runner離線時，job應維持queued，並由操作指南說明切換至`manual-local`或`github-hosted`。

GitHub對找不到符合label的self-hosted runner會保持排隊；若超過平台允許的排隊期限，job會失敗。操作指南必須明確記錄目前GitHub的24小時上限，不能宣稱job會無限等待。

## 7. Workflow分流

### 7.1 PR

Self-hosted模式下，PR不得啟動本機runner。Workflow應建立可理解的skip／policy結果，避免使用者誤以為已完成驗證。

在不使用GitHub-hosted runner的前提下，PR無法額外執行一個summary job。因此本階段接受PR checks顯示為skipped，但文件與Branch Protection必須明確說明：

```txt
skipped ≠ verified
```

不得把這些skipped checks解讀為本機CI已自動完成。

Branch Protection若要求GitHub checks，必須重新評估；不能把永久skip的job誤設成必須成功的required check。

### 7.2 Main push

Self-hosted模式下，main push可以執行：

```txt
Quality
Generated Consistency
Tests
Android representative builds
iOS representative builds
```

Observability Acceptance仍不應每次main push自動執行完整symbols upload與受控事件。它只接受明確的manual dispatch，避免重複build、重複事件與Firebase污染。

### 7.3 Manual dispatch

Manual dispatch可選執行端與suite。Observability除選擇`self-hosted`外，仍須明確啟用remote acceptance旗標，才能讀取Firebase Environment secrets與上傳symbols。

## 8. 本機命令與GitHub workflow的單一實作來源

GitHub self-hosted jobs不得重新複製另一套build邏輯。它們應呼叫既有repository-owned scripts：

```txt
tools/ci/run_local_ci.sh
tools/ci/build_android_*.sh
tools/ci/build_ios_*.sh
tools/ci/upload_*_symbols.sh
```

目標是：

```txt
人工本機
self-hosted GitHub Actions
github-hosted GitHub Actions
```

三條路徑共用同一套底層contract，差異只存在於觸發、runner與artifact transport。

## 9. Secrets與權限

### 9.1 GitHub token

Workflow維持最小權限：

```yaml
permissions:
  contents: read
```

只有確有必要的job才能提升權限。

### 9.2 Firebase secrets

Observability secrets繼續由GitHub Environment：

```txt
staging-observability
```

提供。不得把service account、Firebase config或App ID寫入runner安裝目錄的明文共用設定。

### 9.3 water帳號風險控制

由於runner使用`water`帳號：

- 不允許PR／fork程式碼執行。
- 不在workflow中讀取`~/.ssh`、個人Keychain或其他專案。
- 不把日常開發checkout當runner workspace。
- 不使用無限制的repository script下載與執行遠端任意內容。
- External actions維持full SHA pinning。
- Runner token只用於註冊，不提交repository。

此設計不是完整sandbox。若未來repository接受外部貢獻或公開PR，必須重新評估專用帳號、VM或ephemeral runner。

## 10. Artifact與成本治理

Self-hosted runner不消耗GitHub-hosted execution minutes，但GitHub artifact storage仍可能產生成本。

原則：

- 成功build預設不必全部上傳大型artifact。
- 只上傳必要metadata、failure diagnostics與短期驗收證據。
- iOS不得上傳完整DerivedData。
- Observability artifact retention維持1天。
- 一般verification artifacts需重新審查retention，不以14天作為不可變預設。

## 11. Error handling

### 11.1 Runner離線

```txt
job queued
→ 操作者檢查runner service與Mac狀態
→ 恢復runner，或切換execution mode
```

不得自動fallback到付費GitHub-hosted runner，避免額度不足時產生非預期費用。

### 11.2 工作區污染

每個job使用Actions runner的標準checkout workspace。Workflow開始前與結束後確認沒有沿用日常開發checkout或未追蹤secret檔案。

Self-hosted runner使用持久workspace，必須補上以下清理契約：

- `actions/checkout`維持clean checkout與精確SHA。
- Materialized Firebase config、service account與臨時憑證只存在於job workspace或runner temp。
- 無論成功或失敗，都執行`always()` cleanup。
- Cleanup後檢查敏感檔案不存在。
- 不把`_work`加入日常開發搜尋路徑或手動編輯範圍。
- 發現workspace污染時，runner必須先停用並清理，不能繼續接單。

### 11.3 模式設定錯誤

Contract tests必須檢查三個合法值、manual override與unknown-mode fail-safe。Workflow summary需清楚顯示本次選定的執行端。

### 11.4 Self-hosted與GitHub-hosted差異

Self-hosted可能殘留Pub、Gradle、CocoaPods與Xcode cache。Cache只能改善速度，不得成為正確性前提。定期或manual clean verification必須能從fresh dependency resolution成功。

### 11.5 單機併發與取消

本階段只有一台Mac runner，預設同一時間只執行一個job。多個workflow或同一workflow的多個job會排隊，不以平行執行作為需求。

Workflow concurrency必須避免較新的main push讓舊job在寫入共享artifact或上傳symbols中途被不安全取消。可以取消純quality／build驗證，但Observability upload與runtime acceptance不得被自動`cancel-in-progress`中斷；其取消策略需逐workflow明確定義。

## 12. 測試策略

### 12.1 Static contract tests

新增或更新測試確認：

- 三種execution mode名稱與語意。
- 不再接受模糊的`local`值。
- Self-hosted jobs使用完整專用labels。
- Self-hosted只允許main push與manual dispatch。
- PR不會啟動self-hosted runner。
- Observability只在manual explicit acceptance時執行。
- Unknown mode fail-safe。
- Manual override不修改repository variable。

### 12.2 本機驗證

```txt
docs check
workflow contract tests
shell syntax
actionlint
quality suite
Android build
iOS build
```

### 12.3 Runtime acceptance

1. 在Mac註冊runner並確認online。
2. Manual dispatch最小self-hosted smoke job。
3. Main push觸發self-hosted quality與平台job。
4. GitHub checks回報成功／失敗。
5. PR建立後確認不會派送到Mac。
6. Runner停用後確認job只queued，不會切到GitHub-hosted。
7. 切換`manual-local`後確認所有runner jobs skipped。
8. 切換`github-hosted`只做static／manual驗證；本月額度已滿時不得實際啟動付費job。

## 13. 文件治理與closure

實作完成前必須同步：

- `docs/guides/ci_cd_operations.md`：操作authority。
- `docs/roadmap/active.md`：current Task與next action。
- `docs/audits/milestone_27/27-6_ci_secrets_remote_acceptance_review.md`：補記symbols、local runtime與execution mode evidence。
- 新增Task review或closure review，記錄上一輪流程缺口、修正範圍與驗證結果。
- 更新ADR-023，納入三種execution mode、trusted event boundary、self-hosted runner責任與fail-safe原則。這是既有Repository CI Decision的擴充，不另建平行ADR；guide只保存操作方式，不單獨承擔架構規則。

完成條件：

```txt
實作與contract一致
runtime acceptance完成
current authority同步
文件metadata與scope無衝突
docs checker通過
Task review通過
holistic review通過
工作區乾淨
提交與推送完成
```

## 14. 不在本階段處理

- 專用macOS使用者遷移。
- VM／容器級隔離。
- Ephemeral self-hosted runner orchestration。
- Autoscaling runner fleet。
- Fork PR self-hosted execution。
- Mac睡眠自動喚醒。
- 跨重啟、未登入狀態的完整可用性保證。
- Repository公開化與open-source readiness。

## 15. 推薦落地順序

```txt
1. 先記錄流程缺口，但不在實作前誤寫Task已完成
2. 將local模式正式改名為manual-local
3. 建立三模式resolver與contract tests
4. 安裝repository-scoped Mac self-hosted runner
5. 改造workflow runner routing
6. 完成main push／manual dispatch runtime acceptance
7. 依runtime evidence更新current authority與Task 27-6 review
8. 執行文件治理review與holistic final review
9. 提交並推送closure
```

