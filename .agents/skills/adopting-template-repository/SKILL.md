---
name: adopting-template-repository
description: 當由此 Flutter GitHub Template Repository 建立的新 repository 要首次轉成具體產品 repository，並需保存 template provenance、產品版本語意與後續 fresh Agent admission 時使用。
---

# 採用模板 Repository 為產品

## 核心定位

這是一個薄型、一次性的 Template → Product repository bootstrap orchestration Skill。它不擁有 Requirement Decision、Level、Design／Plan approval、native environment mapping、產品 roadmap、Feature 規劃、signing、Store、release 或 closure。

任何分析、Design、Plan 或 mutation 前，必須先使用 `governing-template-development`。Repository policy、accepted Design／Plan／ADR、source、tests與machine authority高於此 Skill。

## Trigger

只有同時滿足以下條件才使用：

1. root `repository_identity.json` 可讀且 `repository_kind = template`；
2. 使用者意圖是把剛由此 GitHub Template Repository 建立的獨立 repository首次採用為具體產品；
3. 中央 `governing-template-development` 已完成 Requirement Decision 並接受本次 bootstrap scope。

以下不得自動觸發：API-only、visual-only、單一平台 identifier repair、discussion-only、既有 `product` repository 的一般改名／版本／功能工作。

Missing、malformed 或 unknown repository identity 必須 fail closed，不得從 remote URL、資料夾名稱、README prose、native bundle identifier 或聊天記憶猜測 lifecycle。

## Responsibility boundary

本 Skill 只編排：

- 讀取 `repository_identity.json` 與 root `VERSION`；
- 收集／確認產品名稱與 repository bootstrap 所需最小 identity input；
- 保存 template origin repository 與 template baseline；
- 將產品 current `VERSION` 與 template provenance 分離；
- 將 README／project context／roadmap／CHANGELOG 等 current authority 從模板本體投影為產品 repository；
- 需要 Android／iOS product identity 時，委派既有 `adopting-template-product-identity`；
- 維持 blocking validation 完成前 canonical `repository_kind` 仍為 `template`；
- prospective candidate-product validation PASS 後，最後一步才把 canonical manifest 切為 `product`，並立即 fresh re-verify。

本 Skill不得建立第二份 Android／iOS identity mapping，也不得把 `repository_identity.json` 擴張成 API domain、bundle identifier、environment mapping 或產品 Feature authority。

## 必讀 authority

中央分類完成後至少讀取：

```txt
AGENTS.md
repository_identity.json
VERSION
docs/project_context.md
docs/roadmap.md
docs/guides/template_repository_adoption.md（存在後）
tools/docs/verify_repository_identity.py
.agents/skills/adopting-template-product-identity/SKILL.md（native identity in scope 時）
```

Human Guide 尚未建立時，不得自行發明平行 procedure；依 accepted Milestone Design／Plan 執行。

## Atomic completion boundary

首次 bootstrap 必須遵守：

```txt
read template identity + VERSION
→ collect and confirm product inputs
→ repository docs/version/native mutations while canonical kind stays template
→ required docs/native/component validation
→ prospective candidate-product identity validation
→ final canonical repository_identity transition to product
→ canonical identity/docs re-validation
→ fresh no-handoff admission acceptance
```

不得先把 `repository_kind` 改成 `product` 再補驗證。若中途失敗，persistent lifecycle state必須仍可被判定為尚未完成首次採用，而不是半完成 product。

## Product-state guard

如果 fresh admission 讀到 `repository_kind = product`：

- 不得再次執行首次 bootstrap；
- 從 manifest 取得 product name 與 template provenance；
- current product version只讀 root `VERSION`；
- 將新需求交回 `governing-template-development` 正常分類。

## Non-goals

不處理 MVP、產品 roadmap、Feature 拆分、UI／UX、backend architecture、template upstream auto-merge、production signing 或 Store distribution。

壓力測試協議：[references/pressure-scenarios.md](references/pressure-scenarios.md)。
