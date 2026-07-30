# 工作分類

依最高適用風險分類。模糊工作先往較高等級移動，直到 evidence 足以支持較低等級。

| Level | 典型範圍 | 必要項目 | 禁止事項 |
|---|---|---|---|
| 0 — Trivial | typo、comment、非語意 formatting、明顯的單行 metadata 修正 | current authority check、focused validation | formal Spec、Plan、ADR、Milestone；除非 release metadata 改變，否則禁止 full regression |
| 1 — Small Fix | 單一有界 bug、local test 修正、狹窄 refactor | 確認問題與 expected behavior、simplified Task cycle、affected tests | 沒有 evidence 卻建立 formal Milestone；無關 refactor |
| 2 — Standard Feature | 單一 feature capability 與有界 integration | brainstorming、behavioral requirements、Design、Plan、standard Task governance | 跳過 Spec／Plan 核准；沒有需求卻建立 generic framework |
| 3 — Cross-cutting | 多個 features／packages、shared contracts、DI 或 integration boundary | formal Design／Plan、ADR gate、full Task governance、affected workspace regression | 只做 local validation；靜默 architecture change |
| 4 — Architecture／Milestone | stable ownership、framework adoption、repository-wide governance | feasibility／scope decision、Design／Plan、full two-layer governance、holistic review、release decision | 核准前 implementation；建立平行 authority |
| 5 — Critical | database／credential migration、security、platform、production release pipeline | Level 4，加上 rollback、compatibility、failure injection、clean checkout、remote／platform evidence、release 與 post-release validation | 為降低成本而降級；沒有 runtime evidence 卻 closure |

## 升級訊號

當工作會改變 dependency direction、public contract、persistence authority、security boundary、supported platform claim、release process、repository-wide governance 或 irreversible data state 時，提升等級。

## 防止過度治理

- Level 0 不得只為修正 wording 而建立 Milestone。
- Level 1 使用 inline decision 與 simplified Task cycle；除非 behavior 或 architecture 不確定。
- Test count 或 file count 本身不足以支持 Level 3 以上。
- Tool 或 Skill installation 只有在改變 repository workflow 或 authority 時才是 Level 4；local optional helper 可以是 Level 1～2。

## 分類 evidence

Routing 前，記錄支持該等級的訊號，以及曾考慮的更高等級訊號。兩個等級都可能成立時，先選較高者，直到 repository evidence 證明較低等級安全。Classification 只能透過新的 Requirement Decision 修訂；implementation 期間不得靜默降級。
