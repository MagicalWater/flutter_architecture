---
document_type: phase-review
status: accepted
authoritative_for:
  - documentation-usability-hardening-task-1-review
last_reviewed_baseline: 1.8.0
---

# Documentation Usability Hardening Task 1 Review

## Review Scope

本 review 審查 `docs/guides/how-to-add-feature.md` 是否已由早期 placeholder 收斂為可操作的 Feature addition route，並確認它沒有取得 canonical ADR、App README、Feature README 或 Package README 的 architecture authority。

## Review Method

1. 比對 accepted design 與 implementation plan 的 Task 1 scope。
2. 檢查 managed metadata、Guide responsibility與non-authority statement。
3. 逐段核對 Feature responsibility、Domain／Data／Presentation、API／Persistence、DI、Route、Localization、Tests、README、ADR gate與verification route。
4. 檢查相對連結是否指向 current authority。
5. 檢查是否複製完整 ADR contract、使用 historical artifact作為current instruction，或引入 generic framework。

## Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| DUH-T1-R01 | P2 | 初稿在SQLite段落只描述App database ownership，但沒有明確要求同時覆蓋fresh-create與incremental upgrade，容易讓使用者只修改`onUpgrade`或只修改`onCreate` | 已補上fresh-create、incremental upgrade、affected DataSource與migration tests的完整route |
| DUH-T1-R02 | P2 | 初稿的Route段落若只列Router與Guard，仍可能遺漏authentication destination由App coordinator擁有的邊界 | 已加入`AuthNavigationCoordinator`入口及ADR-021 authority link |
| DUH-T1-R03 | P2 | Focused semantic assertion確認Guide只有coordinator檔案路徑，沒有直接點名`AuthNavigationCoordinator`責任，開發者仍需從source自行推導 | 已補上App-owned `AuthNavigationCoordinator`擁有authentication destination transition的短摘要，並維持ADR-021為正式authority |

## Fix Evidence

修正後Guide已明確包含：

- Purpose與non-authority statement。
- 固定最小文件集及task-based pre-reading route。
- Feature／Package responsibility decision gate。
- Domain／Data／Presentation sequence。
- Remote API與Persistence integration entry points。
- App-owned DI composition。
- Router、Guard與Coordinator boundary。
- `AuthNavigationCoordinator`的App-owned destination transition責任。
- App-owned Localization與feature presentation failure mapping。
- Domain／Data／Presentation／App integration tests。
- Production Feature README requirement。
- ADR decision gate。
- Generated source、repository verification與completion checklist。

## Re-review

重新比對current authority後確認：

- Guide只擁有`feature-addition-operational-procedure`。
- 沒有複製完整ADR正文，也沒有宣稱新的architecture rule。
- 所有durable rule均以短摘要與current authority link呈現。
- 沒有引用historical audit／plan作為current instruction。
- 沒有建立generic Feature、Repository、Persistence、Pagination或Cache framework。
- Feature Guide placeholder已完全移除。
- Task 1修改範圍只包含Guide與本review artifact。

## Final Gate

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Guide scope review: Passed
ADR duplication review: Passed
Authority link review: Passed
Integration coverage review: Passed
Task 1 re-review: Passed
```

Task 1可進入validation與commit。Task 2尚未在本review中執行或授權超出既有plan的變更。
