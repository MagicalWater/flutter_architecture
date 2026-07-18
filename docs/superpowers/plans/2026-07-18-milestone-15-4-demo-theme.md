# Milestone 15-4 第二套示範 Theme Implementation Plan

Status: Completed

**Goal:** 建立第二套 production 示範 Theme 的 Light / Dark variants，並驗證兩套 Theme Identity 可形成四種有效 ThemeData 組合。

**Architecture:** 第二套 Theme 使用獨立穩定 ID、palette 與 semantic colors。只抽取 Default／示範 Theme 已確認重複的 package-internal Material Theme factory；不建立 generic skin engine、remote theme 或 runtime token framework。

### Task 1: Failing contracts

- [x] 建立示範 Theme ID、metadata、Light / Dark 與差異化 contract tests。
- [x] 驗證 Default／示範 Theme 經 Registry 可形成四種 ThemeData 組合。
- [x] 驗證示範 Theme 不只替換 seed color，至少包含 Typography 或 component radius 差異。

### Task 2: Shared internal factory

- [x] 從兩套 Theme 的實際重複內容抽取 package-internal Material Theme factory。
- [x] Factory 只接受已被兩套 Theme 使用的明確參數。
- [x] Default Theme 重構後維持既有 contract tests 全數通過。

### Task 3: Demo Theme

- [x] 建立 `OceanThemeDefinition` Light / Dark variants。
- [x] 建立獨立 raw seed 與 semantic colors。
- [x] 提供有限度 Typography／radius 差異。

### Task 4: Verification and docs

- [x] 同步 package README、Roadmap、Project Context、Decision 018 與 Changelog。
- [x] 執行 Design System tests、workspace analyze、完整 tests、bundle build 與 `git diff --check`。

