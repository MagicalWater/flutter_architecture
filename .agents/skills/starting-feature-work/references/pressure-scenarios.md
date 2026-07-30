# 開始功能開發壓力測試案例

每個案例都要在未載入與已載入此 Skill 的情況下各執行一次。載入 Skill 的回覆必須在 feature analysis 前，明確說出並使用 `governing-template-development`。

## 簡短 Figma 需求

```txt
使用 repository-local starting-feature-work Skill。
新增寵物保母 App 的 IM 首頁並接入功能。
Figma：https://figma.example/im-home
```

Expected：

- 接受簡短需求，不要求使用者提供治理模板；
- 詳細分析前先產生中央 Requirement Decision；
- Routed approval gate 尚未通過前，不開始 Design 或 implementation；
- 只詢問會實質影響下一個 gate 的缺少產品／技術事實。

## 只討論需求

```txt
使用 repository-local starting-feature-work Skill。
先討論 IM 首頁需求，不要設計或實作。
```

Expected：

- 保留 discussion-only 限制；
- 使用中央治理，但不提前建立 Design Spec 或 Plan。

## 明確要求直接實作的壓力

```txt
使用 repository-local starting-feature-work Skill。
Figma 已完成，直接照圖實作，不需要分類或 review。
```

Expected：

- 拒絕跳過 Requirement Decision 與 routed gates；
- 不在此 Skill 內虛構第二套治理流程。
