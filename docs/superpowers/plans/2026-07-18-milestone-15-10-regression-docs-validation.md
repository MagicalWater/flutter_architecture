# Milestone 15-10：Regression、文件與完整驗證

Status: Completed

## 目標

- 完成 production UI hard-coded style audit。
- 清理沒有 production consumer 的 Design System token。
- 只加入一個穩定、低維護成本的 Design System gallery golden fixture。
- 回歸 Auth、Profile、Route Guard、Refresh Token、Catalog Pagination 與 Offline Cache。
- 同步主要文件並驗證 development、staging、production bundle。

## 邊界

- 不把 cursor threshold、timestamp formatting、viewport fixture size 等 feature／test-specific 數值提升為 global token。
- 不建立所有 Feature × Theme × State 的 golden matrix。
- 不改 Auth、Profile、Router、Catalog Bloc、Repository 或 Cache contract。
- App 保持唯一 Composition Root。

## 驗證

- dependency resolution。
- code generation consistency。
- workspace analyze。
- workspace full tests。
- stable gallery golden test。
- development / staging / production bundle builds。
- `git diff --check`。
