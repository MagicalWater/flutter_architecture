# Milestone 15-2 Design System Foundation Implementation Plan

Status: Completed

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立 `packages/design_system`、基礎 design tokens，以及可驗證 default／duplicate／fallback 與 Light／Dark factory contract 的 Theme Registry。

**Architecture:** Design System 是不依賴 App、Feature、DI 或 persistence 的純 Flutter package。Milestone 15-2 只建立 tokens 與 Theme contract，production Default Theme 與第二套 Theme 分別留在 15-3、15-4。

**Tech Stack:** Flutter Material、Dart Pub Workspace、flutter_test。

---

### Task 1: Workspace package 與 failing contract tests

**Files:**
- Modify: `pubspec.yaml`
- Create: `packages/design_system/pubspec.yaml`
- Create: `packages/design_system/test/tokens_test.dart`
- Create: `packages/design_system/test/theme_registry_test.dart`

- [x] 建立 package 與 workspace registration。
- [x] 先寫 tokens 與 registry failing tests。
- [x] 執行 `dart pub get`。
- [x] 執行 `flutter test packages/design_system/test`，確認因 production API 尚不存在而失敗。

### Task 2: Primitive tokens

**Files:**
- Create: `packages/design_system/lib/design_system.dart`
- Create: `packages/design_system/lib/src/tokens/ds_space.dart`
- Create: `packages/design_system/lib/src/tokens/ds_radius.dart`
- Create: `packages/design_system/lib/src/tokens/ds_elevation.dart`
- Create: `packages/design_system/lib/src/tokens/ds_icon_size.dart`

- [x] 以最小 public constants 實作 spacing、radius、elevation 與 icon sizes。
- [x] 只由 package entrypoint export public token files。
- [x] 執行 `flutter test packages/design_system/test/tokens_test.dart`，確認通過。

### Task 3: Theme identity contract 與 registry

**Files:**
- Create: `packages/design_system/lib/src/theme/ds_theme_id.dart`
- Create: `packages/design_system/lib/src/theme/ds_theme_metadata.dart`
- Create: `packages/design_system/lib/src/theme/ds_theme_definition.dart`
- Create: `packages/design_system/lib/src/theme/ds_theme_registry.dart`
- Modify: `packages/design_system/lib/design_system.dart`

- [x] 建立穩定 value-based Theme ID。
- [x] 建立 presentation metadata 與 Light／Dark ThemeData factory interface。
- [x] Registry 拒絕空 definitions、重複 ID、缺少 default theme。
- [x] 未知 ID fallback 至 default theme。
- [x] available metadata 保留 registration order 並不可修改。
- [x] 執行 `flutter test packages/design_system/test/theme_registry_test.dart`，確認通過。

### Task 4: Package boundary 與文件收尾

**Files:**
- Create: `packages/design_system/README.md`
- Modify: `docs/roadmap.md`
- Modify: `docs/project_context.md`
- Modify: `CHANGELOG.md`

- [x] 文件說明 public API、raw palette internal policy 與 15-3 邊界。
- [x] 將 Milestone 15-2 標記完成並更新下一階段。
- [x] 執行 package tests、workspace analyze、全部 tests 與 `git diff --check`。
