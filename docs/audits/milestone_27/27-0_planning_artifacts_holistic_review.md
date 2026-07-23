---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-27-planning-artifacts-holistic-review
last_reviewed_baseline: 1.8.0
---

# Milestone 27 — Planning Artifacts Holistic Review

## Review scope

本Review在Milestone 27 activation落檔後，以獨立reviewer視角重新檢查：

- Capability audit。
- Architecture design。
- ADR-026。
- Implementation plan。
- `27-0_planning_review.md`。
- Roadmap、Project Context、ADR／Audit／Plan／Milestone navigation。
- 與ADR-020、023、024、025的authority boundary。

本Review只處理planning artifacts，不開始Task 27-1 source implementation，也不加入Firebase dependency。

## Required execution contract

Milestone 27每個編號Task固定視為一個小階段：

```txt
逐Step／Subtask執行
→ 每步立即review、fix、re-review
→ 全部內容完成
→ 整個小階段implementation review
→ findings fix與holistic re-review
→ Open P0／P1 = 0
→ validation
→ 小階段單一commit
→ 統一回報
```

不得逐Step提交、不得以focused tests取代整體implementation review，也不需在小階段中途等待使用者確認。

## Initial findings

| Finding | Severity | Evidence | Required fix |
|---|---|---|---|
| M27-PA01 Plan只有簡化的Task review流程，未明確保存使用者固定的小階段閉環 | P1 | Plan原流程為`implementation → focused tests → Task review → fix → re-review → commit` | 明定Task／Step層級、整體implementation review、單一commit與統一回報規則 |
| M27-PA02 Collection policy對production default仍可解讀為由provider SDK預設決定 | P1 | ADR寫「由adopter privacy policy決定」，Design matrix未明確template default | 所有environment template預設remote off，只允許明確policy啟用 |
| M27-PA03 Release version／build來源尚未選定，Task 27-1可能建立runtime與build-time雙重authority | P1 | Design允許package metadata或build-time define二選一 | 固定native package metadata為runtime authority；commit SHA獨立使用build-time define |
| M27-PA04 Planning review未導向activation後的整體re-review | P2 | 只有原始`27-0_planning_review.md` | 建立本artifact並加入Audit與Active routing |

## Fixes

- `M27-PA01`：Implementation plan新增強制Execution Protocol，明確定義每個編號Task是一個小階段，內部逐步review，整體implementation review後單一commit。
- `M27-PA02`：ADR-026、Design與Plan統一所有environment remote collection預設關閉；staging acceptance與production collection皆需明確policy。
- `M27-PA03`：Task 27-1固定安裝產物native package metadata為version／build runtime authority；commit SHA只接受受控build-time define且可缺省。
- `M27-PA04`：更新Planning Review、Audit index與Active Roadmap routing。

## Re-review

### Architecture and authority

- ADR-020仍唯一擁有Exception／Failure分類、unknown propagation與基本sensitive-data contract。
- ADR-026只擁有production provider、release identity、collection／privacy adoption、symbol與CI integration。
- ADR-026沒有supersede ADR-020、023、024或025，也沒有讓provider dependency進入Feature／Package。
- Crashlytics維持reference adapter；替換provider只影響App／native／CI integration seam。

### Scope and sequencing

- Task 27-1與27-2明確provider-neutral，不得提前加入Firebase。
- Firebase Core／Crashlytics只能在Task 27-3導入。
- Android mapping／Flutter symbols與iOS dSYM分別由Task 27-4／27-5擁有，沒有混成單一artifact。
- CI secret與remote acceptance集中於Task 27-6；無secret時不得偽裝verified。
- Connectivity、Analytics、APM、Store distribution仍為deferred／non-goal。

### Privacy and runtime safety

- 所有environment remote collection預設關閉。
- Provider config存在不代表允許collection。
- Production必須由adopter明確policy啟用。
- Anonymous-by-default、PII deny-by-default與provider failure isolation維持一致。

### Execution governance

- 每個小階段包含逐步focused review與最後whole-phase implementation review。
- Findings必須修正並re-review至Open P0／P1 = 0。
- 每個小階段只有一個commit，中途不逐Step提交或等待確認。
- Task 27-7仍負責Milestone holistic final review與closure，不被各小階段review取代。

## Final disposition

```txt
Disposition: ACCEPTED AFTER FIX
Open P0: 0
Open P1: 0
Open P2: 0
Next action: Task 27-1 — Release Identity and Provider-neutral Contracts
```

Milestone 27 planning artifacts在補正後可執行。Task 27-1開始後必須完全遵守本Review與Implementation Plan中的固定小階段閉環。
