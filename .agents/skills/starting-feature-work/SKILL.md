---
name: starting-feature-work
description: 當此 repository 要開始新的產品功能、畫面、使用者流程或 Figma-driven implementation 時使用。
---

# 開始功能開發

## 核心規則

這是一個薄型的使用者入口。它不擁有工作分類、核准、branch、Task、validation 或 release policy。

**必要子 Skill：**在進行 feature analysis、Design、Plan 或 implementation 前，必須先使用 `governing-template-development`。

## 輸入 contract

接受簡短需求描述，其中可以包含下列任意組合：

- feature 或 screen 目標；
- Figma 或其他 design source；
- 要加入的 behaviors 或 integrations；
- constraints、exclusions 或已知 dependencies。

不得要求使用者重新貼一次治理模板。

## 必要行為

1. 把使用者原始 wording 與 intent 保留為 request input。
2. 先呼叫 `governing-template-development` 並產生其 Requirement Decision。
3. 只依該 Decision 的 routing，檢查目前 feature、Presentation responsibility、Design System、navigation、domain、data、API、state、accessibility、localization、offline、testing 與 documentation boundaries。
4. Presentation planning必須先讀ADR-032：Page/View/Section/Component/Surface/Layout是responsibility roles，不是固定class/folder tree；local UI mechanics不因存在state就自動升Cubit/Bloc，只有獨立change reason／lifecycle／authority成立才extract或escalate。
5. 使用者只要求討論或探索時，不得開始 Design 或 implementation。
6. 完整遵守中央治理 Skill 的 approval、worktree／branch、Task、validation、release 與 stop rules，不得在此重複建立第二套規則。

## 給使用者的呼叫方式

```txt
使用 repository-local starting-feature-work Skill。

[功能或畫面需求]
Figma：[網址，如有]
```
