# Milestone 15-6 Page State Surfaces Implementation Plan

Status: Completed

**Goal:** 建立 Loading、Empty、Blocking Error 與 Generic Message page state surfaces，提供一致 layout、Semantics、actions 與 text scaling contract。

**Architecture:** 對外提供明確的 state surface widgets；內部只共用 private layout。API 僅接收純 presentation properties，不接收 Bloc state、Failure、Catalog snapshot 或 domain entity。Non-blocking error 仍使用 Status Banner 或 feature-local composite。

### Task 1: Failing contracts

- [x] 建立四種 page state surface widget tests。
- [x] 驗證 Default / Ocean × Light / Dark render。
- [x] 驗證 Loading、Error、Retry Semantics 與 action callback。
- [x] 驗證 320px viewport、text scale 1.0 / 1.3 / 2.0 不裁切主要內容。

### Task 2: Production surfaces

- [x] 建立 typed page state action。
- [x] 建立 Loading、Empty、Blocking Error、Generic Message public widgets。
- [x] 只在 package internal 共用 layout，不建立巨型 public state enum widget。

### Task 3: Scope boundaries

- [x] Blocking error 不承擔 refresh / append / revalidation failure。
- [x] 不在本階段修改 Feature Bloc 或導入現有頁面。
- [x] 不建立 persistence、selector 或 App Theme controller。

### Task 4: Verification and docs

- [x] 同步 package README、Roadmap、Project Context、Decision 018 與 Changelog。
- [x] 執行 Design System tests、workspace analyze、完整 tests、bundle build 與 `git diff --check`。

