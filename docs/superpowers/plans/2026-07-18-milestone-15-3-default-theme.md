# Milestone 15-3 Default Theme Light / Dark Implementation Plan

Status: Completed

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立 production Default Theme 的 Light / Dark `ThemeData`、Typography、Material component themes 與 semantic color `ThemeExtension`。

**Architecture:** `DefaultThemeDefinition` 實作既有 `DsThemeDefinition`，raw palette 維持 package internal。Milestone 15-3 不建立第二套 Theme、不處理 App persistence 或 selector wiring。

**Tech Stack:** Flutter Material 3、Dart、flutter_test。

---

### Task 1: Default Theme contract tests

**Files:**
- Create: `packages/design_system/test/default_theme_test.dart`

- [x] 先寫 Default Theme ID / metadata、Light / Dark brightness 與 ColorScheme tests。
- [x] 鎖定 Typography hierarchy、Material component themes 與 semantic extension contract。
- [x] 驗證 ThemeExtension `copyWith` / `lerp`。
- [x] 執行 failing tests，確認 production API 尚不存在。

### Task 2: Semantic ThemeExtension

**Files:**
- Create: `packages/design_system/lib/src/theme/ds_semantic_colors.dart`
- Modify: `packages/design_system/lib/design_system.dart`

- [x] 建立 success、warning、info 的 foreground / container / on-container semantic colors。
- [x] 實作 `copyWith` 與 `lerp`。
- [x] 不把 raw palette 或所有 spacing 塞入 ThemeExtension。

### Task 3: Production Default Theme

**Files:**
- Create: `packages/design_system/lib/src/theme/default_theme_definition.dart`
- Modify: `packages/design_system/lib/design_system.dart`

- [x] 建立穩定 `default` Theme ID 與 metadata。
- [x] 建立 Light / Dark ColorScheme 與 Typography hierarchy。
- [x] 建立 AppBar、NavigationBar、Input、Button、Card、Divider、ProgressIndicator 與 SnackBar themes。
- [x] 掛載 semantic color extension。
- [x] 保持 Material 3，並讓 Light / Dark 皆通過 contract tests。

### Task 4: 文件與完整驗證

**Files:**
- Modify: `packages/design_system/README.md`
- Modify: `README.md`
- Modify: `docs/architecture_decisions.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/project_context.md`
- Modify: `CHANGELOG.md`

- [x] 將 Milestone 15-3 標記完成，下一階段指向 15-4。
- [x] 執行 package tests、workspace analyze、完整 tests、bundle build 與 `git diff --check`。

### Milestone 15-4 實作注意事項

- [x] 第二套示範 Theme 開始實作前，先比較 Default 與第二套 Theme 的實際重複區段。
- [x] 只抽取已被兩套 Theme 證明重複的 package-internal component theme factory 或 theme spec。
- [x] 不直接複製整份 `DefaultThemeDefinition`，也不建立 generic skin engine、remote theme 或 runtime token framework。

