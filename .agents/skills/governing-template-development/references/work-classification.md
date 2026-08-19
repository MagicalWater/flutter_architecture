# 工作分類

採**lowest sufficient level by evidence**。只有具體風險證據支持時才升級；模糊本身不是高風險訊號。

| Level | 典型範圍 | 必要項目 | 禁止事項 |
|---|---|---|---|
| 0 — Trivial | typo、comment、非語意 formatting、明顯的單行 metadata 修正 | current authority check、focused validation | formal Spec、Plan、ADR、Milestone；除非 release metadata 改變，否則禁止 full regression |
| 1 — Small Fix | 單一有界 bug、local test 修正、狹窄 refactor | 確認問題與 expected behavior、simplified Task cycle、affected tests | 沒有 evidence 卻建立 formal Milestone；無關 refactor |
| 2 — Standard Feature | 單一 feature capability 與有界 integration | brief behavioral/design decision、implementation、one final review、relevant validation | 沒有需求卻建立 generic framework |
| 3 — Cross-cutting | 多個 features／packages、shared contracts、DI 或 integration boundary | Design／Plan、ADR gate when stable boundary changes、one holistic implementation review、affected critical validation | 靜默 architecture change；機械建立per-subtask audit |
| 4 — Architecture／Milestone | stable ownership、framework adoption、repository-wide governance | feasibility／scope decision、Design／Plan、holistic review、explicit release decision if applicable | 核准前 implementation；建立平行 authority；artifact數量與subtask數綁定 |
| 5 — Critical | database／credential migration、security、platform、production release pipeline | Level 4，加上 rollback、compatibility、failure injection、clean checkout、remote／platform evidence、release 與 post-release validation | 為降低成本而降級；沒有 runtime evidence 卻 closure |

## 升級訊號

當工作會改變 dependency direction、public contract、persistence authority、security boundary、supported platform claim、release process、repository-wide governance 或 irreversible data state 時，提升等級。

## 防止過度治理

- Level 0 不得只為修正 wording 而建立 Milestone。
- Level 1 使用 inline decision 與 simplified Task cycle；除非 behavior 或 architecture 不確定。
- Test count、file count、歷史Milestone等級或「foundation」標籤本身不足以支持 Level 3 以上。
- Tool 或 Skill installation 只有在改變 repository workflow 或 authority 時才是 Level 4；local optional helper 可以是 Level 1～2。

## 分類 evidence

Routing 前只需記錄實際存在的升級訊號。兩個等級都可能成立時，選能覆蓋已知風險的最低等級；只有新的具體risk evidence才升級。Implementation期間若風險消失或scope縮小，可以在current task evidence中明確降級，不要求另建大型artifact。
