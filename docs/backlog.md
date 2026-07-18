# Backlog

這裡記錄未來可以加入，但第一階段 MVP 不實作的內容。

目的：

- 好想法不要忘記。
- 目前範圍不要失控。
- 先把核心模板完成。

## 第二階段可以考慮

- ADR：Architecture Decision Record。
- Unit Test / Bloc Test / Repository Test 完整範例。
- API Error Mapping 進階版。
- WebSocket。
- Notification feature。
- Payment feature。
- Firebase Crashlytics。
- Analytics。
- Native Flavor：Android productFlavors、iOS Schemes、applicationId、bundle identifier 與原生 App 名稱切換。
- Localizations。（已由 Milestone 16 Localization Foundation 完成）
- 完整 Feature 新增指南。
- 常見錯誤文件。
- 架構演進文件。

## 已排入正式 Roadmap

- Milestone 10：App Configuration 與 Environment 基礎。
- Milestone 11：CI/CD（Deferred，目前不實作）。
- Milestone 12：Refresh Token + Concurrent 401 Handling。
- Milestone 13：Pagination + Search Debounce。
- Milestone 14：Offline Cache。
- Milestone 15：Design System Foundation。

Milestone 10、12、13 與 15 已完成；Milestone 11 維持 Deferred，Milestone 14 已完成後封存其 roadmap 細節。

## 範圍規則

第一階段只處理：

```txt
Auth + Profile + Protected Route
```

如果新想法不直接服務這個流程，就先放在這份 Backlog。
