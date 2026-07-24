---
document_type: planning-review
status: accepted
authoritative_for:
  - starting-feature-work-adoption-evidence
last_reviewed_baseline: 1.13.0
---

# Starting Feature Work Adoption Review

## Admission review

- Confirmed problem：中央治理可正常自動發現，但指定不存在的快捷 Skill 時，agent 會要求使用者提供路徑，短入口不存在。
- Expected value：使用者只輸入 feature／screen、Figma 與特殊限制，其餘固定流程由 Skill 接管。
- Trigger：新功能、新畫面、user flow、Figma-driven implementation。
- Mutations：新增 repository-local Skill、pressure scenarios、Spec、Plan與人類治理說明。
- Overlap：與中央治理及 Superpowers 有高度流程相鄰性，因此採單向委派，禁止複製規則。
- Authority：不新增平行 authority；`AGENTS.md`與`governing-template-development`保持最高工作治理入口。
- External requirements：無 MCP、credential、network或額外 permission。
- Version／source：repository-owned，隨 Git commit pinning。
- Rollback：刪除快捷 Skill、registry row與shortcut說明；中央治理不受影響。
- Disposition：Approved。

## RED

在 Skill 尚不存在時，以短 Figma brief 執行 Codex。Observed：agent 正確回退中央治理，但明確表示找不到`starting-feature-work`並要求提供路徑，因此快捷入口目標失敗。

## Required GREEN

- Codex 自動發現並讀取`starting-feature-work`。
- 快捷 Skill 明確委派`governing-template-development`。
- Requirement Decision 先於詳細 feature analysis。
- 不要求使用者再貼治理模板或同時指定兩個 Skills。
- 不在 approval gate 前開始 Design、Plan或implementation。

## GREEN result

以相同 short Figma brief 重新執行 Codex。Observed：

- 主動讀取並使用`starting-feature-work`；
- 只由快捷入口委派`governing-template-development`，沒有要求使用者同時指定兩個Skills；
- 明確將Requirement Decision置於feature analysis之前；
- 在Figma、integration scope與success criteria不足時停止於下一個資訊gate，未開始Design或implementation。

Disposition：Passed。

## REFACTOR pressure result

Discussion-only與「直接照圖實作、跳過分類／review／approval」兩個壓力案例均通過：

- discussion-only保留探索限制，不提前建立Design／Plan；
- implementation pressure仍要求中央Requirement Decision、Design approval與Plan approval；
- 未發現需要擴張快捷Skill責任的漏洞。

Disposition：Passed without additional Skill rules。
