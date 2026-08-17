---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-40-readme-title-artwork-corrective
last_reviewed_baseline: 1.20.0
---

# Milestone 40-7T — README Title Artwork Corrective Requirement Decision

## Requirement Decision

- Request（需求）：為 root `README.md` 的 `Flutter Enterprise Architecture Template` 補上一張可直接辨識的藝術字標題視覺，後續圖片生成改用 `chatgpt-web-generation`；不再使用已移除的 `chatgpt-web-image`。
- Problem（問題）：先前 40-7 / 40-7R 把「缺少標題第一視覺」過度設計成第三張 architecture-metaphor Hero，造成 C01／C02 用途不清、與兩張正式架構圖責任重疊，並觸發 accepted Plan 的 return-to-Design stop condition。
- Current behavior（目前行為）：README 只有 Markdown H1 + prose，兩張正式 architecture visuals 已正確 inline；目前沒有 live Hero。40-7R C01／C02 均為 rejected historical evidence。
- Expected behavior（預期行為）：保留 Markdown H1 與兩張正式 architecture visuals；新增一張以 **`Flutter Enterprise Architecture Template`** 文字本身為主體的 typographic title artwork。它只負責第一視覺／產品標題，不承擔 architecture explanation。
- Value（價值）：補足 GitHub 第一視覺，同時避免第三張架構圖、generic dark-tech illustration 與不必要的架構隱喻。
- Classification（分類）：**Level 1 — Small Fix**。
- Decision（決策）：**Accept with reduced scope**。
- Scope（範圍）：title artwork generation、visual review、README title artwork consumer、必要 current-state / audit routing同步。
- Non-goals（非目標）：不重新設計 architecture visuals；不建立 logo / brand system；不修改 architecture、production code、bootstrap contract、version、ADR 或 docs ownership。
- Behavioral requirements required（是否需要行為需求）：否；presentation-only。
- Design Spec required（是否需要 Design Spec）：否。需求已收斂為單一 typographic artwork，Level 1 simplified Task cycle 足夠。
- Implementation Plan required（是否需要 Implementation Plan）：否。
- ADR required（是否需要 ADR）：否。
- Task governance mode（Task 治理模式）：Level 1 simplified Task cycle + visual acceptance gate。
- Worktree／branch：沿用 current managed worktree / current Milestone 40 branch。
- Regression level（Regression 等級）：focused documentation + visual validation；不得執行無關 full regression。
- Release required（是否需要發布）：否；Template Baseline 維持 `1.20.0`。
- Post-release validation（發布後驗證）：不適用。
- Required Superpowers skills（必要 Superpowers Skills）：無 formal Design / Plan routing；review 使用 repository verification method。
- Required artifacts（必要 artifacts）：本 Requirement Decision、governance integrity review、title candidate visual review、README consumer review。

## Why Level 1 is sufficient

這次不再把「一張標題藝術字」包裝成新的 feature capability。它不改 stable contract、不新增 architecture responsibility，也不改 documentation ownership；真正變更只有 public README 的一張 bounded presentation asset 與 consumer。

先前 40-7R 的 Level 2 Design／Plan保留為歷史失敗證據，但不再約束 40-7T 的 artwork representation。這不是 implementation 期間靜默降級；本文件是新的 Requirement Decision，明確依 current evidence 重新分類。

## Title artwork acceptance contract

1. Artwork 的主體必須是完整且可讀的：`Flutter Enterprise Architecture Template`。
2. 不得缺字、錯字、重字、偽字或把標題拆成無法理解的裝飾 glyph。
3. 不得生成第三張 architecture diagram、server rack、phone mockup、motherboard 或 random modules illustration。
4. 可以有少量幾何／藍青色／深 graphite 裝飾，但只能服務文字，不得搶走 title hierarchy。
5. Markdown H1 必須保留，artwork 不成為 accessibility / SEO 唯一文字來源。
6. 兩張 accepted architecture visuals 必須保持原有 authority 與 inline consumer。
7. 約 3:1～4:1 橫幅；360px 寬時標題仍可辨識。
8. GitHub light / dark surrounding background 下都必須有完整邊界，不靠 page background 才成立。
9. 使用者視覺核准前不得 promotion 到 README live consumer。
10. 生成 route 必須使用 fresh discovered `chatgpt-web-generation`；已移除的 `chatgpt-web-image` 不得再作 current execution authority。

