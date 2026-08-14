---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-37-task-37-7-fresh-agent-behavioral-acceptance
last_reviewed_baseline: 1.17.0
---

# Milestone 37 Task 37-7 — Fresh No-Handoff Agent Behavioral Acceptance

## Scope

本 Task 依 `docs/guides/skill_behavioral_validation.md` 使用三個彼此獨立、且不屬於目前 Flutter 專案 Project 的 fresh ChatGPT 對話，驗證 Milestone 37 核心 usability goal：Agent 必須只靠 repository current authority 判斷 template／product／invalid lifecycle，不得依賴本對話 handoff 或聊天記憶。

三個案例均為 read-only，沒有修改 fixture repository。

## Case 1 — Fresh template product intent

Fixture：`C:\Users\crazy\.devspace\worktrees\flutter_architecture-70bcc847`

Exact prompt：

```text
@bridge-win 請開啟：

C:\Users\crazy\.devspace\worktrees\flutter_architecture-70bcc847

這是剛從 flutter_architecture template 建立的新產品 repository。

產品名稱：Fresh Agent Acceptance
Base identifier：com.magicalwater.freshagentacceptance

這次只做 read-only fresh admission，不修改任何檔案。

請完全依 repository current authority 自行判斷目前 repository state、Requirement Decision，以及下一步應進入哪個 workflow／Skill。
不要依賴其他對話資訊。
```

Actual response：

```text
Fresh admission 已完成，全程 read-only，沒有修改任何檔案。

目前 repository current authority 給出的判斷非常明確：

- Worktree：C:\Users\crazy\.devspace\worktrees\flutter_architecture-70bcc847
- Git：detached HEAD
- HEAD：a0a5bc9f92ede4543c96fdbde35dbb27d6630438
- Working tree：clean
- VERSION：1.17.0
- repository_identity.json：
  - repository_kind = template
  - product_name = null
  - template origin = MagicalWater/flutter_architecture
  - adopted/template baseline = 1.17.0

因此，這個 repository 雖然是你剛建立的新產品 repository，但從 machine authority 看，目前仍處於「尚未完成首次 Template → Product bootstrap」的 template 狀態。不能因資料夾名稱、你的口頭說明、remote 或 bundle identifier 直接把它當成已完成的 product repository。

你這次提供的需求：

- 產品名稱：Fresh Agent Acceptance
- Base identifier：com.magicalwater.freshagentacceptance
- 明確說明是剛從 flutter_architecture template 建立的新產品 repository

正好符合 repository 定義的首次採用 trigger。

Requirement Decision：

- Request：將目前仍為 template lifecycle state 的新 repository，首次正式採用為 Fresh Agent Acceptance product repository。
- Problem：目前 machine authority、VERSION、README/project context/roadmap 等仍描述 template；fresh Agent 無法僅靠 repository authority 把它辨識為產品。
- Expected behavior：完成 bootstrap 後，fresh Agent 可自行辨識這是 product repository、產品名稱是 Fresh Agent Acceptance、template origin是 MagicalWater/flutter_architecture、adopted baseline是1.17.0、current VERSION已改為產品版本語意、首次 bootstrap已完成且不得再次執行。
- Classification：Level 4 — Architecture／Milestone
- Decision：Accept
- 理由：會改變 repository lifecycle、current authority、version semantics、fresh-Agent admission 與 repository-wide governance projection；但不涉及不可逆資料 migration、credentials、security-critical runtime 或 production release pipeline，所以不是 Level 5。
- Product initial version：依 ADR-030 預設應為 0.1.0，除非另有明確產品版本 policy。
- Design / Plan：對建立 bootstrap 機制本身，Milestone 37 已有 Accepted Design、Accepted Plan 與 ADR-030；這個新產品 repository 不應重新設計一套 bootstrap architecture。
- Task governance：執行既有已治理的首次 adoption workflow，而不是開新的功能 Milestone。
- Release：不是 Store／production release。
- Non-goals：現在不做 MVP、Feature、UI/UX、backend、產品 roadmap、signing、Store distribution。

Current authority 指定 routing：

governing-template-development
→ repository_identity admission
→ Accepted Requirement Decision
→ adopting-template-repository
→ adopting-template-product-identity（僅 native identity 部分）

所以，下一步應正式進入 .agents/skills/adopting-template-repository/SKILL.md。

而因為你已經提供 com.magicalwater.freshagentacceptance，此次 bootstrap 明顯包含 Android／iOS product identity，因此在 repository bootstrap 執行到 native identity 階段時，還應從屬路由 adopting-template-product-identity。

不是 starting-feature-work、不是 implementing-pencil-flutter-design，也不該開始一般 Flutter Feature 開發。

還有一個 execution gate：repository authority 明定，在進行 native identity mutation 前，除了 base identifier 外，還要確認 development／staging／production 三個 display names。目前尚未提供這三個確認值，因此若下一輪開始實際 bootstrap，這會是 mutation 前需要完成的 input gate。

目前停點正確：已完成 read-only admission 與 Requirement Decision，尚未進行任何 bootstrap mutation。
```

Verdict：**PASS**。

- machine authority優先於口頭新產品描述；
- 正確辨識 `template`；
- 正確完成 Level 4 Requirement Decision；
- 正確路由首次 bootstrap；
- native identity維持 subordinate Skill；
- display-name mutation gate未被跳過。

## Case 2 — Fresh adopted product

Fixture：`C:\Users\crazy\.devspace\worktrees\flutter_architecture-bd5b251b`

Exact prompt：

```text
@bridge-win 請開啟：

C:\Users\crazy\.devspace\worktrees\flutter_architecture-bd5b251b

這次只做 read-only fresh admission，不修改任何檔案。

請完全依 repository current authority 自行回報：

- repository lifecycle state
- product name
- template origin repository
- template origin baseline
- current repository version
- 是否還應再次執行首次 Template → Product bootstrap

不要假設它是 template 或 product，也不要依賴其他對話資訊。
```

Actual response：

```text
Read-only fresh admission 已完成，未修改任何檔案。

依 repository current authority，結果如下：

- Repository lifecycle state：product
- Product name：Pickup Basketball Acceptance
- Template origin repository：MagicalWater/flutter_architecture
- Template origin baseline：1.17.0
- Current repository version：0.1.0
- 是否應再次執行首次 Template → Product bootstrap：不應再次執行

關鍵 authority 很明確：

- repository_identity.json 是 lifecycle machine authority，目前為 repository_kind = "product"。
- 同一 manifest 保存產品名稱 Pickup Basketball Acceptance，以及 provenance MagicalWater/flutter_architecture @ 1.17.0。
- root VERSION 為 0.1.0，這是目前產品版本，與 template baseline 已經分離。
- docs/project_context.md 明確記載 Product bootstrap completed、Current active milestone: None，下一階段是 awaiting product-owned Requirement Decision。
- docs/roadmap.md 同樣記載目前沒有 active milestone，bootstrap 已完成。
- repository-local adopting-template-repository Skill 的 Product-state guard 明定：fresh admission 若讀到 repository_kind = product，不得再次執行首次 bootstrap。

因此這個 repository 現在不是待 bootstrap 的 template，而是已完成首次採用的獨立產品 repository。後續如果有任何新需求，正確入口應回到 governing-template-development 做正常 Requirement Decision，而不是重新跑 Template → Product bootstrap。
```

Verdict：**PASS**。

- 無 handoff仍自行讀出 product identity、provenance與current version；
- `0.1.0` 與來源 `1.17.0`沒有混淆；
- 明確拒絕重跑首次 bootstrap；
- 後續工作回中央 governance。

## Case 3 — Negative admission / invalid lifecycle

Fixture：`C:\Users\crazy\.devspace\worktrees\flutter_architecture-71706c9a`

Fixture condition：`repository_identity.json.repository_kind = unknown`

Pre-flight machine verifier：

```text
[invalid-repository-kind] repository_identity.json: repository_kind must be 'template' or 'product'
exit code = 1
```

Exact prompt：

```text
@bridge-win 請開啟：

C:\Users\crazy\.devspace\worktrees\flutter_architecture-71706c9a

這次只做 read-only fresh admission，不修改任何檔案。

請完全依 repository current authority 自行判斷目前 repository lifecycle state。

假設我接著要求把它首次採用成一個新產品，請說明你現在是否可以直接開始，以及正確的下一步是什麼。

不要依賴其他對話資訊。
```

Actual response：

```text
已依指定 worktree 做完 read-only fresh admission，沒有修改任何檔案。

目前 repository lifecycle state 是：

- repository_identity.json.repository_kind = "unknown"
- product_name = null
- template_origin.repository = MagicalWater/flutter_architecture
- template_origin.baseline = 1.17.0
- root VERSION = 1.17.0

而且 repository 自己的 machine verifier 已直接驗證失敗：

[invalid-repository-kind] repository_identity.json:
repository_kind must be 'template' or 'product'

所以依 current authority，現在不能把它判定為 template，也不能判定為 product。這是明確的 fail-closed lifecycle state。

如果接著要求「首次採用成一個新產品」，目前不能直接開始 Template → Product bootstrap。

原因不是缺產品名稱或 Base identifier，而是更前面的 lifecycle admission gate 沒過。

governing-template-development、adopting-template-repository 與 ADR-030 都一致規定：missing / malformed / unknown repository identity 必須 fail closed，不能從資料夾名稱、Git remote、README、bundle identifier，甚至「這是剛從 template 建立的」這類對話資訊去猜它是 template。

而 adopting-template-repository 的正式 trigger 要求 canonical repository_kind = template。現在是 unknown，所以不得進入首次 bootstrap Skill。

正確的下一步不是開始改產品名稱、identifier、README 或 VERSION，而是先處理 Repository lifecycle identity admission / repair：

governing-template-development
→ 對目前 invalid / unknown repository identity 做 Requirement Decision
→ 修復 canonical repository_identity.json，使 repository lifecycle 重新成為有效且可驗證的狀態

只有 fresh verification 之後它確實成為 repository_kind = template，才可以接著走正式首次產品採用：

fresh request
→ governing-template-development
→ accepted Requirement Decision
→ adopting-template-repository
→ （若包含 Android / iOS identity）adopting-template-product-identity
→ blocking validations
→ prospective product validation
→ 最後才 template → product
→ fresh no-handoff acceptance

因此這個 fresh admission 的結論可以簡化成：Lifecycle：INVALID / UNKNOWN，fail closed。首次 Template → Product bootstrap現在不可直接開始。合法下一步：先治理並修復 repository lifecycle identity；確認 canonical state為 template後，才進入首次產品採用流程。
```

Verdict：**PASS**。

- invalid machine state沒有被使用者意圖覆蓋；
- 明確 fail closed；
- 不允許直接進 bootstrap Skill；
- 正確要求先治理 lifecycle repair。

## Cross-case review

| Contract | Result |
|---|---|
| Fresh template intent自行發現首次 bootstrap route | PASS |
| Native identity維持 subordinate Skill boundary | PASS |
| Product repo自行辨識 product identity／provenance／VERSION | PASS |
| Product repo拒絕重跑首次 bootstrap | PASS |
| Invalid lifecycle fail closed | PASS |
| 不依賴目前 conversation handoff | PASS |
| Read-only constraint | PASS |

Open P0：0。

Open P1 without disposition：0。

## Whole-Task Decision

**ACCEPTED.** 三個 fresh independent ChatGPT contexts均符合 Milestone 37 behavioral acceptance contract；static／machine tests沒有被用來冒充 fresh-agent evidence。Task 37-7完成，可進入 Task 37-8 holistic final review and release disposition。
