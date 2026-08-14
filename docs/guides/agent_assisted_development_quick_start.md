---
document_type: guide
status: active
authoritative_for:
  - agent-assisted-development-user-entry
last_reviewed_baseline: 1.14.0
---

# AI Agent 協作開發快速使用指南

## 目的

本指南提供日常使用 AI Agent 開發此 Flutter 模板時，可直接複製的新對話起頭與需求範本。

本指南只擁有「使用者操作入口與範例」；不擁有工作分類、核准、雙層 Task、架構、測試或 release 規則。發生衝突時，依序以以下 authority 為準：

```txt
AGENTS.md
→ repository 不可違反規則

.agents/skills/governing-template-development/
→ Requirement Decision、Level、artifact、Task與stop／continue規則

相關ADR、Guide、source、tests與CI
→ 對應領域與runtime truth

本指南
→ 日常入口與可複製Prompt
```

所有implementation／fix的validation selection採 **Minimum Sufficient Validation**；repository-owned `tools/ci/validation_planner.py`決定focused／affected／workspace／full／release及exact scopes。Agent不得因「保守」自行把每個Task升級成full workspace test；unknown／ambiguous inputs由planner fail-safe升級。

是否**新增**test是另一個Test Authoring Decision：由中央治理依risk／invariant／failure mode判定`Required`、`Recommended`、`no-new-test justified`或`Should-not-add`。TDD不代表每個Task、class或layer都要新增test；`0 new tests`可以是合法結果，但永遠不等於`0 validation`。

## 每次新對話的共同開頭

先提供 repository 路徑，再選擇本指南後續場景中的一個 Skill 入口。

Windows 範例：

```txt
@bridge-win 請開啟：

`D:\Developer\flutter_architecture`
```

macOS 範例：

```txt
@bridge-mac 請開啟：

`/Users/<user>/Developer/projects/flutter_architecture`
```

Agent 進入 repository 後，必須先依 `AGENTS.md` 讀取固定最小文件集，再依任務載入局部 authority。不要在 Prompt 中複製全部 repository 文件內容。

## 入口選擇表

| 工作類型 | 使用入口 |
|---|---|
| 新增產品功能，無論是否包含畫面 | `starting-feature-work` |
| 新增畫面、完整 user flow、Figma-driven implementation | `starting-feature-work` |
| Bug、異常行為、除錯 | `governing-template-development` |
| Test／CI failure | `governing-template-development` |
| Refactor、效能、技術債 | `governing-template-development` |
| Package、DI、Migration、平台與架構工作 | `governing-template-development` |
| 只討論或可行性評估 | 依工作類型選入口，並明確限制 discussion-only |
| 跨 Android／iOS 正式採用產品 identity | `adopting-template-product-identity` |
| Implementation 的簡化與防止過度設計 | 不手動指定；中央治理會在適用階段載入 `karpathy-guidelines` |
| 已核准repository-local `.pen` → Flutter implementation | `governing-template-development`；admission通過後自動路由`implementing-pencil-flutter-design` |

使用 `starting-feature-work` 時，不需要再同時指定 `governing-template-development`；前者必須自動委派中央治理。

## 場景一：新增純功能，不包含新畫面

適用例子：Session 自動過期、背景同步、匯出資料、登入失敗次數限制、Deep Link 處理或 notification routing。

```txt
請使用 repository-local `starting-feature-work` Skill。

我要新增一個純功能，不包含新畫面：

[功能名稱]
Session 自動過期與登出。

[預期行為]
- 使用者登入後，Session 超過30分鐘未活動就失效。
- Session 失效後清除本地登入狀態。
- 下一次需要驗證身分的操作必須回到登入流程。
- App進入背景與回到前景時都必須正確計算。
- 不新增新畫面，只沿用目前登入頁。

[限制]
- 不改目前登入API。
- 不加入新套件，除非Requirement Decision證明必要。
- 必須完成Test Authoring Decision與文件同步；只有risk／failure owner需要時才新增test。
```

這類需求仍是產品功能。是否需要 Design／Plan，由中央治理依風險分類，不以「沒有畫面」直接判定為小工作。

## 場景二：新增畫面與完整功能規劃

適用例子：通知中心、訂單列表、設定中心、Profile 編輯、註冊或忘記密碼流程。

```txt
請使用 repository-local `starting-feature-work` Skill。

我要新增一個完整功能：

[功能名稱]
通知中心。

[功能目標]
使用者可以查看系統通知、標記已讀，並進入通知對應的內容。

[預期畫面與狀態]
- 通知列表頁。
- 未讀通知有明確狀態。
- 支援下拉更新與分頁載入。
- Empty、Loading、Error與Content狀態必須分開。
- 點擊通知後依通知類型進入對應頁面。

[資料來源]
目前沒有正式API，可先設計interface與mock implementation。

[限制]
- 必須符合目前Clean Architecture、Bloc、Navigation、Localization、Accessibility與Offline治理。
- 先完成完整功能與畫面規劃，不要直接開始實作。
- Design與Plan都要完成repository review並等我核准。
```

Agent 應先盤點既有 Feature 結構、Design System、Navigation、Domain model、Repository／API、Bloc、Localization、Accessibility、Offline／Cache與tests，再建立正式 Design。

## 場景三：依 Figma 新增完整畫面功能

```txt
請使用 repository-local `starting-feature-work` Skill。

我要依照Figma實作新的個人資料編輯功能。

Figma：
[貼上Figma網址]

[功能需求]
- 顯示目前使用者名稱、Email與頭像。
- 使用者可以修改名稱與頭像。
- Email只能顯示，不能修改。
- 儲存成功後更新Profile頁。
- 儲存失敗時保留使用者輸入。
- 支援英文與繁體中文。
- 支援深色模式、大字體與窄畫面。

請先檢查目前Design System、Profile feature、API、Navigation與state management。
先完成Requirement Decision與Design，不要直接實作。
```

Figma 只提供視覺與部分互動線索，不自動擁有 business rules、failure behavior、accessibility或data contract。

## 場景三-A：依已核准 repository-local Pencil 設計稿實作

只有`.pen`已進repository、Requirement／Design／Plan與visual manifest均完成必要核准時才使用此場景。完整流程見[Pencil-to-Flutter Workflow Guide](pencil_to_flutter_workflow.md)。

```txt
請使用 repository-local `governing-template-development` Skill。

我要依目前repository中已接受的`.pen`實作對應Flutter畫面。

請先確認Requirement Decision、Design、Plan、managed worktree、visual manifest與Skill provenance；全部通過後再路由`implementing-pencil-flutter-design`。

不得使用external `.pen`、native parser、PNG／OCR fallback或直接image-to-code。
依雙層Task治理持續執行到真正的決策／manual blocker／正式release gate。
```

使用者不需要手動指定三份Taste Skills。已有accepted `.pen`時，`imagegen-frontend-mobile`不是normal route；Pencil MCP unavailable則保持blocked，不改走目測還原。

## 場景四：Bug 與除錯

Bug 不使用 `starting-feature-work`，直接交給中央治理。

```txt
請使用 repository-local `governing-template-development` Skill。

我要處理以下Bug：

[問題]
使用者登入後快速連續按兩次登出，有時會再次回到已登入狀態。

[目前行為]
- 第一次登出會清除Session。
- 第二次登出期間，較早的Session restore結果可能晚回來。
- 最後UI偶爾重新顯示已登入。

[預期行為]
- Logout一旦開始，所有較舊的Login或Restore結果都不能重新建立Session。
- 連續Logout必須保持idempotent。
- 未知錯誤不能被吞掉。

請先重現並確認root cause。
必須使用systematic debugging；TDD依direct regression owner建立最小充分evidence，不為了流程形式新增trivial test。
不要順便重構無關Auth程式碼。
修正後執行focused review、affected regression與總審查。
```

預期方法是先建立可重現 evidence，再進行最小修正；不得直接猜測原因或只修改 assertion 讓 test 變綠。

## 場景五：Test 或 CI failure

```txt
請使用 repository-local `governing-template-development` Skill。

目前以下驗證失敗：

[命令]
dart run melos exec -- flutter test

[失敗內容]
[貼上錯誤訊息、test名稱或CI連結]

請：
1. 先判斷是production regression、stale test、flaky test或environment問題。
2. 使用systematic debugging找root cause。
3. 不得只為讓test變綠而削弱assertion。
4. 不得在沒有replacement evidence時刪除test。
5. 修正後重跑focused test與affected regression。
6. 完成Task review後再提交。
```

若問題涉及 GitHub-hosted quota、runner或外部服務，必須區分 repository failure 與 environment blocker。

若要在Prompt中要求Agent遵守current validation route，可直接寫：

```txt
請依 tools/ci/validation_planner.py 產生本次Task的 Minimum Sufficient Validation plan，
執行returned focused／affected scopes；只有planner、holistic或release gate要求時才跑full regression。
```

## 場景六：Refactor 或技術債

```txt
請使用 repository-local `governing-template-development` Skill。

我要審查並重構以下範圍：

[範圍]
AuthRepository目前同時負責Login API、OTP、credential persistence、session restore與logout cleanup。

[目標]
降低責任混雜與測試複雜度，但不得改變現有外部行為。

[限制]
- 先審查是否真的需要拆分。
- 不建立沒有實際用途的interface、factory或generic framework。
- 不修改無關Feature。
- 現有security、migration、rollback與error identity不得弱化。
- 需要behavior-preserving regression evidence。
```

進入 production code implementation／refactor／review 後，中央治理會在適用時載入 `karpathy-guidelines`；使用者不需要手動指定。

## 場景七：架構、平台或 Migration

適用例子：資料庫遷移、credential migration、加入平台支援、調整 package dependency direction或更換 framework。

```txt
請使用 repository-local `governing-template-development` Skill。

我要評估並可能執行以下架構變更：

[需求]
將目前的本地資料儲存從套件A遷移至套件B。

[目標]
- 保留既有使用者資料。
- 保持rollback compatibility。
- Android、iOS與Desktop行為一致。
- 不影響既有Repository public contract。

[要求]
- 先做技術可行性與方案比較。
- Requirement Decision通過前不得建立正式Milestone。
- 必須評估ADR、migration fixtures、rollback、failure injection與platform evidence。
- Design與Plan必須分別完成完整雙層Task review並等我核准。
- 實作期間每個Task獨立review與commit。
- 最後做跨Task holistic final review。
```

這類工作通常會提高至 Level 3～5，不能因預估檔案數少而降級。

## 場景八：只討論，不修改 repository

```txt
請使用 repository-local `governing-template-development` Skill。

本次只討論與評估，不修改任何檔案，不建立branch、worktree、Design、Plan或commit。

我要了解：

[問題]
目前Auth架構是否適合加入Passkey登入？

請盤點目前架構、可能方案、套件選擇、優缺點、風險與建議方向。
```

新功能也可以先只討論：

```txt
請使用 repository-local `starting-feature-work` Skill。

本次只討論功能規劃，不修改repository，也不要建立Design或Plan。

我想加入：
[功能描述]

請先分析使用流程、畫面、資料需求、API、state與可能風險。
```

Discussion-only 限制必須保留；Agent 不得因需求看起來明確就直接開始 mutation。

## 場景九：從 GitHub Template Repository 開始新產品

先在 GitHub 對 `flutter_architecture` 使用 `Use this template` 建立新的產品 repository，clone 新 repo 後，新對話只需要提供 repo path、產品名稱與 base identifier：

```txt
@bridge-win 請開啟：
D:\Developer\pickup-basketball

這是剛從 flutter_architecture template 建立的新產品 repository。

產品名稱：找團體打籃球
Base identifier：com.mgwater.pickupbasketball
```

使用者不需要知道 `adopting-template-repository` Skill 名稱。Fresh Agent 必須自行讀 `repository_identity.json`、進入中央治理並在符合首次 bootstrap trigger時路由該 Skill。

完整 repository birth、VERSION／template provenance、atomic completion與fresh-conversation acceptance procedure，見 [Template Repository Adoption Guide](template_repository_adoption.md)。

## 場景十：只處理跨平台 Native Product Identity 採用

只有完整跨 Android／iOS 產品 identity 與三環境 display-name mapping 採用時，才使用此入口。

```txt
請使用 repository-local `adopting-template-product-identity` Skill。

我要把此Flutter模板正式採用為以下產品：

產品名稱：
Acme Shop

Base identifier：
com.acme.shop

Development顯示名稱：
Acme Shop Dev

Staging顯示名稱：
Acme Shop Staging

Production顯示名稱：
Acme Shop

[本次範圍]
- 同步environment manifest。
- 同步Android applicationId。
- 同步iOS bundle identifiers。
- 同步三環境顯示名稱。
- 同步generated Dart projections。
- 執行目前environment contract驗證。

[本次不處理]
- Signing credentials。
- Keystore。
- Apple certificates。
- Store上架。
- API domain修改。
```

完整 manifest-first 順序、三環境build命令與secret boundary，仍以 [Native Environment and Product Identity Adoption Guide](native_environment_adoption.md) 為準。

## 三個最短日常範本

### 新功能

```txt
請使用 repository-local `starting-feature-work` Skill。

我要新增：
[需求]

預期：
[行為與成功條件]

限制：
[不做什麼]
```

### Bug

```txt
請使用 repository-local `governing-template-development` Skill。

目前問題：
[問題]

重現方式：
[步驟]

預期行為：
[預期]

請先重現與找root cause，再依Test Authoring Decision判定regression owner並依TDD修正；若沒有新test價值，記錄`no-new-test justified`並仍執行planner-selected validation。
```

### 架構或技術工作

```txt
請使用 repository-local `governing-template-development` Skill。

我要處理：
[技術需求]

目標：
[目標]

限制：
[邊界]

請先完成Requirement Decision，不要直接實作。
```

## 哪些內容不需要每次重貼

不需要在每個 Prompt 重貼完整雙層 Task 流程。中央治理已固定負責：

```txt
Requirement Decision
→ Level與artifact routing
→ Design／Plan gate（如適用）
→ 每個Task focused review、finding、fix、fresh re-review
→ authority與validation
→ holistic final review
→ commit／push／clean-checkout closure（依分類）
```

一般 finding、test failure、implementation error與stale documentation應直接修正並繼續。只有以下情況應停止等待使用者：

1. 需要使用者決定 scope 或 architecture。
2. 需要 external service、credential或manual action。
3. P0／P1 finding推翻已核准Design或Plan。
4. 整個Milestone或工作正式完成。

## 使用者需要核准的節點

Level 2以上通常會在以下兩個節點停止：

```txt
Design完成review
→ 使用者核准Design

Implementation Plan完成review
→ 使用者核准Implementation Plan
```

可直接回覆：

```txt
核准Design
```

或：

```txt
核准Implementation Plan
```

Plan accepted後，Task通過就應自動進入下一個Task，不需要反覆輸入「繼續」。

## 常見錯誤入口

- 不要同時指定 `starting-feature-work` 與 `governing-template-development`。
- 不要手動把 `karpathy-guidelines` 當成工作入口。
- 不要用 `adopting-template-product-identity` 處理 API-only、visual-only、單平台repair、signing或Store工作。
- 不要把external `.pen`、PNG或historical Flutter screenshot直接當Pencil-to-Flutter implementation authority；先完成repository source／manifest admission。
- 不要把聊天摘要當成repository current authority。
- 不要為了要求「完整流程」而在Prompt中複製整份治理文件；只需清楚描述需求、預期與限制。

## 相關文件

- [Template Development Workflow Governance](../governance/development_workflow.md)
- [Template Repository Adoption Guide](template_repository_adoption.md)
- [Native Environment and Product Identity Adoption Guide](native_environment_adoption.md)
- [Repository-local Pencil-to-Flutter Workflow Guide](pencil_to_flutter_workflow.md)
- [Documentation Hub](../README.md)
- [`AGENTS.md`](../../AGENTS.md)
