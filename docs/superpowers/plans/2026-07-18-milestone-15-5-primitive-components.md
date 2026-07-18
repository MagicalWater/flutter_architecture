# Milestone 15-5 Primitive Components Implementation Plan

Status: Completed

**Goal:** 建立已有明確 consumer 的 Design System primitives，統一 status notice、content width/padding 與 button loading presentation。

**Architecture:** Primitive API 只接受純 presentation properties，不依賴 Bloc、Failure、Catalog state 或 Feature entity。保留 Material Button variants，不建立 generic button；Loading / Empty / Error page state 留在 Milestone 15-6。

### Task 1: Failing widget contracts

- [x] 建立 `DsStatusBanner` tone、Semantics、action、長文字與窄畫面 tests。
- [x] 建立 `DsConstrainedContent` max width、padding 與窄畫面 tests。
- [x] 建立 `DsButtonContent` idle / loading、Semantics 與 Material Button disabled usage tests。
- [x] 驗證 Default / Ocean × Light / Dark 都可 render。

### Task 2: Primitive implementation

- [x] 新增 `DsStatusBanner` 與有限 tone enum。
- [x] 新增 `DsConstrainedContent`。
- [x] 新增 `DsButtonContent`。
- [x] Public entrypoint 只 export stable primitive APIs。

### Task 3: Verification and docs

- [x] 同步 package README、Roadmap、Project Context、Decision 018 與 Changelog。
- [x] 執行 package widget tests、workspace analyze、完整 tests、development bundle 與 `git diff --check`。

