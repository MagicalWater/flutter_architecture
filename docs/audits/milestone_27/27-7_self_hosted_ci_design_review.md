---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-27-task-27-7-self-hosted-ci-design-review
last_reviewed_baseline: 1.8.0
---

# Task 27-7 — Self-hosted CI Execution Mode Design Review

## Review scope

本Review只審查：

```txt
docs/superpowers/specs/2026-07-24-self-hosted-ci-execution-mode-design.md
```

檢查範圍包含Task identity、三種execution mode、trusted event boundary、self-hosted runner labels、持久workspace與secret cleanup、單機併發、runner離線行為、ADR ownership、文件治理與後續implementation gate。

本Review不表示runner已安裝、workflow已改造、runtime acceptance已完成，也不關閉Task 27-6。

## Decision

```txt
Disposition: ACCEPTED
Task: 27-7 — CI Execution Mode and Self-hosted Runner Foundation
Open P0: 0
Open P1: 0
```

Spec在修正本Review findings後，已形成可實作、可驗證且不混淆Task 27-6責任的設計基準，可進入implementation plan Task。

## Findings and disposition

| Finding | Severity | Disposition |
|---|---|---|
| `configuration error`與「完全不啟動runner」不可同時成立 | P1 | Unknown／empty mode改為所有execution jobs skipped；錯誤由contract tests、文件與人工檢查呈現，不偷偷啟動GitHub-hosted runner |
| PR禁止進入Mac且不得消耗hosted分鐘時，無法另外執行policy summary job | P1 | 明確接受PR checks為skipped，並固定`skipped ≠ verified`；Branch Protection需同步治理 |
| Task 27-6與self-hosted CI scope混淆 | P1 | 新能力正式定義為Task 27-7；Task 27-6繼續擁有observability remote acceptance closure |
| CI execution boundary若長期化，不應只由guide持有 | P1 | 固定更新ADR-023，不另建平行ADR |
| Self-hosted持久workspace可能殘留Firebase secrets或provider config | P1 | 新增clean checkout、runner temp、`always()` cleanup、post-clean verification與污染停用規則 |
| 單機runner同時接收多workflow可能造成不安全取消或artifact競爭 | P1 | 明確採單job執行與排隊模型；Observability不得被自動cancel-in-progress中斷 |
| Runner離線等待時間未封頂 | P2 | 文件固定GitHub目前24小時queue上限，超時後視為失敗 |

所有P1已在Spec正文內完成明確處置，沒有留給implementation自行猜測的blocking design choice。

## Architecture and security review

核准：

```txt
manual-local
self-hosted
github-hosted
```

三模式共用repository-owned scripts，只改變觸發與runner transport。

Self-hosted安全邊界固定為：

```txt
main push
workflow_dispatch
repository-scoped runner
完整專用labels
water帳號下獨立runner workspace
禁止PR／fork／Dependabot程式碼執行
```

使用`water`帳號不是完整sandbox。Spec已如實記錄此限制，且沒有以文件措辭假裝達到VM或專用帳號隔離。

## GitHub behavior verification

本Review核對GitHub官方self-hosted runner行為：

- Self-hosted runner由使用者管理硬體與工具鏈，GitHub Actions本身不收取self-hosted execution minutes。
- Job只會派送給符合`runs-on` labels且online／idle的runner。
- 找不到符合runner時保持queued，超過24小時後失敗。
- macOS與ARM64可作為self-hosted runner平台；ARM64目前仍由GitHub標示為public preview。

上述平台事實只支撐設計可行性；實際runner版本、註冊token與service安裝命令仍須在implementation時依GitHub當下頁面取得，不寫死於Spec。

## Documentation governance review

- Spec使用既有`design-spec`類型。
- `authoritative_for`只擁有Task 27-7設計，不宣稱current state或runtime evidence。
- Review使用`planning-review`，只保存審查判定與findings。
- Current roadmap、ADR-023與operations guide尚未提前改寫為已完成；將在implementation與runtime evidence成立後同步。
- Task 27-6與Task 27-7 responsibility已分離，避免兩份active authority重複擁有同一scope。

## Validation evidence

```txt
placeholder scan
dart run melos run docs_check
git diff --check
```

本Task只修改設計與review文件，不要求Flutter tests或platform build。

## Whole-task holistic review

第二輪審查重新從以下角度檢查整份Spec，而非只確認findings文字已加入：

- 三種mode是否具備互斥且可操作的語意。
- Self-hosted安全限制是否與`water`帳號風險一致。
- PR、main push、manual dispatch是否存在互相矛盾的執行承諾。
- Runner離線、workspace污染、secret cleanup與取消策略是否有fail-safe disposition。
- Task 27-6與27-7是否維持單一責任。
- ADR、guide、roadmap、review的authority ownership是否清楚。
- Acceptance條件是否能以static contract與runtime evidence驗證。

結果未發現新的P0／P1。Spec沒有把尚未完成的runner安裝或runtime結果寫成current fact，也沒有以「未來實作決定」保留blocking architecture choice。

## Gate

Spec Task正式通過。下一個獨立Task固定為：

```txt
建立Task 27-7 implementation plan
→ plan focused review
→ findings修正
→ plan whole-task holistic review
→ plan通過後才開始實作
```

