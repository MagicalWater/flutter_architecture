---
name: governing-template-development
description: 當此 Flutter 模板 repository 中的工作需要評估、規劃、實作、審查、遷移、發布或治理時使用。
---

# 治理模板開發

## 核心規則

開始 Design、Plan、implementation 或 review 前，必須先分類工作並產生 Requirement Decision。Repository policy 與 current artifacts 的權威高於此 Skill。此 Skill 負責編排 Superpowers，不取代 Superpowers。

## 必要順序

1. 先讀取 root `repository_identity.json`，確認 repository lifecycle state；missing、malformed 或 unknown state 一律 fail closed，不得從 remote URL、資料夾名稱、README prose 或 bundle identifier 猜測。
2. 檢查需求與相關 current authority。
3. 閱讀[工作分類](references/work-classification.md)，選擇 Level 0～5。
4. 產生下方 Requirement Decision。
5. 閱讀[artifact routing](references/artifact-routing.md)，選擇必要、可選與禁止的 artifacts、Skills 與 validation。
6. 依選定模式套用[雙層 Task 治理](references/two-layer-task-governance.md)。
7. 若工作會修改observable behavior，先依[Test Authoring Decision](references/test-authoring.md)判定是否需要新增regression test與primary owner，再依序使用已路由的 Superpowers Skills。
8. 保持 current authority、review evidence 與 release state 同步。
9. 任一必要 validation 失敗時，維持目前 Task 開啟；修正並 fresh re-verify 後，才可接受或建立 completion commit。

## Requirement Decision

```md
## Requirement Decision

- Request（需求）：
- Problem（問題）：
- Current behavior（目前行為）：
- Expected behavior（預期行為）：
- Value（價值）：
- Classification（分類）：
- Decision（決策）：Accept | Accept with reduced scope | Defer | Reject
- Scope（範圍）：
- Non-goals（非目標）：
- Behavioral requirements required（是否需要行為需求）：
- Design Spec required（是否需要 Design Spec）：
- Implementation Plan required（是否需要 Implementation Plan）：
- ADR required（是否需要 ADR）：
- Task governance mode（Task 治理模式）：
- Worktree／branch：
- Regression level（Regression 等級）：
- Release required（是否需要發布）：
- Post-release validation（發布後驗證）：
- Required Superpowers skills（必要 Superpowers Skills）：
- Required artifacts（必要 artifacts）：
```

不得為 Level 0／1 虛構 artifacts。不得為了逃避治理而降低 cross-cutting、architecture、migration、security、platform 或 release-critical 工作的等級。呼叫其他 workflow Skill 前，必須先記錄選定 Level、Decision、routed artifacts、必要 validations 與停止條件。

## 核准與接受 gate

- Design Spec 只有在完成完整 Task gate 並取得使用者明確核准後，才能從 `proposed` 轉為 `accepted`。
- Implementation Plan 只有在完成完整 Task gate 並取得使用者明確核准後，才能從 `proposed` 轉為 `accepted`。
- Parent Plan 仍為 `proposed` 時，不得開始 implementation。
- 必要 validation 失敗的 Task 必須維持 open 或 blocked；後續 Task 不能回頭冒充它當時已通過。
- Release identity 不等於 Milestone closure。Closure 必須完成 push 與 post-release evidence。

## Decision gate

- `Accept`：problem、value、scope 與 success criteria 清楚。
- `Accept with reduced scope`：保留價值，並明確削減 scope 與 non-goals。
- `Defer`：記錄前置條件、重新評估條件與 roadmap／backlog disposition。
- `Reject`：記錄與 template 定位、成本、風險或重複能力的衝突。

## 與 Superpowers 的關係

- 已接受的 Level 2～5 Design 工作使用 `brainstorming`。
- 只有 Design Spec 完成 repository Task governance 並取得使用者核准後，才使用 `writing-plans`。
- Feature 與 bug implementation使用`test-driven-development`時，目標是為新增／改變的observable behavior建立最小充分regression evidence；**TDD不等於每個Task新增test**、每個class建立test file或逐architecture layer建立重複tests。先完成Test Authoring Decision，再決定RED是否需要新增test；existing owner已充分覆蓋且沒有新failure mode時可使用`no-new-test justified`。
- Failure 或 unexpected behavior 在修正前使用 `systematic-debugging`。
- Routing matrix 要求隔離時使用 `using-git-worktrees`。
- 已核准的 Plan 使用 `subagent-driven-development` 或 `executing-plans`。
- 在 repository review gate 內使用 review Skills 與 `verification-before-completion` 作為方法。
- Release 與 post-release gate 尚未通過前，`finishing-a-development-branch` 不得宣稱 repository 或 Milestone 已完成。

## Test Authoring 與 Validation Execution

兩個決策必須分開：

- **Test Authoring Decision**：回答「這次change是否值得新增test、由哪個primary owner負責」。Canonical disposition為`Required`、`Recommended`、`no-new-test justified`或`Should-not-add`；完整條件由[references/test-authoring.md](references/test-authoring.md)擁有。
- **Validation Execution Decision**：回答「本次Task要執行哪些既有validation」。唯一machine authority仍是`tools/ci/validation_planner.py`。

`no-new-test justified`只代表新增tests可以為0，**不等於不執行validation**。任何Task仍必須執行planner-selected validation；security、persistence、migration、concurrency等新增高風險failure mode不得用`no-new-test justified`逃避direct regression owner。

## Coding companion

完成分類與所有必要 Design／Plan 核准後，production code 的 implementation、refactor 與 code review route 還必須載入 `karpathy-guidelines`。它只是一個從屬的 heuristic companion，絕不成為使用者入口，也不擁有 Level、scope、approval、Task、validation、release 或 closure authority。

純需求討論、核准決策、roadmap disposition、只有文件的 Level 0 工作或 release metadata，不得載入此 companion；除非同時正在審查 production code。

## 模板產品識別 domain route

當已接受的 Requirement Decision 辨識出完整模板採用，且工作會修改跨平台 Android／iOS 產品識別或 development／staging／production 顯示名稱映射時，使用 `adopting-template-product-identity` 作為從屬 domain Skill。

API-only change、visual-only rebranding、有界的單一平台 repair、environment contract change、signing 或 Store distribution，不得在沒有獨立中央分類的情況下交由此 Skill。Domain Skill 不得自行分類或核准需求，也不取代此治理 Skill。

## Template → Product repository bootstrap route

當 `repository_identity.json` 明確為 `template`，且已接受的 Requirement Decision 是把由 GitHub Template Repository 建立的新 repository 首次採用為具體產品時，使用 `adopting-template-repository` 作為薄型 repository bootstrap orchestration Skill。

Routing 必須維持：

```txt
fresh request
→ governing-template-development
→ repository_identity admission
→ accepted Requirement Decision
→ adopting-template-repository
→ adopting-template-product-identity（只有 native product identity portion）
```

若 manifest 為 `product`，再次要求首次 bootstrap 時不得重跑；應回到中央治理重新分類為 bounded repository／product identity change。Missing／invalid manifest 必須 fail closed。API-only、visual-only、單一平台 repair、discussion-only request 也不得誤觸首次 bootstrap Skill。

## Pencil-to-Flutter domain route

當已接受的Requirement Decision明確辨識repository-local `.pen`到Flutter implementation，且Design、Implementation Plan、managed worktree與visual authority gate均已通過時，使用`implementing-pencil-flutter-design`作為從屬domain Skill。

此route只編排Pencil MCP admission、structure extraction、Flutter authority mapping、TDD與visual acceptance。它不得自行分類、接受Design／Plan、解析`.pen`、自由重設計或宣稱release／closure。

Figma-only、image-only concept、ordinary Flutter feature、already-coded UI bugfix、external-only `.pen`與Plan仍為`proposed`的工作不觸發此route。Accepted `.pen`存在時，`imagegen-frontend-mobile`不因「找靈感」自動觸發。

## 停止與繼續

Task 通過後自動繼續下一個 Task。只有下列情況才停止：

1. 需要使用者決定的 scope 或 architecture decision。
2. External service、credential、manual action 或 environment blocker。
3. 推翻已核准 Spec 或 Plan 的 P0／P1 finding。
4. 整個 Milestone 完成。

一般 findings、test failures、implementation errors 與 stale documentation 必須直接修正並重新驗證，不得停下詢問。

## Skill 採用

新增或更新其他 Skill 前，套用[Skill 採用治理](references/skill-adoption-governance.md)。使用[壓力測試案例](references/pressure-scenarios.md)驗證此 Skill 與後續 workflow changes。
