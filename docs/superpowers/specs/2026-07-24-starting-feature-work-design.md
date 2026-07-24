---
document_type: design-spec
status: accepted
authoritative_for:
  - starting-feature-work-skill-design
last_reviewed_baseline: 1.13.0
---

# Starting Feature Work Skill Design

## Requirement Decision

- Request：提供新功能、新畫面與 Figma 實作的短指令入口。
- Problem：目前中央治理可自動接管工作，但使用者若明確指定尚不存在的快捷 Skill，agent 會要求補充 Skill 路徑，無法形成穩定的簡短入口。
- Classification：Level 2 — Standard Feature。
- Evidence：新增可選入口，不改變 repository authority、Level、approval、Task、branch 或 release 規則，因此不升級為 Level 4。
- Decision：Accept。
- Scope：新增 `starting-feature-work` 薄入口、壓力案例與人類文件說明。
- Non-goals：不複製中央治理矩陣；不建立 Bug、Migration、Release 等其他快捷 Skills；不加入 Figma 專屬工具實作。
- Design Spec required：Yes。
- Implementation Plan required：Yes。
- ADR required：No，未改變穩定架構 ownership。
- Task governance mode：Standard。
- Worktree／branch：Optional；本次為文件與 Skill-only bounded change。
- Regression level：Skill behavior、docs checker、docs_check。
- Release required：No；保留於目前 1.13.0 baseline，後續正式版本一併發布。

## Design

`starting-feature-work` 是使用者快捷入口；`governing-template-development` 仍是唯一工作治理引擎。

```txt
short feature brief
→ starting-feature-work
→ governing-template-development
→ Requirement Decision
→ routed Superpowers／Task governance
```

快捷 Skill 只擁有：短 brief 輸入契約、feature／screen／Figma trigger、保留 discussion-only 限制，以及委派中央治理的義務。

快捷 Skill 禁止擁有：Level 判定、artifact matrix、approval、branch／worktree、Task cycle、validation、release 或 closure 規則。

## Acceptance

使用者已明確要求在完整流程審查確認無問題後新增 Skill；本設計經 overlap、authority、placement、permission、rollback 與 pressure-scenario 審查後接受。
